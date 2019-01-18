%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bulgeextrapolation of tensile tests
% 28.07.2018 Tim Benkert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function extrapolates the data of tensile tests after uniform
% elongation using data from bulge tests. The approach used is explained in
% DIN 16808.
%
% [out] = bulgeextrapolationTensileTest(database)
% 
% 
% Input Values
%
% database
% A cell array created by database.m Results of tensile and bulge tests
% need to be in there.
%
% fitTensile, fitBulge (logical)
% To use the fitted data for the further process, submit the value pairs 
% with a logical true.
% The default value in both cases is 'false'.
% 'fitTensile', true
% 'fitBulge', true
%
% Output values
% 
% out (cell array)
% Contains the yield curve. The format is the same as the input format.
% Only the results of this function are contained in the output.
% Is empty if something went wrong within this function.

function [out] = bulgeextrapolationTensileTest(database, varargin)
%% Check input
p = inputParser;
p.CaseSensitive = true;
addRequired(p, 'database', @iscell);
addParameter(p, 'fitTensile', false, @islogical);
addParameter(p, 'fitBulge', false, @islogical);
parse(p, database, varargin{:});

% Get variables needed out of the input data
if p.Results.fitTensile
%     rows = checkLabels(database, 'fitEpsilonYieldCurve', 'fitSigmaYieldCurve');
    msgbox('bulgeextrapolationTensileTest.m: Sorry,working with fitted tensile data is not implemented yet.');
    out = [];
    return;
elseif ~p.Results.fitTensile
    rows = checkLabels(database, 'epsilonYieldCurve', 'sigmaYieldCurve');
end
if p.Results.fitBulge
    msgbox('bulgeextrapolationTensileTest.m: Sorry,working with fitted bulge data is not implemented yet.');
    out = [];
    return;
elseif ~p.Results.fitBulge
    h = checkLabels(database, 'epsilonTruePlBulge', 'sigmaTruePlBulge', ...
                               'epsilonYieldCurveBulge', 'sigmaYieldCurveBulge', 'indexBulgeDataBegin');
    rows = [rows h];
    clear h;
end

epsilonYieldCurve = database{rows(1),2};
sigmaYieldCurve = database{rows(2),2};
epsilonTrueBulge = database{rows(3),2};
sigmaTrueBulge = database{rows(4),2};

%% Calculations
% Get epsilonLTrueRm und epsilonLTrueRm from the data
epsilonLTrueRm = epsilonYieldCurve(end);
sigmaLTrueRm = sigmaYieldCurve(end);
plasticWorkUniformElongation = epsilonLTrueRm*sigmaLTrueRm;

% Find the data point that fulfills the equivalent equation
plasticWorkBulge = epsilonTrueBulge.*sigmaTrueBulge;
index = find(plasticWorkBulge>plasticWorkUniformElongation,1)-1;

% Interpolate between the point i and i+1 to calculate the point, where the
% plastic work in the bulge test equals plasticWorkUniformElongation
sigmaTrueBulgeRef = sigmaTrueBulge(index) + ...
                    (sigmaTrueBulge(index+1)-sigmaTrueBulge(index)) / ...
                    (sigmaTrueBulge(index+1)*abs(epsilonTrueBulge(index+1))-sigmaTrueBulge(index)*abs(epsilonTrueBulge(index))) * ...
                    (plasticWorkUniformElongation-sigmaTrueBulge(index)*abs(epsilonTrueBulge(index)));

% Calculate the biaxial stress ratio
biaxStressRatio = sigmaTrueBulgeRef / sigmaLTrueRm;

% Use the biaxial stress ratio to convert the bulge data
epsilonTrueBulgeConverted = epsilonTrueBulge.*biaxStressRatio;
sigmaTrueBulgeConverted = sigmaTrueBulge./biaxStressRatio;

% Create the yield curve
epsilonYieldCurveBulge = [epsilonYieldCurve epsilonTrueBulgeConverted(index+1:end)];
sigmaYieldCurveBulge = [sigmaYieldCurve sigmaTrueBulgeConverted(index+1:end)];

%% Output
out = database;
out{rows(5),2} = epsilonYieldCurveBulge;
out{rows(6),2} = sigmaYieldCurveBulge;
out{rows(7),2} = length(epsilonYieldCurve);
end