%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Tim Benkert                              %
%                           07.08.2018                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function calculates the alpha value that is the factor in a function
% weighing two extrapolation approaches of tensile test data. It is used to
% fit theses approaches to the bulge data.
%
% [out] = fitAlpha(inp, varargin)
%
% Input
% 
% inp
% Is a cell array, that contains all values within the first row. The
% second row contains the corresponding labels.
% Needed values are two extrapolation approaches for tensile test data with
% their coefficients.
%
% Approaches (character)
% To make the function use your extrapolation approaches, submit
% labels of approach1 and approach2. Those labels need to be present in
% inp. The corresponding data is expected to be cfit.
% Defaults
% approach1: fitSwift
% approach2: fitHS --> HS = HockettSherby
% fitAlpha(inp, 'approach1', 'fitGoce', 'approach2', 'fitHS')
% 
%
% Output
%
% out
% fitEpsilonYieldCurveBulge
% fitSigmaYieldCurveBulge

function [out] = fitAlpha(inp, varargin)
%% Check input
% Define the input parser
p = inputParser;
p.CaseSensitive = true;
addRequired(p, 'inp', @iscell);
addParameter(p, 'approach1', 'fitSwift', @ischar);
addParameter(p, 'approach2', 'fitHockettSherby', @ischar);
parse(p, inp, varargin{:});

rows = checkLabels(inp, p.Results.approach1, p.Results.approach2, 'epsilonYieldCurveBulge', ...
                   'sigmaYieldCurveBulge', 'indexBulgeDataBegin', ...
                   'alpha', 'fitEpsilonYieldCurveBulge', 'fitSigmaYieldCurveBulge', ...
                   'epsilonYieldCurveExport', 'sigmaYieldCurveExport');
approach1 = inp{rows(1),2};
approach2 = inp{rows(2),2};
epsilonYieldCurveBulge = inp{rows(3),2};
sigmaYieldCurveBulge = inp{rows(4),2};
indexBulgeDataBegin = inp{rows(5),2};
yieldBegin = sigmaYieldCurveBulge(1);
epsilonXTrueRp = epsilonYieldCurveBulge(2);
sigmaXTrueRp = sigmaYieldCurveBulge(2);

%% Calculations
% Prepare curve data for fitting
[xData, yData] = prepareCurveData(epsilonYieldCurveBulge(2:end)-epsilonXTrueRp, sigmaYieldCurveBulge(2:end));

% Define the weigh function for the two approaches
F = @(alpha, x) alpha*approach1(x) + (1-alpha)*approach2(x);
% Define the initial value for Alpha
alphaInitial = 0.5;
% Run the regression using upper and lower boundary for alpha beeing 0 / 1
alpha = lsqcurvefit(F, alphaInitial, xData, yData, 0, 1);

% Calculate Yield Curve using the fit until 2.0
xStep = 1e-6;
x = ceil(epsilonXTrueRp/xStep)*xStep:xStep:2;
fitEpsilonYieldCurve =[0 epsilonXTrueRp x];
fitSigmaYieldCurve = [yieldBegin sigmaXTrueRp F(alpha, x-epsilonXTrueRp)'];

%% Write results in out
out = inp;
out{rows(6),2} = alpha;
out{rows(7),2} = fitEpsilonYieldCurve;
out{rows(8),2} = fitSigmaYieldCurve;
out{rows(9),2} = fitEpsilonYieldCurve;
out{rows(10),2} = fitSigmaYieldCurve;
end