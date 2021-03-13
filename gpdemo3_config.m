function gp = gpdemo3_config(gp)
%GPDEMO3_CONFIG Config file demonstrating multigene symbolic regression on data from a simulated pH neutralisation process.
%  
%   This is the configuration file that GPDEMO3 calls.   
%
%   GP = GPDEMO3_CONFIG(GP) generates a parameter structure GP that 
%   specifies the GPTIPS run settings.
%
%   In this example, a maximum run time of 10 seconds is allowed (3 runs).
%
%   Remarks:
%   The data in this example is taken a simulation of a pH neutralisation
%   process with one output (pH), which is a non-linear function of the 
%   four inputs.
%
%   Example:
%   GP = RUNGP(@GPDEMO3_CONFIG) uses this configuration file to perform 
%   symbolic regression with multiple gene individuals on the pH data. The 
%   results and parameters used are stored in fields of the returned GP 
%   structure.
%
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2
%
%   See also REGRESSMULTI_FITFUN, GPDEMO3, GPDEMO2, GPDEMO1, RUNGP

%run control parameters
gp.runcontrol.pop_size = 250;				                  				   
gp.runcontrol.timeout = 10;
gp.runcontrol.runs = 3;

%selection
gp.selection.tournament.size = 25;
gp.selection.tournament.p_pareto = 0.7; 
gp.selection.elite_fraction = 0.7;
gp.nodes.const.p_int= 0.5; 

%fitness 
gp.fitness.terminate = true;
gp.fitness.terminate_value = 0.2;

%set up user data 
load ph2data 

gp.userdata.xtest = nx; %testing set (inputs)
gp.userdata.ytest = ny; %testing set (output)
gp.userdata.xtrain = x; %training set (inputs)
gp.userdata.ytrain = y; %training set (output)
gp.userdata.name = 'pH';

%genes
gp.genes.max_genes = 6;

%define building block function nodes
gp.nodes.functions.name = {'times','minus','plus','tanh','mult3','add3'};