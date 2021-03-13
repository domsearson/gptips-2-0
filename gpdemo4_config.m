function gp = gpdemo4_config(gp)
%GPDEMO4_CONFIG Config file demonstrating feature selection with multigene symbolic regression.
%  
%   This is the configuration file that GPDEMO4 calls.   
%
%   GP = GPDEMO4_CONFIG(GP) generates a parameter structure GP that 
%   specifies the GPTIPS run settings.
%
%   Remarks:
%   The data used in this example was retrieved from the UCI Machine 
%   Learning Repository:
%    
%   http://archive.ics.uci.edu/ml/datasets/Concrete+Compressive+Strength
%
%   The output being modelled is concrete compressive strength (MPa) and the
%   independent variables are:
%
%   Cement (x1) - kg in a m3 mixture
%   Blast furnace slag (x2) - kg in a m3 mixture 
%   Fly ash (x3) - kg in a m3 mixture
%   Water (x4) - kg in a m3 mixture
%   Superplasticiser (x5) - kg in a m3 mixture
%   Coarse aggregate (x6) - kg in a m3 mixture 
%   Fine aggregate (x7) - kg in a m3 mixture
%   Age (x8) - range 1 - 365 days 
%   
%   Plus 50 irrelevant noise variables (x9 -> x58). 
% 
%   Example:
%
%   GP = RUNGP(@gpdemo4_config) uses this configuration file to perform 
%   symbolic regression with multiple gene individuals on the concrete data. 
%   The results and parameters used are stored in fields of the returned GP
%   structure.
%
%   Further remarks:
%
%   The demo configuration shows that variable selection is implicitly
%   performed by the GPTIPS algorithm.
%
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2
%
%   See also REGRESSMULTI_FITFUN, GPDEMO4, GPDEMO3 GPDEMO2, GPDEMO1, RUNGP

%run control
gp.runcontrol.pop_size = 300;				  
gp.runcontrol.num_gen = 500;				                  
gp.runcontrol.showBestInputs = true;
gp.runcontrol.showValBestInputs = true;
gp.runcontrol.timeout = 30;
gp.runcontrol.runs = 2;

%selection
gp.selection.tournament.size = 15;
gp.selection.elite_fraction = 0.3;

%fitness
gp.fitness.terminate = true;
gp.fitness.terminate_value = 7;

%multigene
gp.genes.max_genes = 6;

%constants
gp.nodes.const.p_ERC = 0.05;

%data
load concrete;

%allocate to train, validation and test groups
gp.userdata.xtrain = Concrete_Data(tr_ind,1:8);
gp.userdata.ytrain = Concrete_Data(tr_ind,9);

gp.userdata.ytest = Concrete_Data(te_ind,9);
gp.userdata.xtest = Concrete_Data(te_ind,1:8);

gp.userdata.xval = gp.userdata.xtrain(val_ind,1:8);
gp.userdata.yval = gp.userdata.ytrain(val_ind);

gp.userdata.xtrain = gp.userdata.xtrain(tr_ind2,:);
gp.userdata.ytrain = gp.userdata.ytrain(tr_ind2);

%add 100 noise variables to make problem harder in terms of feature
%selection
gp.userdata.xtrain = [gp.userdata.xtrain 100*randn(size(gp.userdata.xtrain,1),50) ];
gp.userdata.xtest = [gp.userdata.xtest 100*randn(size(gp.userdata.xtest,1),50) ];
gp.userdata.xval = [gp.userdata.xval 100*randn(size(gp.userdata.xval,1),50) ];

%enables hold out validation set
gp.userdata.user_fcn = @regressmulti_fitfun_validate; 

%give known variables aliases (this can include basic HTML markup)
gp.nodes.inputs.names = {'Cement','Slag','Ash','Water','Plastic','Course','Fine','Age'};

%name for dataset
gp.userdata.name = 'Concrete';                 

%define building block function nodes
gp.nodes.functions.name = {'times','minus','plus','rdivide','square','tanh',...
    'exp','log','mult3','add3','sqrt','cube','negexp','neg','abs'};