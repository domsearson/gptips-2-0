function y = gth(a,b)
%GTH Node. Greater than operator
%
%   Performs an element by element comparison of A and B and returns
%   1 if A(i) > B(i) and 0 otherwise.
%
%   (c) Dominic Searson 2009-2015
%
%   GPTIPS 2
%
%   See also LTH, STEP, THRESH, IFLTE, MINX, MAXX, NEG, GPAND, GPNOT, GPOR

y = double(lt(a,b));