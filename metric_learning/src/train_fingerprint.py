import torch
import torch.nn as nn
import torchvision.transforms as T
from torch.utils.data import DataLoader
from torch.utils.tensorboard import SummaryWriter
from torch_optimizer import RAdam
import torch.optim.lr_scheduler as lr_scheduler

import argparse
import logging
import json
import time
import sys
import os
import yaml
from pprint import pformat
from typing import Dict, Any
import scipy.io

from src.trainer import train_one_epoch
from src.models import Resnet50, Resnet18, Resnet34
from src.losses import TripletMarginLoss, ProxyNCALoss, ProxyAnchorLoss, SoftTripleLoss
from src.samplers import PKSampler
from src.fingerprint_dataset import Dataset, get_subset_from_dataset
from src.utils import set_random_seed, get_current_time, log_embeddings_to_tensorboard

from ipdb import set_trace
import numpy as np

CURRENT_TIME: str = get_current_time()

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s  %(name)s  %(levelname)s: %(message)s',
    datefmt='%y-%b-%d %H:%M:%S',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(f"src/logs/{CURRENT_TIME}.txt", mode="w", encoding="utf-8")
    ]
)
logger = logging.getLogger(__name__)


# Define your custom transform function
class CustomTransform:
    def __call__(self, double_array):
        # Perform normalization operation on the tensor
        abs_max = max(abs(double_array.min()), double_array.max())
        norm_array = double_array.astype(np.float32)
        norm_array = np.transpose(norm_array, (1,2,0))
        norm_array = norm_array / abs_max
        # print(norm_array.shape)
        return norm_array


def mat_loader(mat_path):
    mat_data = scipy.io.loadmat(mat_path)
    if 'fingerprint_ant1' in mat_data.keys():
        array_data = mat_data['fingerprint_ant1']
    elif 'fingerprint_ant2' in mat_data.keys():
        array_data = mat_data['fingerprint_ant2']
    elif 'RGB_data' in mat_data.keys():
        array_data = mat_data['RGB_data']
    elif 'nn_data1' in mat_data.keys():
        array_data = mat_data['nn_data1']
    elif 'nn_data2' in mat_data.keys():
        array_data = mat_data['nn_data2']
    elif 'cur_data' in mat_data.keys():
        array_data = mat_data['cur_data']
    return array_data


def main(args: Dict[str, Any]):
    start = time.time()

    # Intialize config
    config_path: str = args["config"]
    with open(config_path, "r", encoding="utf-8") as f:
        config: Dict[str, Any] = yaml.safe_load(f)
    logger.info(f"Loaded config at: {config_path}")
    logger.info(f"{pformat(config)}")


    # Initialize device
    if args["use_gpu"] and torch.cuda.is_available():
        device: torch.device = torch.device("cuda:0")
    else:
        device = torch.device("cpu")


    # Intialize model
    model = nn.DataParallel(Resnet18(
        embedding_size=args["embedding_size"],
        pretrained=config["pretrained"]
    ))
    model = model.to(device)
    logger.info(f"Initialized model: {model}")


    # Initialize optimizer
    optimizer = RAdam(model.parameters(), lr=config["lr"])
    logger.info(f"Initialized optimizer: {optimizer}")

    # for (power, f12, f3) 3d input, we do not apply image transform, just normalizing to [-1,1].
    # As there is a AdaptiveAvgPool2d to make the output_size (1,1)
    # maybe we do not need to resize the input tensor
    transform_train = T.Compose([
        CustomTransform(),
        T.ToTensor()
    ])
    
    logger.info(f"Initialized training transforms: {transform_train}")


    # Initialize training set
    train_set = Dataset(args["train_dir"], transform=transform_train, loader=mat_loader, extensions='.mat')

    if args["loss"] == "tripletloss":
        # Initialize train loader for triplet loss
        batch_size: int = config["classes_per_batch"] * config["samples_per_class"]
        train_loader = DataLoader(
            train_set,
            batch_size,
            sampler=PKSampler(
                train_set.targets,
                config["classes_per_batch"],
                config["samples_per_class"]
            ),
            shuffle=False,
            num_workers=args["n_workers"],
            pin_memory=True,
        )
        logger.info(f"Initialized train_loader: {train_loader.dataset}")

        # Intialize loss function
        loss_function = TripletMarginLoss(
            margin=config["margin"],
            sampling_type=config["sampling_type"]
        )
        logger.info(f"Initialized training loss: {loss_function}")

    elif args["loss"] == "proxy_nca":
        # Initialize train loader for proxy-nca loss
        batch_size: int = config["batch_size"]
        train_loader = DataLoader(
            train_set,
            config["batch_size"],
            shuffle=True,
            num_workers=args["n_workers"],
            pin_memory=True,
        )
        logger.info(f"Initialized train_loader: {train_loader.dataset}")

        loss_function = ProxyNCALoss(
            n_classes=len(train_set.classes),
            embedding_size=args["embedding_size"],
            embedding_scale=config["embedding_scale"],
            proxy_scale=config["proxy_scale"],
            smoothing_factor=config["smoothing_factor"],
            device=device
        )

    elif args["loss"] == "proxy_anchor":
        # Intialize train loader for proxy-anchor loss
        batch_size: int = config["batch_size"]
        train_loader = DataLoader(
            train_set,
            config["batch_size"],
            shuffle=True,
            num_workers=args["n_workers"],
            pin_memory=True,
        )
        logger.info(f"Initialized train_loader: {train_loader.dataset}")

        loss_function = ProxyAnchorLoss(
            n_classes=len(train_set.classes),
            embedding_size=args["embedding_size"],
            margin=config["margin"],
            alpha=config["alpha"],
            device=device
        )

    elif args["loss"] == "soft_triple":
        # Intialize train loader for proxy-anchor loss
        batch_size: int = config["batch_size"]
        train_loader = DataLoader(
            train_set,
            config["batch_size"],
            shuffle=True,
            num_workers=args["n_workers"],
            pin_memory=True,
        )
        logger.info(f"Initialized train_loader: {train_loader.dataset}")

        loss_function = SoftTripleLoss(
            n_classes=len(train_set.classes),
            embedding_size=args["embedding_size"],
            n_centers_per_class=config["n_centers_per_class"],
            lambda_=config["lambda"],
            gamma=config["gamma"],
            tau=config["tau"],
            margin=config["margin"],
            device=device
        )
    else:
        raise Exception("Only the following losses is supported: "
                        "['tripletloss', 'proxy_nca', 'proxy_anchor', 'soft_triple']. "
                        f"Got {args['loss']}")


    # Initialize test transforms
    transform_test = T.Compose([
        CustomTransform(), 
        T.ToTensor()
    ])
    logger.info(f"Initialized test transforms: {transform_test}")


    # Initialize test set and test loader
    test_dataset = Dataset(args["test_dir"], transform=transform_test, loader=mat_loader, extensions='.mat')
    test_loader = DataLoader(
        test_dataset, batch_size,
        shuffle=False,
        num_workers=args["n_workers"],
    )
    logger.info(f"Initialized test_loader: {test_loader.dataset}")


    # Initialize reference set and reference loader
    # If reference set is not given, use train set as reference set, but without random sampling
    if not args["reference_dir"]:
        reference_set = Dataset(args["train_dir"], transform=transform_test, loader=mat_loader, extensions=".mat")
    else:
        reference_set = Dataset(args["reference_dir"], transform=transform_test)
    # Sometimes reference set is too large to fit into memory,
    # therefore we only sample a subset of it.
    n_samples_per_reference_class: int = args["n_samples_per_reference_class"]
    if n_samples_per_reference_class > 0:
        reference_set = get_subset_from_dataset(reference_set, n_samples_per_reference_class)

    reference_loader = DataLoader(
        reference_set, batch_size,
        shuffle=False,
        num_workers=args["n_workers"],
    )
    logger.info(f"Initialized reference set: {reference_loader.dataset}")


    # Initialize checkpointing directory
    checkpoint_dir: str = os.path.join(args["checkpoint_root_dir"], CURRENT_TIME)
    writer = SummaryWriter(log_dir=checkpoint_dir)
    logger.info(f"Created checkpoint directory at: {checkpoint_dir}")


    # Dictionary contains all metrics
    output_dict: Dict[str, Any] = {
        "total_epoch": args["n_epochs"],
        "current_epoch": 0,
        "current_iter": 0,
        "metrics": {
            "mean_average_precision": 0.0,
            "average_precision_at_1": 0.0,
            "average_precision_at_5": 0.0,
            "average_precision_at_10": 0.0,
            "top_1_accuracy": 0.0,
            "top_5_accuracy": 0.0,
            "normalized_mutual_information": 0.0,
        }
    }
    # Start training and testing
    # Define a learning rate scheduler
    step_size = 10
    gamma = 0.1
    scheduler = lr_scheduler.StepLR(optimizer, step_size=step_size, gamma=gamma)
    
    logger.info("Start training...")
    for _ in range(1, args["n_epochs"] + 1):
        output_dict = train_one_epoch(
            model, optimizer, loss_function,
            train_loader, test_loader, reference_loader,
            writer, device, config,
            checkpoint_dir,
            args['log_frequency'],
            args['validate_frequency'],
            output_dict
        )
        scheduler.step()
    logger.info(f"DONE TRAINING {args['n_epochs']} epochs")


    # Visualize embeddings
    logger.info("Calculating train embeddings for visualization...")
    log_embeddings_to_tensorboard(train_loader, model, device, writer, tag="train")
    logger.info("Calculating reference embeddings for visualization...")
    log_embeddings_to_tensorboard(reference_loader, model, device, writer, tag="reference")
    logger.info("Calculating test embeddings for visualization...")
    log_embeddings_to_tensorboard(test_loader, model, device, writer, tag="test")


    # Save all hyper-parameters and corresponding metrics
    logger.info("Saving all hyper-parameters")
    writer.add_hparams(
        config,
        metric_dict={f"hyperparams/{key}": value for key, value in output_dict["metrics"].items()}
    )
    with open(os.path.join(checkpoint_dir, "output_dict.json"), "w") as f:
        json.dump(output_dict, f, indent=4)
    logger.info(f"Dumped output_dict.json at {checkpoint_dir}")


    end = time.time()
    logger.info(f"EVERYTHING IS DONE. Training time: {round(end - start, 2)} seconds")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="")

    parser.add_argument(
        "--train_dir", type=str, required=True, help="Directory to training images"
    )
    parser.add_argument(
        "--test_dir", type=str, required=True, help="Directory to test images"
    )
    parser.add_argument(
        "--reference_dir", type=str, default=None, help="Directory to reference images"
    )
    parser.add_argument(
        "--config", type=str, required=True, help="Path to yaml config file"
    )
    parser.add_argument(
        "--embedding_size", type=int, required=True, help="Size of final embedding"
    )
    parser.add_argument(
        "--loss", type=str, required=True, help="Which loss to use: ['tripletloss', 'proxy_nca', 'proxy_anchor']"
    )
    parser.add_argument(
        "--n_samples_per_reference_class",
        type=int,
        default=-1,
        help="Number of samples per class in reference set to use. Default: use all samples"
    )
    parser.add_argument(
        "--checkpoint_root_dir", type=str, default="src/checkpoints", help="Directory to save model weight"
    )
    parser.add_argument(
        "--n_epochs", type=int, default=100, help="Number of epochs to train"
    )
    parser.add_argument(
        "--n_workers", type=int, default=8, help="Number of threads used for data loading"
    )
    parser.add_argument(
        "--log_frequency", type=int, default=100, help="Number of iterations to print training logs"
    )
    parser.add_argument(
        "--validate_frequency", type=int, default=1000, help="Number of iterations to run test"
    )
    parser.add_argument(
        "--use_gpu", type=bool, default=True, help="Whether to use gpu for training"
    )
    parser.add_argument(
        "--random_seed", type=int, default=12345, help="Random seed"
    )

    args: Dict[str, Any] = vars(parser.parse_args())
    set_random_seed(args["random_seed"])

    main(args)
