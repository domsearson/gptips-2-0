function x = pdiv(arg1,arg2)
%PDIV Node. Performs a protected element by element divide.
%
%   X = PDIV(ARG1,ARG2)
% 
%   For each element in ARG1 and ARG2:
% 
%   X = ARG1/ARG2
%
%   Unless ARG2 == 0 then X = 0.
%
%   Remarks:
%   Renamed from PDIVIDE due to Symbolic Math Toolbox bug. Also -inf bug
%   fixed since v1.0
%
%   (c) Dominic Searson 2009-2015
%
%   GPTIPS 2
%
%   See also PLOG, RDIVIDE

x = arg1./arg2;
i = isinf(x);
x(i) = 0;
