import numpy as np
single_label_sample_num = 78
dim_num = 4
label_num = 100
all_data = np.zeros((single_label_sample_num*label_num, dim_num))

fold_name_list = ['embeddings_length4_f12_2_lo_1_0.94/',
                'embeddings_length4_f12_4_lo_1_0.95/',
                'embeddings_length4_f12_8_lo_1_0.96/',
                'embeddings_length4_f12_8_lo_2_0.98/',
                'embeddings_length4_f12_8_lo_3_0.99/']
for k in range(0,5):
    fold_name = fold_name_list[k]
    for j in range(0, label_num):
        for i in range(0, single_label_sample_num):
            file_name = f'train_sample{i+j*single_label_sample_num}_label{j}.npy'
            data = np.load(fold_name+file_name)
            all_data[j * single_label_sample_num + i, :] = data

    print(np.shape(all_data))
    np.save(fold_name+'/all_data_4embedding',all_data)
