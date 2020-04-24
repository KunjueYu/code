function [solution,value] = raw_value(workload,capacity,deploy_cost,data_rate,band,offload_flag,C_max,s,n,x_lower,x_upper)

	encode = @(x,y) x*n-n+y;
    %decode = @(x) [floor((x-1)/n)+1,mod(x-1,n)+1];
    f = zeros(n*n+n*s,1);
%     for i = 1:n
%         for j = 1:n
%             f(encode(i,j)) = workload(i);
%         end
%     end
    f(1:n*n) = reshape(repmat(workload',[n,1]),[],1);
    f = -f;
    A = zeros(4*n+s+1,n*n+n*s);
    b = zeros(4*n+s+1,1);
    for i = 1:n
        A(i,encode(i,1):1:encode(i,n)) = 1;
    end
    b(1:n) = 1;

    for j = 1:n
        A(j+n,encode(1,j):n:encode(n,j)) = workload';
        A(j+n,(encode(1,j)+n*n):n:(encode(s,j)+n*n)) = -capacity';
    end

    b(n+1:n*2) = 0;
    
	for i = 1:n
		A(i+2*n,encode(i,1):1:encode(i,n)) = data_rate(i);
	end

	b(2*n+1:3*n) = band';

	for j = 1:n
		A(j+3*n,encode(1,j):n:encode(n,j)) = data_rate';
	end

	b(3*n+1:4*n) = band';


    for i = 1:s
        A(i+4*n,encode(i,1)+n*n:1:encode(i,n)+n*n) = 1;
    end
    b(4*n+1:4*n+s) = 1;

%     for i = 1:s
%         for j = 1:n
%             A(4*n+s+1,encode(i,j)+n*n) = deploy_cost(i,j);
%         end
%     end
    A(4*n+s+1,1+n*n:n*s+n*n) = reshape(deploy_cost',1,[]);
    b(4*n+s+1) = C_max;

    Aeq = [];
    beq = [];

    lb = zeros(n*n+n*s,1);
    ub = ones(n*n+n*s,1);
%     for i = 1:n
%         for j = 1:n
%             ub(encode(i,j)) = offload_flag(i,j);
%         end
%     end
    ub(1:n*n) = reshape(offload_flag,[],1);
    lb(n*n+1:n*n+n*s) = x_lower;
    ub(n*n+1:n*n+n*s) = x_upper;

    options = optimoptions('linprog','Algorithm','interior-point','Display','none');
    [solution,value] = linprog(f,A,b,Aeq,beq,lb,ub,options);
    value = -value;
end
