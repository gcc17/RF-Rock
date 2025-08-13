clc;clear;close all;
f12_group_cnt = 5;
ori_f3_cnt = 180;
used_rxch = 3;

gain_vals = 70:81;
gain_cnt = numel(gain_vals);
thin_ids = [11:110];
tag_name_list = [];
for id=thin_ids
    tag_name_list = [tag_name_list, sprintf("thin%d",id)];
end
tag_cnt = numel(tag_name_list);
pos_list = [5, 6, 7, 8];
pos_cnt = numel(pos_list);
lo_list = [1025, 950, 850];
lo_cnt = numel(lo_list);

save_direc = 'new_comb_70_fingerprint_files';
nn_data_direc = 'thin_nn_data';
if ~exist(nn_data_direc, 'dir')
    mkdir(nn_data_direc);
end
train_subdirec = sprintf('%s/train', nn_data_direc);
if ~exist(train_subdirec, 'dir')
    mkdir(train_subdirec);
end
test_subdirec = sprintf('%s/val', nn_data_direc);
if ~exist(test_subdirec, 'dir')
    mkdir(test_subdirec);
end

train_pos_list = [5,7,8];
test_pos_list = [6];


%% method 1
% only order3 (t1-t5) + order5 with 5 nl (t6)
% order3 power choice: [70,71,72,73], [74,75,76,77], [78,79,80,81]
% power group distance 3-5
% order5-5 only use the latter two
power_group1_idx = [1,2,3,4];       % [70,71,72,73]
power_group2_idx = [5,6,7,8];       % [74,75,76,77]
power_group3_idx = [9,10,11,12];    % [78,79,80,81];

for tag_idx=1:tag_cnt
    cur_tag = tag_name_list(tag_idx);
    tag_train_subdirec = sprintf('%s/train/%s', nn_data_direc, cur_tag);
    if ~exist(tag_train_subdirec, 'dir')
        mkdir(tag_train_subdirec);
    end
    tag_test_subdirec = sprintf('%s/val/%s', nn_data_direc, cur_tag);
    if ~exist(tag_test_subdirec, 'dir')
        mkdir(tag_test_subdirec);
    end

    for pos_idx=1:pos_cnt
        all_t1_order3_fingerprint = zeros(f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1, lo_cnt);
        all_t2_order3_fingerprint = zeros(f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1, lo_cnt);
        all_t3_order3_fingerprint = zeros(f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1, lo_cnt);
        all_t4_order3_fingerprint = zeros(f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1, lo_cnt);
        all_t5_order3_fingerprint = zeros(f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1, lo_cnt);
        all_t6_order5_fingerprint = zeros(f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1, lo_cnt);
        
        cur_pos = pos_list(pos_idx);

        for lo_idx=1:lo_cnt    
            cur_lo = lo_list(lo_idx);
            
            t1_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t1_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t1_fingerprint_path);
            t1_order3_fingerprint = fread(file, ...
                f12_group_cnt*used_rxch*gain_cnt*(ori_f3_cnt-1), 'double');
            fclose(file);
            t1_order3_fingerprint = reshape(t1_order3_fingerprint, [f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1]);
            all_t1_order3_fingerprint(:,:,:,:, lo_idx) = t1_order3_fingerprint;
%             for f12_group_idx=1:f12_group_cnt
%                 for gain_idx=1:gain_cnt
%                     figure;
%                     for rxch_idx=1:used_rxch
%                         plot(squeeze(t1_order3_fingerprint(f12_group_idx, rxch_idx, gain_idx, :)), ...
%                             'DisplayName', sprintf('ant-%d', rxch_idx));
%                         hold on;
%                     end
%                     title(sprintf('f12 %d gain %d', f12_group_idx, gain_vals(gain_idx)-80));
%                     legend;
%                 end
%             end

            t2_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t2_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t2_fingerprint_path);
            t2_order3_fingerprint = fread(file, ...
                f12_group_cnt*used_rxch*gain_cnt*(ori_f3_cnt-1), 'double');
            fclose(file);
            t2_order3_fingerprint = reshape(t2_order3_fingerprint, [f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1]);
            all_t2_order3_fingerprint(:,:,:,:, lo_idx) = t2_order3_fingerprint;

            t3_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t3_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t3_fingerprint_path);
            t3_order3_fingerprint = fread(file, ...
                f12_group_cnt*used_rxch*gain_cnt*(ori_f3_cnt-1), 'double');
            fclose(file);
            t3_order3_fingerprint = reshape(t3_order3_fingerprint, [f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1]);
            all_t3_order3_fingerprint(:,:,:,:, lo_idx) = t3_order3_fingerprint;

            t4_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t4_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t4_fingerprint_path);
            t4_order3_fingerprint = fread(file, ...
                f12_group_cnt*used_rxch*gain_cnt*(ori_f3_cnt-1), 'double');
            fclose(file);
            t4_order3_fingerprint = reshape(t4_order3_fingerprint, [f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1]);
            all_t4_order3_fingerprint(:,:,:,:, lo_idx) = t4_order3_fingerprint;

            t5_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t5_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t5_fingerprint_path);
            t5_order3_fingerprint = fread(file, ...
                f12_group_cnt*used_rxch*gain_cnt*(ori_f3_cnt-1), 'double');
            fclose(file);
            t5_order3_fingerprint = reshape(t5_order3_fingerprint, [f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1]);
            all_t5_order3_fingerprint(:,:,:,:, lo_idx) = t5_order3_fingerprint;

            t6_fingerprint_path = sprintf('%s/%s_pos%d_lo%d_t6_fingerprint.bin', ...
                save_direc, cur_tag, cur_pos, cur_lo);
            file = fopen(t6_fingerprint_path);
            t6_order5_fingerprint = fread(file, ...
                f12_group_cnt*used_rxch*gain_cnt*(ori_f3_cnt-1), 'double');
            fclose(file);
            t6_order5_fingerprint = reshape(t6_order5_fingerprint, [f12_group_cnt,used_rxch,gain_cnt,ori_f3_cnt-1]);
            all_t6_order5_fingerprint(:,:,:,:, lo_idx) = t6_order5_fingerprint;
        end

        for p1_idx=power_group1_idx
            for p2_idx=power_group2_idx
                if (p2_idx-p1_idx < 3) || (p2_idx-p1_idx > 5)
                    continue
                end
                for p3_idx=power_group3_idx
                    if (p3_idx-p2_idx < 3) || (p3_idx-p2_idx > 5)
                        continue
                    end
                    for p25_idx=p2_idx
                        if abs(p25_idx-p2_idx) > 1
                            continue
                        end
                        for p35_idx=p3_idx
                            if abs(p35_idx-p3_idx) > 1
                                continue
                            end

                            nn_data1 = zeros(lo_cnt, f12_group_cnt*(3*5+2*1), ori_f3_cnt-1);
                            nn_data2 = zeros(lo_cnt, f12_group_cnt*(3*5+2*1), ori_f3_cnt-1);
                            for lo_idx=1:lo_cnt
                                % t1 fingerprint: correlation between antennas
                                % t1-p1
                                for f12_group_idx=1:f12_group_cnt
                                    t1_p1_all_ants = squeeze(all_t1_order3_fingerprint(f12_group_idx,:,p1_idx,:, lo_idx));
                                    t1_p1_selected_ants = check_consistent(t1_p1_all_ants);
                                    nn_data1(lo_idx, f12_group_idx, :) = t1_p1_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_idx, :) = t1_p1_selected_ants(2,:);
                                end
                                % t1-p2
                                for f12_group_idx=1:f12_group_cnt
                                    t1_p2_all_ants = squeeze(all_t1_order3_fingerprint(f12_group_idx,:,p2_idx,:, lo_idx));
                                    t1_p2_selected_ants = check_consistent(t1_p2_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*1 + f12_group_idx, :) = t1_p2_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*1 + f12_group_idx, :) = t1_p2_selected_ants(2,:);
                                end
                                % t1-p3
                                for f12_group_idx=1:f12_group_cnt
                                    t1_p3_all_ants = squeeze(all_t1_order3_fingerprint(f12_group_idx,:,p3_idx,:, lo_idx));
                                    t1_p3_selected_ants = check_consistent(t1_p3_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*2 + f12_group_idx, :) = t1_p3_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*2 + f12_group_idx, :) = t1_p3_selected_ants(2,:);
                                end

                                % t2 fingerprint: correlation between antennas
                                % t2-p1
                                for f12_group_idx=1:f12_group_cnt
                                    t2_p1_all_ants = squeeze(all_t2_order3_fingerprint(f12_group_idx,:,p1_idx,:, lo_idx));
                                    t2_p1_selected_ants = check_consistent(t2_p1_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*3 + f12_group_idx, :) = t2_p1_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*3 + f12_group_idx, :) = t2_p1_selected_ants(2,:);
                                end
                                % t2-p2
                                for f12_group_idx=1:f12_group_cnt
                                    t2_p2_all_ants = squeeze(all_t2_order3_fingerprint(f12_group_idx,:,p2_idx,:, lo_idx));
                                    t2_p2_selected_ants = check_consistent(t2_p2_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*4 + f12_group_idx, :) = t2_p2_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*4 + f12_group_idx, :) = t2_p2_selected_ants(2,:);
                                end
                                % t2-p3
                                for f12_group_idx=1:f12_group_cnt
                                    t2_p3_all_ants = squeeze(all_t2_order3_fingerprint(f12_group_idx,:,p3_idx,:, lo_idx));
                                    t2_p3_selected_ants = check_consistent(t2_p3_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*5 + f12_group_idx, :) = t2_p3_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*5 + f12_group_idx, :) = t2_p3_selected_ants(2,:);
                                end

                                % t3 fingerprint: correlation between antennas
                                % t3-p1
                                for f12_group_idx=1:f12_group_cnt
                                    t3_p1_all_ants = squeeze(all_t3_order3_fingerprint(f12_group_idx,:,p1_idx,:, lo_idx));
                                    t3_p1_selected_ants = check_consistent(t3_p1_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*6 + f12_group_idx, :) = t3_p1_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*6 + f12_group_idx, :) = t3_p1_selected_ants(2,:);
                                end
                                % t3-p2
                                for f12_group_idx=1:f12_group_cnt
                                    t3_p2_all_ants = squeeze(all_t3_order3_fingerprint(f12_group_idx,:,p2_idx,:, lo_idx));
                                    t3_p2_selected_ants = check_consistent(t3_p2_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*7 + f12_group_idx, :) = t3_p2_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*7 + f12_group_idx, :) = t3_p2_selected_ants(2,:);
                                end
                                % t3-p3
                                for f12_group_idx=1:f12_group_cnt
                                    t3_p3_all_ants = squeeze(all_t3_order3_fingerprint(f12_group_idx,:,p3_idx,:, lo_idx));
                                    t3_p3_selected_ants = check_consistent(t3_p3_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*8 + f12_group_idx, :) = t3_p3_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*8 + f12_group_idx, :) = t3_p3_selected_ants(2,:);
                                end

                                % t4 fingerprint: correlation between antennas
                                % t4-p1
                                for f12_group_idx=1:f12_group_cnt
                                    t4_p1_all_ants = squeeze(all_t4_order3_fingerprint(f12_group_idx,:,p1_idx,:, lo_idx));
                                    t4_p1_selected_ants = check_consistent(t4_p1_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*9 + f12_group_idx, :) = t4_p1_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*9 + f12_group_idx, :) = t4_p1_selected_ants(2,:);
                                end
                                % t4-p2
                                for f12_group_idx=1:f12_group_cnt
                                    t4_p2_all_ants = squeeze(all_t4_order3_fingerprint(f12_group_idx,:,p2_idx,:, lo_idx));
                                    t4_p2_selected_ants = check_consistent(t4_p2_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*10 + f12_group_idx, :) = t4_p2_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*10 + f12_group_idx, :) = t4_p2_selected_ants(2,:);
                                end
                                % t4-p3
                                for f12_group_idx=1:f12_group_cnt
                                    t4_p3_all_ants = squeeze(all_t4_order3_fingerprint(f12_group_idx,:,p3_idx,:, lo_idx));
                                    t4_p3_selected_ants = check_consistent(t4_p3_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*11 + f12_group_idx, :) = t4_p3_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*11 + f12_group_idx, :) = t4_p3_selected_ants(2,:);
                                end

                                % t5 fingerprint: correlation between antennas
                                % t5-p1
                                for f12_group_idx=1:f12_group_cnt
                                    t5_p1_all_ants = squeeze(all_t5_order3_fingerprint(f12_group_idx,:,p1_idx,:, lo_idx));
                                    t5_p1_selected_ants = check_consistent(t5_p1_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*12 + f12_group_idx, :) = t5_p1_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*12 + f12_group_idx, :) = t5_p1_selected_ants(2,:);
                                end
                                % t4-p2
                                for f12_group_idx=1:f12_group_cnt
                                    t5_p2_all_ants = squeeze(all_t5_order3_fingerprint(f12_group_idx,:,p2_idx,:, lo_idx));
                                    t5_p2_selected_ants = check_consistent(t5_p2_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*13 + f12_group_idx, :) = t5_p2_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*13 + f12_group_idx, :) = t5_p2_selected_ants(2,:);
                                end
                                % t4-p3
                                for f12_group_idx=1:f12_group_cnt
                                    t5_p3_all_ants = squeeze(all_t5_order3_fingerprint(f12_group_idx,:,p3_idx,:, lo_idx));
                                    t5_p3_selected_ants = check_consistent(t5_p3_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*14 + f12_group_idx, :) = t5_p3_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*14 + f12_group_idx, :) = t5_p3_selected_ants(2,:);
                                end
                                
                                % t6 fingerprint: order5 and only use last two groups of power
                                % t6-p25, power idx p25
                                for f12_group_idx=1:f12_group_cnt
                                    t6_p2_all_ants = squeeze(all_t6_order5_fingerprint(f12_group_idx,:,p25_idx,:, lo_idx));
                                    t6_p2_selected_ants = check_consistent(t6_p2_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*15 + f12_group_idx, :) = t6_p2_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*15 + f12_group_idx, :) = t6_p2_selected_ants(2,:);
                                end
                                % t6-p35, power idx p35
                                for f12_group_idx=1:f12_group_cnt
                                    t6_p3_all_ants = squeeze(all_t6_order5_fingerprint(f12_group_idx,:,p35_idx,:, lo_idx));
                                    t6_p3_selected_ants = check_consistent(t6_p3_all_ants);
                                    nn_data1(lo_idx, f12_group_cnt*16 + f12_group_idx, :) = t6_p3_selected_ants(1,:);
                                    nn_data2(lo_idx, f12_group_cnt*16 + f12_group_idx, :) = t6_p3_selected_ants(2,:);
                                end

                            end
%                             figure;
%                             mesh(squeeze(nn_data1(1,:,:)));
%                             view(2);
%                             disp('---');

                            % plot to check
%                             for f12_group_idx=1:f12_group_cnt
%                                 for lo_idx=1:lo_cnt
%                                     for pi=1:3
%                                         figure;
%                                         for ti=1:5
%                                             plot(squeeze(nn_data1(lo_idx, f12_group_cnt*3*(ti-1) + f12_group_cnt*(pi-1) + f12_group_idx, :)), ...
%                                                 'DisplayName', sprintf('power%d-target%d-ant1', pi, ti));
%                                             hold on;
%                                             plot(squeeze(nn_data2(lo_idx, f12_group_cnt*3*(ti-1) + f12_group_cnt*(pi-1) + f12_group_idx, :)), ...
%                                                 'DisplayName', sprintf('power%d-target%d-ant2', pi, ti));
%                                             hold on;
%                                         end
%                                         legend
%                                         title(sprintf('f12 %d lo %d power %d', f12_group_idx, lo_idx, pi));
%                                     end
%                                     
%                                     figure;
%                                     for pi=1:2
%                                         plot(squeeze(nn_data1(lo_idx, f12_group_cnt*3*5 + f12_group_cnt*(pi-1) + f12_group_idx, :)), ...
%                                                 'DisplayName', sprintf('power%d-target6-ant1', pi+1));
%                                         hold on;
%                                         plot(squeeze(nn_data2(lo_idx, f12_group_cnt*3*5 + f12_group_cnt*(pi-1) + f12_group_idx, :)), ...
%                                             'DisplayName', sprintf('power%d-target6-ant2', pi+1));
%                                         hold on;
%                                     end
%                                     legend
%                                     title(sprintf('f12 %d lo %d target6 order5', f12_group_idx, lo_idx));
%                                 end
%                             end
                            
                            % save data
                            if ismember(cur_pos, train_pos_list)
                                data1_path = sprintf('%s/%s_pos%d_%d_%d_%d_%d_%d_data1.mat', ...
                                    tag_train_subdirec, cur_tag, cur_pos, p1_idx, p2_idx, p3_idx, p25_idx, p35_idx);
                                save(data1_path, "nn_data1");
                                data2_path = sprintf('%s/%s_pos%d_%d_%d_%d_%d_%d_data2.mat', ...
                                    tag_train_subdirec, cur_tag, cur_pos, p1_idx, p2_idx, p3_idx, p25_idx, p35_idx);
                                save(data2_path, "nn_data2");

                            elseif ismember(cur_pos, test_pos_list)
                                data1_path = sprintf('%s/%s_pos%d_%d_%d_%d_%d_%d_data1.mat', ...
                                    tag_test_subdirec, cur_tag, cur_pos, p1_idx, p2_idx, p3_idx, p25_idx, p35_idx);
                                save(data1_path, "nn_data1");
                                data2_path = sprintf('%s/%s_pos%d_%d_%d_%d_%d_%d_data2.mat', ...
                                    tag_test_subdirec, cur_tag, cur_pos, p1_idx, p2_idx, p3_idx, p25_idx, p35_idx);
                                save(data2_path, "nn_data2");
                            end
                        
                        end
                    end
                end
            end
        end

    end
end
