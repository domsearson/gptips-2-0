classdef gpmodelfilter
    %GPMODELFILTER Object to filter a population of multigene symbolic regression models.
    %
    %   Usage:
    %
    %   First, create a default filter object F
    %
    %   F = GPMODELFILTER
    %
    %   Next, set the properties of the filter. E.g. to keep only models
    %   that have an R^2 >= 0.7 (training data) but contain no more than 3
    %   input variables use:
    %
    %   F.MINR2TRAIN = 0.7; F.MAXVARS = 3;
    %
    %   Finally, apply the filter to the population of models in the GP
    %   struct:
    %
    %   GPF = F.APPLYFILTER(GP);
    %
    %   This returns a structure GPF which is functionally identical to GP
    %   except that that models not meeting the filter specifications have
    %   been removed.
    %
    %   It also removes duplicate models whose genotypes are identical. All
    %   the usual GPTIPS functions such as POPBROWSER, RUNTREE, GPPOPVARS,
    %   GPPRETTY etc. can be applied to the filtered data structure GPF.
    %
    %   Remarks:
    %
    %   The filter has the following settings and defaults:
    %
    %      MINR2TRAIN = 0 (keeps models attaining this R2 on the
    %      training data).
    %
    %      MAXCOMPLEXITY = Inf (keeps models that have this level of
    %      expressional complexity or lower).
    %
    %      PARETOFRONT = FALSE (true to keep only models on the Pareto
    %      front of performance and expressional complexity). Note that
    %      'expressional complexity' is used to compute the front even if
    %      the GPTIPS run was actually performed using 'node count' as the
    %      measure of tree complexity.
    %
    %      MAXVARS = Inf (keeps models containing this max number of input
    %      vars).
    %
    %      MINVARS = 0 (keeps models containing this min number of input
    %      vars).
    %
    %      INCLUDEVARS = [] (keeps models that include these input variables
    %      - a row vector containing the input indices).
    %
    %      EXCLUDEVARS = [] (keeps models that do not contain these
    %      input variables - a row vector containing the input indices).
    %
    %      REMOVEDUPLICATES = TRUE (removes duplicate genotypes from the
    %      population).
    %
    %   Hence, the default filter object only removes duplicates.
    %
    %   [GPF,MODELINDS] = F.APPLYFILTER(GP) does the same but also returns
    %   a Boolean vector MODELINDS which refers to the population indices
    %   in GP that survived the filtering process.
    %
    %   Copyright (c) 2009-2015 Dominic Searson 
    %
    %   GPTIPS 2
    %
    %   See also mergegp, genefilter, popbrowser, paretoreport
    
    properties (SetAccess = public)
        minR2train = 0; %the minimum R2 on the selected dataset
        maxComplexity = Inf; %the maximum complexity of models to retain
        paretoFront = false; %true to select only models on the pareto front
        maxVars = Inf; %selects models containing a max number of input vars
        minVars = 0; %selects models containing a minimum number of input vars
        includeVars =[]; %row vector of inputs that the models must contain
        excludeVars = []; %row vector of inputs that the models must not contain
        removeDuplicates = true; %true to remove duplicate genotypes from population
    end
    
    methods
        
        %set removeDuplicates property
        function obj = set.removeDuplicates(obj, bool)
            if ~islogical(bool)
                disp('Error: removeDuplicates must either be set to true or false');
                return;
            end
            obj.removeDuplicates=bool;
        end
        
        %set excludeVars property
        function obj = set.excludeVars(obj,varList)
            
            if isempty(varList)
                obj.excludeVars = varList;
                return;
            end
            
            if size(varList,1) > 1
                disp('Error: supplied list must be a row vector of input variable numbers.');
                return;
            end
            
            if any(find(varList <= 0))
                disp('Error: 0 or negative numbers are not valid input variable numbers.');
                return;
            end
            
            if numel(varList) ~= numel(unique(varList))
                disp('Error: supplied list must not contain duplicate input variable numbers.');
                return;
            end
            
            if ~isempty(intersect(varList,obj.includeVars))
                disp('Error: supplied exclude list contains variables on the include list.');
                return;
            end
            
            obj.excludeVars = varList;
            
        end%includeVars
        
        %set includeVars property
        function obj = set.includeVars(obj,varList)
            
            if isempty(varList)
                obj.includeVars = varList;
                return;
            end
            
            if size(varList,1) > 1
                disp('Error: supplied list must be a row vector of input variable numbers.');
                return;
            end
            
            if any(find(varList <= 0))
                disp('Error: 0 or negative numbers are not valid input variable numbers.');
                return;
            end
            
            if numel(varList) ~= numel(unique(varList))
                disp('Error: supplied list must not contain duplicate input variable numbers.');
                return;
            end
            
            if numel(varList) > obj.maxVars 
                disp('Error: supplied list must not exceed the maxVars filter property.');
                return;
            end
            
            if ~isempty(intersect(varList,obj.excludeVars))
                disp('Error: supplied include list contains variables on the exclude list.');
                return;
            end
            
            obj.includeVars = varList;
            
        end%includeVars
        
        
        %set R2min property
        function obj = set.minR2train(obj,r2min)
            
            if ~isa(r2min,'double')
                disp('Error: minimum R^2 training must be between 0 and 1.');
                return;
            end
            
            if r2min < 0 || r2min > 1
                disp('Error: minimum R^2 training must be between 0 and 1.');
                return;
            end
            obj.minR2train = r2min;
        end
        
        
        %set maxVars property
        function obj = set.maxVars(obj,maxvars)
            
            if ~isa(maxvars,'double')
                disp('Error: max. input vars must be greater than 0.');
                return;
            end
            
            if maxvars < 1
                disp('Error: max. input vars must be greater than 0.');
                return;
            end
            
            if maxvars < obj.minVars
                disp('Error: max. input vars must be equal to or greater than min. input vars.');
                return;
            end
            
            obj.maxVars = maxvars;
        end
        
        %set minVars property
        function obj = set.minVars(obj,minvars)
            
            if ~isa(minvars,'double')
                disp('Error: min. input vars must be 1 or greater');
                return;
            end
            
            if minvars < 1
                disp('Error: min. input vars must be 1 or greater');
                return;
            end
            
            if minvars > obj.maxVars
                disp('Error: min. input vars must be smaller than or equal to max. input vars.');
                return;
            end
            
            obj.minVars = minvars;
        end
        
        %set maxComplexity property
        function obj = set.maxComplexity(obj,maxc)
            
            if ~isa(maxc,'double')
                disp('Error: maximum complexity must be a number greater than 1.');
                return;
            end
            
            if maxc < 1
                disp('Error: maximum complexity must be a number greater than 1.');
                return;
            end
            obj.maxComplexity = maxc;
        end
        
        %set pareto front property
        function obj = set.paretoFront(obj,bool)
            
            if ~islogical(bool)
                disp('Error: paretoFront must either be set to true or false');
                return;
            end
            obj.paretoFront = bool;
        end
        
        %function to apply the filter settings to a GP structure
        function [gp,filterInds] = applyFilter(obj,gp)
            
            if nargin < 2
                error('Usage is APPLYFILTER(GP)');
            end
            
            
            if ~isfield(gp.fitness,'r2train')
                error('GPMODELFILTER cannot find R^2 training data. GPMODELFILTER is intended for use with populations containing multigene regression models.');
            end
            
            if gp.runcontrol.pop_size > 1000
                disp('Please wait, this may take a few moments...');
            end
            
            %always do r2 & complexity filter first
            filterInds = (gp.fitness.r2train >= obj.minR2train) & (gp.fitness.complexity <= obj.maxComplexity);
            locations = find(filterInds);
            numLeft = numel(locations);
            disp([num2str(numLeft) ' models passed R^2 training (>= ' num2str(obj.minR2train) ') and expressional complexity (<= ' int2str(obj.maxComplexity)  ') filter ...']);
            
            if numLeft == 0
               gp = []; 
               return;
            end
            
            %pareto rank 1 filter
            if obj.paretoFront
                disp('Computing pareto front on training data...');
                paretoInds = ndfsort_rank1([(1-gp.fitness.r2train) gp.fitness.complexity]);
                filterInds = filterInds & paretoInds;
            end
            
            %next apply vars filters
            if ~isinf(obj.maxVars) || obj.minVars || ~isempty(obj.includeVars) || ~isempty(obj.excludeVars)
                
                locations = find(filterInds);
                numLeft = numel(locations);
                disp(['Applying variable filter to ' num2str(numLeft) ' remaining models ...']);
                
                for i=1:numLeft
                    hvec = gpmodelvars(gp,locations(i));
                    vars = find(hvec);
                    numvars = numel(vars);
                    
                    if numvars > obj.maxVars || numvars < obj.minVars
                        filterInds(locations(i)) = false;
                    else
                        
                        if ~isempty(obj.excludeVars)
                            if ~isempty(intersect(vars,obj.excludeVars))
                                filterInds(locations(i)) = false;
                            end
                        end
                        
                        if ~isempty(obj.includeVars)
                            intersection = intersect(vars,obj.includeVars);
                            if  numel(intersection) < numel(obj.includeVars)
                                filterInds(locations(i)) = false;
                            end
                        end
                        
                    end
                    
                    
                end %end of loop through individuals
            end
            
            
            %if enabled, loop through remaining genotypes and remove
            %duplicates.
            if obj.removeDuplicates && ~gp.info.duplicatesRemoved
                
                locations = find(filterInds);
                numLeft = numel(locations);
                disp(['Removing genotype duplicates from ' num2str(numLeft) ' remaining models ...']);
                
                for i=1:numLeft
                    
                    for j=1:numLeft
                        
                        if i~=j && locations(i) && locations(j)
                            model_i = gp.pop{locations(i)};
                            model_j = gp.pop{locations(j)};
                            
                            if numel(model_i) ~= numel(model_j)
                                continue
                            end
                            
                            if isequal(sort(model_i),sort(model_j))
                                filterInds(locations(j)) = false;
                                locations(j)=0;
                            end
                        end
                        
                    end
                    
                end
                
                gp.info.duplicatesRemoved = true;
            end%end of removeDuplicates
            
            
            numModels = sum(filterInds);
            
            if numModels == 0
                disp('No models matching all filter criteria were found.');
                gp=[];
                return
            end
            
            gp.pop = gp.pop(filterInds);
            gp.fitness.returnvalues = gp.fitness.returnvalues(filterInds);
            gp.fitness.values = gp.fitness.values(filterInds);
            gp.fitness.r2train = gp.fitness.r2train(filterInds);
            
            if isfield(gp.fitness,'r2val')
                gp.fitness.r2val = gp.fitness.r2val(filterInds);
            end
            
            if isfield(gp.fitness,'r2test')
                gp.fitness.r2test = gp.fitness.r2test(filterInds);
            end
            
            
            gp.fitness.complexity = gp.fitness.complexity(filterInds);
            gp.fitness.nodecount = gp.fitness.nodecount(filterInds);
            gp.runcontrol.pop_size = numModels;
            gp.info.filtered = true;
            gp.info.lastFilter = obj;
            gp.source = 'gpmodelfilter';
            disp([num2str(numModels) ' models passed the filtering process.']);
        end %applyFilter
        
    end %methods
    
end %classdef