function summary(gp,plotlog)
%SUMMARY Plots basic summary information from a run.
%
%   By default, log(fitness) is plotted rather than raw fitness when all
%   best fitness history values are > 0. Use SUMMARY(GP,FALSE) to plot raw
%   fitness values.
%
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2
%
%   See also RUNTREE, POPBROWSER, GPPOPVARS, GPMODELVARS

if nargin < 1
    disp('Usage is SUMMARY(GP) to plot log fitness values or SUMMARY(GP,FALSE) to plot raw fitness values.');
    return;
end

%plot log of fitness/rmse by default
if nargin < 2 || isempty(plotlog)
    plotlog = true;
end

%check if this is a merged gp structure, because the run history data will
%only apply to the first structure in the merge.
if gp.info.merged
    mergeStr = '1st run in merged population';
else
    mergeStr = 'run';
end

if ~isempty(gp.userdata.name)
    setname = ['. Data: ' gp.userdata.name];
else
    setname='';
end

if strncmpi('regressmulti',func2str(gp.fitness.fitfun),12)
    ylab1 = 'Log RMSE';
    ylab2 = 'RMSE';
else
   ylab1 = ['Log ' gp.fitness.label];
   ylab2 = gp.fitness.label;
end

if any(gp.results.history.bestfitness <= 0)
    plotlog = false;
end

h = figure;
set(h,'name','GPTIPS 2 run summary','numbertitle','off');

if ~plotlog && strncmpi('regressmulti',func2str(gp.fitness.fitfun),12)
    ylab1 = 'RMSE';
end


if plotlog
    subplot(2,1,1);
    stairs(0:1:gp.state.count-1,log(gp.results.history.bestfitness),'LineWidth',2,'Color',[0 0.45 0.74]);
    ylabel(ylab1);
else
    subplot(2,1,1);
    stairs(0:1:gp.state.count-1,gp.results.history.bestfitness,'LineWidth',2,'Color',[0 0.45 0.74]);
    ylabel(ylab2);
end
a=axis;
a(2) = gp.state.count-1;axis(a);
grid on;
     
    
title({['Summary of ' mergeStr], ['Config: ' char(gp.info.configFile) setname '.']},'interpreter','none','fontWeight','bold');
xlabel('Generation');
legend('Best fitness');
legend boxoff;

subplot(2,1,2);
hold on;
plot([0:1:gp.state.count-1],gp.results.history.meanfitness,'-x','LineWidth',2,'Color',[0.85 0.33 0.1]);
plot([0:1:gp.state.count-1],gp.results.history.meanfitness+gp.results.history.std_devfitness,'r:');hold on;
plot([0:1:gp.state.count-1],gp.results.history.meanfitness-gp.results.history.std_devfitness,'r:');
a=axis;
a(2) = gp.state.count-1;axis(a);
set(gca,'box','on');
legend('Mean fitness (+ - 1 std. dev)');
legend boxoff;
xlabel('Generation');
ylabel(ylab2);
grid on;
hold off;