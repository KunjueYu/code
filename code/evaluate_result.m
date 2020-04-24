function [delays] = evaluate_result(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,result,worst_flag,seed)

    worst_case = 0;
    all_random_breakdown_delay = 0;
    random_breakdown_delay = 0;
    % per_task_worst_value = zeros(1,n); 
    % per_task_greedy_value = zeros(1,n);
    if worst_flag
        [worst_case,worst_breaked_assignment_list] = worst_breakdown_value(k,workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,result);
    end
    [greedy_case,greedy_breaked_assignment_list] = greedy_breakdown_value(k,workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,result);

    delays = [worst_case,greedy_case];


    

end