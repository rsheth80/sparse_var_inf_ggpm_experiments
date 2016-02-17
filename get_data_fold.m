function [data_train,data_test] = get_data_fold(data,ixtrain,ixtest)
% function [data_train,data_test] = get_data_fold(data_true,ixtrain,ixtest)
%
% creates training/test sets

data_train.xt = data.x(ixtrain,:);
data_train.yt = data.y(ixtrain);
data_test.xs = data.x(ixtest,:);
data_test.ys = data.y(ixtest);
