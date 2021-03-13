function processOrgChartJS(fid,gp,gpmodel)
%PROCESSORGCHARTJS Writes Google org chart JavaScript for genes to an existing HTML file.
%
%   PROCESSORGCHARTJS(FID,GP,GPMODEL) writes the JavaScript for the
%   multigene regression model structure GPMODEL to the file handle FID
%   (which should be open for writing to and should be closed manually
%   after a call to this function).
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also GPTREESTRUCTURE, GPMODELREPORT, DRAWTREES

%loop through genes and populate a data table for each
for n=1:gpmodel.genes.num_genes
    treestr = gpmodel.genes.geneStrs{n};
    treestruct = gptreestructure(gp,treestr);
    numNodes = length(treestruct);
    
    %set up data table to hold node info
    fprintf(fid,'<script type="text/javascript">\n');
    fprintf(fid,['function drawTree' int2str(n) '() {\n']);
    fprintf(fid,'var treedata = new google.visualization.DataTable();\n');
    fprintf(fid,'treedata.addColumn(''string'',''Id'');\n');
    fprintf(fid,'treedata.addColumn(''string'',''ParentId'');\n');
    fprintf(fid,['treedata.addRows(' int2str(numNodes) ');\n']);
    
    %loop through nodes and configure row in data table for each one
    fprintf(fid,['treedata.setCell(0, 0, ''' int2str(treestruct{1}.id) ''',''' treestruct{1}.name ''');\n']);
    for i=2:numNodes
        fprintf(fid,['treedata.setCell(' int2str(i-1) ', 0, ''' int2str(treestruct{i}.id) ''',''' treestruct{i}.name ''');\n']);
        fprintf(fid,['treedata.setCell(' int2str(i-1) ', 1, ''' int2str(treestruct{i}.parentId) ''');\n']);
    end
    
    fprintf(fid,['treeviz = new google.visualization.OrgChart(document.getElementById(''tree' int2str(n) '''));\n']);
    fprintf(fid,'treeviz.draw(treedata,{allowHtml: true, allowCollapse: true});}\n');
    fprintf(fid,['google.setOnLoadCallback(drawTree' int2str(n) ');\n']);
    fprintf(fid,' </script>\n');   
end