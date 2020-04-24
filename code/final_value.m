function [value] = final_value(workload,capacity,deploy_cost,data_rate,band,offload_flag,s,n,result)
	encode = @(x,y) x*n-n+y;
% 	f = zeros(n*n,1);
% 	for i = 1:n
% 		for j = 1:n
% 			f(encode(i,j)) = workload(i);
% 		end
%     end

    f = reshape(repmat(workload',[n,1]),[],1);
	f = -f;
	A = zeros(4*n,n*n);
	b = zeros(4*n,1);
	for i = 1:n
		A(i,encode(i,1):1:encode(i,n)) = 1;
	end
	b(1:n) = 1;

	for j = 1:n
		A(j+n,encode(1,j):n:encode(n,j)) = workload';
	end

	capacity_sum = zeros(n,1);
	for deploy = result'
		capacity_sum(deploy(2)) = capacity_sum(deploy(2)) + capacity(deploy(1));
	end
	b(n+1:n*2) = capacity_sum;

	for i = 1:n
		A(i+2*n,encode(i,1):1:encode(i,n)) = data_rate(i);
	end

	b(2*n+1:3*n) = band';

	for j = 1:n
		A(j+3*n,encode(1,j):n:encode(n,j)) = data_rate';
	end

	b(3*n+1:4*n) = band';

	Aeq = [];
	beq = [];

	lb = zeros(n*n,1);
	
    
%     ub = ones(n*n,1);
%     for i = 1:n
%         for j = 1:n
%             ub(encode(i,j)) = offload_flag(i,j);
%         end
%     end
    ub = reshape(offload_flag,[],1);
	options = optimoptions('linprog','Algorithm','interior-point','Display','none');
	[y,value] = linprog(f,A,b,Aeq,beq,lb,ub,options);
	value = -value;




end