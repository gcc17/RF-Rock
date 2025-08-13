%% basic rf parameters
clc;clear;close all;
dst_direc = 'singleant_new_comb_70';
f12_pairs = [...
    45 71 71 19; ...
    32 58 83 7; ...
    55 91 91 19; ...
    37 73 103 7; ...
    75 121 121 29; ...
    52 98 133 17; ...
    85 141 141 29; ...
    57 113 73 97; ...
    105 171 171 39; ...
    72 138 89 121 
    ];
f12_cnt = 10;
f12_group_cnt = f12_cnt / 2;
f3_cnt = 70;
gain_vals = 70:81;
gain_cnt = numel(gain_vals);
thin_ids = [11:110];
tag_name_list = [];
for id=thin_ids
    tag_name_list = [tag_name_list, sprintf("thin%d",id)];
end

tag_cnt = numel(tag_name_list);
pos_list = [5,6,7,8];
pos_cnt = numel(pos_list);
lo_list = [1025,950,850];
lo_cnt = numel(lo_list);

% tag_name, pos, lo, fingerprint_type
bin_prefix = '%s_pos%d_newcomb_lo%d_gain%d';
used_rxch = 3;
order3_nl_cnt = 9;
order5_nl_cnt = 15;
t1_order3_nl_idx = [5,1]; 
t1_f12_idx = [1,2];
t2_order3_nl_idx = [1,1];
t2_f12_idx = [2,3];
t3_order3_nl_idx = [1,1];
t3_f12_idx = [2,4];
t4_order3_nl_idx = [2,2];
t4_f12_idx = [1,3];
t5_order3_nl_idx = [3,3];
t5_f12_idx = [1,3];
t6_order5_nl_idx = [5,5];
t6_f12_idx = [1,2];
t7_order5_nl_idx = [9,9];
t7_f12_idx = [1,3];
t8_order5_nl_idx = [13,13];
t8_f12_idx = [1,3];

selected_f3s = [1:4:22, 23:2:36, 38:44, 46:52, 54:2:57, 59:2:62, 64:70, 72:78, 79:2:92, 93:5:122, 124:5:148, 150:5:174,176,180; ...
    1:2:11, 12:18, 20:26, 28:2:31, 33:2:39, 42:4:50, 51:2:62, 64:70, 72:78, 79:2:80, 83:5:122, 124:5:174, 180; ...
    1:4:10, 12:2:23, 25:31, 33:39, 41:2:44, 46:2:50, 51:57, 59:65, 66:2:77, 79:4:95, 98, 104:5:178, 180; ...
    1:6, 8:14, 16:2:25,27, 29:4:44, 46:4:62, 63:2:74, 76:82, 84:90, 92:2:103, 106:4:120, 122:5:176, 180; ...
    

    1:5:34, 36:2:46, 48:54,56:62, 65, 68:2:81, 83, 84:90,92:98, 100:2:111, 114:5:178, 180; ...
    1:2:11, 12:18, 20:26, 28:2:39, 42:5:66, 68:5:70, 71, 74:2:82, 84:90, 92:98, 100:2:111, 113:5:127, 129:6:176, 180; ...
    2:5:16, 17,20:2:28, 30:36, 38:44, 45, 47,48:2:63, 66:72, 74:80, 82:2:93, 96:5:175, 180; ...
    2:6, 8:14, 15:2:27, 29:4:94, 96:102, 104:110, 112:2:123, 123:4:134, 136:4:150, 152:4:160, 163:5:177, 180; ...
    
    1:6:40, 41:5:53, 55:2:66, 68:74, 76:82, 84:2:95, 99, 101:2:112, 114:120, 122:128, 130:2:141, 143:5:150, 153:6:176,180; ...
    1,5, 9:2:20, 22:28, 30:36, 38:2:49, 53:5:60, 61:5:112, 114:120, 122:128, 130:2:141, 143:5:179, 180; ...
    1, 7:5:30, 32:2:43, 45:51, 53:59, 61:2:72, 76, 78:2:89, 91:97, 99:105, 107:2:118, 122:5:150, 153, 159, 166, 172, 180; ...
    1:2:8, 10:16, 18:24, 26:2:37, 41:4:65, 71:5:103, 108, 113:2:124, 126:132, 134:140, 142:2:153, 157:5:176,180; ...

    1:6:45, 48:5:61, 65:2:76, 78:84, 86:92, 94:2:105, 107:5:120, 121:2:126, 128:2:132, 134:140, 142:148, 150:2:161, 163:5:177,180; ...
    1:5:8, 9:2:20, 22:28, 30:36, 38:2:49, 53:5:112, 116, 121:2:132, 134:140, 142:148, 150:2:161, 167:5:176,180; ...
    2:6:35, 37:2:48, 50:56, 58:64, 66:2:77, 78:5:90, 93:2:98,100:2:104, 106:112, 114:120, 122:2:133, 136, 142:5:176,180; 
    2:5:32, 34:4:51, 53:2:60, 63, 64, 66:72, 74:78, 80, 82:2:88, 90, 92:96, 98:104, 106:2:117, 119:4:178,180; ...
    
    1:5:83, 85:2:96, 98:104, 106:112, 114:2:125, 128:5:137, 139:5:148, 150, 151:2:162, 164:170, 172:180; ...
    1:5:17, 19:2:30, 32:38, 40:46, 48:2:59, 61:5:149, 151:2:162, 164:170, 172:180; ...
    1:6:38, 41:5:51, 52:2:63, 65:71, 73:79, 81:2:92, 95:5:104, 106:6:115, 118:2:129, 131:137, 139:145, 147:2:158, 161:5:170,172,180; ...
    1:5:64, 67:2:71, 74:2:80, 82:88, 90:96, 98:2:112, 114:120, 122:128, 130:2:141, 143:5:152, 154:5:168, 170,175,180
    ];
ori_f3_cnt = 180;

save_direc = 'new_comb_70_fingerprint_files';
if ~exist(save_direc, 'dir')
    mkdir(save_direc);
end

%% read nl amps from .bin files
% tag_name, pos, lo, fingerprint_type
% bin_prefix = '%s_pos%d_newcomb_lo%d_gain%d';
for tag_idx=1:tag_cnt
    for pos_idx=1:pos_cnt
        for lo_idx=1:lo_cnt
            cur_tag = tag_name_list(tag_idx);
            cur_pos = pos_list(pos_idx);
            cur_lo = lo_list(lo_idx);
            
            nl_amp_order3 = zeros(f12_cnt, f3_cnt, order3_nl_cnt, 2, used_rxch, gain_cnt);
            nl_amp_order5 = zeros(f12_cnt, f3_cnt, order5_nl_cnt, 2, used_rxch, gain_cnt);
            
            % read data files
            for gain_idx=1:gain_cnt
                cur_gain = gain_vals(gain_idx);
                cur_prefix = sprintf(bin_prefix, cur_tag, cur_pos, cur_lo, cur_gain);
                disp(cur_prefix);

                cur_nl_order3_path = sprintf('%s/%s_order3_amp.bin', dst_direc, cur_prefix);
                file = fopen(cur_nl_order3_path);
                cur_amp_order3 = fread(file, f12_cnt*f3_cnt*order3_nl_cnt*2*used_rxch, 'double');
                fclose(file);
                cur_amp_order3 = reshape(cur_amp_order3, [used_rxch,2,order3_nl_cnt,f3_cnt,f12_cnt]);
                cur_amp_order3 = permute(cur_amp_order3, [5,4,3,2,1]);
                nl_amp_order3(:,:,:,:,:,gain_idx) = cur_amp_order3;

                cur_nl_order5_path = sprintf('%s/%s_order5_amp.bin', dst_direc, cur_prefix);
                file = fopen(cur_nl_order5_path);
                cur_amp_order5 = fread(file, f12_cnt*f3_cnt*order5_nl_cnt*2*used_rxch, 'double');
                fclose(file);
                cur_amp_order5 = reshape(cur_amp_order5, [used_rxch,2,order5_nl_cnt,f3_cnt,f12_cnt]);
                cur_amp_order5 = permute(cur_amp_order5, [5,4,3,2,1]);
                nl_amp_order5(:,:,:,:,:,gain_idx) = cur_amp_order5;
            end

            % correct order3
            corr_f12_idx = [1,1,2,3,3,3,3,4,4,4, 4,4, 7, 8, 8,8,8, 9,9,9, 9,9, 10,10];
            corr_f3_idx = [13,64,54,7,13,38,51,9,22,48, 17,58, 15, 10, 15,20,47, 2,13,39, 2,31, 32,9];
            corr_order3_nl_idx = [1,2,3,5,7];
            corr_pair_idx = [2,2,2,1,1,1,1, 1,1,1, 2,2, 1, 1, 2,2,2, 1,1,1, 2,2, 1,2];
            corr_cnt = numel(corr_f12_idx);

%             corr_f12_idx = [1,1,2,3,3,3,3, 4,4,4, 4,4, 5,5, 6, 7,7,7, 7,7, ...
%                 8,8, 8,8,8, 9,9,9,9,9,9,9, 9,9, 10,10,10];
%             corr_f3_idx = [13,64,54,7,13,38,51, 9,22,48, 17,58, 10,58, 67, 15,62,67, 27,35, ...
%                 10,34, 15,20,47, 2,13,39,19,45,50,67, 2,31, 32,9,64];
%             corr_order3_nl_idx = [1,2,3,5,7];
%             corr_pair_idx = [2,2,2,1,1,1,1, 1,1,1, 2,2, 1,2, 2, 1,1,1, 2,2, ...
%                 1,1, 2,2,2, 1,1,1,1,1,1,1, 2,2, 1,2,2];
%             corr_cnt = numel(corr_f12_idx);
            for corr_idx=1:corr_cnt
                cur_f12_idx = corr_f12_idx(corr_idx);
                cur_f3_idx = corr_f3_idx(corr_idx);
                cur_pair_idx = corr_pair_idx(corr_idx);
                
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        for cur_order3_nl_idx=corr_order3_nl_idx
                            last_val = nl_amp_order3(cur_f12_idx, cur_f3_idx+1, ...
                                cur_order3_nl_idx, cur_pair_idx, rxch_idx, gain_idx);
                            cur_val = nl_amp_order3(cur_f12_idx, cur_f3_idx, ...
                                cur_order3_nl_idx, cur_pair_idx, rxch_idx, gain_idx);
                            if cur_f3_idx > 1
                                prev_val = nl_amp_order3(cur_f12_idx, cur_f3_idx-1, ...
                                    cur_order3_nl_idx, cur_pair_idx, rxch_idx, gain_idx);
                            else
                                prev_val = last_val;
                            end
                            nl_amp_order3(cur_f12_idx, cur_f3_idx, ...
                                cur_order3_nl_idx, cur_pair_idx, rxch_idx, gain_idx) = ...
                                (prev_val+last_val)/2;
                        end
                    end
                end
            end

            % correct order5
            corr_f12_idx = [1,1, 2, 3,3,3,3,3,3,3,  3,3, 4,4,4,4,4, 4,4, 6, 7,7,7, 7, 8,8, 8,8,8,8, 9,9,9, 9,9,9, 10,10,10];
            corr_f3_idx = [64,64, 54, 1,7,13,26,38,51,62, 1,7, 9,22,35,48,59, 17,58, 67, 1,8,15, 1, 10,15, 15,20,29,47, 2,13,39, 2,13,31, 9,32,9];
            corr_order5_nl_idx = [5,9,13];
            corr_pair_idx = [1,2, 2, 1,1,1,1,1,1,1,  2,2, 1,1,1,1,1, 2,2, 2, 1,1,1, 2, 1,1, 2,2,2,2, 1,1,1, 2,2,2, 1,1,2];
            corr_cnt = numel(corr_f12_idx);

%             corr_f12_idx = [1,1, 2,2, 3,3,3,3,3,3,3,  3,3, 4,4,4,4,4,4, 4,4,4,4, 6,6,6, ...
%                 7,7,7,7, 7, 8,8,8,8, 8,8,8,8,8,8,8, 9,9,9,9, 9,9,9,9,9, 10,10,10,10];
%             corr_f3_idx = [64,64, 54,5, 1,7,13,26,38,51,62, 1,7, 9,22,35,48,59,43, 17,58,28,26, 32,67,32, ...
%                 1,8,15,39, 1, 10,15,18,34, 15,20,29,47,5,8,38, 2,13,39,45, 2,13,31,50,67, 38,9,32,9];
%             corr_order5_nl_idx = [5,9,13];
%             corr_pair_idx = [1,2, 2,2, 1,1,1,1,1,1,1,  2,2, 1,1,1,1,1,1, 2,2,2,2, 1,2,2, ...
%                 1,1,1,1, 2, 1,1,1,1, 2,2,2,2,2,2,2, 1,1,1,1, 2,2,2,2,2, 1,1,1,2];
%             corr_cnt = numel(corr_f12_idx);
            for corr_idx=1:corr_cnt
                cur_f12_idx = corr_f12_idx(corr_idx);
                cur_f3_idx = corr_f3_idx(corr_idx);
                cur_pair_idx = corr_pair_idx(corr_idx);
                
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        for cur_order5_nl_idx=corr_order5_nl_idx
                            last_val = nl_amp_order5(cur_f12_idx, cur_f3_idx+1, ...
                                cur_order5_nl_idx, cur_pair_idx, rxch_idx, gain_idx);
                            cur_val = nl_amp_order5(cur_f12_idx, cur_f3_idx, ...
                                cur_order5_nl_idx, cur_pair_idx, rxch_idx, gain_idx);
                            if cur_f3_idx > 1
                                prev_val = nl_amp_order5(cur_f12_idx, cur_f3_idx-1, ...
                                    cur_order5_nl_idx, cur_pair_idx, rxch_idx, gain_idx);
                            else
                                prev_val = last_val;
                            end
                            nl_amp_order5(cur_f12_idx, cur_f3_idx, ...
                                cur_order5_nl_idx, cur_pair_idx, rxch_idx, gain_idx) = ...
                                (prev_val+last_val)/2;
                        end
                    end
                end
            end

            % interpolate
            interpolated_nl_amp_order3 = zeros(f12_cnt, ori_f3_cnt, order3_nl_cnt, 2, used_rxch, gain_cnt);
            for output_idx=1:order3_nl_cnt
                for pair_idx=1:2
                    for rxch_idx=1:used_rxch
                        for gain_idx=1:gain_cnt
                            for f12_idx=1:f12_cnt
                                vq = interp1(selected_f3s(2*(f12_idx-1)+pair_idx,:), ...
                                    nl_amp_order3(f12_idx, :, output_idx, pair_idx, rxch_idx, gain_idx), ...
                                    1:ori_f3_cnt, "linear");
                                if ~ismember(1,selected_f3s(2*(f12_idx-1)+pair_idx,:))
                                    vq(1) = vq(2);
                                end
                                interpolated_nl_amp_order3(f12_idx, :, output_idx, pair_idx,rxch_idx,gain_idx) = ...
                                    vq;
                            end
                        end
                    end
                end
            end
            interpolated_nl_amp_order5 = zeros(f12_cnt, ori_f3_cnt, order5_nl_cnt, 2, used_rxch, gain_cnt);
            for output_idx=1:order5_nl_cnt
                for pair_idx=1:2
                    for rxch_idx=1:used_rxch
                        for gain_idx=1:gain_cnt
                            for f12_idx=1:f12_cnt
                                vq = interp1(selected_f3s(2*(f12_idx-1)+pair_idx,:), ...
                                    nl_amp_order5(f12_idx, :, output_idx, pair_idx, rxch_idx, gain_idx), ...
                                    1:ori_f3_cnt, "linear");
                                if ~ismember(1,selected_f3s(2*(f12_idx-1)+pair_idx,:))
                                    vq(1) = vq(2);
                                end
                                interpolated_nl_amp_order5(f12_idx, :, output_idx, pair_idx,rxch_idx,gain_idx) = ...
                                    vq;
                                
                            end
                        end
                    end
                end
            end

            % calculate t1 fingerprint
            t1_order3_fingerprint = zeros(f12_group_cnt, used_rxch, gain_cnt, ori_f3_cnt-1);
            for f12_group_idx=1:f12_group_cnt
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        nl1 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((t1_f12_idx(1)-1)/2)+1, ...
                            :, t1_order3_nl_idx(1), mod(t1_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        nl2 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((t1_f12_idx(2)-1)/2)+1, ...
                            :, t1_order3_nl_idx(2), mod(t1_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        t1_diff = nl1 - nl2;
                        t1_fingerprint = t1_diff(2:end) - t1_diff(1);
                        t1_order3_fingerprint(f12_group_idx, rxch_idx, gain_idx, :) = t1_fingerprint; 
                    end
                end
            end
            t1_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t1_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t1_fingerprint_path, 'w');
            fwrite(file, t1_order3_fingerprint, 'double');
            fclose(file);

            % calculate t2 fingerprint
            t2_order3_fingerprint = zeros(f12_group_cnt, used_rxch, gain_cnt, ori_f3_cnt-1);
            for f12_group_idx=1:f12_group_cnt
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        nl1 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((t2_f12_idx(1)-1)/2)+1, ...
                            :, t2_order3_nl_idx(1), mod(t2_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        nl2 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((t2_f12_idx(2)-1)/2)+1, ...
                            :, t2_order3_nl_idx(2), mod(t2_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        t2_diff = nl1 - nl2;
                        t2_fingerprint = t2_diff(2:end) - t2_diff(1);
                        t2_order3_fingerprint(f12_group_idx, rxch_idx, gain_idx, :) = t2_fingerprint;
                    end
                end
            end
            t2_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t2_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t2_fingerprint_path, 'w');
            fwrite(file, t2_order3_fingerprint, 'double');
            fclose(file);

            % calculate t3 fingerprint
            t3_order3_fingerprint = zeros(f12_group_cnt, used_rxch, gain_cnt, ori_f3_cnt-1);
            for f12_group_idx=1:f12_group_cnt
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        nl1 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((t3_f12_idx(1)-1)/2)+1, ...
                            :, t3_order3_nl_idx(1), mod(t3_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        nl2 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((t3_f12_idx(2)-1)/2)+1, ...
                            :, t3_order3_nl_idx(2), mod(t3_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        t3_diff = nl1 - nl2;
                        t3_fingerprint = t3_diff(2:end) - t3_diff(1);
                        t3_order3_fingerprint(f12_group_idx, rxch_idx, gain_idx, :) = t3_fingerprint;
                    end
                end
            end
            t3_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t3_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t3_fingerprint_path, 'w');
            fwrite(file, t3_order3_fingerprint, 'double');
            fclose(file);

            % calculate t4 fingerprint
            t4_order3_fingerprint = zeros(f12_group_cnt, used_rxch, gain_cnt, ori_f3_cnt-1);
            for f12_group_idx=1:f12_group_cnt
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        nl1 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((t4_f12_idx(1)-1)/2)+1, ...
                            :, t4_order3_nl_idx(1), mod(t4_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        nl2 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((t4_f12_idx(2)-1)/2)+1, ...
                            :, t4_order3_nl_idx(2), mod(t4_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        t4_diff = nl1 - nl2;
                        t4_fingerprint = t4_diff(2:end) - t4_diff(1);
                        t4_order3_fingerprint(f12_group_idx, rxch_idx, gain_idx, :) = t4_fingerprint;
                    end
                end
            end
            t4_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t4_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t4_fingerprint_path, 'w');
            fwrite(file, t4_order3_fingerprint, 'double');
            fclose(file);
            
            % calculate t5 fingerprint
            t5_order3_fingerprint = zeros(f12_group_cnt, used_rxch, gain_cnt, ori_f3_cnt-1);
            for f12_group_idx=1:f12_group_cnt
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        nl1 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((t5_f12_idx(1)-1)/2)+1, ...
                            :, t5_order3_nl_idx(1), mod(t5_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        nl2 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((t5_f12_idx(2)-1)/2)+1, ...
                            :, t5_order3_nl_idx(2), mod(t5_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        t5_diff = nl1 - nl2;
                        t5_fingerprint = t5_diff(2:end) - t5_diff(1);
                        t5_order3_fingerprint(f12_group_idx, rxch_idx, gain_idx, :) = t5_fingerprint;
                    end
                end
            end
            t5_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t5_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t5_fingerprint_path, 'w');
            fwrite(file, t5_order3_fingerprint, 'double');
            fclose(file);

            % calculate t6 order5 fingerprint
            t6_order5_fingerprint = zeros(f12_group_cnt, used_rxch, gain_idx, ori_f3_cnt-1);
            for f12_group_idx=1:f12_group_cnt
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        nl1 = squeeze(interpolated_nl_amp_order5(2*(f12_group_idx-1)+floor((t6_f12_idx(1)-1)/2)+1, ...
                            :, t6_order5_nl_idx(1), mod(t6_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        nl2 = squeeze(interpolated_nl_amp_order5(2*(f12_group_idx-1)+floor((t6_f12_idx(2)-1)/2)+1, ...
                            :, t6_order5_nl_idx(2), mod(t6_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        t6_diff = nl1 - nl2;
                        t6_fingerprint = t6_diff(2:end) - t6_diff(1);
                        t6_order5_fingerprint(f12_group_idx, rxch_idx, gain_idx, :) = t6_fingerprint;
                    end
                end
            end
            t6_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t6_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t6_fingerprint_path, 'w');
            fwrite(file, t6_order5_fingerprint, 'double');
            fclose(file);

            % calculate t7 order5 fingerprint
            t7_order5_fingerprint = zeros(f12_group_cnt, used_rxch, gain_idx, ori_f3_cnt-1);
            for f12_group_idx=1:f12_group_cnt
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        nl1 = squeeze(interpolated_nl_amp_order5(2*(f12_group_idx-1)+floor((t7_f12_idx(1)-1)/2)+1, ...
                            :, t7_order5_nl_idx(1), mod(t7_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        nl2 = squeeze(interpolated_nl_amp_order5(2*(f12_group_idx-1)+floor((t7_f12_idx(2)-1)/2)+1, ...
                            :, t7_order5_nl_idx(2), mod(t7_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        t7_diff = nl1 - nl2;
                        t7_fingerprint = t7_diff(2:end) - t7_diff(1);
                        t7_order5_fingerprint(f12_group_idx, rxch_idx, gain_idx, :) = t7_fingerprint;
                    end
                end
            end
            t7_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t7_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t7_fingerprint_path, 'w');
            fwrite(file, t7_order5_fingerprint, 'double');
            fclose(file);

            % calculate t8 order5 fingerprint
            t8_order5_fingerprint = zeros(f12_group_cnt, used_rxch, gain_idx, ori_f3_cnt-1);
            for f12_group_idx=1:f12_group_cnt
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        nl1 = squeeze(interpolated_nl_amp_order5(2*(f12_group_idx-1)+floor((t8_f12_idx(1)-1)/2)+1, ...
                            :, t8_order5_nl_idx(1), mod(t8_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        nl2 = squeeze(interpolated_nl_amp_order5(2*(f12_group_idx-1)+floor((t8_f12_idx(2)-1)/2)+1, ...
                            :, t8_order5_nl_idx(2), mod(t8_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        t8_diff = nl1 - nl2;
                        t8_fingerprint = t8_diff(2:end) - t8_diff(1);
                        t8_order5_fingerprint(f12_group_idx, rxch_idx, gain_idx, :) = t8_fingerprint;
                    end
                end
            end
            t8_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t8_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t8_fingerprint_path, 'w');
            fwrite(file, t8_order5_fingerprint, 'double');
            fclose(file);

            % calculate new fingerprint
            new_fingerprint_order3 = zeros(f12_group_cnt, used_rxch, gain_cnt, ori_f3_cnt);
            f12_pair_diffs = zeros(f12_group_cnt,1);
            for f12_group_idx=1:f12_group_cnt
                f12_pair_diffs(f12_group_idx) = f12_pairs(2*f12_group_idx-1,1) - f12_pairs(2*f12_group_idx,1);
            end
            new_f12_idx = [1,3];
            target1_pairs_idx = [5,5];
            target2_pairs_idx = [7,7];
            target3_pairs_idx = [1,1];
            for f12_group_idx=1:f12_group_cnt
                f3_diff = 2*f12_pair_diffs(f12_group_idx);
                for rxch_idx=1:used_rxch
                    for gain_idx=1:gain_cnt
                        target1_pair1 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((new_f12_idx(1)-1)/2)+1, ...
                            :, target1_pairs_idx(1), mod(new_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        target2_pair1 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((new_f12_idx(1)-1)/2)+1, ...
                            :, target2_pairs_idx(1), mod(new_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        target3_pair1 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((new_f12_idx(1)-1)/2)+1, ...
                            :, target3_pairs_idx(1), mod(new_f12_idx(1)-1,2)+1, rxch_idx, gain_idx));
                        downlink_remove_pair1 = target1_pair1 + target2_pair1 - 2*target3_pair1;
            
                        target1_pair2 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((new_f12_idx(2)-1)/2)+1, ...
                            :, target1_pairs_idx(2), mod(new_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        target2_pair2 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((new_f12_idx(2)-1)/2)+1, ...
                            :, target2_pairs_idx(2), mod(new_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        target3_pair2 = squeeze(interpolated_nl_amp_order3(2*(f12_group_idx-1)+floor((new_f12_idx(2)-1)/2)+1, ...
                            :, target3_pairs_idx(2), mod(new_f12_idx(2)-1,2)+1, rxch_idx, gain_idx));
                        downlink_remove_pair2 = target1_pair2 + target2_pair2 - 2*target3_pair2;
            
                        new_fingerprint_order3(f12_group_idx, rxch_idx, gain_idx, 1+f3_diff:end) = ...
                            downlink_remove_pair1(1+f3_diff:end) - downlink_remove_pair2(1:ori_f3_cnt-f3_diff);
                    end
                end
            end
            new_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_new_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(new_fingerprint_path, 'w');
            fwrite(file, new_fingerprint_order3, 'double');
            fclose(file);

        end
    end
end


