%   Tim Benkert
%   31.08.2018
%
% This function calculates the yield curve from experimental data.
%
% [out] = yieldCurve(inp)
%
% Input
%
% inp (cell array, required)
% Is the cell array created by database.m. The following values need to be
% there.

% If there is no pronounced yield strength
% epsilonLRp -> beginning of yield in engineering declaration. Usually this
%               value is set to 0.002 --> Rp0.2
% ELit -> needs to be empty if EExp is to be used to calculate epsilon
%         elastic, longer explanation below
%
% If there is a pronounced yield strength
% 
%
% ELit (optional, numeric)
% If the calculated E-Modulus is not similar to literature vaules e.g. due
% to bad experimental equipment, you can provide an E-Modulus here. This is
% used to calculate the theoretical point, where your curve should start if
% your test equipment was perfect. Later on this can be used to correct the
% epsilon values of the yield curve. This makes sense only when your
% provided E-Modulus is larger than the calculated one. 
%
% evalMaxYieldBegin
%
% out
% 
% Rp        -> stress value
% epsilonRp -> strain value corresponding to Rp
% epsilonLEngRp -> strain value where you define beginning of yield (e.g. 0.002)
% epsilonLEng0Theo -> theoretical epsilon, where your data would begin if
% your experimental setup was perfectly stiff. Is empty if no ELit is
% provided.

function [out] = yieldCurve_app(inp, varargin)
    %% Get input
    % Define the input parser
    p = inputParser;
    p.CaseSensitive = true;
    addRequired(p, 'inp', @iscell);
    addParameter(p, 'pronouncedYieldStrength', false, @islogical);
    addParameter(p, 'epsilonLEngRp', 0.002, @isnumeric);
    addParameter(p, 'ELit', [], @isnumeric);
    addParameter(p, 'evalMaxYieldBegin', [], @isnumeric);
    addParameter(p, 'indexPronouncedYieldStrength', [], @isnumeric);  %NOTE
    parse(p, inp, varargin{:});

    inp = p.Results.inp;
    pronouncedYieldStrength = p.Results.pronouncedYieldStrength;
    epsilonLEngRp = p.Results.epsilonLEngRp;
    ELit = p.Results.ELit;
    evalMaxYieldBegin = p.Results.evalMaxYieldBegin;
    if isempty(evalMaxYieldBegin) || evalMaxYieldBegin<epsilonLEngRp
        evalMaxYieldBegin = epsilonLEngRp*1.1;
    end
    indexPronouncedYieldStrength = p.Results.indexPronouncedYieldStrength;

    rows = checkLabels(inp, 'EExp', 'sigmaLEng', 'epsilonLEng', 'A0', 'epsilonLTrue', 'A', 'sigmaLTrue', ...
                            'EFit', 'tensileTest', 'crushTest', ...
                            'epsilonLEngRp', 'epsilonXRp', 'Rp', 'indexRp', 'fRp',...
                            'forceRp', 'epsilonLEng0Theo', 'epsilonXTrueRp', 'ARp', ...
                            'sigmaLTrueRp', 'epsilonLTrueEl', 'epsilonLTruePl', 'sigmaLTruePl', ...
                            'epsilonYieldCurve', 'sigmaYieldCurve', 'evalMaxYieldBegin', ...
                            'epsilonYieldCurveExport', 'sigmaYieldCurveExport', 'ELit');
    EExp = inp{rows(1),2};
    sigmaLEng = inp{rows(2),2};
    epsilonLEng = inp{rows(3),2};
    A0 = inp{rows(4),2};
    epsilonLTrue = inp{rows(5),2};
    A = inp{rows(6),2};
    sigmaLTrue = inp{rows(7),2};
    EFit = inp{rows(8),2};
    tensileTest = inp{rows(9),2};
    crushTest = inp{rows(10),2};

    % Check if E-modulus from experiments is to be used or if an E-modulus is provided
    if isempty(ELit)
        E = EExp;
    else
        E = ELit;
    end

    %% Calculation
     if pronouncedYieldStrength
         [epsilonXRp, Rp, indexRp, forceRp, epsilonLEng0Theo, fRp, epsilonXTrueRp, ARp, sigmaLTrueRp, epsilonLTrueEl, ...
          epsilonLTruePl, sigmaLTruePl, epsilonYieldCurve, sigmaYieldCurve] = PronouncedYieldStrength(EFit, ELit, E, sigmaLEng, epsilonLEng, ...
                                                                                                        A0, A, sigmaLTrue, epsilonLTrue,...
                                                                                                        tensileTest, crushTest, indexPronouncedYieldStrength);
        if isempty(epsilonXRp)
            out = [];
            return;
        end
     elseif ~pronouncedYieldStrength
         [epsilonXRp, Rp, indexRp, forceRp, epsilonLEng0Theo, fRp, epsilonXTrueRp, ARp, sigmaLTrueRp, epsilonLTrueEl, ...
          epsilonLTruePl, sigmaLTruePl, epsilonYieldCurve, sigmaYieldCurve] = noPronouncedYieldStrength(EExp, ELit, E, sigmaLEng, epsilonLEng, epsilonLEngRp, ...
                                                                                                        A0, A, sigmaLTrue, epsilonLTrue, evalMaxYieldBegin, ...
                                                                                                        tensileTest, crushTest);
     end


    %% Write results in out
    out = inp;
    out{rows(11),2} = epsilonLEngRp;
    out{rows(12),2} = epsilonXRp;
    out{rows(13),2} = Rp;
    out{rows(14),2} = indexRp;
    out{rows(15),2} = fRp;
    out{rows(16),2} = forceRp;
    out{rows(17),2} = epsilonLEng0Theo;
    out{rows(18),2} = epsilonXTrueRp;
    out{rows(19),2} = ARp;
    out{rows(20),2} = sigmaLTrueRp;
    out{rows(21),2} = epsilonLTrueEl;
    out{rows(22),2} = epsilonLTruePl;
    out{rows(23),2} = sigmaLTruePl;
    out{rows(24),2} = epsilonYieldCurve;
    out{rows(25),2} = sigmaYieldCurve;
    out{rows(26),2} = evalMaxYieldBegin;
    out{rows(27),2} = epsilonYieldCurve;
    out{rows(28),2} = sigmaYieldCurve;
    out{rows(29),2} = ELit;

end

function [epsilonXRp, Rp, indexRp, forceRp, epsilonLEng0Theo, fRp, epsilonXTrueRp, ARp, sigmaLTrueRp, epsilonLTrueEl, ...
          epsilonLTruePl, sigmaLTruePl, epsilonYieldCurve, sigmaYieldCurve] = noPronouncedYieldStrength(EExp, ELit, E, sigmaLEng, epsilonLEng, epsilonLEngRp, ...
                                                                                                        A0, A, sigmaLTrue, epsilonLTrue, evalMaxYieldBegin, tensileTest, crushTest)
    F = @(x) EExp*(x-epsilonLEngRp); % linear equation with slope EExp moved by epsilonLEngRp in positive x-direction
    h = sigmaLEng - F(epsilonLEng); % subtract F from sigmaLEng. The point where F becomes larger than sigmalEng is just behind the section point
    indexRp = find(h<0,1); % find the first point where h is negative. Its index is just behind the section point
    clear h;
    m = (sigmaLEng(indexRp)-sigmaLEng(indexRp-1))/(epsilonLEng(indexRp)-epsilonLEng(indexRp-1)); % slope of sigmaLEng at index
    n = sigmaLEng(indexRp)-m*epsilonLEng(indexRp); % section point with y-axis of linear equation with slope m
    % To understand what I am doing here, just think of two easy linear
    % equations y=mx+n. Make a linear equation system B*x=b out of them. Now solve
    % this system and you will have the section point of your linear equations.
    % This is what I am doing here.
    B = [EExp -1; m -1];
    b = [EExp*epsilonLEngRp; -n];
    h = B\b;        % solve B and b for section point
    epsilonXRp = h(1);
    Rp = h(2);
    clear h B b;
    % Check if a literature value for ELit has been submitted and calculate
    % epsilonLEng0Theo if ELit is not empty. If epsilonLEngTheo0 is smaller
    % than 1e-3 set it to zero
    if isempty(ELit)
        epsilonLEng0Theo = 0;
        epsilonLTrue0Theo = 0;
    else
        epsilonLEng0Theo = epsilonXRp - Rp / ELit - epsilonLEngRp;
        if tensileTest
            epsilonLTrue0Theo = log(1+epsilonLEng0Theo);
        elseif crushTest
            epsilonLTrue0Theo = -log(1-epsilonLEng0Theo);
        end
        if epsilonLEng0Theo<1e-4
            epsilonLEng0Theo = 0;
            epsilonLTrue0Theo = 0;
        end
    end
    fRp = (epsilonXRp-epsilonLEng(indexRp-1))/(epsilonLEng(indexRp)-epsilonLEng(indexRp-1));
    forceRp = Rp * A0;
    epsilonXTrueRp = epsilonLTrue(indexRp-1) + fRp * (epsilonLTrue(indexRp)-epsilonLTrue(indexRp-1));
    ARp = A(indexRp-1) + fRp * (A(indexRp)-A(indexRp-1));
    sigmaLTrueRp = forceRp / ARp;
    epsilonLTrueTemp = [epsilonLTrue(1:indexRp-1) epsilonXTrueRp epsilonLTrue(indexRp:end)];
    sigmaLTrueTemp = [sigmaLTrue(1:indexRp-1) sigmaLTrueRp sigmaLTrue(indexRp:end)];
    epsilonLTrueEl = sigmaLTrueTemp / E;
    epsilonLTruePl = epsilonLTrueTemp(indexRp:end)-epsilonLTrueEl(indexRp:end)-epsilonLTrue0Theo;
    sigmaLTruePl = sigmaLTrueTemp(indexRp:end);

    % Yield Begin
    indexEvalYieldBegin = find(epsilonLTruePl>=evalMaxYieldBegin, 1);
    [xData, yData] = prepareCurveData(epsilonLTruePl(1:indexEvalYieldBegin), sigmaLTruePl(1:indexEvalYieldBegin));
    fitYieldBegin = fit(xData, yData, 'poly1');
    sigmaYieldBegin = fitYieldBegin.p2;

    % Yield curve
    epsilonYieldCurve = [0 epsilonLTruePl];
    sigmaYieldCurve = [sigmaYieldBegin sigmaLTruePl];
end


% NOTE: Parameter indexPronouncedYieldStrength hinzugefügt. User Input entfernt
function [epsilonXRp, Rp, indexRp, forceRp, epsilonLEng0Theo, fRp, epsilonXTrueRp, ARp, sigmaLTrueRp, epsilonLTrueEl, ...
          epsilonLTruePl, sigmaLTruePl, epsilonYieldCurve, sigmaYieldCurve] = PronouncedYieldStrength(EFit, ELit, E, sigmaLEng, epsilonLEng, ...
                                                                                                        A0, A, sigmaLTrue, epsilonLTrue, tensileTest, crushTest, indexPronouncedYieldStrength)
                                                                                                    
    [xData, yData] = prepareCurveData(epsilonLEng(indexPronouncedYieldStrength), sigmaLEng(indexPronouncedYieldStrength));
    ft = fittype('a*x+b', 'independent', 'x', 'dependent', 'y' );
    fo = fitoptions('Method', 'NonlinearLeastSquares');
    fo.Lower = [1 -inf];
    fo.StartPoint = [0 200];
    F = fit(xData, yData, ft, fo);
    sigmaEval = max(sigmaLEng(indexPronouncedYieldStrength))*1.1;
    indexSigmaEval = find(sigmaLEng(indexPronouncedYieldStrength(1):end)>sigmaEval,1)+indexPronouncedYieldStrength(1)-1;
    indexEval = indexPronouncedYieldStrength(1):indexSigmaEval;
    h = sigmaLEng(indexEval) - F(epsilonLTrue(indexEval))';
    indexRp = find(h<0, 1,'last')+indexPronouncedYieldStrength(1);
    clear h;
    m1 = (sigmaLEng(indexRp) - sigmaLEng(indexRp-1)) / (epsilonLEng(indexRp) - epsilonLEng(indexRp-1));
    n1 = sigmaLEng(indexRp) - m1*epsilonLEng(indexRp);
    epsilonXRp = (F.b-n1)/(m1-F.a);
    Rp = F(epsilonXRp);
    epsilonEExp = (F.b-EFit.p2)/(EFit.p1-F.a);
    sigmaYieldBegin = F(epsilonEExp);
    % Check if a literature value for ELit has been submitted and calculate
    % epsilonLEng0Theo if ELit is not empty. If epsilonLEngTheo0 is smaller
    % than 1e-3 set it to zero
    if isempty(ELit)
        epsilonLEng0Theo = 0;
        epsilonLTrue0Theo = 0;
    else
        epsilonLEng0Theo = epsilonEExp - sigmaYieldBegin / ELit;
        if tensileTest
            epsilonLTrue0Theo = log(1+epsilonLEng0Theo);
        elseif crushTest
            epsilonLTrue0Theo = -log(1-epsilonLEng0Theo);
        end
        if epsilonLEng0Theo<1e-4
            epsilonLEng0Theo = 0;
            epsilonLTrue0Theo = 0;
        end
    end
    fRp = (epsilonXRp-epsilonLEng(indexRp-1))/(epsilonLEng(indexRp)-epsilonLEng(indexRp-1));
    forceRp = Rp * A0;
%     epsilonXTrueRp = epsilonLTrue(indexRp-1) + fRp * (epsilonLTrue(indexRp)-epsilonLTrue(indexRp-1));
    if tensileTest
        epsilonXTrueRp = log(1+epsilonXRp);
    elseif crushTest
        epsilonXTrueRp = -log(1-epsilonXRp);
    end
    ARp = A(indexRp-1) + fRp * (A(indexRp)-A(indexRp-1));
    sigmaLTrueRp = forceRp / ARp;
    if sigmaLTrueRp<=sigmaYieldBegin
        % In crush tests the transformation from engineering to true
        % results in a stress decrease between beginning and end of the
        % pronounced yield strength area, due to the increase in cross
        % section area of the specimen. This needs to be corrected in the
        % model as most FEM tools cannot deal with discontinuous
        % stress-strain-curves. We take sigmaYield as a start point for a
        % linear equation with a very small slope and look for the section
        % point with the true stress-strain-data. This section point will
        % become the new end of the pronounced yield strength area.
        a = sigmaLTrue;
        m2 = 1;
        if tensileTest
            n2 = sigmaYieldBegin-(1e-6)*log(1+epsilonEExp);
        elseif crushTest
            n2 = sigmaYieldBegin+(1e-6)*log(1-epsilonEExp);
        end
        b = m2*epsilonLTrue+n2;
        h = a-b;
        indexRp = find(h(indexRp:end)>0,1)+indexRp-1;
        clear a b h;
        m3 = (sigmaLTrue(indexRp) - sigmaLTrue(indexRp-1)) / (epsilonLTrue(indexRp) - epsilonLTrue(indexRp-1));
        n3 = sigmaLTrue(indexRp) - m3*epsilonLTrue(indexRp);
        epsilonXTrueRp = (n2-n3)/(m3-m2);
        sigmaLTrueRp = m3*epsilonXTrueRp+n3;
    end
    epsilonLTrueTemp = [epsilonLTrue(1:indexRp-1) epsilonXTrueRp epsilonLTrue(indexRp:end)];
    sigmaLTrueTemp = [sigmaLTrue(1:indexRp-1) sigmaLTrueRp sigmaLTrue(indexRp:end)];
    epsilonLTrueEl = sigmaLTrueTemp / E;
    epsilonLTruePl = epsilonLTrueTemp(indexRp:end)-epsilonLTrueEl(indexRp:end)-epsilonLTrue0Theo;
    sigmaLTruePl = sigmaLTrueTemp(indexRp:end);
    % Create yield curve
    epsilonYieldCurve = [0 epsilonLTruePl];
    sigmaYieldCurve = [sigmaYieldBegin sigmaLTruePl];
end