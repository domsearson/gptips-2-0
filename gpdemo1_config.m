function gp = gpdemo1_config(gp)
%GPDEMO1_CONFIG Config file demonstrating simple (naive) symbolic regression.
%
%   The simple quartic polynomial (y=x+x^2+x^3+x^4) from John Koza's 1992
%   Genetic Programming book is used. It is very easy to solve.
%
%   GP = GPDEMO1_CONFIG(GP) returns the user specified parameter structure
%   GP for the quartic polynomial problem.
%   
%   Example:
%
%   GP = GPTIPS(@GPDEMO1_CONFIG) performs a GPTIPS run using this
%   configuration file and returns the results in a structure called GP.
%
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2
% 
%   See also QUARTIC_FITFUN, GPDEMO1

%run control
gp.runcontrol.pop_size = 50;			
gp.runcontrol.num_gen = 100;			                                 
gp.runcontrol.verbose = 25;    

%selection
gp.selection.tournament.size = 2;        

%fitness function
gp.fitness.fitfun = @quartic_fitfun;           

%quartic polynomial data  
x=linspace(-1,1,20)'; 
gp.userdata.x = x;
gp.userdata.y = x + x.^2 +x.^3 + x.^4; 
gp.userdata.name = 'Quartic Polynomial';

%input configuration 
gp.nodes.inputs.num_inp = 1; 		         

%quartic example doesn't need constants
gp.nodes.const.p_ERC = 0;		              

%maximum depth of trees 
gp.treedef.max_depth = 12; 
 	              
%maximum depth of sub-trees created by mutation operator
gp.treedef.max_mutate_depth = 7;

%genes
gp.genes.multigene = false;

%define function nodes
gp.nodes.functions.name = {'times','minus','plus','rdivide'};