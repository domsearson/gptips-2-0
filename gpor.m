function c = gpor(a,b)
%GPOR Node. Wrapper for logical or
%
%   Copyright (c) 2009-2015 Dominic Searson 
%   
%   GPTIPS 2
%
%   See also GPNOT, GPAND, LTH, GTH, MAXX, MINX, NEG, IFLTE, STEP, THRESH

if any(isnan(a)) || any(isnan(b))
    c = nan;
    return;
end
c = double(or(real(a),real(b)));