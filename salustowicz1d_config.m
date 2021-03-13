function gp=salustowicz1d_config(gp)
%SALUSTOWICZ1D_CONFIG Multigene regression config for one dimensional Salustowicz function.
%
%   GP = SALUSTOWICZ1D_CONFIG(GP) generates a parameter structure GP that
%   specifies the GPTIPS run settings for the one dimensional Salustowicz
%   function . This is a function f of a single input variable as follows:
%
%   f(x) = exp(-x) x^3 cos(x) sin(x) (sin(x)^2 cos(x) - 1)
%
%   Example:
%
%   GP = RUNGP(@SALUSTOWICZ1D_CONFIG) uses this configuration file to
%   perform symbolic regression on the data with multigene individuals.
%
%   Note:
%
%   The settings in this file are not intended to be 'optimal'. Feel free
%   to experiment with them.
%
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2
%
%   See also RIPPLE_CONFIG, UBALL_CONFIG, CUBIC_CONFIG,
%   REGRESSMULTI_FITFUN, RUNGP

%run control
gp.runcontrol.pop_size = 200;				  				                    
gp.runcontrol.timeout = 30;
gp.runcontrol.num_gen = 500;
gp.runcontrol.runs = 3;
gp.runcontrol.parallel.auto = true;

%selection
gp.selection.tournament.size = 20;
gp.selection.tournament.p_pareto = 0.3;
gp.selection.elite_fraction = 0.3;

%meta data
gp.userdata.name = 'Salustowicz - 1D';
         
%genes            
gp.genes.max_genes = 6;  

%generate training data
x = [0.05:0.2:10]'; %generate training points in range [0.05 10]
gp.userdata.xtrain = x;
sx = sin(x);
cx = cos(x);
gp.userdata.ytrain = exp(-x) .* (x.^3) .*sx .* cx .* ((sx.^2) .*cx -1);

%generate random test data in same range
x = rand(500,1) * 9.95 + 0.05;
sx = sin(x);
cx = cos(x);
gp.userdata.ytest = exp(-x) .* (x.^3) .*sx .* cx .* ((sx.^2) .*cx -1);
gp.userdata.xtest = x;

%function nodes
gp.nodes.functions.name = {'times','minus','plus','rdivide','square','sin',...
    'cos','exp','power','cube','sqrt','add3','mult3','negexp','neg','abs'};
