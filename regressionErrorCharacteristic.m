function [xdata,ydata,xdataref,ydataref] = regressionErrorCharacteristic(y,ypred)
%REGRESSIONERRORCHARACTERISTIC Generates REC curve data using actual and predicted output vectors.
%
%   [XDATA,YDATA] = REGRESSIONERRORCHARACTERISTIC(Y,YPRED) generates REC
%   (regression error characteristic) curve data for the model prediction
%   YPRED of the actual response Y.
%
%   [XDATA,YDATA,XDATAREF,YDATAREF] = REGRESSIONERRORCHARACTERISTIC(Y,YPRED)
%   generates REC curve data as well as data for naive reference prediction
%   (in this case the mean of the Y data is used as a naive prediction of 
%   any Y). This is similar to the ZeroR model in Weka, e,g, see 
%   http://weka.wikispaces.com/ZeroR
%
%   Remarks: 
%
%   Based on the method outlined in "Regression Error Characteristic
%   Curves", Jinbo Bi & Kristin P. Bennett, Proceedings of the Twentieth
%   International Conference on Machine Learning (ICML-2003), Washington
%   DC, 2003.
%   
%   Note: 
%
%   This function only generates REC data, to generate a graph use
%   COMPAREMODELSREC
%
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2
%
%   See also COMPAREMODELSREC

%first compute loss function abs(y-ypred)
err = abs(y - ypred);
m = numel(err);
eprev = 0;
correct = 0;

%count of plottable points on curve
datapoints = 1;

%sort errors
errs= sort(err);

%generate plot data for model prediction
%(x - abs. error, y - fraction of sample accurate within error)
for i=1:m
    if errs(i) > eprev
        xdata(datapoints,1)= eprev;
        ydata(datapoints,1) = correct/m;
        datapoints = datapoints + 1;
        eprev = errs(i);
    end
    correct = correct + 1;
end

xdata(datapoints,1) = errs(m);
ydata(datapoints,1) = correct/m;

%next do the same for reference model
err = abs(y-mean(y));
errs= sort(err);
eprev = 0;
correct = 0;
datapoints = 1;

%generate plot data for reference prediction
%(x - abs. error, y - fraction of sample accurate within error)
for i=1:m
    if errs(i) > eprev
        xdataref(datapoints,1) = eprev;
        ydataref(datapoints,1) = correct/m;
        datapoints = datapoints + 1;
        eprev = errs(i);
    end
    correct = correct + 1;
end

xdataref(datapoints,1) = errs(m);
ydataref(datapoints,1) = correct/m;