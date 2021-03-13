function fitness = runtree(gp,ID,knockout)
%RUNTREE Run the fitness function on an individual in the current population.
%
%   RUNTREE(GP,ID) runs the fitness function using a user selected
%   individual with numeric identifier ID from the current population.
%   Despite the name RUNTREE will run either a single or a multigene
%   individual.
%
%   RUNTREE(GP,'best') runs the fitness function using the 'best'
%   individual in the current population.
%
%   RUNTREE(GP,'valbest') runs the fitness function using the best
%   individual on the validation data set (if it exists - for symbolic
%   regression problems that use the fitness function REGRESSMULTI_FITFUN).
%
%   RUNTREE(GP,'testbest') runs the fitness function using the best
%   individual on the test data set (if it exists - for symbolic
%   regression problems that use the fitness function REGRESSMULTI_FITFUN).
%
%   RUNTREE(GP,GPMODEL) runs the fitness function using the GPMODEL struct
%   representing a multigene regression model, i.e. the struct returned by
%   the functions GPMODEL2STRUCT or GENES2GPMODEL.
%
%   FITNESS = RUNTREE(GP,ID) also returns the FITNESS value as returned by
%   the fitness function specified in gp.fitness.fitfun
%
%   Additional functionality:
%
%   RUNTREE can also accept an optional third argument KNOCKOUT which
%   should be a boolean vector the with same number of entries as genes in
%   the individual to be run. This evaluates the individual with the
%   indicated genes removed ('knocked out').
%
%   E.g. RUNTREE(GP,'best',[1 0 0 1]) knocks out the 1st and 4th genes from
%   the best individual of run. In the case of multigene symbolic
%   regression (i.e. if the fitness function is REGRESSMULTI_FITFUN) the
%   weights for the remaining genes are recomputed by least squares
%   regression on the training data.
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also EVALFITNESS, GPMODELREPORT

if nargin < 2 || isempty(ID)
    disp('Basic usage is RUNTREE(GP,ID) where ID is the population identifier of the selected individual.');
    disp('or RUNTREE(GP,''best'') to run the best individual in the population.');
    
    if nargout > 0
        fitness = [];
    end
    
    return;
    
elseif nargin < 3
    knockout = 0;
end

if isempty(knockout) || ~any(knockout)
    doknockout = false;
else
    doknockout = true;
end

i = ID;

if isnumeric(ID)
    
    if i > 0 && i <= gp.runcontrol.pop_size
        
        %set this in case the fitness function needs to retrieve
        %the right returnvalues
        gp.state.current_individual = i;
        treestrs = tree2evalstr(gp.pop{i},gp);
        
        %if genes are being knocked out then remove appropriate gene
        if doknockout
            treestrs = kogene(treestrs, knockout);
            gp.state.force_compute_theta = true; %need to recompute gene weights if doing symbolic regression
            gp.userdata.showgraphs = true; %if using symbolic regression, plot graphs
        end
        
        fitness = feval(gp.fitness.fitfun,treestrs,gp);
        
    else
        error('A valid population member ID must be entered, e.g. 1, 99 or ''best''');
    end
    
elseif ischar(ID) && strcmpi(ID,'best')
    
    gp.fitness.returnvalues{gp.state.current_individual} = gp.results.best.returnvalues;
    treestrs = gp.results.best.eval_individual;
    
    if doknockout
        treestrs = kogene(treestrs, knockout);
        gp.state.force_compute_theta = true;
        gp.userdata.showgraphs = true;
    end
    
    fitness = feval(gp.fitness.fitfun,treestrs,gp);
    
elseif ischar(ID) && strcmpi(ID,'valbest')
    
    % check that validation results/data present
    if ~isfield(gp.results,'valbest')
        disp('No validation results/data were found. Try runtree(gp,''best'') instead.');
        return;
    end
    
    %copy "valbest" return values to a slot in the "current" return values
    gp.fitness.returnvalues{gp.state.current_individual} = gp.results.valbest.returnvalues;
    
    treestrs = gp.results.valbest.eval_individual;
    
    if doknockout
        treestrs = kogene(treestrs, knockout);
        gp.state.force_compute_theta = true;
        gp.userdata.showgraphs = true;
    end
    
    fitness=feval(gp.fitness.fitfun,treestrs,gp);
    
 elseif ischar(ID) && strcmpi(ID,'testbest')
    
    % check that test data results are present
    if ~isfield(gp.results,'testbest')
        disp('No test results/data were found. Try runtree(gp,''best'') instead.');
        return;
    end
    
    %copy "testbest" return values to a slot in the "current" return values
    gp.fitness.returnvalues{gp.state.current_individual} = gp.results.testbest.returnvalues;
    
    treestrs = gp.results.testbest.eval_individual;
    
    if doknockout
        treestrs = kogene(treestrs, knockout);
        gp.state.force_compute_theta = true;
        gp.userdata.showgraphs = true;
    end
    
    fitness=feval(gp.fitness.fitfun,treestrs,gp);   
    
    %if the selected individual is a GPMODEL struct (NB knockout disabled
    %for this form)
elseif isa(ID,'struct') && isfield(ID,'source') && ...
        (strcmpi(ID.source,'gpmodel2struct') || strcmpi(ID.source,'genes2gpmodel') );
    
    treestrs = ID.genes.geneStrs;
    treestrs = tree2evalstr(treestrs,gp);
    gp.fitness.returnvalues{gp.state.current_individual} = ID.genes.geneWeights;
    fitness = feval(gp.fitness.fitfun,treestrs,gp);
    
else
    error('Invalid argument.');  
end