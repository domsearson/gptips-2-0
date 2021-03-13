% GPDEMO3 GPTIPS 2 demo of multigene symbolic regression on non-linear simulated pH data.
%
%   Demonstrates multigene symbolic regression and some post run analysis
%   functions such as SUMMARY and RUNTREE and the use of the Symbolic Math
%   Toolbox to simplify expressions and create HTML reports using
%   PARETOREPORT, GPMODELREPORT and DRAWTREES to visualise the models.
%
%   (c) Dominic Searson 2009-2015
%
%   GPTIPS 2
%
%   See also GPDEMO3_CONFIG, GPDEMO1, GPDEMO2, GPDEMO4, PARETOREPORT,
%   GPMODELREPORT, DRAWTREES, SUMMARY, RUNTREE, GPPRETTY, POPBROWSER

clc;
disp('GPTIPS 2 Demo 3: multigene pareto symbolic regression on pH data');
disp('------------------------------------------------------------------');
disp('In this example, the training data is 700 steady state data points');
disp('from a simulation of a pH neutralisation process.');
disp(' ' );
disp('Here we use use pareto tournaments to bias the model discovery process');
disp('towards low complexity models.');
disp(' ');
disp('GPTIPS is run 3 times for a maximum of 10 seconds per run or until a');
disp('RMSE of 0.2 is reached. The runs are merged into a single population');
disp('at the end.');
disp(' ');
disp('The output y has an unknown non-linear dependence on the 4 inputs x1,');
disp('x2, x3 and x4.');
disp(' ');
disp('300 data points are available as a test set to validate the evolved model(s).');
disp('');
disp('The configuration file is gpdemo3_config.m and the raw data is in ph2data.mat');
disp(' ');
disp('Here, 6 genes are used (plus a bias term) so the form of the model will be');
disp('ypred = c0 + c1*tree1 + ... + c6*tree6');
disp('where ypred = predicted output, c0 = bias and c1,...,c6 are the gene weights.')
disp(' ');
disp('Genes are limited to a depth of 4.');
disp(' ');
disp('The function nodes used are:  TIMES MINUS PLUS TANH MULT3 ADD3');
disp(' ');
disp('First, run GPTIPS using the configuration in gpdemo3_config.m :');
disp('>>gp=rungp(@gpdemo3_config);');
disp('Press a key to continue');
disp(' ');
pause;

%run GPTIPS using the configuration in gpdemo3_config.m
gp = rungp(@gpdemo3_config);

%run the best individual of the run on the fitness function
disp(' ');
disp('Evaluate the ''best'' individual of the run using:');
disp('>>runtree(gp,''best'');');

disp('Press a key to continue');disp(' ');pause;
runtree(gp,'best');

%run the best individual of the run on the fitness function
disp(' ');
disp('Next, display the population in terms of performance and complexity.');
disp('Because pareto tournaments have been enabled you should notice a');
disp('''well-defined'' pareto front (green circles).');
disp('This should indicate good models in terms of the performance/complexity');
disp('tradeoff rather than simply the ''best'' model on the training data (this');
disp('may be considerably more complex than very slightly ''lower'' performing');
disp('models.');
disp('>>popbrowser(gp);');

disp('Press a key to continue');disp(' ');pause;
popbrowser(gp);

%If Symbolic Math toolbox is present
if gp.info.toolbox.symbolic
   
    %pareto report
    disp(' ');
    disp('The PARETOREPORT function generates a standalone interactive HTML report');
    disp('listing the multigene regression models on the Pareto front in terms');
    disp('of their simplified equation structure, expressional complexity and'); 
    disp('performance on the training data (R2).');
    disp('These models correspond to the green circles in the popbrowser');
    disp('visualisation and can be sorted by performance or complexity by'); 
    disp('clicking on the appropriate column header.');
    disp('>>paretoreport(gp);');
    disp('Press a key to continue');disp(' ');pause;
    paretoreport(gp);
    
    %gppretty
    disp(' ');
    disp('It is possible to display any multigene model at the command line.');
    disp('E.g. to use the GPPRETTY command on the ''best'' model on the training data: ');
    disp('>>gppretty(gp,''best'')');
    disp('Press a key to continue');
    disp(' ');
    pause;
    gppretty(gp,'best');
end
disp(' ');
disp('Additionally, the DRAWTREES function can be used to draw the genes in any');
disp('model to a browser window.');
disp('E.g. to draw the genes in the ''best'' model on the training data use');
disp('>>drawtrees(gp,''best'');');
disp('Press a key to continue');disp(' ');pause;
drawtrees(gp,'best');

%reports
if gp.info.toolbox.symbolic
   
    disp(' ');
    disp('Finally, for multigene models the GPMODELREPORT function can be ');
    disp('used to generate a comprehensive model performance report for ');
    disp('reference purposes. This is created in a browser window.');
    disp('E.g. to generate a performance report for the ''best'' model');
    disp('on the training data use');
    disp('>>gpmodelreport(gp,''best'');');
    disp('Press a key to continue');disp(' ');pause;
    gpmodelreport(gp,'best');
end