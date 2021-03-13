function varargout = paretoreport(gp,reportName,nobrowser)
%PARETOREPORT Generate an HTML performance/complexity report on the Pareto front of the population.
%
%   PARETOREPORT(GP) generates an HTML report called pareto.htm on the
%   expressional complexity/R2 Pareto front of the multigene symbolic
%   regression models in the GPTIPS data structure GP.
% 
%   PARETOINDS = PARETOREPORT(GP) does the same and returns a vector
%   PARETOINDS containing the numerical population IDs of the models in GP
%   on the Pareto front.
%
%   [PARETOINDS, GPFILTERED] = PARETOREPORT(GP) does the same and returns a
%   data structure GPFILTERED which is functionally identical to GP but
%   only contains population models on the Pareto front.
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
%   See also GPMODELREPORT, DRAWTREES, GPPRETTY, GPMODEL2SYM,
%   GPMODEL2STRUCT, GPMODELFILTER

if ~gp.info.toolbox.symbolic
    error('The Symbolic Math Toolbox is required to use this function.');
end

if ~strncmpi('regressmulti',func2str(gp.fitness.fitfun),12)
    error('PARETOREPORT may only be used on a GP structure with a population containing multigene symbolic regression models.');
end

if nargin < 2 || isempty(reportName)
    reportName = 'pareto';
end

if nargin < 3 || isempty(nobrowser)
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

%apply a GPMODELFILTER to get the pareto front with R2 > 0 (training)
f = gpmodelfilter;
f.paretoFront = true;
f.minR2train = 0;
[gpf,paretoInds] = f.applyFilter(gp);
paretoInds = find(paretoInds);

%function outputs
if nargout > 0
    varargout{1} = paretoInds;
end

if nargout == 2
     varargout{2} = gpf;
end

popsize = numel(gp.pop);
frontSize = numel(gpf.pop);

%header
writeheader(gpf,paretoInds,fid);

%report body
fprintf(fid,'<body>\n');
fprintf(fid,'<body style="font-family: ''Open Sans'',''Helvetica Neue'', Helvetica, Arial, sans-serif; border: 0;">\n');
fprintf(fid,'<div style="text-align: left; margin-bottom: 50px;margin-top: 50px;margin-left: 15px;">');
fprintf(fid,'<h2>GPTIPS pareto front report</h2>');
fprintf(fid,['<p>' datestr(now) '</p>\n']);

if ~isempty(gp.userdata.name)
    fprintf(fid,['<p>Data: ' gp.userdata.name '</p>\n']);
end
fprintf(fid,['<p>Config file: ' func2str(gp.info.configFile) '.m</p>\n']);
fprintf(fid,['<p>Number of models on front: ' int2str(frontSize) '</p>']);
fprintf(fid,['<p>Total models: ' int2str(popsize) '</p>']);

fprintf(fid,'<p style="margin-top: 30px;">This report shows the expressional complexity/performance characteristics (on training data) of symbolic models on the pareto front.</p>');
fprintf(fid,'<p>Numerical precision is reduced for display purposes.</p>');
fprintf(fid,'<p style="margin-bottom: 30px;">Click on column headers to sort models by expressional complexity and goodness of fit (R<sup>2</sup>).</p>');
fprintf(fid,'<div id="perf_table">');
fprintf(fid,'</div>\n');
%footer & close
fprintf(fid,'<p style="color:gray;text-align:center;margin-top: 50px;">GPTIPS - the symbolic data mining platform for MATLAB</p>');
fprintf(fid,'<p style="color:gray;text-align:center;">&#169; Dominic Searson 2009-2015</p>');
fprintf(fid,'</div>\n');
fprintf(fid,'</body>\n');
fprintf(fid,'</html>\n');
fclose(fid);

disp(['Model report created in ' reportName '.htm']);

if ~nobrowser
    disp('Opening report in system browser.');
    web(htmlFileName,'-browser');
end

function writeheader(gp,paretoInds,fid)

%html header info
fprintf(fid,'<!DOCTYPE html>\n');
fprintf(fid,'<html lang="en">\n');
fprintf(fid,'<head>\n');
fprintf(fid,'<meta http-equiv="content-type" content="text/html; charset=utf-8" name="description" content="GPTIPS 2 pareto report" name="author" content="Dominic Searson"/>\n');

setStr = '';
if ~isempty(gp.userdata.name)
    setStr = [' Data: ' gp.userdata.name];
end

fprintf(fid,['<title>GPTIPS pareto front report.' setStr '</title>\n']);
fprintf(fid,'<script type="text/javascript" src="http://www.google.com/jsapi"></script>\n');

%load table vis from Google
fprintf(fid,'<script type="text/javascript">google.load(''visualization'', ''1'', {packages: [''table'']});\n');
fprintf(fid,'</script>\n');

%font
fprintf(fid,'<link href=''http://fonts.googleapis.com/css?family=Open+Sans'' rel=''stylesheet'' type=''text/css''>');

reportStyles(fid);
generateTable(gp,paretoInds,fid);
fprintf(fid,'</head>\n');

function generateTable(gp,paretoInds,fid)
%generates the JS for the table based on supplied filtered GP structure
fprintf(fid,'<script type="text/javascript">\n');
fprintf(fid,'function drawPerformanceTable() {\n');
fprintf(fid,'var data = new google.visualization.DataTable();\n');
fprintf(fid,'data.addColumn(''number'',''Model ID'');\n');
fprintf(fid,'data.addColumn(''number'',''Goodness of fit (R<sup>2</sup>)'');\n');
fprintf(fid,'data.addColumn(''number'',''Model complexity'');\n');
fprintf(fid,'data.addColumn(''string'',''Model'');\n');

numModels = numel(gp.pop);

fprintf(fid,['data.addRows(' int2str(numModels) ');\n']);

for i = 1:numModels
    cellnum = int2str(i-1);
    model = gpmodel2struct(gp,i,false,true,true,true); %use fastMode for model simplification
    
    if model.valid
        eqn = googfix( HTMLequation(gp,char(vpa(model.sym,3)),3) );
    else
        eqn=['Invalid model (' model.invalidReason ')'];
    end
    
    fprintf(fid,['data.setCell(' cellnum ',0, '  int2str(paretoInds(i))  ');\n']);
    fprintf(fid,['data.setCell(' cellnum  ',1, '  num2str(model.train.r2,3)  ');\n']);
    fprintf(fid,['data.setCell(' cellnum ',2, ' int2str(model.expComplexity) ');\n']);
    fprintf(fid,['data.setCell(' cellnum ',3, ''' eqn ''');\n']);
end

fprintf(fid,'viz = new google.visualization.Table(document.getElementById(''perf_table''));\n');
fprintf(fid,'viz.draw(data,  {width: 1000, allowHtml: true});}\n');
fprintf(fid,'google.setOnLoadCallback(drawPerformanceTable);\n');
fprintf(fid,' </script>\n');

function reportStyles(fid)
%apply CSS formatting to page elements
fprintf(fid,'\n<style>\n');
fprintf(fid,'h1, h2, h3 {\n');
fprintf(fid,'color: #0073bd; ');
fprintf(fid,'margin-top: 20px; ');
fprintf(fid,'\n}\n');
fprintf(fid,'p.warn {\n');
fprintf(fid,'color: #993300; ');
fprintf(fid,'\n}\n');
fprintf(fid,'.google-visualization-table-table .google-visualization-table-td-number {\n');
fprintf(fid,'font-family: ''Open Sans'',''Helvetica Neue'', Helvetica, Arial, sans-serif;');
fprintf(fid,'text-align: left;');
fprintf(fid,'\n}\n');
fprintf(fid,'.google-visualization-table-td {\n');
fprintf(fid,'padding-top: 6px;');
fprintf(fid,'padding-bottom: 6px;');
fprintf(fid,'font-size: 14px;');
fprintf(fid,'\n}\n');
fprintf(fid,'</style>\n');

function strOut=googfix(strIn)
%GOOGFIX Ameliorates poor rendering of <sub> and <sup> in Google tables.

strOut=strrep(strIn,'</sub>','</span>');
strOut=strrep(strOut,'</sup>','</span>');
strOut=strrep(strOut,'<sub>','<span style="position:relative;top: 0.3em;font-size:0.7em">');
strOut=strrep(strOut,'<sup>','<span style="position:relative;bottom: 0.3em;font-size:0.7em">');
