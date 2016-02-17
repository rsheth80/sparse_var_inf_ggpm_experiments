function ix=random_sample(n,N)
% function ix=random_sample( n, N )
% 
% Returns 'n' random indices of an 'N' x 1 sample (indices are unique)
%
% n:			requested number of indices [scalar integer]
% N:			total number of indices [scalar integer]
% ix:			indices ['n' x 1 array integer]

% original code used for icml paper (very slow for large N)

ix=[];
ixx=1:N;
while(n)
    u=rand;
    while(~u)
        u=rand;
    end;
    e=ixx(ceil(u*N));
    ix=[ix;e];
    ixx=setdiff(ixx,e);
    N=N-1;
    n=n-1;
end;
