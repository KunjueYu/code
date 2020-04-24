function [result] = Algorithm1(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,seed)
% 
	rng(seed);
	disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%  algorithm 1  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");


	% disp(workload);
	% disp(user_compute);
	% disp(node_compute);
	% disp(upload_time);

	value_list = zeros(s,n);
	mask = true(s,n);
    [J,M] = meshgrid(1:n,1:s);
    parfor par_index = 1:numel(J)
        value_list(par_index) = final_value(workload,capacity,deploy_cost,data_rate,band,offload_flag,s,n,[M(par_index),J(par_index)]);
    end

	result = zeros(s,2);
    result_index = 0;
	index = 1:s*n;
	cur_cost = 0;
    for i = 1:k

        cur_mask = mask & (deploy_cost <= C_max - cur_cost);
        max_value = max(reshape(value_list(cur_mask),[],1));
        candidate = value_list(cur_mask) == max_value;
        masked_index = index(cur_mask);
        cand_index = masked_index(candidate);
        candidate_margin_value = zeros(length(cand_index),1);
        cur_result = result(1:result_index,:);
        parfor par_index = 1:length(cand_index)
            now_index = cand_index(par_index);
            [j,m] = ind2sub([s,n],now_index);
            candidate_margin_value(par_index) = final_value(workload,capacity,deploy_cost,data_rate,band,offload_flag,s,n,[cur_result;[j,m]]);
        end
        
        max_margin_value = max(reshape(candidate_margin_value,[],1));
        
        candidate = candidate_margin_value == max_margin_value;
        real_index = cand_index(candidate);
        [~,cur] = min(reshape(deploy_cost(real_index),[],1));
        [j,m] = ind2sub([s,n],real_index(cur));
        disp(num2str(i)+ " servers are selected.");
		mask(j,:) = false;
		cur_cost = cur_cost + deploy_cost(j,m);
        result_index = result_index + 1;
		result(result_index,:) = [j,m];
    end
    % disp("part1 finished");
	temp_result = zeros(s,2);
    temp_result_index = 0;
	for i = (k + 1):s
        cur_mask = mask & (deploy_cost <= C_max - cur_cost);
        masked_index = index(cur_mask);
        if isempty(masked_index)
            result = result(1:result_index,:);
			disp(result);
			return;
        end
        cur_temp_result = temp_result(1:temp_result_index,:);
        value_list = zeros(length(masked_index),1);
        parfor par_index = 1:length(masked_index)
            now_index = masked_index(par_index);
            [j,m] = ind2sub([s,n],now_index);
			temp = [cur_temp_result;[j,m]];
			value_list(par_index) = final_value(workload,capacity,deploy_cost,data_rate,band,offload_flag,s,n,temp);
        end
        max_value = max(reshape(value_list,[],1));
        
        candidate = value_list == max_value;
        cand_index = masked_index(candidate);
        [~,cur] = min(reshape(deploy_cost(cand_index),[],1));
        [j,m] = ind2sub([s,n],cand_index(cur));
        
        disp(num2str(i) + " servers are selected.");
        temp_result_index = temp_result_index + 1;
        temp_result(temp_result_index,:) = [j,m];
		mask(j,:) = false;
		cur_cost = cur_cost + deploy_cost(j,m);
        result_index = result_index + 1;
		result(result_index,:) = [j,m];
	end
    result = result(1:result_index,:);
	disp(result);

	% upper_bound = 0;
	% for i = 1:n
	% 	upper_bound = upper_bound + workload(i)/user_compute(i);
	% end

	% disp("upper bound of algorithm 2 is "+ num2str(upper_bound));
	% value_2 = worst_breakdown_value_2(k,value_matrix,workload,user_compute,node_compute,result);
	% disp("approximate function 2 is " + num2str(value_2));


end


























