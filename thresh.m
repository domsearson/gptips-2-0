function x = thresh(a,b)
%THRESH Node. Threshold function that returns 1 if the first argument is >= to the second argument and returns 0 otherwise.
%
%   X = THRESH(A,B)
%
%   This performs: 
%
%   If A >= B then X = 1 else X = 0 on an element by element basis.
%
%   Remarks:
%
%   If both of A and B are scalars then X will be scalar. If one or more of
%   A and B are vectors then X will be a vector.
%
%   Copyright (c) 2009-2015 Dominic Searson 
%   
%   GPTIPS 2
%
%   See also IFLTE, STEP, MAXX, MINX, GTH, LTH, GPAND, GPNOT, GPOR

x=((a>=b) .* 1) + ((b>a) .* 0);

