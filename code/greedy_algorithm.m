function [result] = greedy_algorithm(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,seed)
% 
	rng(seed);
	disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%  greedy algorithm  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");


	% disp(workload);
	% disp(user_compute);
	% disp(node_compute);
	% disp(upload_time);


	mask = true(s,n);
	result = zeros(s,2);
    result_index = 0;
	index = 1:s*n;
	cur_cost = 0;

	for i = 1:s
        cur_mask = mask & (deploy_cost <= C_max - cur_cost);
        masked_index = index(cur_mask);
%         if isempty(masked_index) || ~isempty(find(cur_mask < mask,1))
        if isempty(masked_index)
            result = result(1:result_index,:);
			disp(result);
			return;
        end
        cur_result = result(1:result_index,:);
        value_list = zeros(length(masked_index),1);
        parfor par_index = 1:length(masked_index)
            now_index = masked_index(par_index);
            [j,m] = ind2sub([s,n],now_index);
			temp = [cur_result;[j,m]];
			value_list(par_index) = final_value(workload,capacity,deploy_cost,data_rate,band,offload_flag,s,n,temp);
        end
        [~,cur] = max(reshape(value_list,[],1));
        [j,m] = ind2sub([s,n],masked_index(cur));
        
        disp(num2str(i) + " servers are selected.");
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


























