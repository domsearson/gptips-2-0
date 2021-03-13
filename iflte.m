function x = iflte(a,b,c,d)
% IFLTE Node. Performs an element wise IF THEN ELSE operation on vectors and scalars.
%
%   X = IFLTE(A,B,C,D) computes X as follows on an element by element
%   basis:
%
%   If  A <= B then X = C else X = D.
%
%   Remarks:
%
%   If all of A,B,C,D are scalars then X will be scalar. If some, but not
%   all, of A,B,C,D are scalars then X will be a vector.
%
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2
%
%   See also THRESH, STEP, MINX, MAXX, NEG, GTH, LTH, GPNOT, GPAND, GPOR

x = ((a<=b) .* c) + ((a>b) .* d);

