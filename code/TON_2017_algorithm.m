function [result] = TON_2017_algorithm(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,seed)
%%% n = 7 ,s = 9, 20min

    disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%  TON 2017 algorithm  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
    rng(seed);

    encode = @(x,y) x*n-n+y;
    decode = @(x) [floor((x-1)/n)+1,mod(x-1,n)+1];
    x_lower = zeros(n*s,1);
    x_upper = ones(n*s,1);
    raw_index = 1:n*s;
    mask = true(n*s,1);
    result = zeros(s,2);
    result_index = 0;
    cur_cost = 0;

    while(~isempty(find(mask,1)))
        [solution,~] = raw_value(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,x_lower,x_upper);

        x_solution = solution(n*n+1:n*n+n*s);
        

        masked_index = raw_index(mask);
        [~,index_temp] = max(x_solution(mask));
        index = masked_index(index_temp);

        x_decoded = decode(index);
        

        if cur_cost + deploy_cost(x_decoded(1),x_decoded(2)) <= C_max
            result_index = result_index +1;
            result(result_index,:) = [x_decoded(1),x_decoded(2)];
            mask(encode(x_decoded(1),1):1:encode(x_decoded(1),n)) = false;
            cur_cost = cur_cost + deploy_cost(x_decoded(1),x_decoded(2));
            x_lower(index) = 1;
            for i = [1:x_decoded(2)-1,x_decoded(2)+1:n]
                x_upper(encode(x_decoded(1),i)) = 0;
            end
        else
            % for i = 1:n
            %     x_upper(encode(x_decoded(1),i)) = 0;
            % end
%             x_upper(index) = 0;
%             mask(index) = false;
            break;
        end
        
    end
    result = result(1:result_index,:);
    disp(result);

end



















