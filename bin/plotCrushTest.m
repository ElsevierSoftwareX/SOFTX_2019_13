function plotCrushTest(results, description)
    rows = checkLabels(results, 'epsilonLEng', ...          % 1
                                'sigmaLEng', ...            % 2
                                'EExp', ...                 % 3
                                'epsilonLTrue', ...         % 4
                                'sigmaLTrue', ...           % 5
                                'epsilonYieldCurve', ...    % 6
                                'sigmaYieldCurve', ...      % 7
                                'epsilonLTruePl', ...       % 8
                                'epsilonLEngRp', ...        % 9
                                'epsilonYieldCurveExport', ... % 10
                                'sigmaYieldCurveExport', ...   % 11
                                'EFit');                    % 12
    epsilonLEng = results{rows(1),2};
    sigmaLEng = results{rows(2),2};
    EExp = results{rows(3),2};
    epsilonLTrue = results{rows(4),2};
    sigmaLTrue = results{rows(5),2};
    epsilonYieldCurve = results{rows(6),2};
    sigmaYieldCurve = results{rows(7),2};
    epsilonLTruePl = results{rows(8),2};
    epsilonLEngRp = results{rows(9),2};
    epsilonYieldCurveExport = results{rows(10),2};
    sigmaYieldCurveExport = results{rows(11),2};
    EFit = results{rows(12),2};
    
    figure('pos', [30 100 1800 800], 'Name', description);
    % crush test data
%     subplot(1,1,1)
    x = 0:0.001:0.02;
    y = EFit(x);
    sigmaMax = max(sigmaLTrue);
    indexBegin = find(y>0,1);
    indexEnd = find(y>sigmaMax,1);
    plot(epsilonLEng, sigmaLEng)  % engineering stres-strain-curve
    hold on
    plot(x(indexBegin:indexEnd), y(indexBegin:indexEnd)) % linear equation with slope E-Modul
    plot(epsilonLTrue, sigmaLTrue) % true stress-strain-curve
    plot(epsilonYieldCurve, sigmaYieldCurve) % yield curve
    legend('engineering stress-strain','E-Modulus equation','true stress-strain', 'yield curve', 'Location', 'south')
    xlabel('$\varepsilon_L$ [-]', 'Interpreter','latex');
    ylabel('$\sigma\ [N/mm^2]$', 'Interpreter','latex');
    title('crush test data');
    grid on;
    grid minor;
end