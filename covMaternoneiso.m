function K = covMaternoneiso(hyp, x, z, i)

d = 1;
if(~nargin)
    K = covMaterniso(d);
elseif(nargin==1)
    K = covMaterniso(d,hyp);
elseif(nargin==2)
    K = covMaterniso(d,hyp,x);
elseif(nargin==3)
    K = covMaterniso(d,hyp,x,z);
else
    K = covMaterniso(d,hyp,x,z,i);
end;

