function K = covPolytwo(hyp, x, z, i)

d = 2;
if(~nargin)
    K = covPoly(d);
elseif(nargin==1)
    K = covPoly(d,hyp);
elseif(nargin==2)
    K = covPoly(d,hyp,x);
elseif(nargin==3)
    K = covPoly(d,hyp,x,z);
else
    K = covPoly(d,hyp,x,z,i);
end;
