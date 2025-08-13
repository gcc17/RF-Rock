import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm

single_label_sample_num = 78
label_num = 100

dim_num = 4
fold_name_list = ['embeddings_length4_f12_2_lo_1_0.94/',
                'embeddings_length4_f12_4_lo_1_0.95/',
                'embeddings_length4_f12_8_lo_1_0.96/',
                'embeddings_length4_f12_8_lo_2_0.98/',
                'embeddings_length4_f12_8_lo_3_0.99/']
fold_name = fold_name_list[4]
all_data = np.load(fold_name+"all_data_4embedding.npy")

np.savetxt(fold_name+'all_data.txt', all_data, delimiter=',')




fig, axes = plt.subplots(1, dim_num, figsize=(15, 4))  # figsize控制总体图的大小
for dim_id in range(dim_num):
    tag_id = 1
    ax = axes[dim_id]
    current_dim = all_data[tag_id:tag_id+single_label_sample_num-1, dim_id]
    # current_dim = all_data[:, dim_id]
    mu, std = norm.fit(current_dim)

    ax.hist(current_dim, bins=10, edgecolor='black', density=True)
    xmin, xmax = ax.get_xlim()
    x = np.linspace(xmin, xmax, 100)
    p = norm.pdf(x, mu, std)
    ax.plot(x, p, 'k', linewidth=2)

    title = f"Dim {dim_id+1}: mu = {mu:.2f},  std = {std:.2f}, tag = {tag_id}"
    ax.set_title(title)
plt.tight_layout()
plt.show()
