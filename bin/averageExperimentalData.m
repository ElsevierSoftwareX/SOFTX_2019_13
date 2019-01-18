%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Averaging of the experimental data using interp1 (linear)
% Tim Benkert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function interpolates experimental data that result from multiple
% specimens. Therefore, all data need to have the same base vector. 
% First step is to create this base vector. The second step is to
% interpolate between the data points to match the points given by the base
% vector. The third step is calculating the mean values of the different
% measurments (specimens).
%
% [out] =  averageExperimentalData(inp, labelsIn)
% 
% Input data
% 
% inp (cell array, required)
% is the cell array created by databayse.m filled with measuring data
%
% labelsIn (cell array of character vectors, required)
% Labels of the rows that this function will work on. Rows
% have to contain vectors with more than one entry, otherwise the function
% stops. The first label defines the reference row. 
% averageExperimentalData(database, {'length', 'force'})
%
% Creation of base vector
% The base vector is created from the data within
% inp. Duplicate data points will be removed. To define the base
% vector, two methods exist.
% Method 1: The smallest step between to entries of the reference row of
% inp is determined and taken as step size for the base vector.
% Afterwards, the biggest and the smallest values of the reference row in
% inp are determined and taken as beginning and end of the base vector.
% Method 2: You can submit beginning, stepSize and end of the base
% vector. Use name-value-pairs to do so. You can submit any combination of
% those three parameters. Not submitted parameters are determined like in
% method 1.
% Default is method 1.
% Optional parameters:
% averageExperimentalData(inp, 'baseVectorMin', 0);
% averageExperimentalData(inp, 'baseVectorStepSize', 1e-6);
% averageExperimentalData(inp, 'baseVectorMax', 0.7)
% 
% 
% Interpolation
% The interpolation uses the interp1 function with linear connections
% between the data points. 
%
% Output Data
% 
% out
% database cell array with averaged data.



function [out] =  averageExperimentalData(inp, labelsIn, varargin)
    %% Check input data
    p = inputParser;
    p.CaseSensitive = true;
    addRequired(p, 'inp', @iscell);
    addRequired(p, 'labelsIn', @iscell);
    addParameter(p, 'labelsOut', {}, @iscell);
    addParameter(p, 'baseVectorMin', [], @isnumeric);
    addParameter(p, 'baseVectorStepSize', [], @isnumeric);
    addParameter(p, 'baseVectorMax', [], @isnumeric);
    parse(p,inp, labelsIn, varargin{:});

    data = p.Results.inp;
    labelsIn = p.Results.labelsIn(:)'; % make sure labels is a 1 x X cell array
    labelsOut = p.Results.labelsOut(:)';
    baseVectorMin = p.Results.baseVectorMin;
    baseVectorStepSize = p.Results.baseVectorStepSize;
    baseVectorMax = p.Results.baseVectorMax;
    
    % Check the input for base vector for sense    
    if ~isempty(baseVectorMin) && ~isempty(baseVectorMax) 
        if baseVectorMin>= baseVectorMax
            baseVectorMin = [];
            baseVectorMax = [];
        end
    end
    if ~isempty(baseVectorStepSize)
        if baseVectorStepSize <= 0
            baseVectorStepSize = [];
        end
        if ~isempty(baseVectorMin) && ~isempty(baseVectorMax)
            if baseVectorStepSize>=baseVectorMax-baseVectorMin
                baseVectorStepSize = [];
            end
        end
    end
    
    % Check that labelsIn contains character vectors, is longer than one and
    % get rows out of labelsIn
    h = size(labelsIn);
    nLabelsIn=h(2);
    clear h;
    if nLabelsIn == 1
       msgbox('You provided one label only. Nothing is done.')
       out = data;
       return;
    end
    rowsLabelsIn = [];
    for jj = 1:nLabelsIn
        if ~ischar(labelsIn{1, jj})
            out = [];
            msgbox('averageExperimentalData.m: You provided a non character value in labels.');
            return;
        end
        rowsLabelsIn(end+1) = checkLabels(database, labelsIn{1,jj});
    end
    
    % Check that labelsOut contains character vectors, and
    % get rows out of labelsOut
    h = size(labelsOut);
    nLabelsOut=h(2);
    clear h;
    if isempty(labelsOut)
      rowsLabelsOut = rowsLabelsIn;
      nLabelsOut = nLabelsIn;
    elseif nLabelsIn~=nLabelsOut
        out=[];
        msgbox('averageExperimentalData.m: The number of output variables is not the same as the number of input variables.');
        return;
    else
        rowsLabelsOut = [];
        for jj = 1:nLabelsOut
            if ~ischar(labelsOut{1, jj})
                out = [];
                msgbox('averageExperimentalData.m: You provided a non character value in labelsOut.');
                return;
            end
            rowsLabelsOut(end+1) = checkLabels(database, labelsOut{1,jj});
        end
    end
    % Base vector input
    rowsBaseVector = checkLabels(database, 'baseVectorMin', 'baseVectorStepSize', 'baseVectorMax');
    
    % Check if data vectors are of the same length or of length one and numeric
    h = size(data);
    nData = h(2);
    clear h;
    for jj = 2:nData % Go throuh the columns of database
        h = [];
        for ii = 1:nLabelsIn % Go through the rows of provided labels in database
            if ~isnumeric(data{rowsLabelsIn(ii),jj}) || isempty(data{rowsLabelsIn(ii),jj}) % check if data at current position is not numeric or if position is emtpy
               msgbox(['The vector in row ', num2str(rowsLabelsIn(ii)), ' and column ', num2str(jj), ' is not numeric or emtpy!']);
               out = [];
               return;
            end
            if length(data{rowsLabelsIn(ii),jj})>1 % check if length of vector at current position is greater than 1
                h(end+1) = length(data{rowsLabelsIn(ii),jj}); % Write the length of the data at current position behind the last entry in h
            end
        end
        if max(h)~=min(h)
           out = [];
           msgbox('The length of the vectors to average is not equal!'); 
           return;
        end
    end
    
    %% Create the base vector
    base_step = inf; % initial step of base vector
    base_max = 0; % inital maximum of base vector
    base_min = inf; % initial minium of base vector
    
    % Create the inputs for the base vector
    % StepSize
    if isempty(baseVectorStepSize)
        for jj = 2:nData % Go through all columns of data
            a = data{rowsLabelsIn(1),jj}(2:end); % create minuend
            b = data{rowsLabelsIn(1),jj}(1:end-1); % create subtrahend
            c = a-b; % calculate difference
            d = min(c(find(c>0))); % search smallest positive value
            if d<base_step % if current step is smaller than the saved one
                base_step = d; % set current time step the saved time step
            end
            clear a b c d;
        end
    else
        base_step = baseVectorStepSize; 
    end
    % Max Value
    if isempty(baseVectorMax)
        for jj = 2:nData % Go through all columns of data
            if base_max < max(data{rowsLabelsIn(1),jj})
                base_max = max(data{rowsLabelsIn(1),jj});
            end
        end
    else
        base_max = baseVectorMax;
    end
    % Min Value
    if isempty(baseVectorMin)
        for jj = 2:nData % Go through all columns of data
            if base_min > min(data{rowsLabelsIn(1),jj})
                base_min = min(data{rowsLabelsIn(1),jj});
            end
        end
    else
        base_min = baseVectorMin;
    end

    
    % Create the base vector    
    base = base_min:base_step:base_max; % base vector 
    
    %% Interpolate between the data points based on base vector
    % run the interpolation on all vectors but the reference vector and
    % scalars
    for kk = 2:nLabelsIn
        if length(data{rowsLabelsIn(kk),2}) > 1 % make sure there is no scalar
            for jj = 2:nData % Walk through the columns of the input data
                [x, index] = unique(data{rowsLabelsIn(1),jj}); % make the etries in recVector unique
                v = data{rowsLabelsIn(kk),jj}(index); % take only those values for v with index
                data{rowsLabelsOut(kk),jj} = interp1(x,v,base); % run the interpolation
                clear index x v;
            end
        end
    end
    % Set the reference vector equal to the base vector
    for jj = 2:nData
        data{rowsLabelsOut(1),jj} = base;
    end
    
    %% Calculate the average values, delete unnecessary columns and NaN
    index = [];
    for kk = 1:nLabelsOut % for all rows defined by labels
        A = [];
        if nData>2 % if the user selected only one file than no averaging is needed
            for jj = 2:nData % for all columns in data
                A = [A; data{rowsLabelsOut(kk),jj}]; % write the data vectors in matrix
                data{rowsLabelsOut(kk),jj} = []; % delete content of current cell
            end
            data{rowsLabelsOut(kk),2} = mean(A); % Calculate the mean value and write in data
        end
        index = [index find(isnan(data{rowsLabelsOut(kk),2}))];
    end
    index = unique(index); % remove double entries from index and sort index
    for kk = 1:nLabelsOut % for all rows defined by labelsIn
        if length(data{rowsLabelsOut(kk),2}) > 1 % make sure there is no scalar
            data{rowsLabelsOut(kk),2}(index) = []; % delete entries that contain NaN
        end
    end
    
    %% Clear empty columns in database
    h = size(data);
    for kk = 1:h(2)
        if h(1) == sum(cellfun('isempty', data(:,h(2)-kk+1))) % Check if column is empty
            data(:,h(2)-kk+1) = [];
        end
    end
    clear h; 
    
    %% Output
    out = data;
    out{rowsBaseVector(1),2} = base_min;
    out{rowsBaseVector(2),2} = base_step;
    out{rowsBaseVector(3),2} = base_max;
end