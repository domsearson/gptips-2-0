function f = gpmodel2func(gp,ID)
%GPMODEL2FUNC Converts a multigene symbolic regression model to an anonymous function and returns the function handle.
%
%   F = GPMODEL2FUNC(GP,ID) converts the model identified by numeric
%   identifier ID to a standard MATLAB anonymous function with function
%   handle F.
%
%   F = GPMODEL2FUNC(GP,'best') converts the best model on the training
%   data to a MATLAB anonymous function with function handle F.
%
%   F = GPMODEL2FUNC(GP,'valbest') converts the best model on the
%   validation data (if it exists) to a MATLAB anonymous function with
%   function handle F.
%
%   F = GPMODEL2FUNC(GP,'testbest') converts the best model on the test
%   data (if it exists) to a MATLAB anonymous function with function handle
%   F.
%
%   F = GPMODEL2FUNC(GP,GPMODEL) operates on the GPMODEL struct
%   representing a multigene regression model, i.e. the struct returned by
%   the functions GPMODEL2STRUCT or GENES2GPMODEL.
%
%   The anonymous function F can then be used to evaluate the model on new
%   data. It can also be used in MATLAB visualisation tools such as the
%   EZSURF function.
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also GPMODEL2SYM, GPMODEL2MFILE, FUNCTION_HANDLE, MATLABFUNCTION,
%            EZPLOT, EZCONTOUR, EZSURF

if ~gp.info.toolbox.symbolic
    error('The Symbolic Math Toolbox is required to use this function.');
end

if nargin < 2
    disp('Basic usage is F = GPMODEL2FUNC(GP,ID)');
    disp('or F = GPMODEL2FUNC(GP,''best'')');
    disp('or F = GPMODEL2FUNC(GP,''valbest'')');
    disp('or F = GPMODEL2FUNC(GP,''testbest'')');
    return;
end

if isnumeric(ID) && ( ID < 1 || ID > numel(gp.pop) )
    error('The supplied numerical model indentifier ID is not valid.');
end

if ~strncmpi('regressmulti', func2str(gp.fitness.fitfun),12)
    error('GPMODEL2FUNC may only be used for multigene symbolic regression problems.');
end

s = gpmodel2sym(gp,ID);

if isempty(s)
    error('Not a valid model ID or model selector');
end

f = matlabFunction(s);