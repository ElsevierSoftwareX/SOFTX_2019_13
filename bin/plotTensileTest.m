function plotTensileTest(results, ansBulge, description)
    rows = checkLabels(results, 'epsilonLEng', ...          % 1
                                'sigmaLEng', ...            % 2
                                'EExp', ...                 % 3
                                'epsilonLTrue', ...         % 4
                                'sigmaLTrue', ...           % 5
                                'epsilonYieldCurve', ...    % 6
                                'sigmaYieldCurve', ...      % 7
                                'epsilonBTruePl', ...       % 8
                                'slope', ...                % 9
                                'epsilonLTruePl', ...       % 10
                                'epsilonLEngRp', ...        % 11
                                'r', ...                    % 12
                                'nValue', ...               % 13
                                'nValueC', ...              % 14
                                'fitLudwik', ...            % 15
                                'fitGhosh', ...              % 16
                                'fitHockettSherby', ...     % 17
                                'fitSwift', ...             % 18
                                'fitVoce', ...              % 19
                                'epsilonYieldCurveExport', ... % 20
                                'sigmaYieldCurveExport');   % 21
    epsilonLEng = results{rows(1),2};
    sigmaLEng = results{rows(2),2};
    EExp = results{rows(3),2};
    epsilonLTrue = results{rows(4),2};
    sigmaLTrue = results{rows(5),2};
    epsilonYieldCurve = results{rows(6),2};
    sigmaYieldCurve = results{rows(7),2};
    epsilonBTruePl = results{rows(8),2};
    slope = results{rows(9),2};
    epsilonLTruePl = results{rows(10),2};
    epsilonLEngRp = results{rows(11),2};
    r = results{rows(12),2};
    nValue = results{rows(13),2};
    nValueC = results{rows(14),2};
    fitLudwik = results{rows(15),2};
    fitGhosh = results{rows(16),2};
    fitHockettSherby = results{rows(17),2};
    fitSwift = results{rows(18),2};
    fitVoce = results{rows(19),2};
    epsilonYieldCurveExport = results{rows(20),2};
    sigmaYieldCurveExport  = results{rows(21),2};
    yieldBegin = sigmaYieldCurveExport(1);
    epsilonXTrueRp = epsilonYieldCurveExport(2);
    sigmaXTrueRp = sigmaYieldCurveExport(2);

    if strcmp(ansBulge, 'Yes')
        rowsBulge = checkLabels(results, 'epsilonTruePlBulge', ...
                                         'sigmaTruePlBulge', ...
                                         'epsilonYieldCurveBulge', ...
                                         'sigmaYieldCurveBulge', ...
                                         'indexBulgeDataBegin', ...
                                         'fitEpsilonYieldCurveBulge', ...
                                         'fitSigmaYieldCurveBulge', ...
                                         'alpha');
        epsilonTruePlBulge = results{rowsBulge(1),2};
        sigmaTruePlBulge = results{rowsBulge(2),2};
        epsilonYieldCurveBulge = results{rowsBulge(3),2};
        sigmaYieldCurveBulge = results{rowsBulge(4),2};
        indexBulgeDataBegin = results{rowsBulge(5),2};
        fitEpsilonYieldCurveBulge = results{rowsBulge(6),2};
        fitSigmaYieldCurveBulge = results{rowsBulge(7),2};
        alpha = results{rowsBulge(8),2};
    end

    figure('pos', [30 100 1800 800], 'Name', description);
    % tensile test data
    subplot(2,3,1)
    x = epsilonLEngRp:0.001:0.01;
    y = EExp*(x-epsilonLEngRp);
    sigmaMax = max(sigmaLTrue);
    index = find(y>sigmaMax,1);
    plot(epsilonLEng, sigmaLEng)  % engineering stres-strain-curve
    hold on
    plot(x(1:index), y(1:index)) % linear equation with slope E-Modul through Rp0.2
    plot(epsilonLTrue, sigmaLTrue) % true stres-strain-curve
    plot(epsilonYieldCurve, sigmaYieldCurve) % yield curve
    legend('engineering stress-strain','E-Modulus equation','true stress-strain', 'yield curve', 'Location', 'south')
    xlabel('$\varepsilon_L$ [-]', 'Interpreter','latex');
    ylabel('$\sigma\ [N/mm^2]$', 'Interpreter','latex');
    title('tensile test data');
    grid on;
    grid minor;
    % r value
    subplot(2,3,2)
    plot(epsilonLTruePl, epsilonBTruePl); % epsilonBTruePl über epsilonLTruePl
    hold on;
    plot(epsilonLTruePl, slope*epsilonLTruePl); % Regressionsgerade r-Wert
    legend('data points', 'linear regression')
    xlabel('$\varepsilon_L^{pl}$ [-]', 'Interpreter','latex');
    ylabel('$\varepsilon_B^{pl}$ [-]', 'Interpreter','latex');
    title(['r value: ' num2str(r, '%.1f')]);
    grid on;
    grid minor;
    % n value
    subplot(2,3,3)
    plot(log(epsilonYieldCurve), log(sigmaYieldCurve));
    hold on;
    plot(log(epsilonYieldCurve), nValue*log(epsilonYieldCurve)+nValueC); % linear regression n value
    legend('data points', 'regression')
    xlabel('$log(\varepsilon_L^{pl})$ [-]', 'Interpreter','latex');
    ylabel('$log(\sigma_L^{pl})$ [-]', 'Interpreter','latex');
    title(['n value: ' num2str(nValue, '%.2f')]);
    grid on;
    grid minor;
    % extrapolation
    subplot(2,3,4)
    x = 0.01:0.001:2;
    plot(epsilonYieldCurveExport, sigmaYieldCurveExport);
    hold on;
    plot([0 epsilonXTrueRp x], [yieldBegin sigmaXTrueRp fitLudwik(x)'], 'r');
    plot([0 epsilonXTrueRp x], [yieldBegin sigmaXTrueRp fitGhosh(x)'], 'b');
    plot([0 epsilonXTrueRp x], [yieldBegin sigmaXTrueRp fitHockettSherby(x)'], 'c');
    plot([0 epsilonXTrueRp x], [yieldBegin sigmaXTrueRp fitSwift(x)'], 'g');
    plot([0 epsilonXTrueRp x], [yieldBegin sigmaXTrueRp fitVoce(x)'], 'y');
    legend('data points','Ludwik', 'Ghosh', 'HockettSherby', 'Swift', 'Voce', 'Location', 'south');
    xlabel('$\varepsilon^{pl}$ [-]', 'Interpreter','latex');
    ylabel('$\sigma [N/mm^2]$', 'Interpreter','latex');
    title('Yield Curve and Extrapolations on tensile data');
    grid on;
    grid minor;

    if strcmp(ansBulge, 'Yes')
        % data bulge vs. tensile
        subplot(2,3,5)
        plot(epsilonLTrue, sigmaLTrue); % data points tensile true
        hold on;
        plot(epsilonTruePlBulge, sigmaTruePlBulge); % data points bulge true
        legend('data points tensile test','data points bulge test', 'Location', 'south');
        xlabel('$\varepsilon^{pl}$ [-]', 'Interpreter','latex');
        ylabel('$\sigma [N/mm^2]$', 'Interpreter','latex');
        title('Data points tensile vs. bulge');
        grid on;
        grid minor;
        % results bulge
        subplot(2,3,6)
        plot(epsilonYieldCurveBulge, sigmaYieldCurveBulge );
        hold on;
        plot(fitEpsilonYieldCurveBulge, fitSigmaYieldCurveBulge);
        plot(epsilonYieldCurveBulge(indexBulgeDataBegin), sigmaYieldCurveBulge(indexBulgeDataBegin), '.k', 'MarkerSize', 10);
        legend('data points','fit Alpha', 'equibiaxial point', 'Location', 'south');
        xlabel('$\varepsilon^{pl}$ [-]', 'Interpreter','latex');
        ylabel('$\sigma [N/mm^2]$', 'Interpreter','latex');
        title(['Bulge test results, alpha: ' num2str(alpha)]);
        grid on;
        grid minor;
    end
end