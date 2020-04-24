clearvars;
%close all;
clc;


%INFOCOM 2019 S = 6, N =100

%944 4 8
%926
%924


s = 5;
n = 10;
initial_seed = 4328;
workload_range = 0.5;
capacity_base = 42;
capacity_range = 16;
k = 2;
test_count = 1;


rng(initial_seed);


% workload_base = 0.5;
workload_base_range = 0.2:0.05:0.65;
workload_base_num = length(workload_base_range);
workload_base_index = 1:workload_base_num;




delay_num = 4;
% per_delay_num = 2;

show_algorithm = [1,3,4,5];
k_related_algorithm = [1,2];
random_algorithm_raw = 3;
random_count = 10;
algorithm_num = length(show_algorithm);

algorithm_refer = {@Algorithm1,@optimal_algorithm,@random_algorithm,@greedy_algorithm,@TON_2017_algorithm};

algorithms = {"Algorithm1","optimal algorithm","random algorithm","greedy algorithm","TON 2017 algorithm"};
delays = zeros(algorithm_num,delay_num,workload_base_num);
run_time = zeros(1,algorithm_num);
% per_task_delays = zeros(algorithm_num,per_delay_num,workload_base_num,n);
parameters = cell(workload_base_num,7);




% [raw_delay,worst_case_delay,greedy_case_delay,random_breakdown_delay,all_random_breakdown_delay]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for test_i = 1:test_count
	disp("%%%%  epoch  " + num2str(test_i) + " %%%%%");
	result = cell(1,algorithm_num);
	seed = randi(2^15);

	% [workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max] = get_parameter(workload_base,workload_range,capacity_base,capacity_range,n,s,seed);
	for workload_base_index = 1:workload_base_num
		workload_base = workload_base_range(workload_base_index);
		disp("generating data workload_base = " + num2str(workload_base));
		[parameters{workload_base_index,1},parameters{workload_base_index,2},parameters{workload_base_index,3},parameters{workload_base_index,4},parameters{workload_base_index,5},parameters{workload_base_index,6},parameters{workload_base_index,7}] = get_parameter(workload_base,workload_range,capacity_base,capacity_range,n,s,seed);
	end
	% disp(offload_flag);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	algorithms_indexed = algorithms(show_algorithm);
	index = 0;
	k_related_index = [];
	random_algorithm_index = 0;
	for i = show_algorithm
		disp("Getting result for " + algorithms{i});
		index = index + 1;
		if ~isempty(find(k_related_algorithm == i))

			k_related_index = [k_related_index,index];
			result{index} = cell(1,workload_base_num);
			cur_runtime = 0;
			for workload_base_index = 1:workload_base_num
				workload_base = workload_base_range(workload_base_index);
				tic;
				result{index}{workload_base_index} = algorithm_refer{i}(parameters{workload_base_index,1},parameters{workload_base_index,2},parameters{workload_base_index,3},parameters{workload_base_index,4},parameters{workload_base_index,5},parameters{workload_base_index,6},parameters{workload_base_index,7},s,n,k,seed);
				cur_runtime = cur_runtime + toc*1000;
			end
			run_time(index) = run_time(index) + cur_runtime/workload_base_num;
		elseif i == random_algorithm_raw
			random_algorithm_index = index;
			result{index} = cell(workload_base_num,random_count);
			rng(seed);
			cur_runtime = 0;
			for workload_base_index = 1:workload_base_num
				workload_base = workload_base_range(workload_base_index);
				for random_i = 1:random_count
					rand_seed = randi(2^15);
					% disp(rand_seed);
					tic;
					result{index}{workload_base_index,random_i} = algorithm_refer{i}(parameters{workload_base_index,1},parameters{workload_base_index,2},parameters{workload_base_index,3},parameters{workload_base_index,4},parameters{workload_base_index,5},parameters{workload_base_index,6},parameters{workload_base_index,7},s,n,rand_seed);
					cur_runtime = cur_runtime + toc*1000;
				end
			end
			run_time(index) = run_time(index) + cur_runtime/random_count/workload_base_num;
		else
			result{index} = cell(1,workload_base_num);
			cur_runtime = 0;
			for workload_base_index = 1:workload_base_num
				workload_base = workload_base_range(workload_base_index);
				tic;
				result{index}{workload_base_index} = algorithm_refer{i}(parameters{workload_base_index,1},parameters{workload_base_index,2},parameters{workload_base_index,3},parameters{workload_base_index,4},parameters{workload_base_index,5},parameters{workload_base_index,6},parameters{workload_base_index,7},s,n,seed);
				cur_runtime = cur_runtime + toc*1000;
			end
			run_time(index) = run_time(index) + cur_runtime/workload_base_num;

		end
	end

	disp("%%%%%%%%%%%%%%%%%%%%%% running time %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
	for i = 1:algorithm_num
		disp(algorithms_indexed{i});
		disp(run_time(i)/test_i);
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	for workload_base_index = 1:workload_base_num
		workload_base = workload_base_range(workload_base_index);
		disp("Evaluate result workload base is " + num2str(workload_base));
		for i = 1:algorithm_num
			if ~isempty(find(k_related_index == i, 1))
				delays(i,:,workload_base_index) = delays(i,:,workload_base_index) + evaluate_result(parameters{workload_base_index,1},parameters{workload_base_index,2},parameters{workload_base_index,3},parameters{workload_base_index,4},parameters{workload_base_index,5},parameters{workload_base_index,6},parameters{workload_base_index,7},s,n,k,result{i}{workload_base_index},seed);
			elseif i == random_algorithm_index
				cur_delay = zeros(1,delay_num);
				for random_i = 1:random_count
					cur_delay = cur_delay + evaluate_result(parameters{workload_base_index,1},parameters{workload_base_index,2},parameters{workload_base_index,3},parameters{workload_base_index,4},parameters{workload_base_index,5},parameters{workload_base_index,6},parameters{workload_base_index,7},s,n,k,result{i}{workload_base_index,random_i},seed);
				end
				delays(i,:,workload_base_index) = delays(i,:,workload_base_index) + cur_delay/random_count;
			else
				delays(i,:,workload_base_index) = delays(i,:,workload_base_index) + evaluate_result(parameters{workload_base_index,1},parameters{workload_base_index,2},parameters{workload_base_index,3},parameters{workload_base_index,4},parameters{workload_base_index,5},parameters{workload_base_index,6},parameters{workload_base_index,7},s,n,k,result{i}{workload_base_index},seed);
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







figure;
x1 = workload_base_range + workload_range/2;
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
title("total satisfied workload after worst breakdown with n = " + num2str(n) + " and s = " + num2str(s)+ " and seed = " + num2str(initial_seed))
legend1 = legend(axes1,'show');
set(legend1,'Location','northeast');
xlabel('average workload per task')
ylabel('total satisfied workload after worst breakdown (s)')


% figure;
% x2 = workload_base_range;
% X2 = repmat(x2,algorithm_num,1)';
% Y2 = squeeze(delays(:,2,:))';
% axes1 = axes;
% hold(axes1,'on');
% plot1 = plot(X2,Y2);
% NameArray = {'DisplayName','Color','Marker'};
% ValueArray = {'Algorithm1',[0.3010 0.7450 0.9330],'o';...
% 'optimal algorithm','k','d';...
% 'random algorithm','m','*';...
% 'greedy algorithm',[0.4660 0.6740 0.1880],'s';...
% 'TON 2017 algorithm','b','x';...
% 'Algorithm2','r','+';...
% 'TVT 2019 algorithm',[0.4940 0.1840 0.5560],'^';...
% 'INFOCOM 2017 algorithm',[0.6350 0.0780 0.1840],'v'
% };
% ValueArray = ValueArray(show_algorithm,:);
% set(plot1,NameArray,ValueArray);
% box(axes1,'on');
% title("total delay after greedy breakdown with n = " + num2str(n) + " and s = " + num2str(s))
% legend1 = legend(axes1,'show');
% set(legend1,'Location','northeast');
% xlabel('number of breakdown connection')
% ylabel('total delay after greedy breakdown (s)')
