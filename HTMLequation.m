function strOut = HTMLequation(gp,eqn,numDigits)
%HTMLEQUATION Returns an HTML formatted multigene regression model equation.
%
%   HTMLEQN = HTMLEQUATION(GP,EQN) where EQN is a Symbolic Math object
%   representing the GPTIPS model and GP is the GPTIPS data structure
%   returns a string HTMLEQN containing the equation in HTML format.
%
%   HTMLEQN = HTMLEQUATION(GP,ID) where ID is a numeric model identifier in
%   the GP data structure. Returns a string HTMLEQN containing the overall
%   model equation in HTML format.
%
%   HTMLEQN = HTMLEQUATION(GP,ID, NUMDIGITS) does the same but formats the
%   displayed precision to NUMDIGITS where NUMDIGITS >=2.
%
%   HTMLEQN = HTMLEQUATION(GP,'best') returns a string HTMLEQN containing
%   the 'best' model equation (on the training data) in HTML format.
%
%   HTMLEQN = HTMLEQUATION(GP,'valbest') returns a string HTMLEQN
%   containing the 'best' model (on the validation data) equation in HTML
%   format.
%
%   HTMLEQN = HTMLEQUATION(GP,'testbest') returns a string HTMLEQN
%   containing the 'best' model (on the test data) equation in HTML format.
%
%   Note:
%
%   The model equation is not by default returned with full numeric
%   precision.
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also SYM/VPA, GPMODEL2SYM, GPMODELREPORT, PARETOREPORT, GPPRETTY

strOut = [];

if nargin < 2
    disp('Usage is HTMLEQUATION(EQN,GP)');
    return;
end

if ~gp.info.toolbox.symbolic
    error('The Symbolic Math Toolbox is required to use this function.');
end

if nargin < 3 || isempty(numDigits)
    numDigits = 4;
end

if numDigits < 2
    error('The number of digits must be > 1.');
end

modelform = true;

if isa(eqn,'sym')
    modelform = false;
elseif isnumeric(eqn)
    model = gpmodel2struct(gp,eqn,false,true,false);
elseif strcmpi(eqn,'best')
    model = gpmodel2struct(gp,'best',false,true,false);
elseif strcmpi(eqn,'testbest')
    model = gpmodel2struct(gp,'testbest',false,true,false);
elseif strcmpi(eqn,'valbest')
    model = gpmodel2struct(gp,'valbest',false,true,false);
else %otherwise assume that the 'eqn' is in raw form, e.g.'x1'
    modelform = false;
end

if modelform
    
    if model.valid
        eqn = formattedPrecisChar(model.sym,numDigits);
    else
        disp(['Invalid model specified. Reason: ' model.invalidReason]);
        return;
    end
    
else
    eqn = formattedPrecisChar(eqn,numDigits);
end

pat1 = 'x(\d+)'; %subscript regex;
pat2='\^([-]?\d+(\.\d*)?|\.\d+)'; %decimal numerical power superscript regex;
pat3 = '\^((\()[-]?\d+(/)\d+(\)))'; %fractional numerical power subscript

strOut = regexprep(eqn,pat1,'x<sub>$1</sub>');
strOut = regexprep(strOut,pat2,'<sup>$1</sup>');

%specific replacements for sqrt being represented as '^(1/2)' by symbolic math
%toolbox
strOut = strrep(strOut,'^(1/2)','<sup>1/2</sup>');
strOut = strrep(strOut,'^(3/2)','<sup>3/2</sup>');
strOut = strrep(strOut,'^(1/4)','<sup>1/4</sup>');
strOut = strrep(strOut,'^(1/8)','<sup>1/8</sup>');

%any other numerical fractions
strOut = regexprep(strOut,pat3,'<sup>$1</sup>');

%also, get rid of '*' for display purposes
strOut = strrep(strOut,'*',' ');

%replace plain versions of user defined variable names with marked up
%versions
for i = 1:numel(gp.nodes.inputs.names)
    if ~isempty(gp.nodes.inputs.names{i})
        strOut = strrep(strOut,gp.nodes.inputs.namesPlain{i},gp.nodes.inputs.names{i});
    end
end

function eqn = formattedPrecisChar(symEq,numDigits)
%gets the char form of the SYM equation with controlled numeric precision.
%Uses MuPAD's Pref::outputDigits setting and may not work properly on old
%Matlab versions

%exit if a char eqn.
if ~isa(symEq,'sym')
    eqn = symEq;
    return;
end

verReallyOld = verLessThan('matlab', '7.7.0');

if nargin < 2 || isempty(numDigits)
    numDigits = 4;
end

%get existing value of MuPAD's 'Pref::outputDigits' setting so this can be
%be restored after this function call.
userDigits = char(feval(symengine,'Pref::outputDigits'));

if ~verReallyOld
    evalin(symengine,['Pref::outputDigits(' int2str(numDigits) ')']);
end

%use VPA here (not sure why this is actually necessary having just set
%Pref::outputDigits but it seems to be reqd in some cases)
eqn = char(vpa(symEq,numDigits));

if ~verReallyOld
    evalin(symengine,['Pref::outputDigits(' userDigits ')']);
end
