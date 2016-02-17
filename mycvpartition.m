function [ ixtrain, ixtest ] = mycvpartition( N, K, ix )
% function [ ixtrain, ixtest ] = mycvpartition( N, K, ix )
%
% returns cell arrays containing indices for training and test sets
% 'ix' is optional: if it is provided, then the outputs will be referenced
% to the indices provided in 'ix'

ixtrain = cell( K, 1 );
ixtest = cell( K, 1 );
n = floor( N/K );

% create test set indices
for i = 1:K
    ixa = ( 1:n )' + ( i-1 )*n;
    ixtest{ i } = ixa;
end;

% distribute extra data randomly over test folds
r = N - n*K;
s = random_sample( r, K );
for i = 1:r
    ixtest{ s(i) } = [ ixtest{ s(i) }; n*K+i ];
end;

% create training set indices 
for i = 1:K
    ixb = setdiff( (1:N)', ixtest{ i } );
    ixtrain{ i } = ixb;
end;

% create final set of training and test set indices by indexing into a 
% randomized index set
s = random_sample( N, N );
for i = 1:K
    ixtrain{ i } = s( ixtrain{ i } );
    ixtest{ i } = s( ixtest{ i } );
end;

% reference indices to those provided in 'ix', if it has been provided
if(nargin==3 && ~isempty(ix))
    ixtrain0 = ixtrain;
    ixtest0 = ixtest;
    for i = 1:K
        ixtrain0{i} = ix(ixtrain{i});
        ixtest0{i} = ix(ixtest{i});
    end;
    ixtrain = ixtrain0;
    ixtest = ixtest0;
end;
