%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Tim Benkert                                   %
%                           29.07.2018                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function determines parameters of different extrapolation approaches
% for experimental data.
% Extrapolation Approaches
% Ludwik
% Ghosh
% HockettSherby
% Swift
% Voce
%
% [out] = extrapolation(inp, strainLabel, stressLabel)
%
% Input
% 
% inp (cell array, required)
% Is the ceall array created by database.m
% 
% type (character array, optional)
% If you want to run only a selection of extrapolation approaches and not
% all of them, use the type parameter. Pass a character array containing
% the name of the extrapolation approaches. 
% Available approaches are:
% Ludwik
% Ghosh
% HockettSherby
% Swift
% Voce
% Let's assume you only want to use Swift and HockettSherby's approaches:
% 'type', {'Swift' 'HockettSherby'}
% Default: all
%
% export (character, optional)
% If you want to export one fit into your final material model, submit its
% name here. Use the approaches defined under 'type'.
% Default: empty
% extrapolation(inp, strainLabel, stressLabel, 'export', 'Swift')
%
% Output
% The same as the input with the relevant spots filled with data.
%
% If there are any errors, out is empty.


function [out] = extrapolation(inp, varargin)
%% Check input
% Define default values for type
defaultType = {'Ludwik' 'Ghosh' 'HockettSherby' 'Swift' 'Voce'};
% defaultType = {'Ghosh' 'HockettSherby' 'Swift' 'Voce'};
% Define the input parser
p = inputParser;
p.CaseSensitive = true;
addParameter(p, 'type', defaultType, @iscell);
addParameter(p, 'export', '', @ischar);
parse(p, varargin{:});

rows = checkLabels(inp, 'epsilonYieldCurve', 'sigmaYieldCurve',...
                        'fitLudwik', 'gofLudwik', 'fitGhosh', 'gofGhosh', ...
                        'fitHockettSherby', 'gofHockettSherby', 'fitSwift', 'gofSwift', ...
                        'fitVoce', 'gofVoce', ...
                        'fitEpsilonYieldCurve', 'fitSigmaYieldCurve', ...
                        'epsilonYieldCurveExport', 'sigmaYieldCurveExport');
strain = inp{rows(1),2};
stress = inp{rows(2),2};
yieldBegin = stress(1);
epsilonXTrueRp = strain(2);
sigmaXTrueRp = stress(2);

%% Initialise variables
fitLudwik = [];
gofLudwik = [];
fitGhosh = [];
gofGhosh = [];
fitHS = [];
gofHS = [];
fitSwift = [];
gofSwift = [];
fitVoce = [];
gofVoce = [];


%% Calculations

% Prepare curve data for the fit function
% [xData, yData] = prepareCurveData(strain, stress);
[xData, yData] = prepareCurveData(strain(2:end)-strain(2), stress(2:end));
yieldBeginChar =  num2str(yieldBegin);
sigmaXTrueRpChar =  num2str(sigmaXTrueRp);
% w = linspace(0.5, 10, length(strain));
w = linspace(1, 10, length(strain(2:end)));
% w = (w - w(length(w)/2)).^2+1;
w = w(:);

% Ludwik
if any(strcmp(p.Results.type,'Ludwik')) % check if Ludwik extrapolation is wanted
%     ftLudwik = fittype(['a*x^b+' yieldBeginChar], 'independent', 'x', 'dependent', 'y' );
    ftLudwik = fittype(['a*x^b+' sigmaXTrueRpChar], 'independent', 'x', 'dependent', 'y' );
    optLudwik = fitoptions( 'Method', 'NonlinearLeastSquares' );
    optLudwik.Algorithm = 'Trust-Region';
    optLudwik.Display = 'Off';
    optLudwik.Lower = [0 0];
    optLudwik.Robust = 'off';
    optLudwik.StartPoint = [1 0.5];
    optLudwik.Upper = [inf 1];
    optLudwik.TolFun = 1*10^(-10);
    optLudwik.TolX = 1*10^(-10);
    optLudwik.DiffMinChange = 1*10^(-10);
    optLudwik.Weights = w;
%     [fitLudwik, gofLudwik, outputLudwik] = fit( xData, yData, ftLudwik, optLudwik );
    [fitLudwik, gofLudwik] = fit(xData, yData, ftLudwik, optLudwik);
end


% Ghosh
if any(strcmp(p.Results.type,'Ghosh'))
%     FLSQ = @(x,y, yieldBegin, a)mean(w.*(a(1).*(a(2)+x).^a(3)-yieldBegin-y).^2);
    FLSQ = @(x,y, sigmaXTrueRp, a)sum(w.*(a(1).*(a(2)+x).^a(3)-sigmaXTrueRp-y).^2);
%     x0 = [1 0.002 0.5];
    x0 = [1 1 0.5]; % According to med switching from 0.002 to 1 yields better fits
    lb = [0 0 0];
    ub = [inf 10 1];
%     fitGhosh = fmincon(@(a)FLSQ(xData,yData,yieldBeginChar,a), x0, [], [], [], [], lb, ub, @(a)nonlconGhosh(yieldBeginChar, a));
    fitGhosh = fmincon(@(a)FLSQ(xData,yData,sigmaXTrueRp,a), x0, [], [], [], [], lb, ub, @(a)nonlconGhosh(sigmaXTrueRp, a));
    ftGhosh = fittype ('a.*(b+x).^c-d', 'independent', 'x', 'dependent', 'y');
    fitGhosh = cfit(ftGhosh, fitGhosh(1), fitGhosh(2), fitGhosh(3), sigmaXTrueRp);
end

% HockettSherby
if any(strcmp(p.Results.type,'HockettSherby'))
%     ftHS = fittype( ['a-exp(-b*x^c)*(a-' yieldBeginChar ')'], 'independent', 'x', 'dependent', 'y' );
    ftHS = fittype( ['a-exp(-b*x^c)*(a-' sigmaXTrueRpChar ')'], 'independent', 'x', 'dependent', 'y' );
    optHS = fitoptions( 'Method', 'NonlinearLeastSquares' );
    optHS.Algorithm = 'Trust-Region';
    optHS.Display = 'Off';
    optHS.Robust = 'off';
    optHS.Lower = [0 0 0];
    optHS.Upper = [5000 10 10];
    optHS.StartPoint = [400 1.5 0.58];
    optHS.Weights = w;
    [fitHS, gofHS] = fit(xData, yData, ftHS, optHS);
end

% Swift
if any(strcmp(p.Results.type,'Swift'))
    FLSQ = @(x,y,a)mean(w.*(a(1).*(a(2)+x).^a(3)-y).^2);
%     x0 = [1 0.002 0.5];  %% NOTE
    x0 = [1 0.002 0.5];  % According to med switching from 0.002 to 1 yields better fits
    lb = [0 0 0];
    ub = [inf 10 1];
%     fitSwift = fmincon(@(a)FLSQ(xData,yData,a), x0, [], [], [], [], lb, ub, @(a)nonlconSwift(yieldBegin, a));
    fitSwift = fmincon(@(a)FLSQ(xData,yData,a), x0, [], [], [], [], lb, ub, @(a)nonlconSwift(sigmaXTrueRp, a));
    ftSwift = fittype ('a.*(b+x).^c', 'independent', 'x', 'dependent', 'y');
    fitSwift = cfit(ftSwift, fitSwift(1), fitSwift(2), fitSwift(3));
%     ftSwift = fittype( 'a*(b+x)^c', 'independent', 'x', 'dependent', 'y' );
%     optSwift = fitoptions( 'Method', 'NonlinearLeastSquares' );
%     optSwift.Algorithm = 'Trust-Region';
%     optSwift.Display = 'Off';
%     optSwift.Lower = [0 0 0];
%     optSwift.Robust = 'off';
%     optSwift.StartPoint = [1114 0.002714 0.2074];
%     optSwift.Upper = [5000 10 1];
%     optSwift.TolFun = 1*10^(-10);
%     optSwift.TolX = 1*10^(-10);
%     optSwift.DiffMinChange = 1*10^(-10);
%     [fitSwift, gofSwift] = fit(xData, yData, ftSwift, optSwift);
end

% Voce
if any(strcmp(p.Results.type,'Voce'))
%     ftVoce = fittype(['a-exp(-b*x)*(a-' yieldBeginChar ')'], 'independent', 'x', 'dependent', 'y' );
    ftVoce = fittype(['a-exp(-b*x)*(a-' sigmaXTrueRpChar ')'], 'independent', 'x', 'dependent', 'y' );
    optVoce = fitoptions( 'Method', 'NonlinearLeastSquares' );
    optVoce.Algorithm = 'Trust-Region';
    optVoce.Display = 'Off';
    optVoce.Lower = [0 0];
    optVoce.Upper = [5000 10];
    optVoce.StartPoint = [400 1.5];
    optVoce.Robust = 'off';
    optVoce.TolFun = 1*10^(-10);
    optVoce.TolX = 1*10^(-10);
    optVoce.DiffMinChange = 1*10^(-10);
    optVoce.Weights = w;
    [fitVoce, gofVoce] = fit(xData, yData, ftVoce, optVoce);
end

%% Write results in out
out = inp;
out{rows(3),2} = fitLudwik;
out{rows(4),2} = gofLudwik;
out{rows(5),2} = fitGhosh;
out{rows(6),2} = gofGhosh;
out{rows(7),2} = fitHS;
out{rows(8),2} = gofHS;
out{rows(9),2} = fitSwift;
out{rows(10),2} = gofSwift;
out{rows(11),2} = fitVoce;
out{rows(12),2} = gofVoce;
xStep = 1e-6;
% epsilonExport = ceil(epsilonXTrueRp/xStep)*xStep:xStep:2;
epsilonExport = ceil(epsilonXTrueRp/xStep)*xStep:xStep:2;
% epsilonExport = 0:0.0001:2;
if strcmp(p.Results.export, 'Ludwik')
    x = [0 epsilonXTrueRp epsilonExport];
    y = [yieldBegin sigmaXTrueRp fitLudwik(epsilonExport-strain(2))'];
%     x = epsilonExport;
%     y = fitLudwik(epsilonExport)';
    out{rows(13),2} = x;
    out{rows(14),2} = y;
    out{rows(15),2} = x;
    out{rows(16),2} = y;
elseif strcmp(p.Results.export, 'Ghosh')
    x = [0 epsilonXTrueRp epsilonExport];
    y = [yieldBegin sigmaXTrueRp fitGhosh(epsilonExport-strain(2))'];
    out{rows(13),2} = x;
    out{rows(14),2} = y;
    out{rows(15),2} = x;
    out{rows(16),2} = y;
elseif strcmp(p.Results.export, 'HockettSherby')
    x = [0 epsilonXTrueRp epsilonExport];
    y = [yieldBegin sigmaXTrueRp fitHS(epsilonExport-strain(2))'];
    out{rows(13),2} = x;
    out{rows(14),2} = y;
    out{rows(15),2} = x;
    out{rows(16),2} = y;
elseif strcmp(p.Results.export, 'Swift')
    x = [0 epsilonXTrueRp epsilonExport];
    y = [yieldBegin sigmaXTrueRp fitSwift(epsilonExport-strain(2))];
    out{rows(13),2} = x;
    out{rows(14),2} = y;
    out{rows(15),2} = x;
    out{rows(16),2} = y;
elseif strcmp(p.Results.export, 'Voce')
    x = [0 epsilonXTrueRp epsilonExport];
    y = [yieldBegin sigmaXTrueRp fitVoce(epsilonExport-strain(2))'];
    out{rows(13),2} = x;
    out{rows(14),2} = y;
    out{rows(15),2} = x;
    out{rows(16),2} = y;
elseif strcmp(p.Results.export, '')
else
    msgbox('extrapolation.m: You submitted an export character that I do not know. Nothing is exported.');
end

end

function [c, ceq] = nonlconGhosh(sigmaXTrueRp, a)
    c = [];
    ceq = a(1)*a(2)^a(3)-2*sigmaXTrueRp;
end
% function [c, ceq] = nonlconGhosh(yieldBegin, a)
%     c = [];
%     ceq = a(1)*a(2)^a(3)-2*yieldBegin;
% end

function [c, ceq] = nonlconSwift(sigmaXTrueRp, a)
    c = [];
    ceq = a(1)*a(2)^a(3)-sigmaXTrueRp;
end
% function [c, ceq] = nonlconSwift(yieldBegin, a)
%     c = [];
%     ceq = a(1)*a(2)^a(3)-yieldBegin;
% end

