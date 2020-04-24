function [value,breaked_assignment_list] = greedy_breakdown_value(k,workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,assignment_list)
	value = 0;
	n = length(workload);
	s = length(capacity);
	% disp(assignment_list);
	[assignment_list_len,~] = size(assignment_list);

	mask = logical(ones(1,assignment_list_len));
	index = 1:n;
	if k >= assignment_list_len
		value = 0;
		breaked_assignment_list = [];
		return;
	end
	min_num = inf;
	final_num = final_value(workload,capacity,deploy_cost,data_rate,band,offload_flag,s,n,assignment_list);
	final_mask = logical(ones(1,assignment_list_len));
	for i = 1:k
		min_num = inf;
		for j = 1:sum(mask)
			cur_index = index(mask);
			cur_assignemnt_list = assignment_list(mask,:);
			cur_assignemnt_list(j,:) = [];
			cur_value = final_value(workload,capacity,deploy_cost,data_rate,band,offload_flag,s,n,cur_assignemnt_list);
			if cur_value < min_num
				min_num = cur_value;
				index_to_masked = cur_index(j);
				if min_num < final_num
					final_num = min_num;
					final_mask = mask;
					final_mask(index_to_masked) = 0;
				end
			end
		end
		mask(index_to_masked) = 0;
	end
	value = final_num;
	breaked_assignment_list = assignment_list(final_mask,:);


end


