%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Christoph Hartmann                               %
%                           10.07.2018                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function determines the E-modulus of provided measuring data.
%
% [out] = Emodulus(inp)
%
% Input
% 
% inp
% Is the cell array created by database.m. sigmaLEng and epsilonLEng have
% to in there.
%
% lowerBoundary (numeric, optional)
% Defines the stress value which the search begins at in percent of the
% maximum stress value in your stress data. So if your maximum occuring
% stress is 1000 MPa and you define a lowerBoundary of 0.1, the search for
% the E-Modulus will start at 100 MPa.
% Default: 0.05
% Emodulus(inp, 'lowerBoundary', 0.1)
%
% upperBoundary (numeric, optional)
% see explanation of lowerBoundary. It is the same here, just with the
% maximum stress value. If your maximum stress value is 1000 MPa and you
% define an upperBoundary of 0.9, the search for the E-modulus terminates
% at 900 MPa.
% Default: 0.95
% Emodulus(inp, 'upperBoundary', 0.9)
%
% initialPoints (numeric, optional)
% Defines the initial number of data points that are used for the fit of a first
% degree polynom to your data. There will be no smaller set of data points
% tried to be matched to your data. 
% Default: 21
% Emodulus(inp, 'initialPoints', 35)
%
% initialStepSize (numeric, optional)
% Defines the step size in indices between upper and lower boundary that is
% used to start a loop to look for the E-modulus. The higher this value,
% the less loops are carried out to determine the E-Modulus. If you have a
% lot of data points, increase this value to speed up the search for the
% E-Modulus. Be careful though with high values as this will decrease your
% result quality.
% Default: 5
% Emodulus(inp, 'initialStepSize', 10)
%
% Output
%
% EExp -> experimentally determined E-Modulus

function [out] = EModulus(inp, varargin)
%% Check input
p = inputParser;
p.CaseSensitive = true;
addRequired(p, 'inp', @iscell);
addParameter(p, 'lowerBoundary', 0.05, @isnumeric); % lowerBoundary
addParameter(p, 'upperBoundary', 1, @isnumeric); % upperBoundary
addParameter(p, 'initialPoints', 21, @isnumeric); % initialPoints
addParameter(p, 'stepSize', 3, @isnumeric); % stepSize
parse(p, inp, varargin{:});

inp = p.Results.inp;
lowerBoundary = p.Results.lowerBoundary;
upperBoundary = p.Results.upperBoundary;
initialPoints = p.Results.initialPoints;
stepSize = p.Results.stepSize;

rows = checkLabels(inp, 'epsilonLTrue', 'sigmaLTrue', 'EExp', 'EFit');
epsilonLTrue = inp{rows(1),2};
sigmaLTrue = inp{rows(2),2};
divisor = max(sigmaLTrue);
%% Determination of Boundary
[~,indexLowerBoundary]=min(abs(sigmaLTrue./divisor-lowerBoundary));
[~,indexUpperBoundary]=min(abs(sigmaLTrue./divisor-upperBoundary));
indexBoundary=[indexLowerBoundary:stepSize:indexUpperBoundary];

%% Dynamic Regression
EFit3= 1:length(indexBoundary);
EFit4 = {};
EFit5 = {};
for ii=1:length(indexBoundary)
    for jj=initialPoints:indexUpperBoundary-indexBoundary(ii)-1
        [EFit,gofFIT,~]=fit(epsilonLTrue(indexBoundary(ii):(indexBoundary(ii)+jj))',sigmaLTrue(indexBoundary(ii):(indexBoundary(ii)+jj))','poly1');    
        RMSFit2(jj-initialPoints+1)=gofFIT.rmse;    
        EFit2(jj-initialPoints+1)=EFit.p1;
        EFit4{jj-initialPoints+1,1}=EFit;
    % Stop criterion
        if RMSFit2(jj-initialPoints+1) > mean(RMSFit2)+std(RMSFit2)
            break
        end
    end
[~,indexRMSMin]=min(RMSFit2);
EFit3(ii)=EFit2(indexRMSMin);
EFit5{ii,1}=EFit4{indexRMSMin,1};
end
clear jj ii
% Young's modulus selection
[~,indexEMax]=max(EFit3);
E=EFit3(indexEMax);
EFitOut=EFit5{indexEMax,1};
%% Write results in out
out = inp;
out{rows(3),2} = E;
out{rows(4),2} = EFitOut;
end