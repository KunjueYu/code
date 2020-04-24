clearvars;
%close all;
clc;
%INFOCOM 2019 S = 6, N =100


%131173
%116947266
s = 50;
n = 200;
initial_seed = 43242; %1203 43242 1130
workload_base = 0.5;
workload_range = 0.5;
capacity_base = 32;
capacity_range = 16;
test_count = 1;


rng(initial_seed);

worst_flag = false;


datasize_base = 0.5;
datasize_range = 0.5;

request_rate_base = 3;
request_rate_range = 2;


%INFOCOM 2019 32-48Mflops/s
%REIN 20 GHZ



% ratio [330; 960]
%REIN bandwidth 2 MHZ
%INFOCOM 2019  16-24KBps



k_range = 1:min(s-1,4); 
k_num = length(k_range);
k_index = 1:k_num;




delay_num = 2;
% per_delay_num = 2;

show_algorithm = [1,3,4,5];
k_related_algorithm = [1,2];
random_algorithm_raw = 3;
random_count = 2;
algorithm_num = length(show_algorithm);

algorithm_refer = {@Algorithm1,@optimal_algorithm,@random_algorithm,@greedy_algorithm,@TON_2017_algorithm};

algorithms = {"Algorithm1","optimal algorithm","random algorithm","greedy algorithm","TON 2017 algorithm"};
delays = zeros(algorithm_num,delay_num,k_num);
run_time = zeros(1,algorithm_num);
% per_task_delays = zeros(algorithm_num,per_delay_num,k_num,n);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
band_base = 16;
band_range = 8;

cost_base = 0.5;
cost_range = 0.5;
C_max = (cost_base + cost_range/5)*s;

seed = randi(2^15);%26896
rng(seed);

real_data = xlsread("new_data.xlsx");
real_data = real_data/24/30/60;

request_rate = randsample(real_data,n);
request_rate = reshape(request_rate,[],1);
% request_rate = request_rate_range*rand(n,1) + request_rate_base;

workload_pertask = workload_range*rand(n,1) + workload_base;

datasize_pertask = datasize_range*rand(n,1) + datasize_base;

workload = workload_pertask .* request_rate;

data_rate = datasize_pertask .* request_rate;

capacity = capacity_range*rand(s,1) + capacity_base;

deploy_cost = cost_range*rand(s,n) + cost_base;

band = band_range*rand(n,1) + band_base;


dis = zeros(n,n);
for i = 1:n
	for j = (i+1):n
		dis(i,j) = rand();
		dis(j,i) = dis(i,j);
	end
end


offload_flag = double(dis < 2/n);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for test_i = 1:test_count
	disp("%%%%  epoch  " + num2str(test_i) + " %%%%%");
	result = cell(1,algorithm_num);
	seed = randi(2^15);

%  	[workload,~,~,~,~,~,~] = get_parameter(workload_base,workload_range,capacity_base,capacity_range,n,s,seed);

	%disp(workload);
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
			result{index} = cell(1,k_num);
			cur_runtime = 0;
			for k_index = 1:k_num
				k = k_range(k_index);
                disp("Getting result for k = " + num2str(k));
				tic;
				result{index}{k_index} = algorithm_refer{i}(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,seed);
				cur_runtime = cur_runtime + toc*1000;
			end
			run_time(index) = run_time(index) + cur_runtime/k_num;
		elseif i == random_algorithm_raw
			random_algorithm_index = index;
			result{index} = cell(1,random_count);
			rng(seed);
			cur_runtime = 0;
			for random_i = 1:random_count
				rand_seed = randi(2^15);
				% disp(rand_seed);
				tic;
				result{index}{random_i} = algorithm_refer{i}(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,rand_seed);
				cur_runtime = cur_runtime + toc*1000;
			end
			run_time(index) = run_time(index) + cur_runtime/random_count;
		else
			tic;
			result{index} = algorithm_refer{i}(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,seed);
			run_time(index) = run_time(index) + toc*1000;

		end
	end

	disp("%%%%%%%%%%%%%%%%%%%%%% running time %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
	for i = 1:algorithm_num
		disp(algorithms_indexed{i});
		disp(run_time(i)/test_i);
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	for k_index = 1:k_num
		k = k_range(k_index);
		disp("Evaluate result k is " + num2str(k));
		for i = 1:algorithm_num
			if ~isempty(find(k_related_index == i, 1))
				delays(i,:,k_index) = delays(i,:,k_index) + evaluate_result(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,result{i}{k_index},worst_flag,seed);
				%,per_task_delays(i,:,k_index,:)
			elseif i == random_algorithm_index
				cur_delay = zeros(1,delay_num);
				for random_i = 1:random_count
					cur_delay = cur_delay + evaluate_result(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,result{i}{random_i},worst_flag,seed);
					% per_task_delays(i,:,k_index,:) = per_task_delays(i,:,k_index,:) + reshape(cur_per_delay,[per_delay_num,1,1,n]);
				end
				delays(i,:,k_index) = delays(i,:,k_index) + cur_delay/random_count;
				% per_task_delays(i,:,k_index,:) = per_task_delays(i,:,k_index,:)/random_count;
			else
				%per_task_delays(i,:,k_index,:)
				delays(i,:,k_index) = delays(i,:,k_index) + evaluate_result(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,k,result{i},worst_flag,seed);
			end
		end	
	end
end

delays = delays / test_count;




% disp("%%%%%%%%%%%%%%%%%%% raw delay %%%%%%%%%%%%%%%%%%%%%%");
% for i = 1:algorithm_num
% 	disp(algorithms_indexed{i});
% 	disp(squeeze(delays(3,i,:))');
% end

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
% disp("%%%%%%%%%%%%%%%%%%% random breakdown delay %%%%%%%%%%%%%%%%%%%%%%");
% for i = 1:algorithm_num
% 	disp(algorithms_indexed{i});
% 	disp(squeeze(delays(4,i,:))');
% end
% disp("%%%%%%%%%%%%%%%%%%% all random breakdown delay %%%%%%%%%%%%%%%%%%%%%%");
% for i = 1:algorithm_num
% 	disp(algorithms_indexed{i});
% 	disp(squeeze(delays(5,i,:))');
% end






if worst_flag
    figure;
    x1 = k_range;
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
    title("total satisfied workload after worst breakdown with n = " + num2str(n) + " and s = " + num2str(s) + " and seed = " + num2str(initial_seed));
    legend1 = legend(axes1,'show');
    set(legend1,'Location','northeast');
    xlabel('number of breakdown servers')
    ylabel('total satisfied workload after worst breakdown (s)')

else
    figure;
    x2 = k_range;
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
    title("total satisfied workload after greedy breakdown with n = " + num2str(n) + " and s = " + num2str(s)+ " and seed = " + num2str(initial_seed))
    legend1 = legend(axes1,'show');
    set(legend1,'Location','northeast');
    xlabel('number of breakdown servers')
    ylabel('total satisfied workload after worst breakdown (s)')
end