%GPDEMO2 GPTIPS 2 demo of multigene regression on a non-linear function.
%
%   Demonstrates multigene symbolic regression and some post run analysis
%   functions such as SUMMARY, RUNTREE, POPBROWSER, DRAWTREES and the use
%   of the Symbolic Math Toolbox with GPPRETTY to simplify expressions.
%
%   (c) Dominic Searson 2009-2015
%
%   GPTIPS 2
%
%   See also GPDEMO2_CONFIG, REGRESSMULTI_FITFUN, GPDEMO1, GPDEMO3,
%   GPDEMO4, DRAWTREES, SUMMARY, RUNTREE, GPPRETTY, POPBROWSER

clc;
disp('GPTIPS 2 Demo 2: multigene symbolic regression');
disp('----------------------------------------------');
disp('Multigene regression on 400 data points genenerated by the non-linear');
disp('function with 4 inputs y = exp(2*x1*sin(pi*x4)) + sin(x2*x3).');
disp(' ');
disp('The configuration file is gpdemo2_config.m and the raw data is in demo2data.mat');
disp('At the end of the run the predictions of the evolved model will be plotted');
disp('for the training data as well as for an independent test data set generated');
disp('from the same function.');
disp(' ');
disp('Here, 3 genes are used (plus a bias term) so the form of the model will be: ');
disp('ypred = c0 + c1*tree1 + c2*tree2 + c3*tree3');
disp('where c0 = bias and c1, c2 and c3 are the gene weights.');
disp(' ');
disp('The bias and weights (i.e. regression coefficients) are automatically');
disp('determined by a least squares procedure for each multigene model.');
disp(' ');
disp('In this run the following function nodes are used: ');
disp('TIMES MINUS PLUS SQRT SQUARE SIN COS EXP ADD3 MULT3');
disp(' ');
disp('The run is configured to proceed for 100 generations or to terminate');
disp('when a fitness (RMSE) of 0.003 is achieved.');
disp(' ');
disp('First, run GPTIPS using the configuration in gpdemo2_config.m');
disp('>>gp = rungp(@gpdemo2_config);');
disp('Press a key to continue');
disp(' ');pause;
gp = rungp(@gpdemo2_config);

disp('Plot summary information of run using');
disp('>>summary(gp)');

disp('Press a key to continue');
disp(' ');pause;summary(gp);

disp('Run the best model on the training data using:');
disp('>>runtree(gp,''best'');');

disp('Press a key to continue');
disp(' ');pause;runtree(gp,'best');

%If Symbolic Math toolbox is present
if gp.info.toolbox.symbolic
    disp('Using the symbolic math toolbox it is possible to combine the gene');
    disp('expressions with the gene weights (regression coefficients) to display');
    disp('a single overall model that predicts the output using the inputs x1,');
    disp('x2, x3 and x4.');
    disp('E.g. using the the GPPRETTY function on the best individual on ');
    disp('the training data.');
    disp('>>gppretty(gp,''best'')');
    disp('Press a key to continue');
    disp(' ');
    pause;
    gppretty(gp,'best');
    disp(' ');
    disp('Additionally, the DRAWTREES function can be used to draw the genes in any'); 
    disp('model to a browser window.');
    disp('E.g. to draw the genes in the ''best'' model on the training data use'); 
    disp('>>drawtrees(gp,''best'');');
    disp('Press a key to continue');disp(' ');pause;
    drawtrees(gp,'best');
end

disp(' ');
disp('The POPBROWSER function may be used to display the population of evolved');
disp('models in terms of their expressional complexity as well as their');
disp('performance (1 - R^2).');
disp('POPBROWSER can be used to identify models that perform relatively well');
disp('and are less complex than the ''best'' model in the population (which is');
disp('highlighted with a red circle). Clicking on a circle reveals the');
disp('model ID as well as its simplified symbolic equation (if the Symbolic.');
disp('Math toolbox is installed.');
disp('The POPBROWSER is launched using:');
disp('>>popbrowser(gp)');
disp('Press a key to continue.');
pause;
popbrowser(gp);