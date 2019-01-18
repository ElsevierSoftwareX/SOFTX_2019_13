function indexOut = selectInput_averaged(xData, yData, varargin)
   % load('\\nas.ads.mwn.de\ne84gam\utg-Profil\Dokumente\Matlabskripte\Ergebnisse_bis_Rp.mat');
%     xData = messCrushAverage{1,1};
%     yData = messCrushAverage{1,2};
    %% Check Input
    p = inputParser;
    p.CaseSensitive = true;
    addRequired(p, 'xData', @isnumeric);
    addRequired(p, 'yData', @isnumeric);
    addParameter(p, 'xlabelIn', '', @ischar);
    addParameter(p, 'ylabelIn', '', @ischar);
    addParameter(p, 'titleIn', '', @ischar);
    parse(p,xData, yData, varargin{:});
    xData = p.Results.xData;
    yData = p.Results.yData;
    xlabelIn = p.Results.xlabelIn;
    ylabelIn = p.Results.ylabelIn;
    titleIn = p.Results.titleIn;
    
    %% Calculations
    indexOut = 1:length(xData);
    fig = figure;
    fig.Units = 'pixels';
    %fig.OuterPosition = [50 -300 2000 1200];
    ax1 = axes;
    ax1.Position = [0.1 0.25 0.8 0.7];
    setappdata(fig,'xData',xData);
    setappdata(fig,'yData',yData);
    setappdata(fig, 'index', indexOut);
    setappdata(fig, 'xlabelIn', xlabelIn);
    setappdata(fig, 'ylabelIn', ylabelIn);
    setappdata(fig, 'titleIn', titleIn);
    buttonDelete = uicontrol('parent', fig, 'String', 'Select Data to crop (rectangle)', ...
                        'Units', 'normalized',...
                        'Callback', @cutData,...
                        'OuterPosition', [0.03 0.1 0.3 0.05]);
    buttonCrop = uicontrol('parent', fig, 'String', 'Select Data to crop (multi klick)', ...
                        'Units', 'normalized',...
                        'Callback', @cutDataMulti,...
                        'OuterPosition', [0.03 0.02 0.3 0.05]);
    buttonSelect = uicontrol('parent', fig, 'String', 'Select Data', ...
                        'Units', 'normalized',...
                        'Callback', @selectData,...
                        'OuterPosition', [0.35 0.1 0.2 0.05]);
    resetButton = uicontrol('parent', fig, 'String', 'Reset', ...
                        'Units', 'normalized',...
                        'Callback', {@reset,xData, yData},...
                        'OuterPosition', [0.57 0.1 0.2 0.05]);
    continueButton = uicontrol('parent', fig, 'String', 'Continue', ...
                        'Units', 'normalized',...
                        'Callback', 'uiresume(gcf)',...
                        'OuterPosition', [0.79 0.1 0.2 0.05]);
    plot(ax1, xData, yData);
    xlabel(xlabelIn);
    ylabel(ylabelIn);
    title(titleIn);
    grid on;
    grid minor;
    uiwait(gcf);
    
    %% Out
    if isvalid(fig)
        indexOut = getappdata(fig,'index');
        indexOut(isnan(indexOut)) = [];
        close(fig);
    else
        indexOut =[];
        return;
    end
end

%% Additional functions
function cutData(objHandle,~)
    ax = gca;
    hold off;
    xIn = getappdata(objHandle.Parent,'xData');
    yIn = getappdata(objHandle.Parent,'yData');
    index = getappdata(objHandle.Parent,'index');
    xlabelIn = getappdata(objHandle.Parent,'xlabelIn');
    ylabelIn = getappdata(objHandle.Parent,'ylabelIn');
    titleIn = getappdata(objHandle.Parent,'titleIn');
    [xCut, yCut] = ginput(2);
    inside = inpolygon(xIn,yIn,xCut,yCut);
    index(inside) = NaN;
    setappdata(objHandle.Parent,'index', index);
    index(isnan(index)) = [];
    plot(ax, xIn(index), yIn(index));
    xlabel(xlabelIn);
    ylabel(ylabelIn);
    title(titleIn);
    grid on;
    grid minor;
end

function cutDataMulti(objHandle,~)
    ax = gca;
    hold off;
    xIn = getappdata(objHandle.Parent,'xData');
    yIn = getappdata(objHandle.Parent,'yData');
    index = getappdata(objHandle.Parent,'index');
    xlabelIn = getappdata(objHandle.Parent,'xlabelIn');
    ylabelIn = getappdata(objHandle.Parent,'ylabelIn');
    titleIn = getappdata(objHandle.Parent,'titleIn');
    [xCut, yCut] = ginput;
    inside = inpolygon(xIn,yIn,xCut,yCut);
    index(inside) = NaN;
    setappdata(objHandle.Parent,'index', index);
    index(isnan(index)) = [];
    plot(ax, xIn(index), yIn(index));
    xlabel(xlabelIn);
    ylabel(ylabelIn);
    title(titleIn);
    grid on;
    grid minor;
end

function selectData(objHandle,~)
    ax = gca;
    hold off;
    xIn = getappdata(objHandle.Parent,'xData');
    yIn = getappdata(objHandle.Parent,'yData');
    index = getappdata(objHandle.Parent,'index');
    xlabelIn = getappdata(objHandle.Parent,'xlabelIn');
    ylabelIn = getappdata(objHandle.Parent,'ylabelIn');
    titleIn = getappdata(objHandle.Parent,'titleIn');
    [xSelect, ySelect] = ginput(2);
    inside = inpolygon(xIn,yIn,xSelect,ySelect);
    index(~inside) = NaN;
    setappdata(objHandle.Parent,'index', index);
    index(isnan(index)) = [];
    plot(ax, xIn(index), yIn(index));
    xlabel(xlabelIn);
    ylabel(ylabelIn);
    title(titleIn);
    grid on;
    grid minor;
end

function reset(objHandle, ~, xIn, yIn)
    ax = gca;
    hold off;
    indexOut = 1:length(xIn);
    setappdata(objHandle.Parent,'index', indexOut);
    setappdata(objHandle.Parent,'xData', xIn);
    setappdata(objHandle.Parent,'yData', yIn);
    plot(ax, xIn, yIn);
    grid on;
    grid minor;
end