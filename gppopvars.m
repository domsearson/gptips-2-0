function hvec = gppopvars(gp,R2thresh,complexityThresh)
%GPPOPVARS Display frequency of the input variables present in models in the population.
%
%   For multigene symbolic regression problems:
%
%   GPPOPVARS(GP) displays an input frequency barchart for all models in GP
%   with R2 >= 0.6 where R2 is the coefficient of the determination for the
%   models on the training data.
%
%   GPPOPVARS(GP,R2THRESH) displays an input frequency barchart for all
%   models with R2 >= R2THRESH. R2THRESH must be > 0 and <= 1.
%
%   GPPOPVARS(GP,R2THRESH,COMPLEXITYTHRESH) displays an input frequency
%   barchart for all models with R2 >= R2THRESH which have complexities
%   (node count or expressional complexity) lower or equal to
%   COMPLEXITYTHRESH.
%
%   HITVEC = GPPOPVARS(GP,R2THRESH,COMPLEXITYTHRESH) returns a frequency
%   vector and suppresses graphical output.
%
%   For other (non multigene regression) problems:
%
%   HITVEC = GPPOPVARS(GP) displays and returns an input frequency vector
%   for the best 5% of the population.
%
%   HITVEC = GPPOPVARS(GP,TOP_FRAC) displays and returns an input frequency
%   vector for the best fraction TOP_FRAC of the population. TOP_FRAC must
%   be > 0 and <= 1.
%
%   Remarks:
%
%   Assumes lower fitnesses are better.
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also GPMODELVARS

if nargin < 1
    disp('Basic usage is GPPOPVARS(GP).');
    
    if nargout > 0
        hvec = [];
    end
    
    return
end

if nargout < 1
    graph = true;
else
    graph = false;
end

if nargin < 3
    complexityThresh = Inf;
end

%set threshold defaults
if nargin < 2
    R2thresh = 0.6;
    top_frac = 0.05;
end

if R2thresh <= 0 || R2thresh > 1
    error('Supplied R^2 threshold must be greater than zero and less than or equal to 1.');
end

if complexityThresh < 1
    error('Complexity/nodecount threshold must be greater than zero.');
end

numx = gp.nodes.inputs.num_inp;
hitvec = zeros(1,numx);

if isfield(gp.userdata,'name') && ~isempty(gp.userdata.name)
    setname = ['Data: ' gp.userdata.name];
else
    setname = '';
end

%for mg symbolic regression models
if strncmpi('regressmulti',func2str(gp.fitness.fitfun),12)
    
    %get indices of models satisfying constraints
    inds = (gp.fitness.r2train >= R2thresh) & (gp.fitness.complexity <= complexityThresh);
    numModels = sum(inds);
    
    if numModels == 0
        disp(['No models matching the supplied criteria (R2 >= ' num2str(R2thresh)...
            ', complexity <= ' num2str(complexityThresh) ') were found.']);
        hitvec = [];
        return
    end
    
    inds2scan = find(inds);
    num2scan = numel(inds2scan);
    
    if num2scan > 200
        disp('Please wait, scanning models ...');
    end
    
    for i=1:num2scan
        model = gp.pop{i};
        hitvec = hitvec + scangenes(model,numx);
    end
    
    if ~isinf(complexityThresh)
        if gp.fitness.complexityMeasure
            endstr = [' and complexity <= ' num2str(complexityThresh) '.'];
        else
            endstr = [' and node count <= ' num2str(complexityThresh) '.'];
        end
    else
        endstr = '.';
    end
    titlestr = {setname,['Input frequency in ' num2str(numModels) ' models (from ' num2str(gp.runcontrol.pop_size) ') with R^2 >= ' num2str(R2thresh) endstr]};
    
else %non mg symbolic regression
    
    num2process = ceil(top_frac*gp.runcontrol.pop_size);
    
    [~,sort_ind] = sort(gp.fitness.values);
    sort_ind = sort_ind(1:num2process);
    
    if ~gp.fitness.minimisation
        sort_ind = flipud(sort_ind);
    end
    
    %loop through population
    for i=1:num2process
        model = gp.pop{sort_ind(i)};
        hitvec = hitvec + scangenes(model,numx);
    end
    titlestr= ['Input frequency - best ' num2str(100*top_frac) '% of whole population.'];
end

% plot results as barchart
if graph
    
    h = figure;
    set(h,'name','GPTIPS 2 Population input frequency','numbertitle','off');
    a = gca;
    bar(a,hitvec);
    if ~verLessThan('matlab','8.4') %R2014b
        a.Children.FaceColor = [0 0.45 0.74];
        a.Children.BaseLine.Visible = 'off';
    else
        b = get(a,'Children');
        set(b,'FaceColor',[0 0.45 0.74],'ShowBaseLine','off');
    end
    grid on;
    xlabel('Input');
    ylabel('Input frequency');
    title(titlestr,'FontWeight','bold');
    hitvec=hitvec';
else
    h = [];
end

if nargout > 0
    hvec = hitvec';
end
