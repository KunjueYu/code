function [result] = random_algorithm(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,seed)
% 
	rng(seed);
	disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%  random algorithm  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");


	% disp(workload);
	% disp(user_compute);
	% disp(node_compute);
	% disp(upload_time);

	% value_matrix = zeros(n,s);
	mask = true(1,s);
	% disp(value_matrix);

	all_mask = true(s,n);

	result = zeros(s,2);
    result_index = 0;
	index = 1:s;
	cur_cost = 0;

	% decode = @(x) [mod(x-1,s)+1,floor((x-1)/s)+1];
    
	while(~isempty(find(all_mask,1)))
		[row,col] = find(all_mask);
		len = length(row);
		sample_index = randi(len);
		sample_s = row(sample_index);
		sample_n = col(sample_index);


		if cur_cost + deploy_cost(sample_s,sample_n) > C_max
			all_mask(sample_s,sample_n) = false;
			continue;
        end
        result_index = result_index + 1;
		result(result_index,:) = [sample_s,sample_n];
		for m = 1:n
			all_mask(sample_s,m) = false;
		end
		cur_cost = cur_cost + deploy_cost(sample_s,sample_n);
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


























