%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Tim Benkert                                   %
%                           10.07.2018                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script calculates r values from tensile tests
%
% [out] = rValue(inp, epsilonLEngMin, epsilonLEngMax)
%
% Input
% 
% inp
% Is the cell created by database.m
%
% epsilonLEngMin, epsilonLEngMax
% These two values represent the range of engineering strain which will be
% used for the calculations. The values need to be provided in percent and
% as numeric values.
% Example: epsilonLEngMin -> 8
%          epsilonLEngMax -> 12
%
% nue
% To calculate r values Poissons number is needed. 
% Default: 0.3
% rValue(inp, epsilonLEngMin, epsilonLEngMax, 'nue', 0.2)
% 
% Output
%
% out
% 


function [out] = rValue(inp, epsilonLEngMin, epsilonLEngMax, varargin)
%% Check input
% Define the input parser
p = inputParser;
p.CaseSensitive = true;
addRequired(p, 'inp', @iscell);
addRequired(p, 'epsilonLEngMin', @isnumeric);
addRequired(p, 'epsilonLEngMax', @isnumeric);
addParameter(p, 'nue', 0.3, @isnumeric);
parse(p, inp, epsilonLEngMin, epsilonLEngMax, varargin{:});

inp = p.Results.inp;
epsilonLEngMin = p.Results.epsilonLEngMin;
epsilonLEngMax = p.Results.epsilonLEngMax;
nue = p.Results.nue;

rows = checkLabels(inp, 'widthTensileTest', 'widthInitialTensileTest', 'sigmaLTrue', ...
                        'EExp', 'ELit', 'indexRp', 'epsilonLTrue', 'epsilonLTruePl', 'indexRm',...
                        'b', 'epsilonBTrue', 'epsilonBTrueEl', 'epsilonBTruePl', 'nue', 'r', 'slope', ...
                        'epsilonLEng', 'sigmaLEng');
widthTensileTest = inp{rows(1),2};
widthInitialTensileTest = inp{rows(2),2};
sigmaLTrue = inp{rows(3),2};
EExp = inp{rows(4),2};
ELit = inp{rows(5),2};
indexRp = inp{rows(6),2};
epsilonLTrue = inp{rows(7),2};
epsilonLTruePl = inp{rows(8),2};
indexRm = inp{rows(9),2};
epsilonLEng = inp{rows(17),2};
sigmaLEng = inp{rows(18),2};

% Check if eval range makes sense
if isnan(epsilonLEngMin) || isnan(epsilonLEngMax)
    out = [];
    msgbox('rValue.m: You did not provide an evaluation range for the r value.');
    return;
elseif epsilonLEngMin>=epsilonLEngMax
    out = [];
    msgbox('rValue.m: The minum value of the evaluation range is bigger than the maximum value.');
    return;
elseif epsilonLEngMax/100<=epsilonLEng(1)
    out = [];
    msgbox('rValue.m: The maximum value of the evaluation range is smaller than the lowest value in epsilon.');
    return;
elseif epsilonLEngMax/100>epsilonLEng(end)
    out = [];
    msgbox('rValue.m: The maximum value of the evaluation range is bigger than the highest value in epsilon.');
    return;
end

% Determine which E-modulus to use
if isempty(ELit)
    E = EExp;
elseif isnumeric(ELit)
    E = ELit;
end

%% Calculations

b = -widthTensileTest + widthInitialTensileTest; % calculate total width at every data point
epsilonBTrue = log(b ./ widthInitialTensileTest); % calculate the true strain in lateral direction
epsilonBTrueEl = -nue * sigmaLTrue ./ E; % calculate the true elastic strain in lateral direction
epsilonBTruePl = epsilonBTrue(1:indexRm) - epsilonBTrueEl; % calculate the true plastic strain in lateral direction
epsilonBTruePl = epsilonBTruePl(indexRp-1:end); % Cut away all elements with indexes before indexRp
epsilonLTrueMin = log(1+epsilonLEngMin/100); % convert the evalMin value to true 
epsilonLTrueMax = log(1+epsilonLEngMax/100); % convert the evalMax value to true
indexMin = find(epsilonLTrue>=epsilonLTrueMin,1); % find indices in true strain that contain values bigger or equal than the true min value
indexMax = find(epsilonLTrue>=epsilonLTrueMax,1); % find indices in true strain that contain values bigger or equal than the true max value
epsilonLTruePlMin = epsilonLTrueMin - sigmaLTrue(indexMin) / E; % calculate the true plastic strain value for the min value 
epsilonLTruePlMax = epsilonLTrueMax - sigmaLTrue(indexMax) / E; % calculate the true plastic strain value for the max value
rMin = find(epsilonLTruePl>=epsilonLTruePlMin); % find indices in true plastic strain that contain values bigger or equal than the true plastic min value
rMax = find(epsilonLTruePl>=epsilonLTruePlMax); % find indices in true plastic strain that contain values bigger or equal than the true plastic max value

% calculate the slope of a linear equation of epsilonBTrue over
% epsilonLTrue -> see DIN EN ISO 10113
slope = transpose(epsilonLTruePl(rMin:rMax))\transpose(epsilonBTruePl(rMin:rMax)); % linear equation through origin, the backslash operator expects column vectors
r = - slope/(1 + slope); % calculate r Value according to above standard

%% Write results in out
out = inp;
out{rows(10),2} = b;
out{rows(11),2} = epsilonBTrue;
out{rows(12),2} = epsilonBTrueEl;
out{rows(13),2} = epsilonBTruePl;
out{rows(14),2} = nue;
out{rows(15),2} = r;
out{rows(16),2} = slope;

end