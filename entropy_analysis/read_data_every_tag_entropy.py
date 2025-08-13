import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm

single_label_sample_num = 78
dim_num = 4
label_num = 100

fold_name_list = ['embeddings_length4_f12_2_lo_1_0.94/',
                'embeddings_length4_f12_4_lo_1_0.95/',
                'embeddings_length4_f12_8_lo_1_0.96/',
                'embeddings_length4_f12_8_lo_2_0.98/',
                'embeddings_length4_f12_8_lo_3_0.99/']
fold_name = fold_name_list[1]
all_data = np.load(fold_name+"all_data_4embedding.npy")
print(np.shape(all_data))


fit_result = np.zeros((label_num,dim_num,2))
for label_id in range(0,label_num):
    for dim_id in range(dim_num):
        start_idx = label_id * single_label_sample_num
        end_idx = start_idx + single_label_sample_num
        current_dim = all_data[start_idx:end_idx, dim_id]
        mu, std = norm.fit(current_dim)
        fit_result[label_id,dim_id,:] = np.array([mu,std])

plt.hist(fit_result[:,0,1],bins = 20) # sigma at dimension 0
plt.show()

np.set_printoptions(threshold=np.inf)
mean_norm = np.mean(fit_result,axis=0)
print(mean_norm)
median_norm = np.median(fit_result,axis=0)
data_points = np.squeeze(fit_result[:,:,0])

def estimate_entropy(arr, bins=40):
    """Estimate and compute the entropy of an array of continuous numbers."""
    # Estimate the PDF using a histogram
    arr = np.squeeze(arr)
    hist, bin_edges = np.histogram(arr, bins=bins, range=(-1, 1), density=True)
    
    # Compute the tiny 'dx' for each bin (bin width)
    dx = bin_edges[1] - bin_edges[0]
    
    # Non-zero probabilities to avoid log(0)
    hist = hist[hist > 0]
    hist = hist*dx

    # Estimate the entropy using the formula
    H = -np.sum(hist * np.log2(hist))
    return H


bit = 0
for dim_id in range(0,dim_num):
    dx = int(np.floor(2/mean_norm[dim_id,1]/2.3548))
    H = estimate_entropy(all_data[:,dim_id],dx)
    print(H)
    bit += H

print("Estimated Bits:", bit)
