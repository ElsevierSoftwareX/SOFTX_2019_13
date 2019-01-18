%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Tim Benkert                                   %
%                           06.07.2018                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script calculates different values from tensile test data.
%
% [out] = calculationsEngCrushTest(inp)
%
% Input
% 
% inp (cell, required)
% Is the cell array created by database.m
%
% Output
%
% A0 -> Initial cross surface of tensile specimen
% A -> Current cross section of tensile specimen
% l  -> current length of tensile specimen
% sigmaLeng     -> engineering stress in longitudinal direction
% epsilonLEng   -> engineering strain in longitudinal direction
% sigmaLTrue    -> true stress in longitudinal direction
% epsilonLTrue  -> true stress in longitudinal direction


function [out] = calculationsTensileTest(inp)
%% Check input
rows = checkLabels(inp, 'forceTensileTest', 'lengthTensileTest', 'lengthInitialTensileTest', 'widthInitialTensileTest', 'thicknessInitialTensileTest', ...
                         'A0', 'l', 'A', 'sigmaLEng', 'epsilonLEng', 'sigmaLTrue', 'epsilonLTrue', ...
                         'lOriginal', 'AOriginal', 'sigmaLEngOriginal', 'epsilonLEngOriginal', 'sigmaLTrueOriginal', 'epsilonLTrueOriginal', 'specimenTypeTensileTest');
force = inp{rows(1),2};
length = inp{rows(2),2};
initialLength = inp{rows(3),2};
initialWidth = inp{rows(4),2};
initialThickness = inp{rows(5),2};
specimenType = inp{rows(19),2};

%% Calculations
if strcmp(specimenType, 'flat')
    A0 = initialWidth*initialThickness;
elseif strcmp(specimenType, 'round')
    A0 = pi*initialWidth^2/4;
else
    out = [];
    return;
end
l = initialLength + length;
A = initialLength * A0 ./ l;
sigmaLEng = force ./ A0;
epsilonLEng = length ./ initialLength;
sigmaLTrue = force ./ A;
epsilonLTrue = log(l ./ initialLength);

%% Output
out = inp;
out{rows(6),2} = A0;
out{rows(7),2} = l;
out{rows(8),2} = A;
out{rows(9),2} = sigmaLEng;
out{rows(10),2} = epsilonLEng;
out{rows(11),2} = sigmaLTrue;
out{rows(12),2} = epsilonLTrue;
out{rows(13),2} = l;
out{rows(14),2} = A;
out{rows(15),2} = sigmaLEng;
out{rows(16),2} = epsilonLEng;
out{rows(17),2} = sigmaLTrue;
out{rows(18),2} = epsilonLTrue;


end
