% GPDEMO4 GPTIPS 2 demo of multigene symbolic regression on a concrete compressive strength data set.
%
%   The output being modelled is concrete compressive strength (MPa) and
%   the input variables are:
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
%   Demonstrates feature selection in multigene symbolic regression and
%   some post run analysis functions.
%
%   (c) Dominic Searson 2009-2015
%
%   GPTIPS 2
%
%   See also GPDEMO4_CONFIG, GPDEMO1, GPDEMO2, GPDEMO4, PARETOREPORT,
%   GPMODELREPORT, DRAWTREES, SUMMARY, RUNTREE, GPPRETTY, POPBROWSER

clc;
disp('GPTIPS 2 Demo 4: feature selection with concrete compressive strength data set');
disp('------------------------------------------------------------------------------');
disp('The output being modelled is concrete compressive strength (MPa) and');
disp('the input variables are:');
disp(' ');
disp('   Cement (x1) - kg in a m3 mixture');
disp('   Blast furnace slag (x2) - kg in a m3 mixture');
disp('   Fly ash (x3) - kg in a m3 mixture');
disp('   Water (x4) - kg in a m3 mixture');
disp('   Superplasticiser (x5) - kg in a m3 mixture');
disp('   Coarse aggregate (x6) - kg in a m3 mixture');
disp('   Fine aggregate (x7) - kg in a m3 mixture');
disp('   Age (x8) - range 1 - 365 days');
disp(' ');
disp('To demonstrate feature selection in GPTIPS another 50 variables ');
disp('consisting of normally distributed noise have been added to form the');
disp('input variables x9 to x58.');
disp(' ');
disp('The configuration file is gpdemo4_config.m and the raw data is in');
disp('concrete.mat');
disp(' ');
disp('The data has been divided into a training set, a holdout validation set');
disp('and a testing set.');
disp(' ');
disp('GPTIPS is run twice for a maximum of 30 seconds per run or until a');
disp('RMSE of 6.5 is reached. The runs are merged into a single population');
disp('at the end.');
disp(' ');
disp('6 genes are used (plus a bias term) so the form of the model will be');
disp('ypred = c0 + c1*tree1 + ... + c6*tree6');
disp('where ypred = predicted output, c0 = bias and c1,...,c6 are the gene weights.')
disp(' ');
disp('Genes are limited to a depth of 4.');
disp(' ');
disp('The function nodes used are:');
disp('TIMES MINUS PLUS RDIVIDE SQUARE TANH EXP LOG MULT3 ADD3 SQRT CUBE');
disp('POWER NEGEXP NEG ABS');
disp(' ');
disp('The input variables that appear in the best model on the training');
disp('and validation data sets can be displayed at run time by ');
disp('including the following two settings in gpdemo4_config.m : ');
disp(' ');
disp('gp.runcontrol.showBestInputs = true;');
disp('gp.runcontrol.showValBestInputs = true;');
disp(' ');
disp('GPTIPS is run with the configuration in gpdemo4_config.m using :');
disp('>>gp=rungp(@gpdemo4_config);');
disp('Press a key to continue');
disp(' ');
pause;
gp = rungp(@gpdemo4_config);

%Run the best val individual of the run on the fitness function
disp(' ');
disp('Evaluate the best validation individual of');
disp('the runs on the fitness function using:');
disp('>>runtree(gp,''valbest'');');

disp('Press a key to continue');
disp(' ');
pause;
runtree(gp,'valbest');

%If Symbolic Math toolbox is present
if gp.info.toolbox.symbolic
    
    disp(' ');
    disp('Next, use the the GPPRETTY command on the best validation individual: ');
    disp('>>gppretty(gp,''valbest'')');
    disp('Press a key to continue');
    disp(' ');
    pause;
    
    gppretty(gp,'valbest');
    disp(' ');
    disp('If the runs have been successful, the only variables present in ');
    disp('the best validation model should be the following:');
    disp('Cement Slag Ash Water Plastic Course Fine Age');
    disp('(these are defined as variable name aliases in gpdemo4_config.m');
    disp('using the gp.nodes.inputs.names setting.)');
    disp(' ');
    disp('Less successful runs may contain the noise variables x9 - x58.');
    disp('If the results seem poor, try running the demo again.');
    
end

disp('Press a key to continue');
disp(' ');
pause;
disp('To visualise at the frequency distribution of input variables in all');
disp('models with an R^2 >= 0.75 the GPPOPVARS function can be used.');
disp('This should show a high frequency of variables x1 - x8 and a low');
disp('frequency of the irrelevant noise inputs.');
disp('>>gppopvars(gp,0.75);');
disp(' ');
disp('Press a key to continue');
disp(' ');
pause
gppopvars(gp,0.75);
disp(' ');

if gp.info.toolbox.symbolic
    disp('Finally, an HTML report listing the models on the Pareto optimal front');
    disp('of model expressional complexity and performance can be generated using');
    disp('the PARETOREPORT function.');
    disp('>>paretoreport(gp)');
    disp(' ');
    disp('Press a key to continue');
    disp(' ');
    pause;
    paretoreport(gp);
end