%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Tim Benkert                                   %
%                           17.08.2018                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script function calculates the n value from uniaxial tensile tests
% according to DIN EN ISO 10275
%
% [out] = nValue(inp)
%
% Input
% 
% inp
% Is the cell array created by database.m
%
% evalNMin, evalNMax (numeric, optional)
% These two values represent the range in logarithmic true plastic strain and 
% stress which will be used for the calculations. 
% Example: nValue(inp, 'evalNMin', -3.5)
%          nValue(inp, 'evalNMax', -1,5)
% 
% Output
%
% out
% n value
% logarithmic constant from Ludwik's equation


function [out] = nValue(inp, varargin)
%% Check input
% Define the input parser
p = inputParser;
p.CaseSensitive = true;
addRequired(p, 'inp', @iscell);
addParameter(p, 'evalNMin', [], @isnumeric);
addParameter(p, 'evalNMax', [], @isnumeric);
parse(p, inp, varargin{:});

inp = p.Results.inp;
evalNMin = p.Results.evalNMin;
evalNMax = p.Results.evalNMax;

rows = checkLabels(inp, 'epsilonLTruePl', 'sigmaLTruePl', ...
                        'nValue', 'nValueC');
epsilonLTruePl = log(inp{rows(1),2});
sigmaLTruePl = log(inp{rows(2),2});

% check if evaluation range makes sense, otherwise set values
if isempty(evalNMin) || epsilonLTruePl(1)>evalNMin
    evalNMin = epsilonLTruePl(1);
end
if isempty(evalNMax) || epsilonLTruePl(end)<evalNMax
    evalNMax = epsilonLTruePl(end);
end
if evalNMin>evalNMax
    evalNMin = epsilonLTruePl(1);
    evalNMax = epsilonLTruePl(end);
end

%% Calculations
% Shorten sigma and epsilon and make them logarithmic
iBegin = find(epsilonLTruePl>evalNMin, 1)-1;
iEnd = find(epsilonLTruePl>=evalNMax, 1);
xData = epsilonLTruePl(iBegin:iEnd);
yData = sigmaLTruePl(iBegin:iEnd);

% Prepare data for curve fitting
[xData, yData] = prepareCurveData(xData, yData);

fitData = fit(xData, yData, 'poly1');
nValue = fitData.p1;
nValueC = fitData.p2;

%% Write results in out
out = inp;
out{rows(3),2} = nValue;
out{rows(4),2} = nValueC;
end