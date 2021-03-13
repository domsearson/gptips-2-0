function gp = uball_config(gp)
%UBALL_CONFIG Multigene regression config for the n dimensional Unwrapped Ball function.
%  
%   GP = UBALL_CONFIG(GP) generates a parameter structure GP that specifies
%   the GPTIPS run settings.
%
%   Example:
%
%   GP = RUNGP(@UBALL_CONFIG) uses this configuration file to perform
%   symbolic regression with multigene individuals.
%
%   Remarks:
%
%   The 5D version of this function was proposed as a 'standardised' GP
%   symbolic regression benchmark (Vladislavleva-4) in White et al.,
%   'Better GP benchmarks: community survey results and proposals', Genet.
%   Program Evolvable Mach. (2013) 14:3:29 (Table 4).
%
%   It is unusual in that the test data in the above reference requires
%   extrapolation beyond the bounds of the training data.
%
%   (C) Dominic Searson 2009-2015
%
%   GPTIPS 2
%
%   See also SALUSTOWICZ1D_CONFIG, RIPPLE_CONFIG, CUBIC_CONFIG,
%   REGRESSMULTI_FITFUN, RUNGP

%run control
gp.runcontrol.pop_size = 200;				  
gp.runcontrol.num_gen = 1000;				   
gp.runcontrol.verbose = 5;                  
gp.runcontrol.timeout = 45;
gp.runcontrol.runs = 3 ;
gp.runcontrol.parallel.auto = true;
gp.selection.elite_fraction = 0.25;

%selection
gp.selection.tournament.size = 20;
gp.selection.tournament.p_pareto = 0.2; 

%genes           
gp.genes.max_genes = 8;     
gp.treedef.max_depth = 5;

%set dimension of problem
n = 5;

%training data
%generate 512 n dimensional data points in the range [0.05 6.05]
x = 0.05 + rand(512,n)*6; 

dsum = 0;
for i=1:n
   dsum = dsum + (( x(:,i)- 3 ).^2); 
end
y = 10./(5+dsum);

gp.userdata.ytrain = y;
gp.userdata.xtrain = x;

%testing data
%generate 512 test data inside the training range
x = 0.05 + rand(512,n)*6; 

dsum = 0;
for i=1:n
   dsum = dsum + (( x(:,i)- 3 ).^2); 
end
y = 10./(5+dsum);

gp.userdata.ytest = y;
gp.userdata.xtest = x;

%validation data
%generate holdout validation in same region as training space
x = 0.05 + rand(512,n)*6; 

dsum = 0;
for i=1:n
   dsum = dsum + (( x(:,i)- 3 ).^2); 
end
y = 10./(5+dsum);

gp.userdata.yval = y;
gp.userdata.xval = x;

%enables hold out validation set
gp.userdata.user_fcn = @regressmulti_fitfun_validate;

%Add a name to data set
gp.userdata.name = ['Uball (n = ' num2str(n) ')'];

%function nodes
gp.nodes.functions.name = {'times','minus','plus','rdivide','square','sin',...
    'cos','cube','exp','power','sqrt','add3','mult3','log','negexp','abs','neg'};