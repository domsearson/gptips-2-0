function treestructure = gptreestructure(gp,expr)
%GPTREESTRUCTURE Create cell array containing tree structure connectivity and label information for an encoded tree expression.
%
%   TREESTRUCTURE = GPTREESTRUCTURE(GP,EXPR) on the encoded expression
%   string EXPR - e.g. g(a(m(x2),x1)) -  returns the cell array
%   TREESTRUCTURE, each element of which contains a MATLAB structure
%   describing tree connectivity information for a node in EXPR. The ith
%   structure in TREESTRUCTURE describes the ith node in EXPR. Node 1 is
%   the root node (other nodes are numbered in an arbitrary but consistent
%   way).
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also DRAWTREES, GPMODELREPORT, TREEGEN

%get a list of all nodes in expression, left to right
nodes = picknode(expr,6,gp);
numnodes = length(nodes);

%construct cell array for holding info for each node
treestructure = cell(1,numnodes);

%proceeding from left to right, get the name of the function node and the
%id of its parent and its own node id
for i=1:numnodes
    
    node = struct;
    shortName = expr(nodes(i));
    node.id = i;
    
    %lookup node in function table
    floc = strfind(gp.nodes.functions.afid,shortName);
    
    %if not empty then it is a function node
    if ~isempty(floc)
        node.name = lower(gp.nodes.functions.active_name_UC{floc});
    else %otherwise it is a terminal or constant so extract it
        
        [~,node.name] = extract(nodes(i),expr);
        
        %if terminal then replace with lookup name, if it exists
        if node.name(1) == 'x'
            
            newnameInd = str2double(strrep(node.name,'x',''));
            if newnameInd <= numel(gp.nodes.inputs.names) && ~isempty(gp.nodes.inputs.names{newnameInd})
                node.name = gp.nodes.inputs.names{newnameInd};
            end
            
            if gp.info.toolbox.symbolic
                node.name = HTMLequation(gp,node.name);
            end
            
            %if ERC then strip brackets and reduce digits
        elseif node.name(1) == '['
            newname = strrep(node.name,'[','');
            newname = strrep(newname,']','');
           
            if length(newname) > 6 %clip long ERCs
                newname = newname(1:6);
            end
            node.name = newname;
        end
    end
    
    %if the id is 1 then it is root node and has no parent
    if node.id == 1
        node.parentId = [];
        
    else %otherwise find the parent id of this node
        
        %search left across string for opening '(' not matched by
        % a closing ')'. The node to the left of this is the parent node.
        substring = expr(1:nodes(i)-1);
        len = length(substring);
        
        numClosed = 0;
        for j=len:-1:1
            if substring(j) =='(' && numClosed == 0
                node.parentId = find(nodes==(j-1));
                break
            elseif substring(j) == ')'
                numClosed = numClosed + 1;
            elseif substring(j) == '('
                numClosed = numClosed - 1;
            end
            
        end
    end
    treestructure{1,i} = node;
end