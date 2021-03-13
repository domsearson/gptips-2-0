function gpmodel = genes2gpmodel(gp,genes,uniqueGeneList,tbxStats,createSyms,modelStruc,fastSymMode)
%GENES2GPMODEL Create a data structure representing a multigene symbolic regression model from the specified gene list.
%
%   GPMODEL = GENES2GPMODEL(GP,GENES,UNIQUEGENELIST) creates a multigene
%   model GPMODEL (functionally identical to that obtained using the
%   GPMODEL2STRUCT function) using the list of genes in UNIQUEGENELIST
%   where the unique genes are contained within the GENES data structure.
%   The list is comprised of numeric model IDs, e.g. [77 22 99 1].
%
%   The 'optimal' gene weighting coefficients are computed using a least
%   squares procedure on the training data.
%
%   Note:
%
%   The GENES data structure must be first obtained using the UNIQUEGENES
%   function. See GPMODEL2STRUCT for more details about the GPMODEL data
%   structure returned.
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also UNIQUEGENES, GPMODEL2STRUCT, GENEBROWSER, GENEFILTER

if nargin < 3
    error('Usage is GENES2GPMODEL(GP,GENES,UNIQUEGENELIST)');
end

if nargin < 6 || isempty(fastSymMode)
    fastSymMode = false;
end

%scan model genes for input frequency, depth, complexity? (default = yes).
%(setting to false is a bit quicker but doesn't compute the structural info)
if nargin < 6 || isempty(modelStruc)
    modelStruc = true;
end

%create symbolic objects of overall model and genes? (default = yes).
%(setting to false is significantly quicker but you don't get the symbolic
%math object for each gene)
if nargin < 5 || isempty(createSyms)
    createSyms = true;
end

%compute statistics toolbox stats? (default = no).
if nargin < 4 || isempty(tbxStats)
    tbxStats = false;
end

%remove duplicates in list
uniqueGeneList = unique(uniqueGeneList);
noGene = (uniqueGeneList == 0);
uniqueGeneList(noGene) = [];

%get gene encodings from genes structure
geneStrs = genes.uniqueGenesCoded(uniqueGeneList)';

%create gpmodel struct
gpmodel = gpmodel2struct(gp,geneStrs,tbxStats,createSyms,modelStruc,fastSymMode);
gpmodel.source = 'genes2gpmodel';