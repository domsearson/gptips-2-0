function gp = ripple_config(gp)
%RIPPLE_CONFIG Config file for multigene regression on the 2D Ripple function.
%  
%   GP = RIPPLE_CONFIG(GP) generates a parameter structure GP that
%   specifies the GPTIPS run settings for the 2D Ripple function. This is
%   a function f of two input variables as follows:
%
%   f(x1,x2) = (x1 - 3)(x2 - 3) + 2 sin((x1 - 4) (x2 - 4))
%
%   Note:
%
%   The settings in this file are not intended to be 'optimal'. Feel free
%   to experiment with them.
%
%   Example:
%
%   GP = RUNGP(@RIPPLE_CONFIG) uses this configuration file to perform
%   symbolic regression with multigene individuals.
%
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2
%
%   See also SALUSTOWICZ1D_CONFIG, UBALL_CONFIG, CUBIC_CONFIG,
%   REGRESSMULTI_FITFUN, RUNGP

%run control
gp.runcontrol.pop_size = 200;				  
gp.runcontrol.num_gen = 500;				   
gp.runcontrol.verbose = 5;                  
gp.runcontrol.timeout = 30;
gp.runcontrol.runs = 3;
gp.runcontrol.parallel.auto = true;

%selection
gp.selection.tournament.size = 20;
gp.selection.tournament.p_pareto = 0.2;
gp.selection.elite_fraction = 0.3;

%genes
gp.genes.max_genes = 8;   %increase this for more 'accurate' but more unwieldy models

%data
%generate 300 random training data points in the range 0.05 6.05
x = 0.05 + rand(300,2) * 6; 
y = (x(:,1)-3).*(x(:,2)-3) + 2*sin( (x(:,1)-4).*(x(:,2)-4)  );

gp.userdata.ytrain = y;
gp.userdata.xtrain = x;

%generate 1000 random test data
x = 0.05 + rand(1000,2) * 6; 
y = (x(:,1)-3).*(x(:,2)-3) + 2*sin( (x(:,1)-4).*(x(:,2)-4)  );

gp.userdata.ytest = y;
gp.userdata.xtest = x;

%generate holdout validation in same region as training space
x=0.05 + rand(200,2) * 6; 
y=(x(:,1)-3).*(x(:,2)-3) + 2*sin( (x(:,1)-4).*(x(:,2)-4)  );

gp.userdata.yval = y;
gp.userdata.xval = x;
gp.userdata.name = 'Ripple 2D';
gp.userdata.user_fcn = @regressmulti_fitfun_validate; 

%function nodes
gp.nodes.functions.name = {'times','minus','plus','rdivide','square',...
    'sin','cos','exp','mult3','add3','sqrt','cube','power','negexp','neg','abs','log'};