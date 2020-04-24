function [value,breaked_assignment_list] = worst_breakdown_value(k,workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,assignment_list)
	value = 0;
	n = length(workload);
	s = length(capacity);
	% disp(assignment_list);
	[server_num,~] = size(assignment_list);

	if k >= server_num
		value = 0;
		breaked_assignment_list = [];
		return;
	end

	index = 1:server_num;

	brute_force_list = nchoosek(index,server_num - k);
	[list_len,~] = size(brute_force_list);
	if list_len > 5*10^6
		disp(list_len);
	end
	min_num = inf;
	min_assignment_list = [];
	for z = 1:list_len
		cur_assignemnt_list = assignment_list(brute_force_list(z,:),:);
        cur_value = final_value(workload,capacity,deploy_cost,data_rate,band,offload_flag,s,n,cur_assignemnt_list);
        if cur_value < min_num
        	min_num = cur_value;
        	min_assignment_list = cur_assignemnt_list;
        end
	end
	value = min_num;
	breaked_assignment_list = min_assignment_list;

end


% brute_force search for the additional delay after deleting 1 to k element from the 1 to s node list
% for 1 to s node list, see them as backpack problem with grouping by recognize deleting 1 to k connections as k elements 
