function stats = standaloneModelStats(yactual,ypredicted)
%STANDALONEMODELSTATS Compute model performance stats for actual and predicted values.
%
%   STATS = STANDALONEMODELSTATS(YACTUAL,YPREDICTED) returns a structure
%   STATS containing model performance metrics.
%
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2

%residuals
e = (yactual-ypredicted);
stats.e = e;

%rsquared
stats.rsq = 1 - sum(e.^2)/sum( (yactual-mean(yactual)).^2 );

%corrcoef
c = corrcoef(yactual, ypredicted);
stats.r = c(1,2);

%rmse
stats.rmse = sqrt(mean(e.^2));

%mae
stats.mae = mean(abs(e));

%mse
stats.mse = mean(e.^2);


