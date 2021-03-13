function comparemodelsREC(gp,modelList,dataset,showBest,showValBest,showTestBest)
%COMPAREMODELSREC Graphical REC performance curves for between 1 and 5 multigene models.
%
%   COMPAREMODELSREC(GP,MODELLIST,DATASET,SHOWBEST,SHOWVALBEST,SHOWTESTBEST)
%   generates a graphical REC (regression error characteristic) comparison
%   of multigene regression models in GP with the numeric IDs in the row
%   vector MODELLIST. DATASET is either 'train','test' or 'val' and setting
%   SHOWBEST to TRUE also shows the best model in GP (as evaluated on the
%   training data) and setting SHOWVALBEST to TRUE shows the best model of
%   the run as evaluated on the validation data (if it exists). Similarly,
%   setting SHOWTESTBEST to TRUE shows the best model as evaluated on the
%   test data (if it exists).
%
%   Examples:
%
%   COMPAREMODELSREC(GP,[10 19 12]) shows REC curves for models 10, 19 and
%   12 on the training data.
%
%   COMPAREMODELSREC(GP,[10 19 12],'test',TRUE) shows REC curves for
%   models 10, 19 and 12 on the test data and also shows the 'best' model
%   of the run (as evaluated on the training data).
%
%   Remarks: 
%
%   REC curves are similar to receiever operating characteristic (ROC)
%   curves for classifiers. The REC curve for a model shows the proportion
%   of data (on the Y axis, as a fraction between 0 and 1) that was
%   predicted with an accuracy equal to or better than the absolute error
%   on the corresponding X axis. Better models lie above and to the left
%   of worse models.
%
%   Based on the method outlined in "Regression Error Characteristic
%   Curves", Jinbo Bi & Kristin P. Bennett, Proceedings of the Twentieth
%   International Conference on Machine Learning (ICML-2003), Washington
%   DC, 2003.
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also POPBROWSER, GPMODELREPORT, REGRESSIONERRORCHARACTERISTIC

if nargin < 5 || isempty(showValBest)
    showValBest = false;
end

if nargin < 4 || isempty(showBest)
    showBest = false;
end

if nargin < 5 || isempty(showTestBest)
   showTestBest = false; 
end

if nargin < 3
    dataset = 'train';
end

if nargin < 2 || isempty(modelList)
    disp('Usage is COMPAREMODELSREC(GP,MODELLIST)');
    return;
end

if ~strcmpi(func2str(gp.fitness.fitfun),'regressmulti_fitfun');
    error('This function is only for use on multigene regression models.');
end

if isempty(dataset)
    dataset = 'train';
end

if strcmpi(dataset,'train')
    dset = 1;
    
elseif strcmpi(dataset,'test')
    
    if ~isfield(gp.userdata,'xtest')
        error('Cannot find testing data.');
    end
    dset = 2;
    
elseif strcmpi(dataset,'val')
    
    if ~isfield(gp.userdata,'xval')
        error('There is no validation data.');
    end
    dset = 3;
    
else
    error('The dataset must be ''train'', ''test'' or ''val''.');
end

if ~isnumeric(modelList) || size(modelList,1) > 1
    error('Supplied model list must be a row vector of model indices.');
end

numModels = numel(modelList);

if numModels > 5
    error('Maximum number of models to compare is 5.');
end

plotdata = struct;

for i=1:numModels
    model = gpmodel2struct(gp,modelList(i),false,false,false);
    if ~model.valid
        error(['Model ' num2str(modelList(i)) ' in the supplied list is invalid because: ' model.invalidReason]);
    end
    
    if dset == 1
        [xdata,ydata,xref,yref] = regressionErrorCharacteristic(gp.userdata.ytrain,model.train.ypred);
    elseif dset == 2
        [xdata,ydata,xref,yref] = regressionErrorCharacteristic(gp.userdata.ytest,model.test.ypred);
    else
        [xdata,ydata,xref,yref] = regressionErrorCharacteristic(gp.userdata.yval,model.val.ypred);
    end
    
    plotdata.xref = xref;
    plotdata.yref = yref;
    plotdata.model(i).xdata = xdata;
    plotdata.model(i).ydata = ydata;
end

%plot
pcol = 'bgrcy';
recFig = figure('visible','off','name','GPTIPS 2 - REC model comparison','numbertitle','off');

plot(plotdata.model(1).xdata,plotdata.model(1).ydata,'b','LineWidth',2);
hold on;
legstr = cell(0);
legstr{1} = ['Model ID: ' num2str(modelList(1))];

pre2014b = verLessThan('matlab','8.4'); %R2014b (HG2)

for i=2:numModels
    if pre2014b
        plot(plotdata.model(i).xdata,plotdata.model(i).ydata,'LineWidth',2,'Color',pcol(i));
    else
        plot(plotdata.model(i).xdata,plotdata.model(i).ydata,'LineWidth',2);
    end
    legstr{i} = ['Model ID: ' num2str(modelList(i))];
end

xlabel('Absolute error');
ylabel('Accuracy');
grid on;

if ~isempty(gp.userdata.name)
    dstr = [' Data set: ' gp.userdata.name];
else
    dstr = '';
end

if dset == 1
    title(['REC model comparison. Training data.' dstr],'interpreter','none','fontWeight','bold');
elseif dset == 2
    title(['REC model comparison. Test data.' dstr],'interpreter','none','fontWeight','bold');
else
    title(['REC model comparison. Validation data.' dstr],'interpreter','none','fontWeight','bold');
end

%add best and valbest if specified
if showBest
    model = gpmodel2struct(gp,'best');
    
    if dset == 1
        [xdata,ydata] = regressionErrorCharacteristic(gp.userdata.ytrain,model.train.ypred);
    elseif dset == 2
        [xdata,ydata] = regressionErrorCharacteristic(gp.userdata.ytest,model.test.ypred);
    else
        [xdata,ydata] = regressionErrorCharacteristic(gp.userdata.yval,model.val.ypred);
    end
    
    plot(xdata,ydata,'k','LineWidth',2);
    legstr = horzcat(legstr,'''Best'' model');
end

if showValBest && isfield(gp.userdata,'xval') && ~isempty(gp.userdata.xval)
    model = gpmodel2struct(gp,'valbest');
    
    if dset == 1
        [xdata,ydata] = regressionErrorCharacteristic(gp.userdata.ytrain,model.train.ypred);
    elseif dset == 2
        [xdata,ydata] = regressionErrorCharacteristic(gp.userdata.ytest,model.test.ypred);
    else
        [xdata,ydata] = regressionErrorCharacteristic(gp.userdata.yval,model.val.ypred);
    end
    
    plot(xdata,ydata,'m','LineWidth',2);
    legstr = horzcat(legstr,'''Valbest'' model');
end

if showTestBest && isfield(gp.userdata,'xtest') && ~isempty(gp.userdata.xtest)
    model = gpmodel2struct(gp,'testbest');
    
    if dset == 1
        [xdata,ydata] = regressionErrorCharacteristic(gp.userdata.ytrain,model.train.ypred);
    elseif dset == 2
        [xdata,ydata] = regressionErrorCharacteristic(gp.userdata.ytest,model.test.ypred);
    else
        [xdata,ydata] = regressionErrorCharacteristic(gp.userdata.yval,model.val.ypred);
    end
    
    plot(xdata,ydata,'g','LineWidth',2);
    legstr = horzcat(legstr,'''Testbest'' model');
end

legend(legstr);legend boxoff;
hold off;
set(recFig,'visible','on');
