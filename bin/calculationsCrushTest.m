%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Tim Benkert                                   %
%                           06.07.2018                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script calculates different values from crush test data.
%
% [out] = calculationsCrushTest(inp)
%
% Input
% 
% inp (cell, required)
% Is the cell array created by database.m
%
% Output
%
% A0 -> Initial cross section of crush specimen
% A -> Current cross section of crush specimen
% l  -> current length of crush specimen
% sigmaLeng     -> engineering stress in longitudinal direction
% epsilonLEng   -> engineering strain in longitudinal direction
% sigmaLTrue    -> true stress in longitudinal direction
% epsilonLTrue  -> true stress in longitudinal direction


function [out] = calculationsCrushTest(inp)
%% Check input
rows = checkLabels(inp, 'forceCrushTest', 'lengthCrushTest', 'diameterInitialCrushTest', 'lengthInitialCrushTest', ...
                         'A0', 'l', 'A', 'sigmaLEng', 'epsilonLEng', 'sigmaLTrue', 'epsilonLTrue');
force = inp{rows(1),2};
length = inp{rows(2),2};
initialDiameter = inp{rows(3),2};
initialLength = inp{rows(4),2};

%% Calculations
A0 = pi*initialDiameter^2/4;
l = initialLength - length;
A = initialLength * A0 ./ l;
sigmaLEng = force ./ A0;
epsilonLEng = length ./ initialLength;
sigmaLTrue = force ./ A;
epsilonLTrue = -log(l ./ initialLength);

%% Output
out = inp;
out{rows(5),2} = A0;
out{rows(6),2} = l;
out{rows(7),2} = A;
out{rows(8),2} = sigmaLEng;
out{rows(9),2} = epsilonLEng;
out{rows(10),2} = sigmaLTrue;
out{rows(11),2} = epsilonLTrue;
end
