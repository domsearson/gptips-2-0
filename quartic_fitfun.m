function [fitness,gp] = quartic_fitfun(evalstr,gp)
%QUARTIC_FITFUN Fitness function for simple ("naive") symbolic regression on the quartic polynomial y = x + x^2 + x^3 + x^4. 
%   
%   FITNESS = QUARTIC_FITFUN(EVALSTR,GP) returns the FITNESS value of the
%   symbolic expression contained within the cell array EVALSTR using the
%   information in the GP struct.
%   
%   Copyright (c) 2009-2015 Dominic Searson 
%
%   GPTIPS 2
%
%   See also GPDEMO1_CONFIG, GPDEMO1

%extract x and y data from GP struct
x1 = gp.userdata.x;
y = gp.userdata.y;

%evaluate the tree (assuming only 1 gene is suppled in this case - if the
%user specified multigene config then only the first gene encountered will be used)
eval(['out=' evalstr{1} ';']);

%fitness is sum of absolute differences between actual and predicted y
fitness = sum( abs(out-y) );

%if this is a post run call to this function then plot graphs
if gp.state.run_completed
    figure;
    plot(x1,y,'o-','LineWidth',2,'color',[0 0.45 0.74]);grid on;hold on;
    plot(x1,out,'x-','LineWidth',2,'color',[0.85 0.33 0.1]);
    xlabel('x');ylabel('y');
    legend('y','predicted y');legend boxoff; hold off;
    title('Prediction of quartic polynomial over range [-1 1]');
end

