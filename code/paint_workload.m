clearvars;
%close all;
clc;


%INFOCOM 2019 S = 6, N =100

%944 4 8
%926
%924

s = 5;
n = 10;
initial_seed = 43242;

workload_range = 0.5;
capacity_base = 32;
capacity_range = 16;
k = 1;
test_count = 5;


rng(initial_seed);
worst_flag = true;


%2-20 range 8
workload_base_range = 0.1:0.1:0.7;
x_num = length(workload_base_range);
x_index = 1:x_num;




delay_num = 2;
% per_delay_num = 2;

show_algorithm = [1,3,4,5];
k_related_algorithm = [1,2];
random_algorithm_raw = 3;
random_count = 2;
algorithm_num = length(show_algorithm);

algorithm_refer = {@Algorithm1,@optimal_algorithm,@random_algorithm,@greedy_algorithm,@TON_2017_algorithm};

algorithms = {"Algorithm1","optimal algorithm","random algorithm","greedy algorithm","TON 2017 algorithm"};
delays = zeros(algorithm_num,delay_num,x_num);
run_time = zeros(1,algorithm_num);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datasize_base = 0.5;
datasize_range = 0.5;

request_rate_base = 3;
request_rate_range = 2;


%INFOCOM 2019 32-48Mflops/s
%REIN 20 GHZ


band_base = 16;
band_range = 8;
% ratio [330; 960]
%REIN bandwidth 2 MHZ
%INFOCOM 2019  16-24KBps

cost_base = 0.5;
cost_range = 0.5;
C_max = (cost_base + cost_range/5)*s;


seed = randi(2^15);
rng(seed);

request_rate = request_rate_range*rand(n,1) + request_rate_base;
% 
% workload_pertask = workload_range*rand(n,1) + workload_base;
% 
datasize_pertask = datasize_range*rand(n,1) + datasize_base;
% 
% workload = workload_pertask .* request_rate;

data_rate = datasize_pertask .* request_rate;

capacity = capacity_range*rand(s,1) + capacity_base;

deploy_cost = cost_range*rand(s,n) + cost_base;

band = band_range*rand(n,1) + band_base;


% lambda_n = (330 + 630*rand(1,n))/8;
% data_n = (420+580*rand(1,n))*1024*8;
% workload = lambda_n.*data_n/10^9;
% upload_bandwidth = ones(1,s)*2*10^6;
dis = zeros(n,n);
for i = 1:n
	for j = (i+1):n
		dis(i,j) = rand();
		dis(j,i) = dis(i,j);
	end
end


offload_flag = double(dis < 2/n);



% [raw_delay,worst_case_delay,greedy_case_delay,random_breakdown_delay,all_random_breakdown_delay]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(initial_seed);
for test_i = 1:test_count
	disp("%%%%  epoch  " + num2str(test_i) + " %%%%%");
	result = cell(1,algorithm_num);
	seed = randi(2^15);
%     seed = 26896;
	workload_list = cell(x_num,1);
	for x_index = 1:x_num
		workload_base = workload_base_range(x_index);
 		[workload_list{x_index},~,~,~,~,~,~] = get_parameter(workload_base,workload_range,capacity_base,capacity_range,n,s,seed);
	end
	% disp(offload_flag);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	algorithms_indexed = algorithms(show_algorithm);
	index = 0;
	k_related_index = zeros(length(k_related_algorithm),1);
    related_index = 0;
	random_algorithm_index = 0;
	for i = show_algorithm
		disp("Getting result for " + algorithms{i});
		index = index + 1;
		if ~isempty(find(k_related_algorithm == i, 1))
            related_index = related_index+1;
			k_related_index(related_index) = index;
			result{index} = cell(1,x_num);
			cur_runtime = 0;
			for x_index = 1:x_num
				workload = workload_list{x_index};
				tic;
				result{index}{x_index} = algorithm_refer{i}(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,seed);
				cur_runtime = cur_runtime + toc*1000;
			end
			run_time(index) = run_time(index) + cur_runtime/x_num;
		elseif i == random_algorithm_raw
			random_algorithm_index = index;
			result{index} = cell(x_num,random_count);
			rng(seed);
			cur_runtime = 0;
			for x_index = 1:x_num
				workload = workload_list{x_index};
				for random_i = 1:random_count
					rand_seed = randi(2^15);
					% disp(rand_seed);
					tic;
					result{index}{x_index,random_i} = algorithm_refer{i}(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,rand_seed);
					cur_runtime = cur_runtime + toc*1000;
				end
			end
			run_time(index) = run_time(index) + cur_runtime/random_count/x_num;
		else
			result{index} = cell(1,x_num);
			cur_runtime = 0;
			for x_index = 1:x_num
				workload = workload_list{x_index};
				tic;
				result{index}{x_index} = algorithm_refer{i}(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,seed);
				cur_runtime = cur_runtime + toc*1000;
			end
			run_time(index) = run_time(index) + cur_runtime/x_num;

		end
	end

	disp("%%%%%%%%%%%%%%%%%%%%%% running time %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
	for i = 1:algorithm_num
		disp(algorithms_indexed{i});
		disp(run_time(i)/test_i);
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	for x_index = 1:x_num
		workload = workload_list{x_index};
		disp("Evaluate result index is " + num2str(x_index));
		for i = 1:algorithm_num
			if ~isempty(find(k_related_index == i, 1))
				delays(i,:,x_index) = delays(i,:,x_index) + evaluate_result(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,result{i}{x_index},worst_flag,seed);
			elseif i == random_algorithm_index
				cur_delay = zeros(1,delay_num);
				for random_i = 1:random_count
					cur_delay = cur_delay + evaluate_result(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,result{i}{x_index,random_i},worst_flag,seed);
				end
				delays(i,:,x_index) = delays(i,:,x_index) + cur_delay/random_count;
			else
				delays(i,:,x_index) = delays(i,:,x_index) + evaluate_result(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,result{i}{x_index},worst_flag,seed);
			end
		end	
	end
end

delays = delays / test_count;




disp("%%%%%%%%%%%%%%%%%%% worst delay %%%%%%%%%%%%%%%%%%%%%%");
for i = 1:algorithm_num
	disp(algorithms_indexed{i});
	disp(squeeze(delays(i,1,:))');
end
disp("%%%%%%%%%%%%%%%%%%% greedy worst delay %%%%%%%%%%%%%%%%%%%%%%");
for i = 1:algorithm_num
	disp(algorithms_indexed{i});
	disp(squeeze(delays(i,2,:))');
end






if worst_flag
    figure;
    x1 = workload_base_range+workload_range/2;
    X1 = repmat(x1,algorithm_num,1)';
    Y1 = squeeze(delays(:,1,:))';
    axes1 = axes;
    hold(axes1,'on');
    plot1 = plot(X1,Y1);
    NameArray = {'DisplayName','Color','Marker'};
    ValueArray = {'Algorithm1',[0.3010 0.7450 0.9330],'o';...
        'optimal algorithm','k','d';...
        'random algorithm','m','*';...
        'greedy algorithm',[0.4660 0.6740 0.1880],'s';...
        'TON 2017 algorithm','b','x';...
        'Algorithm2','r','+';...
        'TVT 2019 algorithm',[0.4940 0.1840 0.5560],'^';...
        'INFOCOM 2017 algorithm',[0.6350 0.0780 0.1840],'v'
        };
    ValueArray = ValueArray(show_algorithm,:);
    set(plot1,NameArray,ValueArray);
    box(axes1,'on');
    title("total satisfied workload after worst breakdown with n = " + num2str(n) + " and s = " + num2str(s) + " and seed = " + num2str(initial_seed))
    legend1 = legend(axes1,'show');
    set(legend1,'Location','northeast');
    xlabel('workload')
    ylabel('total satisfied workload after worst breakdown (s)')

else
    figure;
    x2 = workload_base_range+workload_range/2;
    X2 = repmat(x2,algorithm_num,1)';
    Y2 = squeeze(delays(:,2,:))';
    axes1 = axes;
    hold(axes1,'on');
    plot1 = plot(X2,Y2);
    NameArray = {'DisplayName','Color','Marker'};
    ValueArray = {'Algorithm1',[0.3010 0.7450 0.9330],'o';...
    'optimal algorithm','k','d';...
    'random algorithm','m','*';...
    'greedy algorithm',[0.4660 0.6740 0.1880],'s';...
    'TON 2017 algorithm','b','x';...
    'Algorithm2','r','+';...
    'TVT 2019 algorithm',[0.4940 0.1840 0.5560],'^';...
    'INFOCOM 2017 algorithm',[0.6350 0.0780 0.1840],'v'
    };
    ValueArray = ValueArray(show_algorithm,:);
    set(plot1,NameArray,ValueArray);
    box(axes1,'on');
    title("total delay after greedy breakdown with n = " + num2str(n) + " and s = " + num2str(s))
    legend1 = legend(axes1,'show');
    set(legend1,'Location','northeast');
    xlabel('workload')
    ylabel('total delay after greedy breakdown (s)')
end
