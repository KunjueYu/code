function [result] = optimal_algorithm(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,seed)
%%% n = 7 ,s = 9, 20min

    disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%  optimal algorithm  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
    rng(seed);






    result = zeros(s,2);

    enumerate_index = int16(ones(s,1));
    max_value = -inf;
    disp_num = min(s,4);
    cur_par_num = 0;
    par_batch = 64;
    par_assignment_list = cell(par_batch,1);
    while enumerate_index(s) <= n + 1
        % disp(cur_index);
        % task_index is masked index
        cur = enumerate_index(disp_num);
        cur_assignment_list = [(1:s)',enumerate_index];
        [len, ~] = size(cur_assignment_list);
        
        enumerate_index(1) = enumerate_index(1)+1;
        for i = 1:s-1
        	enumerate_index(i+1) = enumerate_index(i+1) + idivide(enumerate_index(i)-1,n+1);
        	enumerate_index(i) = mod(enumerate_index(i) - 1,n+1) + 1;
        end
        if (enumerate_index(disp_num) ~= cur)
        	disp(enumerate_index(disp_num:s)');
            % cur_time = toc;
            % disp(cur_time);
        end
        
        
        index = 1:len;
        placed_index = index(cur_assignment_list(:,2) <= n);
        not_placed_index = index(cur_assignment_list(:,2) == n+1);
        
        list_index = sub2ind([s,n],cur_assignment_list(placed_index,1),cur_assignment_list(placed_index,2));
        cost_sum = sum(deploy_cost(list_index));
        if cost_sum > C_max
            continue;
        end
        full_flag = true;
        for i = not_placed_index
            for j = 1:n
                if cost_sum + deploy_cost(cur_assignment_list(i,1),j) < C_max
                    full_flag = false;
                end
            end
        end

        if ~full_flag
            continue;
        end
        for i = len:-1:1
            if cur_assignment_list(i,2) == n+1
                cur_assignment_list(i,:) = [];
            end
        end
        cur_par_num = cur_par_num +1;
        par_assignment_list{cur_par_num} = cur_assignment_list;
        value_list = zeros(par_batch,1);
        if cur_par_num == par_batch
            parfor i = 1:cur_par_num
                value_list(i) = worst_breakdown_value(k,workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,par_assignment_list{i});
            end
            cur_par_num = 0;
        end
        [par_max_value,max_index] = max(value_list);
        if par_max_value > max_value
            max_value = par_max_value;
            result = par_assignment_list{max_index};
        end

    end
    parfor i = 1:cur_par_num
        value_list(i) = worst_breakdown_value(k,workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,par_assignment_list{i});
    end
    value_list = value_list(1:cur_par_num);
    [par_max_value,max_index] = max(value_list);
    if par_max_value > max_value
        result = par_assignment_list{max_index};
    end
    % disp(min_value);
    disp(result);


end



















