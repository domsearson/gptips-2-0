function gp=gpdemo2_config(gp)
%GPDEMO2_CONFIG Config for multigene symbolic regression on data (y) generated from a non-linear function of 4 inputs (x1, x2, x3, x4).
%
%   GP = GPDEMO2_CONFIG(GP) returns a parameter structure GP containing the
%   settings for GPDEMO2.
% 
%   Remarks:
%
%   There is one output y which is a non-linear function of the four inputs
%   y = exp(2*x1*sin(pi*x4)) + sin(x2*x3). The objective of the GP run is
%   to evolve a multiple gene symbolic function of x1, x2, x3 and x4 that
%   closely approximates y.
%
%   This function was described by:
%
%   Cherkassky, V., Gehring, D., Mulier F, Comparison of adaptive methods
%   for function estimation from samples, IEEE Transactions on Neural
%   Networks, 7 (4), pp. 969- 984, 1996. (Function 10 in Appendix 1)
%   
%   Example:
%
%   GP = rungp(@gpdemo2_config) uses this configuration file to perform
%   symbolic regression with multiple gene individuals on the data from the
%   above function.
%
%   (C) Dominic Searson 2009-2015
% 
%   GPTIPS 2
%
%   See also GPDEMO2, GPDEMO3_CONFIG, GPDEM03, GPDEMO1, REGRESSMULTI_FITFUN

%run control parameters
gp.runcontrol.pop_size = 100;                     
gp.runcontrol.num_gen = 100;				                                                 
			
%selection
gp.selection.tournament.size = 6;

%termination
gp.fitness.terminate = true;
gp.fitness.terminate_value = 0.003;

%load in the raw x and y data
load demo2data 
gp.userdata.xtrain = x(101:500,:); %training set (inputs)
gp.userdata.ytrain = y(101:500,1); %training set (output)
gp.userdata.xtest = x(1:100,:); %testing set (inputs)
gp.userdata.ytest = y(1:100,1); %testing set (output)
gp.userdata.name = 'Cherkassky function';

%genes
gp.genes.max_genes = 3;                   

%define function nodes
gp.nodes.functions.name = {'times','minus','plus','sqrt','square','sin','cos','exp','add3','mult3'};