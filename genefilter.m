function genes = genefilter(genes,corrThresh)
%GENEFILTER Removes highly correlated genes from a unique GENES struct.
%
%   GENESFILT = GENEFILTER(GENES) returns a unique genes structure
%   GENESFILT with the most complex gene of any highly correlated pair of
%   genes removed from the GENES structure. Hence, the most complex of any
%   pair of genes whose outputs (as evaluated on the training data) have a
%   correlation of >= (1 - CORRTHESH) is removed.
%
%   This has the effect of reducing the size of the 'gene space' whilst
%   leaving the predictive ability of the remaining genes largely
%   unchanged. The default correlation threshold of CORRTHRESH is 0.001.
%
%   GENESFILT = GENEFILTER(GENES,CORRTHRESH) does the same but CORRTHRESH
%   is the user supplied correlation threshold.
%
%   Remarks:
%
%   Prior to using this function, the GENES structure should be generated
%   using the UNIQUEGENES function.
%
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2
%
%   See also UNIQUEGENES, GENEBROWSER, GPMODELFILTER

if nargin < 1
   error('Basic usage is GENEFILTER(GENES)');
end

if ~gptoolboxcheck
    error('The Symbolic Math Toolbox is required to use this function.');
end

%set the default correlation threshold
%(i.e. when pairs of genes that have a correlation > (1-threshold)
%then the most complex gene in the pair is removed.
if nargin < 2 || isempty(corrThresh)
    corrThresh = 0.001;
end

disp(['Filtering genes with correlation threshold ' num2str(corrThresh)]);

%get abs. correlation matrix of gene outputs
c = abs(corrcoef(genes.geneOutputsTrain));

%loop pairwise through genes and flag correlates for removal.
%when correlated then always remove the more complex of the genes.
removals = false(genes.numUniqueGenes,1);

for i=1:genes.numUniqueGenes
    
    %if already removed then skip
    if removals(i)
        continue;
    end
    
    %flag matches for ith gene
    matches = find( c(:,i) >= (1 - corrThresh) );
    
    %remove the identity match
    ident = (matches == i);
    matches(ident) = [];
    
    %if no other matches then jump to next
    if isempty(matches)
        continue;
    end
    
    %loop through matches for ith gene and get complexities for each match
    identComplexity = genes.complexity(i);
    for j=1:numel(matches)
        
        complexity = genes.complexity(matches(j));
        
        %flag for removal jth gene if complexity of jth is higher
        %flag for removal ith gene otherwise
        if identComplexity <= complexity
            removals(matches(j)) = true;
        else
            removals(i) = true;
        end
        
    end
    
end

%tidy up GENES structure
genes.filtered = corrThresh;
genes.numUniqueGenes = genes.numUniqueGenes-sum(removals);
remain = ~removals;
genes.rtrain = genes.rtrain(remain);
genes.complexity = genes.complexity(remain);
genes.uniqueGenesSym = genes.uniqueGenesSym(remain);
genes.uniqueGenesCoded = genes.uniqueGenesCoded(remain);
genes.uniqueGenesDecoded = genes.uniqueGenesDecoded(remain);
genes.geneOutputsTrain = genes.geneOutputsTrain(:,remain);

if ~isempty(genes.geneOutputsTest)
    genes.geneOutputsTest = genes.geneOutputsTest(:,remain);
end

if ~isempty(genes.geneOutputsVal)
    genes.geneOutputsVal = genes.geneOutputsVal(:,remain);
end

disp(['Number of genes removed : ' int2str(sum(removals))]);
disp(['Number of genes retained: ' int2str(sum(remain))]);

genes.source = 'genefilter';