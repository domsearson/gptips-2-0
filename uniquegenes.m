function genes = uniquegenes(gp,modelList)
%UNIQUEGENES Returns a GENES structure containing the unique genes in a population.
%
%   GENES = UNIQUEGENES(GP) scans through the symbolic regression models
%   stored in the population contained in GP and extracts the unique set of
%   genes that makes up the population of 'valid' models. This unique set
%   is returned in a MATLAB data struct GENES. (See GPMODEL2STRUCT for what
%   constitutes a 'valid' model.)
%
%   GENES = UNIQUEGENES(GP, MODELLIST) does the same but only scans the
%   population members with indices contained in the row vector MODELLIST.
%
%   E.g. GENES = UNIQUEGENES(GP, [1 3 9 10]) returns a structure GENES
%   containing the unique genes in the models from GP with population
%   indices 1, 3, 9 and 10.
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also GENEFILTER, GENEBROWSER, GPMODELFILTER, GPMODEL2STRUCT

if nargin < 1
    disp('Basic usage is UNIQUEGENES(GP).');
    if nargout > 0
        genes = [];
    end
    return
end

if ~gp.info.toolbox.symbolic
    error('The Symbolic Math Toolbox is required to use this function.');
end

if nargin < 2
    modelList = 1:gp.runcontrol.pop_size;
end

if ~strncmpi(func2str(gp.fitness.fitfun),'regressmulti',12);
    error('This function is intended only for use on populations containing multigene regression models.');
end

if ~isnumeric(modelList) || size(modelList,1) > 1
    error('Supplied model list must be a row vector of model indices.');
end

verOld = verLessThan('matlab', '7.7.0');

numSuppliedModels = numel(modelList);

%check model validity
numGenes = 0;
models = cell(numSuppliedModels,1);
disp(['Scanning ' num2str(numSuppliedModels) ' models ...']);

for i = 1:numSuppliedModels
    models{i} = gpmodel2struct(gp,modelList(i),false,false,false);
    if ~models{i}.valid
        %if model is 'invalid' do nothing and skip to next model
    else
        numGenes = numGenes + models{i}.genes.num_genes;
    end
end

if numGenes == 0;
    error('No valid models found in supplied population list.');
end

%addin genes from 'best' model on training data and 'valbest' and
%'testbest'
if numSuppliedModels == gp.runcontrol.pop_size
    modelbest = gpmodel2struct(gp,'best', false, false, false);
    modelvalbest = gpmodel2struct(gp,'valbest', false, false, false);
    modeltestbest = gpmodel2struct(gp,'testbest', false, false, false);
    
    numGenes = numGenes + modelbest.genes.num_genes;
    
    if modelvalbest.valid
        numGenes = numGenes + modelvalbest.genes.num_genes;
    end
    
    if modeltestbest.valid
        numGenes = numGenes + modeltestbest.genes.num_genes;
    end
else
    modelvalbest.valid = false;
    modeltestbest.valid = false;
    modelbest.valid = false;
end

%loop through valid models and get all genes
allGenes = cell(numGenes,1);
offset = 0;

for i=1:numSuppliedModels
    if models{i}.valid
        numModelGenes = models{i}.genes.num_genes;
        allGenes(1+offset:numModelGenes+offset) = models{i}.genes.geneStrs;
        offset = offset + numModelGenes;
    end
end

if modelbest.valid
    numModelGenes = modelbest.genes.num_genes;
    allGenes(1+offset:numModelGenes+offset) = modelbest.genes.geneStrs;
    offset = offset + numModelGenes;
end

if modelvalbest.valid
    numModelGenes = modelvalbest.genes.num_genes;
    allGenes(1+offset:numModelGenes+offset) = modelvalbest.genes.geneStrs;
    offset = offset + numModelGenes;
end

if modeltestbest.valid
    numModelGenes = modeltestbest.genes.num_genes;
    allGenes(1+offset:numModelGenes+offset) = modeltestbest.genes.geneStrs;
    offset = offset + numModelGenes;
end

unique_genes = unique(allGenes);
disp(['Total encoded genes found: ' num2str(numel(allGenes))]);
disp(['Unique encoded genes found: ' num2str(numel(unique_genes))]);
disp('Decoding & simplifying genes...please wait.');

genes.uniqueGenesCoded = unique_genes;
genes.uniqueGenesDecoded = gpreformat(gp,unique_genes)';
genes.numModelsScanned = numSuppliedModels;

symgenes = cell(numel(genes.uniqueGenesDecoded),1);
simpleGenes = cell(numel(genes.uniqueGenesDecoded),1);
simpleGenesChar = cell(numel(genes.uniqueGenesDecoded),1);

for i=1:numel(symgenes)
    
    disp(['Simplifying gene ' num2str(i)]);
    symgenes{i} = sym(genes.uniqueGenesDecoded{i});
    
    try
        simpleGenes{i} = gpsimplify(symgenes{i},10,verOld, true);
    catch
        warning(['Could not simplify gene ' num2str(i)]);
        simpleGenes{i} = symgenes{i};
    end
    
    simpleGenesChar{i} = char(simpleGenes{i});
end

[~, uniqueInds] = unique(simpleGenesChar);
genes.symUniqueInds = sort(uniqueInds);
genes.uniqueGenesSym = simpleGenes(genes.symUniqueInds);
genes.numUniqueGenes = numel(genes.uniqueGenesSym);

%rectify non-sym gene lists
genes.uniqueGenesCoded = genes.uniqueGenesCoded(genes.symUniqueInds);
genes.uniqueGenesDecoded = genes.uniqueGenesDecoded(genes.symUniqueInds);

genes.totalGenes = numel(allGenes);
genes.numUniqueGenes = numel(genes.uniqueGenesSym);
disp(['Unique decoded genes found: ' num2str(genes.numUniqueGenes)]);

%modify the GP structure to just contain the unique genes
gp.pop = genes.uniqueGenesCoded;
gp.state.run_completed = true;
gp.state.force_compute_theta = true;
gp.runcontrol.pop_size = genes.numUniqueGenes;
gp.userdata.showgraphs = false;
gp.userdata.stats = false;

codedGenes2Use = genes.uniqueGenesCoded;
geneOutputs =  zeros(length(gp.userdata.ytrain),genes.numUniqueGenes);

if isfield(gp.userdata,'yval') && ~isempty(gp.userdata.yval)
    geneOutputsVal = zeros(length(gp.userdata.yval),genes.numUniqueGenes);
else
    geneOutputsVal = [];
end

if isfield(gp.userdata,'ytest') && ~isempty(gp.userdata.ytest)
    geneOutputsTest = zeros(length(gp.userdata.ytest),genes.numUniqueGenes);
else
    geneOutputsTest = [];
end

rtrainGenes =    zeros(genes.numUniqueGenes,1);
geneComplexity = zeros(genes.numUniqueGenes,1);

%evaluate the genes against the output & get corrcoef
for i=1:numel(codedGenes2Use)
    evalstr = tree2evalstr(codedGenes2Use{i},gp);
    gp.state.current_individual = i;
    [fitness,gp,~,ypredtrain,~,~,~,~,~,~,...
        gene_outputs,gene_outputs_test,gene_outputs_val] = feval(gp.fitness.fitfun,{evalstr},gp);
    
    %in rare cases genes in isolation give overflows etc, just set the
    %corrcoef to zero.
    if isinf(fitness)
        rtrainGenes(i,1) = 0;
    else
        c = abs(corrcoef(ypredtrain,gp.userdata.ytrain));
        rtrainGenes(i,1) = c(1,2);
        geneComplexity(i,1) = getcomplexity(codedGenes2Use{i});
        geneOutputs(:,i) = gene_outputs(:,2);
        if ~isempty(gene_outputs_test)
            geneOutputsTest(:,i) = gene_outputs_test(:,2);
        elseif i == 1
            geneOutputsTest = [];
        end
        
        if ~isempty(gene_outputs_val)
            geneOutputsVal(:,i) = gene_outputs_val(:,2);
        elseif i == 1
            geneOutputsVal = [];
        end
    end
end

%tidy up
genes.about = 'A struct containing unique genes from a population.';
genes.geneOutputsTrain = geneOutputs;
genes.geneOutputsTest = geneOutputsTest;
genes.geneOutputsVal = geneOutputsVal;
genes.rtrain = rtrainGenes;
genes.complexity = geneComplexity;
genes = rmfield(genes,'symUniqueInds');
genes.filtered = false;
genes = orderfields(genes);
genes.source = 'uniqueGenes';