function c = gpand(a,b)
%GPAND Node. Wrapper for logical AND
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also GPNOT, GPOR, GTH, LTH, MAXX, MINX, STEP, THRESH, IFLTE

if any(isnan(a)) || any(isnan(b))
    c = nan;
    return;
end
c = double(and(real(a),real(b)));