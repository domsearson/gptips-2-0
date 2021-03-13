function x = gp_2d_mesh(x1,x2)
%GP_2D_MESH Creates new training matrix containing pairwise values of all x1 and x2.
%
%   X = GP_2D_MESH(X1,X2)
%
%   e.g. if X1 = [0 1]' and X2 = [5 6]' then
%
%   X = [0 5
%        0 6
%        1 5
%        1 6]
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2

%create a training "mesh" over the range spanned by x1 and x2
numx1 = length(x1);
numx2 = length(x2);
x=[];

for i = 1:numx1
    xtemp = ones(numx2,2);
    xtemp(:,1) = xtemp(:,1)*x1(i);
    xtemp(:,2) = x2;
    x = [x;xtemp];
end
