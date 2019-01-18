%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  Determining Rm-Value            %
%                04.07.2018 Tim Benkert           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function determines the Rm value of given data from tensile tests.
% The data from multiple specimens need to be averaged before it is
% forwarded to this function.

function [out] =  Rm(inp)
%% Check Input
rows = checkLabels(inp, 'epsilonLEng', 'sigmaLEng', 'epsilonLTrue', 'sigmaLTrue', 'l', 'A', 'Rm', 'indexRm');
epsilonLEng = inp{rows(1),2};
sigmaLEng = inp{rows(2),2};
epsilonLTrue = inp{rows(3),2};
sigmaLTrue = inp{rows(4),2};
l = inp{rows(5),2};
A = inp{rows(6),2};

%% Calculations
[Rm, index] = max(sigmaLEng);

% Delete all values after Rm
epsilonLEng(index+1:end) = [];
sigmaLEng(index+1:end) = [];
epsilonLTrue(index+1:end) = [];
sigmaLTrue(index+1:end) = [];
l(index+1:end) = [];
A(index+1:end) = [];

%% Write results in out
out = inp;
out{rows(1),2} = epsilonLEng;
out{rows(2),2} = sigmaLEng;
out{rows(3),2} = epsilonLTrue;
out{rows(4),2} = sigmaLTrue;
out{rows(5),2} = l;
out{rows(6),2} = A;
out{rows(7),2} = Rm;
out{rows(8),2} = index;
end
