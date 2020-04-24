function [workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max] = get_parameter(workload_base,workload_range,capacity_base,capacity_range,n,s,seed)



%INFOCOM 2019 [3-5]*[0.5,1]

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






end

