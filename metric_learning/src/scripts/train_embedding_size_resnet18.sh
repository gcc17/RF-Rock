for embedding_size in 5 6 7
do

CUDA_VISIBLE_DEVICES=0 PYTHONPATH=./ python src/train_fingerprint.py --train_dir /NVMe/thin_nn_data_train578_test6/train --test_dir /NVMe/thin_nn_data_train578_test6/val --loss tripletloss --config src/configs/fingerprint_triplet_loss.yaml --checkpoint_root_dir src/eval_checkpoints/fingerprint_thin_train578_test6_triplet_resnet18_embedding${embedding_size} --n_epochs 100 --embedding_size $embedding_size

done
