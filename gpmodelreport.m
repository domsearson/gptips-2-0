function gpmodelreport(gp,ID,reportName,nobrowser)
%GPMODELREPORT Generate an HTML report on the specified multigene regression model.
%
%   The generated standalone HTML report contains a variety of run
%   information, model performance metrics, performance graphs and the tree
%   structure of the specified regression model.
%
%   GPMODELREPORT(GP,ID) generates a report called modelreport.htm for the
%   model with numeric identifier ID in the GPTIPS datastructure GP.
%
%   GPMODELREPORT(GP,ID,'REPORTNAME') generates a report called REPORTNAME
%   for the model with numeric identifier ID in the GPTIPS datastructure
%   GP.
%
%   GPMODELREPORT(GP,'best') generates a report for the best model of the
%   run (as evaluated on training data).
%
%   GPMODELREPORT(GP,'valbest') generates a report for the model that
%   performed best on the validation data (if this data exists).
%
%   GPMODELREPORT(GP,'testbest') generates a report for the model that
%   performed best on the test data (if this data exists).
%
%   GPMODELREPORT(GP,GPMODEL) generates a report for the GPMODEL struct
%   representing a multigene regression model, i.e. the struct returned by
%   the functions GPMODEL2STRUCT or GENES2GPMODEL.
%
%   GPMODELREPORT(GP,'testbest',[],NOBROWSER) where NOBROWSER is TRUE does
%   not attempt to open the report in the system browser.
%
%   Remarks:
%
%   Assumes the fitness function REGRESSMULTI_FITFUN has been used in the
%   run (i.e. multigene symbolic regression).
%
%   This function connects to the Google Visualization API and hence
%   internet connectivity is required for all report features to be
%   displayed correctly.
%
%   For the paranoid:
%
%   According to Google: "All code and data are processed and rendered in
%   the browser. No data is sent to any server."
%
%   For details see:
%
%   https://developers.google.com/chart/interactive/docs/index
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also PARETOREPORT, DRAWTREES, GPPRETTY, GPMODEL2MFILE, GPMODEL2SYM,
%   GPMODEL2STRUCT, GPMODEL2FUNC

if nargin < 2
    disp('Basic usage is GPMODELREPORT(GP,ID) where ID is a model identifier or');
    disp('GPMODELREPORT(GP,''BEST'') or');
    disp('GPMODELREPORT(GP,''VALBEST'') or');
    disp('GPMODELREPORT(GP,''TESTBEST'')');
    return;
end

if isa(ID,'struct') && isfield(ID,'valid')
    gpmodel = ID;
else
    %get model data from supplied selector
    disp('Simplifying model ...');
    gpmodel = gpmodel2struct(gp,ID);
end

if ~gpmodel.valid
    error(['Cannot generate a report for this model because it is invalid. Reason: ' gpmodel.invalidReason]);
end

if nargin < 3 || isempty(reportName)
    reportName = 'modelreport';
end

if nargin < 4 || isempty(nobrowser)
    nobrowser = false;
end

%create an html file
if ~ischar(reportName)
    error('The reportname parameter must be a string.');
end
    
htmlFileName = [reportName '.htm'];
fid = fopen(htmlFileName,'wt+');

if fid == -1
    error(['Could not open the file ' htmlFileName ' for writing.']);
end

%html header info
fprintf(fid,'<!DOCTYPE html>\n');
fprintf(fid,'<html lang="en">\n');
fprintf(fid,'<head>\n');
fprintf(fid,'<meta http-equiv="content-type" content="text/html; charset=utf-8" name="description" content="GPTIPS 2 Multigene model performance report" name="author" content="Dominic Searson"/>\n');

setStr = '';
if ~isempty(gp.userdata.name)
    setStr = [' Data: ' gp.userdata.name];
end

if nargin < 3
    fprintf(fid,['<title>GPTIPS model report.' setStr '</title>\n']);
else
    fprintf(fid,['<title>GPTIPS model report: ' reportName '</title>\n']);
end
fprintf(fid,'<script type="text/javascript" src="http://www.google.com/jsapi"></script>\n');

%load table & charts vis from Google
fprintf(fid,'<script type="text/javascript">google.load(''visualization'', ''1'', {packages: [''table'']});\n');
fprintf(fid,'google.load(''visualization'', ''1'', {packages: [''orgchart'']});');
fprintf(fid,'google.load(''visualization'', ''1'', {packages: [''corechart'']});');
fprintf(fid,'</script>\n');

fprintf(fid,'<link href=''http://fonts.googleapis.com/css?family=Open+Sans'' rel=''stylesheet'' type=''text/css''>');

%visualization scripts
disp('Generating visualisations ...');
reportStyles(fid);
configTableJS(fid,gp);
trainPerformanceTableJS(fid,gpmodel);
processOrgChartJS(fid,gp,gpmodel);
runVarsTableJS(fid,gp);
trainPredictionsChartJS(fid,gp,gpmodel);
trainScatterChartJS(fid,gp,gpmodel);

if gp.info.toolbox.symbolic
fullModelSymTableJS(fid,gpmodel,gp);
geneSymTableJS(fid,gpmodel,gp);
end

structPropertiesTableJS(fid,gp,gpmodel);
geneWeightsChartJS(fid,gpmodel);

if ~gpmodel.val.warning
    valPredictionsChartJS(fid,gp,gpmodel);
    valScatterChartJS(fid,gp,gpmodel);
    valPerformanceJS(fid,gpmodel);
end

if ~gpmodel.test.warning
    testPerformanceTableJS(fid,gpmodel);
    testPredictionsChartJS(fid,gp,gpmodel);
    testScatterChartJS(fid,gp,gpmodel);
end
fprintf(fid,'</head>\n');

%report body
fprintf(fid,'<body style="font-family: ''Open Sans'',''Helvetica Neue'', Helvetica, Arial, sans-serif; border: 0;">\n');
fprintf(fid,'<div style="text-align: left;margin-bottom: 50px;margin-top: 50px;margin-left: 15px;">');

if nargin < 3
    fprintf(fid,'<h2>GPTIPS model report</h2>\n');
else
    fprintf(fid,['<h2>">GPTIPS model report: '  reportName '</h2>\n']);
end

if isnumeric(ID) && ID > 0 && ID <= gp.runcontrol.pop_size
    fprintf(fid,['<p class="text">For model with ID: ' int2str(ID) '</p>\n']);
elseif strcmpi(ID,'best')
    fprintf(fid,'<p class="text">For best model on training data.</p>\n');
elseif strcmpi(ID,'valbest');
    fprintf(fid,'<p class="text">For best model on validation data.</p>\n');
elseif strcmpi(ID,'testbest');
    fprintf(fid,'<p class="text">For best model on test data.</p>\n');
elseif isstruct(ID) && isfield(ID,'source') && ...
        (strcmp(ID.source,'gpmodel2struct') || strcmp(ID.source,'genes2gpmodel'))
    fprintf(fid,'<p class="text">For user supplied model struct.</p>\n');
end
fprintf(fid,['<p class="date">' datestr(now) '</p>\n']);

%table containing basic run info
fprintf(fid,'<h3>Configuration</h3>\n');
fprintf(fid,'<div id="configtable"></div>\n');

%table containing main control params
if gp.info.merged
    fprintf(fid,'<h3>Run parameters (run 1)</h3>\n');
else
    fprintf(fid,'<h3>Run parameters</h3>\n');
end
fprintf(fid,'<div id="runtable"></div>\n');

%table to hold overall simplified model (reqs symbolic math toolbox)
fprintf(fid,'<h3>Overall model</h3>\n');
if gp.info.toolbox.symbolic
    
    fprintf(fid,'<p class="text">Overall model after simplification. Numerical precision reduced for display purposes.</p>\n');
    fprintf(fid,'<div id="fullmodel_table"></div>\n');
    
    %table to hold individual model terms (reqs symbolic math toolbox)
    fprintf(fid,'<h3>Individual genes/model terms</h3>\n');
    fprintf(fid,'<p class="text">Each gene includes its weighting coefficient. Numerical precision reduced for display purposes.</p>\n');
    fprintf(fid,'<div id ="genes_table"></div>\n');
else
   fprintf(fid,'<p class="warn">Note: no model equations are displayed because the Symbolic Math toolbox is not installed.</p>\n'); 
end

fprintf(fid,'<div id ="gene_colchart"></div>\n');

%model performance tables
fprintf(fid,'<h3>Model performance</h3>\n');
fprintf(fid,'<p class="text">Performance metrics for the model.</p>\n');
fprintf(fid,'<p class="text">R<sup>2</sup> - goodness of fit (coefficient of determination).</p>\n');
fprintf(fid,'<p class="text">RMSE - root mean squared error.</p>\n');
fprintf(fid,'<p class="text">MAE - mean absolute error.</p>\n');
fprintf(fid,'<p>SSE - sum of squared errors.</p>\n');
fprintf(fid,'<p>MSE - mean squared error.</p>\n');

%warnings for validation data
if gpmodel.val.warning
    fprintf(fid,['<p class="warn">Note: no validation predictions are displayed because ' lower(gpmodel.val.warningReason) '</p>\n']);
end

%warnings for test data
if gpmodel.test.warning
    fprintf(fid,['<p class="warn">Note: no test data predictions are displayed because ' lower(gpmodel.test.warningReason) '</p>\n']);
end

fprintf(fid,'<p><b>Training Data</b></p>\n');
fprintf(fid,'<div id ="perf_train_table"></div>\n');

if ~gpmodel.val.warning
    fprintf(fid,'<p><b>Validation Data</b></p>\n');
    fprintf(fid,'<div id ="perf_val_table"></div>\n');
end

if ~gpmodel.test.warning
    fprintf(fid,'<p><b>Test Data</b></p>\n');
    fprintf(fid,'<div id ="perf_test_table"></div>\n');
end
%end of model performance tables

%model structural properties table
fprintf(fid,'<h3>Model properties</h3>\n');
fprintf(fid,'<p>Structural properties relating to GP tree representation.</p>\n');
fprintf(fid,'<div id ="structtable"></div>\n');

%model prediction charts
fprintf(fid,'<h3>Model predictions and actual outputs</h3>');
fprintf(fid,'<p>Graphs showing model predictions and actual values. Click and drag to zoom.</p>');
fprintf(fid,'<div id="trainpreds"></div>\n');
fprintf(fid,'<div id="trainvizpng"></div>\n');
fprintf(fid,'<div id="valpreds"></div>\n');
fprintf(fid,'<div id="testpreds"></div>\n');

%scatter charts
fprintf(fid,'<h3>Scatterplots (predicted vs actuals)</h3>');
fprintf(fid,'<p>Good predictions are those close to the identity line (shown in black). Click and drag to zoom.</p>');
fprintf(fid,'<div id="trainscatter"></div>\n');
fprintf(fid,'<div id="valscatter"></div>\n');
fprintf(fid,'<div id="testscatter"></div>\n');
fprintf(fid,'<h3>Gene tree structures</h3>\n');
fprintf(fid,'<p>Tree structure of the individual genes that comprise the model.</p>\n');

%gene tree structures
for n=1:gpmodel.genes.num_genes
    fprintf(fid,'<table>'); fprintf(fid,'<tr>');
    fprintf(fid,'<td style="text-align:center;">');
    fprintf(fid,['<p>Gene ' int2str(n) '</p>\n']); fprintf(fid,'</td>');fprintf(fid,'</tr>');
    fprintf(fid,'<tr>'); fprintf(fid,'<td>');
    fprintf(fid,['<div id="tree' int2str(n) '" style="width: 300px;"></div>\n']);
    fprintf(fid,'</td>'); fprintf(fid,'</tr>');
    fprintf(fid,'</table>');
end

%footer & close
fprintf(fid,'<p style="color:gray;text-align:center;margin-top: 50px;">GPTIPS - the symbolic data mining platform for MATLAB</p>');
fprintf(fid,'<p style="color:gray;text-align:center;">&#169; Dominic Searson 2009-2015</p>');

fprintf(fid,'</div>');fprintf(fid,'</body>\n');fprintf(fid,'</html>\n');
fclose(fid);

disp(['Model report created in ' reportName '.htm']);

if ~nobrowser
    disp('Opening report in system browser.');
    web(htmlFileName,'-browser');
end

function configTableJS(fid,gp)
%javascript for main run config table

fprintf(fid,'\n<script type="text/javascript">\n');
fprintf(fid,'function drawConfigTable() {\n');
fprintf(fid,'var configdata = new google.visualization.DataTable();\n');
fprintf(fid,'configdata.addColumn(''string'',''Run parameter'');\n');
fprintf(fid,'configdata.addColumn(''string'',''Value'');\n');
fprintf(fid,'configdata.addRows(11);\n');

fprintf(fid,'configdata.setCell(0, 0, ''<p class="table">Config file</p>'');\n');
fprintf(fid,['configdata.setCell(0, 1, ''<p class="table">' char(gp.info.configFile) '</p>'');\n']);

fprintf(fid,'configdata.setCell(1, 0, ''<p class="table">Fitness function</p>'');\n');
fprintf(fid,['configdata.setCell(1, 1, ''<p class="table">' char(gp.fitness.fitfun) '</p>'');\n']);

fprintf(fid,'configdata.setCell(2, 0, ''<p class="table">Generational user function</p>'');\n');

if isempty(gp.userdata.user_fcn)
    fprintf(fid,'configdata.setCell(2, 1, ''<p class="table">None</p>'');\n');
else
    fprintf(fid,['configdata.setCell(2, 1, ''<p class="table">' char(gp.userdata.user_fcn) '</p>'');\n']);
end

fprintf(fid,'configdata.setCell(3, 0, ''<p class="table">Data set</p>'');\n');

if isempty(gp.userdata.name)
    fprintf(fid,'configdata.setCell(3, 1, ''<p class="table">Unspecified</p>'');\n');
else
    fprintf(fid,['configdata.setCell(3, 1, ''<p class="table">' gp.userdata.name '</p>'');\n']);
end

fprintf(fid,'configdata.setCell(4, 0, ''<p class="table">Parallel mode</p>'');\n');

if gp.runcontrol.parallel.auto
    fprintf(fid,'configdata.setCell(4, 1, ''<p class="table">Auto<p>'');\n');
elseif gp.runcontrol.parallel.enable
    fprintf(fid,'configdata.setCell(4, 1, ''<p class="table">Manual<p>'');\n');
else
    fprintf(fid,'configdata.setCell(4, 1, ''<p class="table">Off</p>'');\n');
end

fprintf(fid,'configdata.setCell(5, 0, ''<p class="table">Parallel workers</p>'');\n');
if gp.runcontrol.parallel.enable && gp.runcontrol.parallel.ok
    fprintf(fid,['configdata.setCell(5, 1, ''<p class="table">' int2str(gp.runcontrol.parallel.numWorkers) '</p>'');\n']);
else
    fprintf(fid,'configdata.setCell(5, 1, ''<p class="table">0</p>'');\n');
end

fprintf(fid,'configdata.setCell(6, 0, ''<p class="table">Fitness cache</p>'');\n');
if gp.runcontrol.usecache
    fprintf(fid,'configdata.setCell(6, 1, ''<p class="table">Enabled<p>'');\n');
else
    fprintf(fid,'configdata.setCell(6, 1, ''<p class="table">Disabled<p>'');\n');
end

fprintf(fid,'configdata.setCell(7, 0, ''<p class="table">Start time</p>'');\n');
fprintf(fid,['configdata.setCell(7, 1, ''<p class="table">' gp.info.startTime  '</p>'');\n']);

fprintf(fid,'configdata.setCell(8, 0, ''<p class="table">Stop time</p>'');\n');
fprintf(fid,['configdata.setCell(8, 1, ''<p class="table">' gp.info.stopTime  '</p>'');\n']);

fprintf(fid,'configdata.setCell(9, 0, ''<p class="table">Merged independent runs</p>'');\n');
fprintf(fid,['configdata.setCell(9, 1, ''<p class="table">' int2str(gp.runcontrol.runs)  '</p>'');\n']);

fprintf(fid,'configdata.setCell(10, 0, ''<p class="table">Run timeout (sec)</p>'');\n');
fprintf(fid,['configdata.setCell(10, 1, ''<p class="table">' num2str(gp.runcontrol.timeout)  '</p>'');\n']);

fprintf(fid,'configviz_div = document.getElementById(''configtable'');\n');
fprintf(fid,'configviz = new google.visualization.Table(configviz_div);\n');
fprintf(fid,'configviz.draw(configdata,  {width: 800, allowHtml: true});}\n');
fprintf(fid,'google.setOnLoadCallback(drawConfigTable);\n');
fprintf(fid,' </script>\n');

function structPropertiesTableJS(fid,gp,gpmodel)
%javascript for tables containing structual properties relating to the GP tree representation

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawStructPropertiesTable() {\n');
fprintf(fid,'var structdata = new google.visualization.DataTable();\n');
fprintf(fid,'structdata.addColumn(''string'',''Description'');\n');
fprintf(fid,'structdata.addColumn(''string'',''Value'');\n');
fprintf(fid,'structdata.addRows(6);\n');

fprintf(fid,'structdata.setCell(0, 0, ''<p class="table">Genes</p>'');\n');
fprintf(fid,['structdata.setCell(0, 1, ''<p class="table">' int2str(gpmodel.genes.num_genes) '</p>'');\n']);

fprintf(fid,'structdata.setCell(1, 0, ''<p class="table">Nodes</p>'');\n');
fprintf(fid,['structdata.setCell(1, 1, ''<p class="table">' int2str(gpmodel.numNodes) '</p>'');\n']);

fprintf(fid,'structdata.setCell(2, 0, ''<p class="table">Expressional complexity</p>'');\n');
fprintf(fid,['structdata.setCell(2, 1, ''<p class="table">' int2str(gpmodel.expComplexity) '</p>'');\n']);

fprintf(fid,'structdata.setCell(3, 0, ''<p class="table">Depth</p>'');\n');
fprintf(fid,['structdata.setCell(3, 1, ''<p class="table">' int2str(gpmodel.maxDepth) '</p>'');\n']);

fprintf(fid,'structdata.setCell(4, 0, ''<p class="table">Inputs</p>'');\n');
fprintf(fid,['structdata.setCell(4, 1, ''<p class="table">' int2str(gpmodel.numInputs) '</p>'');\n']);

usedInputs = '';
for i=1:gpmodel.numInputs
    if gp.info.toolbox.symbolic
        usedInputs = [usedInputs ' '  googfix(HTMLequation(gp,gpmodel.inputs{i})) ];
    else
        usedInputs = [usedInputs ' '  gpmodel.inputs{i} ];
    end
end

fprintf(fid,'structdata.setCell(5, 0, ''<p class="table">Inputs used</p>'');\n');
fprintf(fid,['structdata.setCell(5, 1, ''<p class="table">' usedInputs '</p>'');\n']);

fprintf(fid,'structviz = new google.visualization.Table(document.getElementById(''structtable''));\n');
fprintf(fid,'structviz.draw(structdata,  {width: 800, allowHtml: true});}\n');
fprintf(fid,'google.setOnLoadCallback(drawStructPropertiesTable);\n');
fprintf(fid,' </script>\n');

function runVarsTableJS(fid,gp)
%javascript for run variables table

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawRunVarsTable() {\n');
fprintf(fid,'var rundata = new google.visualization.DataTable();\n');
fprintf(fid,'rundata.addColumn(''string'',''Run parameter'');\n');
fprintf(fid,'rundata.addColumn(''string'',''Value'');\n');
fprintf(fid,'rundata.addRows(17);\n');

fprintf(fid,'rundata.setCell(0, 0, ''<p class="table">Population size</p>'');\n');

if gp.info.merged
    fprintf(fid,['rundata.setCell(0, 1, ''<p class="table">' int2str(gp.info.mergedPopSizes(1)) '</p>'');\n']);
else
    fprintf(fid,['rundata.setCell(0, 1, ''<p class="table">' int2str(gp.runcontrol.pop_size) '</p>'');\n']);
end

fprintf(fid,'rundata.setCell(1, 0, ''<p class="table">Max. generations</p>'');\n');
fprintf(fid,['rundata.setCell(1, 1, ''<p class="table">' int2str(gp.runcontrol.num_gen) '</p>'');\n']);

fprintf(fid,'rundata.setCell(2, 0, ''<p class="table">Generations elapsed</p>'');\n');
fprintf(fid,['rundata.setCell(2, 1, ''<p class="table">' int2str(gp.state.count) '</p>'');\n']);

fprintf(fid,'rundata.setCell(3, 0, ''<p class="table">Input variables</p>'');\n');
fprintf(fid,['rundata.setCell(3, 1, ''<p class="table">' int2str(gp.nodes.inputs.num_inp) '</p>'');\n']);

fprintf(fid,'rundata.setCell(4, 0, ''<p class="table">Training instances</p>'');\n');
fprintf(fid,['rundata.setCell(4, 1, ''<p class="table">' int2str(gp.userdata.numytrain) '</p>'');\n']);

fprintf(fid,'rundata.setCell(5, 0, ''<p class="table">Tournament size</p>'');\n');
fprintf(fid,['rundata.setCell(5, 1, ''<p class="table">' int2str(gp.selection.tournament.size) '</p>'');\n']);

fprintf(fid,'rundata.setCell(6, 0, ''<p class="table">Elite fraction</p>'');\n');
fprintf(fid,['rundata.setCell(6, 1, ''<p class="table">' num2str(gp.selection.elite_fraction) '</p>'');\n']);

fprintf(fid,'rundata.setCell(7, 0, ''<p class="table">Lexicographic selection pressure</p>'');\n');

if gp.selection.tournament.lex_pressure
    fprintf(fid,'rundata.setCell(7, 1, ''<p class="table">On</p>'');\n');
else
    fprintf(fid,'rundata.setCell(7, 1, ''<p class="table">Off</p>'');\n');
end

fprintf(fid,'rundata.setCell(8, 0, ''<p class="table">Probability of pareto tournament</p>'');\n');
fprintf(fid,['rundata.setCell(8, 1, ''<p class="table">' num2str(gp.selection.tournament.p_pareto)  '</p>'');\n']);

fprintf(fid,'rundata.setCell(9, 0, ''<p class="table">Max. genes</p>'');\n');
fprintf(fid,['rundata.setCell(9, 1, ''<p class="table">' int2str(gp.genes.max_genes)  '</p>'');\n']);

fprintf(fid,'rundata.setCell(10, 0, ''<p class="table">Max. tree depth</p>'');\n');
fprintf(fid,['rundata.setCell(10, 1, ''<p class="table">' int2str(gp.treedef.max_depth)  '</p>'');\n']);

fprintf(fid,'rundata.setCell(11, 0, ''<p class="table">Max. total nodes</p>'');\n');
fprintf(fid,['rundata.setCell(11, 1, ''<p class="table">' num2str(gp.treedef.max_nodes)  '</p>'');\n']);

ercIntProb = gp.nodes.const.p_int;
if ercIntProb
   intstr =['Integer ' num2str(ercIntProb)]; 
else
    intstr = '';
end

fprintf(fid,'rundata.setCell(12, 0, ''<p class="table">ERC probability</p>'');\n');
fprintf(fid,['rundata.setCell(12, 1, ''<p class="table">' num2str(gp.nodes.const.p_ERC) ...
  '<p class="muted">'  intstr  '</p></p>'');\n']);

ctypes(1,1) = gp.genes.operators.p_cross_hi;
ctypes(1,2) = 1 - ctypes(1);
highStr = '';lowStr = '';
if ctypes(1), highStr = ['High level ' num2str(ctypes(1))];end
if ctypes(2), lowStr = [', Low level ' num2str(ctypes(2))];end
fprintf(fid,'rundata.setCell(13, 0, ''<p class="table">Crossover probability</p>'');\n');
fprintf(fid,['rundata.setCell(13, 1, ''<p class="table">' num2str(gp.operators.crossover.p_cross) ...
   '<p class="muted">'  highStr lowStr '</p></p>'');\n']);


%display mutation subtypes if enabled
mtypes = gp.operators.mutation.mutate_par;
subtreeStr = ''; termStr = '';perturbStr = '';zeroStr = ''; randStr = '';unityStr = '';
if mtypes(1), subtreeStr = ['Subtree ' num2str(mtypes(1))];end
if mtypes(2), termStr = [', Input ' num2str(mtypes(2))];end
if mtypes(3), perturbStr = [', Perturb ERC ' num2str(mtypes(3))];end
if mtypes(4), zeroStr = [', Zero ERC ' num2str(mtypes(4))];end
if mtypes(5), randStr = [', Rand ERC ' num2str(mtypes(5))];end
if mtypes(6), unityStr = [', Unity ERC ' num2str(mtypes(6))];end
fprintf(fid,'rundata.setCell(14, 0, ''<p class="table">Mutation probabilities</p>'');\n');
fprintf(fid,['rundata.setCell(14, 1, ''<p class="table">' num2str(gp.operators.mutation.p_mutate) '<p class="muted">'  subtreeStr ...
    termStr  perturbStr zeroStr randStr unityStr '</p></p>'');\n']);


fprintf(fid,'rundata.setCell(15, 0, ''<p class="table">Complexity measure</p>'');\n');
if gp.fitness.complexityMeasure
    fprintf(fid,'rundata.setCell(15, 1, ''<p class="table">Expressional</p>'');\n');
else
    fprintf(fid,'rundata.setCell(15, 1, ''<p class="table">Node count</p>'');\n');
end

functions ='';
for i=1:length(gp.nodes.functions.active_name_UC)
    functions = [functions ' ' gp.nodes.functions.active_name_UC{i}];
end
functions = strtrim(functions);

fprintf(fid,'rundata.setCell(16, 0, ''<p class="table">Function set</p>'');\n');
fprintf(fid,['rundata.setCell(16, 1, ''<p class="table">' functions  '</p>'');\n']);

fprintf(fid,'runviz = new google.visualization.Table(document.getElementById(''runtable''));\n');
fprintf(fid,'runviz.draw(rundata,  {width: 800, allowHtml: true});}\n');
fprintf(fid,'google.setOnLoadCallback(drawRunVarsTable);\n');
fprintf(fid,' </script>\n');

function trainPredictionsChartJS(fid,gp,gpmodel)
%model predictions (training) plot javascript for selected model

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawTrainPredictions() {\n');
fprintf(fid,'var trainpreddata = new google.visualization.DataTable();\n');
fprintf(fid,'trainpreddata.addColumn(''number'',''x'');\n');
fprintf(fid,'trainpreddata.addColumn(''number'',''Actual'');\n');
fprintf(fid,'trainpreddata.addColumn(''number'',''Predicted'');\n');

%loop through training data and get actual and predictions
numData = length(gpmodel.train.ypred);

%write actual and predicted to a datatable row
for i=1:numData
    fprintf(fid,['trainpreddata.addRow([' int2str(i) ',' num2str(gp.userdata.ytrain(i)) ',' num2str(gpmodel.train.ypred(i)) ']);\n']);
end

%draw
fprintf(fid,'trainpredviz_div =  document.getElementById(''trainpreds'');\n');
fprintf(fid,'trainpredviz = new google.visualization.LineChart(trainpredviz_div);\n');
fprintf(fid,'trainpredviz.draw(trainpreddata,{curvetype: "function", width: 1000, height: 625, title: "Training data predictions",  fontName: "Open Sans",  explorer: { actions: [''dragToZoom'', ''rightClickToReset''] }, chartArea: {left: 75,top: 75}, series: {0:{color: ''#0073BD''},1:{color: ''#D9541A''}}, hAxis: {title: ''Datapoint''},vAxis: {title: ''y''}});\n');

fprintf(fid,'}\n'); %end of drawTrainPredictions
fprintf(fid,'google.setOnLoadCallback(drawTrainPredictions);\n');
fprintf(fid,' </script>\n');

function testPredictionsChartJS(fid,gp,gpmodel)
%generate model predictions (testing) plot javascript for selected model

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawTestPredictions() {\n');
fprintf(fid,'var testpreddata = new google.visualization.DataTable();\n');
fprintf(fid,'testpreddata.addColumn(''number'',''x'');\n');
fprintf(fid,'testpreddata.addColumn(''number'',''Actual'');\n');
fprintf(fid,'testpreddata.addColumn(''number'',''Predicted'');\n');

%loop through test data and get actual and predictions
numData = length(gpmodel.test.ypred);

%write actual and predicted to a datatable row
for i=1:numData
    fprintf(fid,['testpreddata.addRow([' int2str(i) ',' num2str(gp.userdata.ytest(i)) ',' num2str(gpmodel.test.ypred(i)) ']);\n']);
end
fprintf(fid,'testpredviz = new google.visualization.LineChart(document.getElementById(''testpreds''));\n');
fprintf(fid,'testpredviz.draw(testpreddata,{curvetype: "function", width: 1000, height: 625, fontName: "Open Sans",  explorer: { actions: [''dragToZoom'', ''rightClickToReset''] }, title: ''Test data predictions'',series: {0:{color: ''#0073BD''},1:{color: ''#D9541A''}},chartArea: {left: 75, top:75},hAxis: {title: ''Datapoint''},vAxis: {title: ''y''}});}\n');
fprintf(fid,'google.setOnLoadCallback(drawTestPredictions);\n');
fprintf(fid,' </script>\n');

function valPredictionsChartJS(fid,gp,gpmodel)
%generate model predictions (testing) plot javascript for selected model

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawValPredictions() {\n');
fprintf(fid,'var valpreddata = new google.visualization.DataTable();\n');
fprintf(fid,'valpreddata.addColumn(''number'',''x'');\n');
fprintf(fid,'valpreddata.addColumn(''number'',''Actual'');\n');
fprintf(fid,'valpreddata.addColumn(''number'',''Predicted'');\n');

%loop through validation data and get actual and predictions
numData = length(gpmodel.val.ypred);

%write actual and predicted to a datatable row
for i=1:numData
    fprintf(fid,['valpreddata.addRow([' int2str(i) ',' num2str(gp.userdata.yval(i)) ',' num2str(gpmodel.val.ypred(i)) ']);\n']);
end
fprintf(fid,'valpredviz = new google.visualization.LineChart(document.getElementById(''valpreds''));\n');
fprintf(fid,'valpredviz.draw(valpreddata,{curvetype: "function", width: 1000, height: 625,  fontName: "Open Sans", series: {0:{color: ''#0073bd''},1:{color: ''#d9541a''}},  explorer: { actions: [''dragToZoom'', ''rightClickToReset''] }, title: ''Validation data predictions'',chartArea: {left: 75, top:75}, hAxis: {title: ''Datapoint''},vAxis: {title: ''y''}});}\n');
fprintf(fid,'google.setOnLoadCallback(drawValPredictions);\n');
fprintf(fid,' </script>\n');

function trainPerformanceTableJS(fid,gpmodel)
%generate javascript for model performance on training data table

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawModelPerfTrainTable() {\n');
fprintf(fid,'var data = new google.visualization.DataTable();\n');
fprintf(fid,'data.addColumn(''string'',''Metric'');\n');
fprintf(fid,'data.addColumn(''string'',''Value'');\n');
fprintf(fid,'data.addRows(6);\n');

fprintf(fid,googfix('data.setCell(0, 0, ''<p class="table">R<sup>2</sup></p>'');\n'));
fprintf(fid,['data.setCell(0, 1, ''<p class="table">' num2str(gpmodel.train.r2) '</p>'');\n']);

fprintf(fid,'data.setCell(1, 0, ''<p class="table">RMSE</p>'');\n');
fprintf(fid,['data.setCell(1, 1, ''<p class="table">' num2str(gpmodel.train.rmse) '</p>'');\n']);

fprintf(fid,'data.setCell(2, 0, ''<p class="table">MAE</p>'');\n');
fprintf(fid,['data.setCell(2, 1, ''<p class="table">' num2str(gpmodel.train.mae) '</p>'');\n']);

fprintf(fid,'data.setCell(3, 0, ''<p class="table">SSE</p>'');\n');
fprintf(fid,['data.setCell(3, 1, ''<p class="table">' num2str(gpmodel.train.sse) '</p>'');\n']);

fprintf(fid,'data.setCell(4, 0, ''<p class="table">Max. abs. error</p>'');\n');
fprintf(fid,['data.setCell(4, 1, ''<p class="table">' num2str(gpmodel.train.maxe) '</p>'');\n']);

fprintf(fid,'data.setCell(5, 0, ''<p class="table">MSE</p>'');\n');
fprintf(fid,['data.setCell(5, 1, ''<p class="table">' num2str(gpmodel.train.mse) '</p>'');\n']);

fprintf(fid,'viz = new google.visualization.Table(document.getElementById(''perf_train_table''));\n');
fprintf(fid,'viz.draw(data,  {width: 800, allowHtml: true});}\n');
fprintf(fid,'google.setOnLoadCallback(drawModelPerfTrainTable);\n');
fprintf(fid,' </script>\n');

function testPerformanceTableJS(fid,gpmodel)
%generate javascript for model performance on test data table

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawModelPerfTestTable() {\n');
fprintf(fid,'var data = new google.visualization.DataTable();\n');
fprintf(fid,'data.addColumn(''string'',''Metric'');\n');
fprintf(fid,'data.addColumn(''string'',''Value'');\n');
fprintf(fid,'data.addRows(6);\n');

fprintf(fid,googfix('data.setCell(0, 0, ''<p class="table">R<sup>2</sup></p>'');\n'));
fprintf(fid,['data.setCell(0, 1, ''<p class="table">' num2str(gpmodel.test.r2) '</p>'');\n']);

fprintf(fid,'data.setCell(1, 0, ''<p class="table">RMSE</p>'');\n');
fprintf(fid,['data.setCell(1, 1, ''<p class="table">' num2str(gpmodel.test.rmse) '</p>'');\n']);

fprintf(fid,'data.setCell(2, 0, ''<p class="table">MAE</p>'');\n');
fprintf(fid,['data.setCell(2, 1, ''<p class="table">' num2str(gpmodel.test.mae) '</p>'');\n']);

fprintf(fid,'data.setCell(3, 0, ''<p class="table">SSE</p>'');\n');
fprintf(fid,['data.setCell(3, 1, ''<p class="table">' num2str(gpmodel.test.sse) '</p>'');\n']);

fprintf(fid,'data.setCell(4, 0, ''<p class="table">Max. abs. error</p>'');\n');
fprintf(fid,['data.setCell(4, 1, ''<p class="table">' num2str(gpmodel.test.maxe) '</p>'');\n']);

fprintf(fid,'data.setCell(5, 0, ''<p class="table">MSE</p>'');\n');
fprintf(fid,['data.setCell(5, 1, ''<p class="table">' num2str(gpmodel.test.mse) '</p>'');\n']);

fprintf(fid,'viz = new google.visualization.Table(document.getElementById(''perf_test_table''));\n');
fprintf(fid,'viz.draw(data,  {width: 800, allowHtml: true});}\n');
fprintf(fid,'google.setOnLoadCallback(drawModelPerfTestTable);\n');
fprintf(fid,' </script>\n');

function valPerformanceJS(fid,gpmodel)
%generate javascript for model performance on validation data

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawModelPerfValTable() {\n');
fprintf(fid,'var data = new google.visualization.DataTable();\n');
fprintf(fid,'data.addColumn(''string'',''Metric'');\n');
fprintf(fid,'data.addColumn(''string'',''Value'');\n');
fprintf(fid,'data.addRows(6);\n');

fprintf(fid,googfix('data.setCell(0, 0, ''<p class="table">R<sup>2</sup></p>'');\n'));
fprintf(fid,['data.setCell(0, 1, ''<p class="table">' num2str(gpmodel.val.r2) '</p>'');\n']);

fprintf(fid,'data.setCell(1, 0, ''<p class="table">RMSE</p>'');\n');
fprintf(fid,['data.setCell(1, 1, ''<p class="table">' num2str(gpmodel.val.rmse) '</p>'');\n']);

fprintf(fid,'data.setCell(2, 0, ''<p class="table">MAE</p>'');\n');
fprintf(fid,['data.setCell(2, 1, ''<p class="table">' num2str(gpmodel.val.mae) '</p>'');\n']);

fprintf(fid,'data.setCell(3, 0, ''<p class="table">SSE</p>'');\n');
fprintf(fid,['data.setCell(3, 1, ''<p class="table">' num2str(gpmodel.val.sse) '</p>'');\n']);

fprintf(fid,'data.setCell(4, 0, ''<p class="table">Max. abs. error</p>'');\n');
fprintf(fid,['data.setCell(4, 1, ''<p class="table">' num2str(gpmodel.val.maxe) '</p>'');\n']);

fprintf(fid,'data.setCell(5, 0, ''<p class="table">MSE</p>'');\n');
fprintf(fid,['data.setCell(5, 1, ''<p class="table">' num2str(gpmodel.val.mse) '</p>'');\n']);

fprintf(fid,'viz = new google.visualization.Table(document.getElementById(''perf_val_table''));\n');
fprintf(fid,'viz.draw(data,  {width: 800, allowHtml: true});}\n');
fprintf(fid,'google.setOnLoadCallback(drawModelPerfValTable);\n');
fprintf(fid,' </script>\n');

function fullModelSymTableJS(fid,gpmodel,gp)
%generate javascript for full symbolic model table

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawFullModelSymTable() {\n');
fprintf(fid,'var data = new google.visualization.DataTable();\n');
fprintf(fid,'data.addColumn(''string'',''Model'');\n');
fprintf(fid,'data.addRows(1);\n');

eqn = [gpmodel.output  ' = ' googfix( HTMLequation(gp,char(vpa(gpmodel.sym,3)),3) )];

fprintf(fid,['data.setCell(0, 0, ''<p style="font-size:120%%">' eqn '</p>'');\n']);
fprintf(fid,'viz = new google.visualization.Table(document.getElementById(''fullmodel_table''));\n');
fprintf(fid,'viz.draw(data,  {width: 800, allowHtml: true});}\n');
fprintf(fid,'google.setOnLoadCallback(drawFullModelSymTable);\n');
fprintf(fid,' </script>\n');

function geneSymTableJS(fid,gpmodel,gp)
%generate javascript for model genes table

rows = gpmodel.genes.num_genes+1;

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawGeneSymTable() {\n');
fprintf(fid,'var data = new google.visualization.DataTable();\n');
fprintf(fid,'data.addColumn(''string'',''Term'');\n');
fprintf(fid,'data.addColumn(''string'',''Value'');\n');
fprintf(fid,['data.addRows(' int2str(rows) ');\n']);

%first row contains bias term
fprintf(fid,'data.setCell(0, 0, ''<p class="table">Bias</p>'');\n');
fprintf(fid,['data.setCell(0, 1, ''<p class="table">' char(vpa(gpmodel.genes.geneSyms{1},3)) '</p>'');\n']);

%now iterate over genes and add each to a row
for i=1:gpmodel.genes.num_genes
    eqn=googfix(HTMLequation(gp,gpmodel.genes.geneSyms{i+1},3)); %1st genesym is 'bias'
    fprintf(fid,['data.setCell(' int2str(i) ', 0, ''<p class="table">Gene ' int2str(i) '</p>'');\n']);
    fprintf(fid,['data.setCell(' int2str(i) ', 1, ''<p class="table">' eqn '</p>'');\n']);
end

fprintf(fid,'viz = new google.visualization.Table(document.getElementById(''genes_table''));\n');
fprintf(fid,'viz.draw(data,  {width: 800, allowHtml: true});}\n');
fprintf(fid,'google.setOnLoadCallback(drawGeneSymTable);\n');
fprintf(fid,' </script>\n');

function trainScatterChartJS(fid,gp,gpmodel)
%generate scatter plot javascript for selected model (training)

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawScatterTrain() {\n');
fprintf(fid,'var data = new google.visualization.DataTable();\n');
fprintf(fid,'data.addColumn(''number'',''Actual'');\n');
fprintf(fid,'data.addColumn(''number'',''Actual / Predicted'');\n');
fprintf(fid,'data.addColumn(''number'',''Identity'');\n');

%loop through training data and get actual and predictions
numData = length(gpmodel.train.ypred);

%write actual and predicted (and identity co-ords) to a datatable row
for i=1:numData
    fprintf(fid,['data.addRow([' num2str(gp.userdata.ytrain(i)) ',' num2str(gpmodel.train.ypred(i)) ',' num2str(gp.userdata.ytrain(i)) ']);\n']);
end
fprintf(fid,'viz = new google.visualization.ScatterChart(document.getElementById(''trainscatter''));\n');
fprintf(fid,'viz.draw(data,{width: 1000, height: 625, explorer: { actions: [''dragToZoom'', ''rightClickToReset''] }, fontName: "Open Sans", title: ''Training data predictions vs actuals'',chartArea: {left: 75,top: 75},hAxis: {title: ''Actual''},series:{1:{color:''black'',pointSize:0,lineWidth:2,visibleInLegend:false},0:{visibleInLegend:false, color: ''#0073BD''}},vAxis: {title: ''Predicted''}});}\n');
fprintf(fid,'google.setOnLoadCallback(drawScatterTrain);\n');
fprintf(fid,' </script>\n');

function testScatterChartJS(fid,gp,gpmodel)
%generate scatter plot javascript for selected model (test data)

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawScatterTest() {\n');
fprintf(fid,'var data = new google.visualization.DataTable();\n');
fprintf(fid,'data.addColumn(''number'',''Actual'');\n');
fprintf(fid,'data.addColumn(''number'',''Actual / Predicted'');\n');
fprintf(fid,'data.addColumn(''number'',''Identity'');\n');

%loop through test data and get actual and predictions
numData = length(gpmodel.test.ypred);

%write actual and predicted (and identity co-ords) to a datatable row
for i=1:numData
    fprintf(fid,['data.addRow([' num2str(gp.userdata.ytest(i)) ',' num2str(gpmodel.test.ypred(i)) ',' num2str(gp.userdata.ytest(i)) ']);\n']);
end
fprintf(fid,'viz = new google.visualization.ScatterChart(document.getElementById(''testscatter''));\n');
fprintf(fid,'viz.draw(data,{width: 1000, height: 625,title: ''Test data predictions vs actuals'', fontName: "Open Sans", explorer: { actions: [''dragToZoom'', ''rightClickToReset''] } ,chartArea: {left: 75,top: 75},hAxis: {title: ''Actual''},series:{1:{color:''black'',pointSize:0,lineWidth:2,visibleInLegend:false},0:{visibleInLegend:false, color: ''#0073BD''}},vAxis: {title: ''Predicted''}});}\n');
fprintf(fid,'google.setOnLoadCallback(drawScatterTest);\n');
fprintf(fid,' </script>\n');

function valScatterChartJS(fid,gp,gpmodel)
%generate scatter plot javascript for selected model (validation data)

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawScatterVal() {\n');
fprintf(fid,'var data = new google.visualization.DataTable();\n');
fprintf(fid,'data.addColumn(''number'',''Actual'');\n');
fprintf(fid,'data.addColumn(''number'',''Actual / Predicted'');\n');
fprintf(fid,'data.addColumn(''number'',''Identity'');\n');

%loop through test data and get actual and predictions
numData = length(gpmodel.val.ypred);

%write actual and predicted (and identity co-ords) to a datatable row
for i=1:numData
    fprintf(fid,['data.addRow([' num2str(gp.userdata.yval(i)) ',' num2str(gpmodel.val.ypred(i)) ',' num2str(gp.userdata.yval(i)) ']);\n']);
end
fprintf(fid,'viz = new google.visualization.ScatterChart(document.getElementById(''valscatter''));\n');
fprintf(fid,'viz.draw(data,{width: 1000, height: 625,title: ''Validation data predictions vs actuals'', series: {0:{color: ''#0073bd''}}  , fontName: "Open Sans", explorer: { actions: [''dragToZoom'', ''rightClickToReset''] }  ,chartArea: {left: 75,top: 75},hAxis: {title: ''Actual''},series:{1:{color:''black'',pointSize:0,lineWidth:2,visibleInLegend:false},0:{visibleInLegend:false, color: ''#0073BD''}},vAxis: {title: ''Predicted''}});}\n');
fprintf(fid,'google.setOnLoadCallback(drawScatterVal);\n');
fprintf(fid,' </script>\n');

function geneWeightsChartJS(fid,gpmodel)
%generate column plot javascript for selected model

fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawGeneWeightsPlot() {\n');
fprintf(fid,'var data = new google.visualization.DataTable();\n');
fprintf(fid,'data.addColumn(''string'',''Gene'');\n');
fprintf(fid,'data.addColumn(''number'',''Value'');\n');
fprintf(fid,'data.addColumn({type:''string'', role:''annotation''});\n');

%write bias value
fprintf(fid,['data.addRow([''Bias'',' num2str(gpmodel.genes.geneWeights(1)) ','   '''' num2str(gpmodel.genes.geneWeights(1),3) '''' ']);\n']);

%write actual and predicted (and identity co-ords) to a datatable row
for i=1:gpmodel.genes.num_genes
    fprintf(fid,['data.addRow([''Gene ' num2str(i) ''',' num2str(gpmodel.genes.geneWeights(i+1)) ','  '''' num2str(gpmodel.genes.geneWeights(i+1),3) '''' ']);\n']);
end
fprintf(fid,'viz = new google.visualization.ColumnChart(document.getElementById(''gene_colchart''));\n');
fprintf(fid,'var options = {width: 1000, height: 625,title: ''Gene weights'',chartArea: {left: 75,top: 75},  fontName: "Open Sans", series: {0:{visibleInLegend: false, color: ''#0073BD'' }}};\n');
fprintf(fid,'viz.draw(data,options);}\n');
fprintf(fid,'google.setOnLoadCallback(drawGeneWeightsPlot);\n');
fprintf(fid,' </script>\n');

function reportStyles(fid)
% Apply CSS formatting to page elements
fprintf(fid,'\n<style>\n');
fprintf(fid,'h1, h2, h3 {\n');
fprintf(fid,'color: #0073BD; ');
fprintf(fid,'margin-top: 30px; ');
fprintf(fid,'\n}\n');
fprintf(fid,'p.warn {\n');
fprintf(fid,'color: #d9541a; ');
fprintf(fid,'\n}\n');
fprintf(fid,'p.table {\n');
fprintf(fid,'font-size: 120%%; ');
fprintf(fid,'\n}\n');
fprintf(fid,'p.muted {\n');
fprintf(fid,'font-size: 120%%; color: gray;');
fprintf(fid,'\n}\n');
fprintf(fid,'.google-visualization-table-table {\n');
fprintf(fid,'font-family: ''Open Sans'',''Helvetica Neue'', Helvetica, Arial, sans-serif;');
fprintf(fid,'\n}\n');
fprintf(fid,'</style>');

%CSS formatting for tree nodes
nodeTextColor = 'black';
connectionLineStyle = '2px solid #0073BD';
nodeBorderStyle = '2px solid #0073BD';
nodeColor1 = 'white';
nodeColor2 = 'white';
boxShadow = false;
nodeFont = ' ''Open Sans'' ,''Lucida Sans Unicode'', ''Lucida Grande'', sans-serif';
fprintf(fid,'\n<style>\n');
fprintf(fid,'.google-visualization-orgchart-node {\n');
fprintf(fid,['color: ' nodeTextColor ' ;']);
fprintf(fid,'text-align: center;');
fprintf(fid,'vertical-align: middle;');
fprintf(fid,['font-family:' nodeFont ';']);
fprintf(fid,['border: ' nodeBorderStyle ' ;']);
fprintf(fid,['background-color: ' nodeColor1 ';']);
fprintf(fid,['background: -webkit-gradient(linear, left top, left bottom, from(' nodeColor1 '), to(' nodeColor2 '));']);
fprintf(fid,'vertical-align: middle;');

if ~boxShadow
    fprintf(fid,'box-shadow: none;');
    fprintf(fid,'-webkit-box-shadow: none;');
    fprintf(fid,'-moz-box-shadow: none;');
end
fprintf(fid,'}');
fprintf(fid,'\n</style>\n');

%connecting line CSS
fprintf(fid,'\n<style>\n');
fprintf(fid,'.google-visualization-orgchart-lineleft {\n');
fprintf(fid,[' border-left: ' connectionLineStyle ' ; }']);
fprintf(fid,'.google-visualization-orgchart-lineright {');
fprintf(fid,[' border-right: ' connectionLineStyle ' ; }']);
fprintf(fid,'.google-visualization-orgchart-linebottom {');
fprintf(fid,[' border-bottom: ' connectionLineStyle ' ; }']);
fprintf(fid,'\n</style>\n');

function strOut=googfix(strIn)
%GOOGFIX Ameliorates poor rendering of <sub> and <sup> in Google tables.

strOut=strrep(strIn,'</sub>','</span>');
strOut=strrep(strOut,'</sup>','</span>');
strOut=strrep(strOut,'<sub>','<span style="position:relative;top: 0.3em;font-size:0.7em">');
strOut=strrep(strOut,'<sup>','<span style="position:relative;bottom: 0.3em;font-size:0.7em">');