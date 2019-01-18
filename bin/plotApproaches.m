function plotApproaches(~,~)
    fig = gcf;
    ax1 = gca;
    approaches = guidata(fig);
    yieldBegin = approaches.sigmaYieldCurve(1);
    epsilonXTrueRp = approaches.epsilonYieldCurve(2);
    sigmaXTrueRp = approaches.sigmaYieldCurve(2);
    xStep = 1e-6;
%     x = ceil(epsilonXTrueRp/xStep)*xStep:xStep:2;
    x = epsilonXTrueRp:xStep:2;
%     x = 0:1e-6:2;
    labels = {'data points'};
    hold off;
    plot(ax1, approaches.epsilonYieldCurve, approaches.sigmaYieldCurve);
    hold on;
    if approaches.chkLudwik.Value
        plot(ax1,[0 epsilonXTrueRp x], [yieldBegin sigmaXTrueRp approaches.fitLudwik(x-epsilonXTrueRp)']);
        if approaches.yMax<max(approaches.fitLudwik(x-epsilonXTrueRp))
            approaches.yMax = 1.1*max(approaches.fitLudwik(x-epsilonXTrueRp));
        end
        h = size(labels);
        labels{1,h(2)+1} = 'Ludwik';
    end
    if approaches.chkGhosh.Value
        plot(ax1,[0 epsilonXTrueRp x], [yieldBegin sigmaXTrueRp approaches.fitGhosh(x-epsilonXTrueRp)']);
%         plot(ax1,x, approaches.fitGhosh(1).*(x+approaches.fitGhosh(2)).^approaches.fitGhosh(3)-yieldBegin);
%         if approaches.yMax<max(approaches.fitGhosh(1).*(x+approaches.fitGhosh(2)).^approaches.fitGhosh(3)-yieldBegin)
        if approaches.yMax<max(approaches.fitGhosh(x-epsilonXTrueRp))
            approaches.yMax = 1.05*max(approaches.fitGhosh(x-epsilonXTrueRp));
        end
        h = size(labels);
        labels{1,h(2)+1} = 'Ghosh';
    end
    if approaches.chkHockettSherby.Value
        plot(ax1,[0 epsilonXTrueRp x], [yieldBegin sigmaXTrueRp approaches.fitHockettSherby(x-epsilonXTrueRp)']);
%         plot(ax1, x, approaches.fitHockettSherby(x)');
        if approaches.yMax<max(approaches.fitHockettSherby(x-epsilonXTrueRp))
            approaches.yMax = 1.05*max(approaches.fitHockettSherby(x-epsilonXTrueRp));
        end
        h = size(labels);
        labels{1,h(2)+1} = 'HockettSherby';
    end
    if approaches.chkSwift.Value
        plot(ax1,[0 epsilonXTrueRp x], [yieldBegin sigmaXTrueRp approaches.fitSwift(x-epsilonXTrueRp)']);
%         plot(ax1,x, approaches.fitSwift(1).*(approaches.fitSwift(2)+x).^approaches.fitSwift(3));
        if approaches.yMax<max(approaches.fitSwift(x-epsilonXTrueRp))
            approaches.yMax = 1.05*max(approaches.fitSwift(x-epsilonXTrueRp));
        end
        h = size(labels);
        labels{1,h(2)+1} = 'Swift';
    end
    if approaches.chkVoce.Value
        plot(ax1,[0 epsilonXTrueRp x], [yieldBegin sigmaXTrueRp approaches.fitVoce(x-epsilonXTrueRp)']);
%         plot(ax1, x, approaches.fitVoce(x)');
        if approaches.yMax<max(approaches.fitVoce(x-epsilonXTrueRp))
            approaches.yMax = 1.05*max(approaches.fitVoce(x-epsilonXTrueRp));
        end
        h = size(labels);
        labels{1,h(2)+1} = 'Voce';
    end
    legend(labels, 'Location', 'southeast');
    ax1.XLim = [0 2];
    ax1.YLim = [0 approaches.yMax];
    grid on;
    grid minor;
    title(approaches.titlePlot);
    guidata(fig,approaches);
end