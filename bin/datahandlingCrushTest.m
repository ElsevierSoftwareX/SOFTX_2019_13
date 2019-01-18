%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datahandling results of crush tests           %
%                29.08.2018 Tim Benkert           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datahandling of crush test data
% 
% This function reads data from files, that hold the results of crush
% tests. There need to be the following entries for the function to work
% properly and the data has to be arranged in columns, seperated by the
% delimiter. Every column needs to have a label which must stand
% somewhere above the column. All labels need to be in the same row of the
% file.
%
% [out] = datahandlingCrushTest(filenames, path, database varargin)
% 
% 
% Input Values
%
% filenames (cell, required)
% cell array containing the filenames of the experimental data
% 
% path (cell, required)
% path to the folder of the files from above
%
% database
% Cell array created by database.m
% 
% delimiter (cell, optional)
% cell array containing the delimiters, e.g. delimiter = {',',';'}
% datahandlingCrushTest(filenames, path, database, 'delimiter', {';'})
% Default delimiter: ;
% 
% displacementLabel, forceLabel, timeLabel, diameterInitialLabel,
% lengthInitialLabel, (character, optional parameter)
% Labels of the columns containing the experimental data.
% datahandlingCrushTest(filenames, path, 'timeLabel', 'time')
% Defaults:
% displacement:     Standardweg
% force:            Standardkraft
% time:             Pr?fzeit
% diameterInitial:  Durchmesser
% lengthInitial:    Probenh?he
% 
% Output values
% 
% out
% Is empty if something goes wrong.

function [out] = datahandlingCrushTest(filenames, path, database, labels, varargin)
%% Check input data
displacementLabel = labels{1,1};
forceLabel = labels{2,1};
diameterInitialLabel = labels{3,1};
timeLabel = labels{4,1};
lengthInitialLabel = labels{5,1};

p = inputParser;
p.CaseSensitive = true;
addRequired(p,'filenames',@iscell);
addRequired(p,'path',@ischar);
addRequired(p,'database',@iscell);
addParameter(p, 'delimiter', {';'}, @iscell);
addParameter(p, 'displacementLabel', displacementLabel, @ischar);
addParameter(p, 'forceLabel', forceLabel, @ischar);
addParameter(p, 'timeLabel', timeLabel, @ischar);
addParameter(p, 'diameterInitialLabel', diameterInitialLabel, @ischar);
addParameter(p, 'lengthInitialLabel', lengthInitialLabel, @ischar);
addParameter(p, 'displacementColumn', 1, @isnumeric);
addParameter(p, 'forceColumn', 2, @isnumeric);
addParameter(p, 'timeColumn', 3, @isnumeric);
addParameter(p, 'diameterInitialColumn', 4, @isnumeric);
addParameter(p, 'lengthInitialColumn', 5, @isnumeric);
parse(p,filenames, path, database, varargin{:});
out = p.Results.database;
rows = checkLabels(out, 'lengthCrushTestOriginal', ...
                        'forceCrushTestOriginal', ...
                        'timeCrushTestOriginal', ...
                        'diameterInitialCrushTestOriginal', ...
                        'lengthInitialCrushTestOriginal', ...
                        'lengthCrushTestEdit', ...
                        'forceCrushTestEdit', ...
                        'timeCrushTestEdit', ...
                        'diameterInitialCrushTestEdit', ...
                        'lengthInitialCrushTestEdit', ...
                        'lengthCrushTest', ...
                        'forceCrushTest', ...
                        'timeCrushTest', ...
                        'diameterInitialCrushTest', ...
                        'lengthInitialCrushTest');

%% Read data from the submitted files
% Loop to go through the provided files
for i = 1:length(p.Results.filenames)
    % initiate variables
    forceLabelFound = [];
    timeLabelFound = [];
    displacementLabelFound = [];
    diameterInitialLabelFound = [];
    lengthInitialLabelFound = [];

    % read file and write content into a variable
    datei = fullfile(p.Results.path, p.Results.filenames(i)); % build path to file
    fileID = fopen(datei{1},'r'); % open in file in read mode
    fullText = fread(fileID,'char=>char')'; % read file in a long character row vector
    fclose(fileID); % close file
    inp = splitlines(fullText); % split the long string at the newline characters
    h = size(inp);
    m = h(1);
    
    for j = 1:m % loop until the end-1 of inp, the last row is empty by definition
        h = str2num(inp{j}); % convert current row to numeric and write in help variable
        if isempty(h) == 0 % if current row could be converted to numeric h is not empty
            data{i,j} =  h; % write numeric values in array
        elseif isempty(h) == 1 % if current row could not be converted to numeric h is empty
            data{i,j} = inp{j}; % write input data unchanged in array
        else
            out = [];
            msgbox(['Error while reading ', num2str(i), '. file!']);
            return;
        end
        % Check if the current line contains labels
        if contains(inp{j}, p.Results.forceLabel) % Check if label occurs in the current line
            labelRow = j; % Set counter number as the column number where the labels are
            forceLabelFound = 1;
        end
        if contains(inp{j}, p.Results.timeLabel)
            labelRow = j;
            timeLabelFound = 1;
        end
        if contains(inp{j}, p.Results.displacementLabel)
            labelRow = j;
            displacementLabelFound = 1;
        end
        if contains(inp{j}, p.Results.diameterInitialLabel)
            labelRow = j;
            diameterInitial = strsplitConv2Num(inp{j});
            diameterInitialLabelFound = 1;
        end
        if contains(inp{j}, p.Results.lengthInitialLabel)
            labelRow = j;
            lengthInitial = strsplitConv2Num(inp{j});
            lengthInitialLabelFound = 1;
        end
    end
    
    % look for the first column that contains measuring data --> is numeric
    j = 1;
    while ischar(data{i,j})
        j = j+1;
        measuringDataColumn = j; % 
    end
    
    % Check if there are any labels that have not been found
    missing = [];
    if isempty(forceLabelFound)  % Check if label does not occur in the label row
        missing = [missing ', ' p.Results.forceLabel]; % write the label name in the variable "missing"
    end
    if isempty(timeLabelFound)
        missing = [missing ', ' p.Results.timeLabel];
    end
    if isempty(displacementLabelFound)
        missing = [missing ', ' p.Results.displacementLabel];
    end
    if isempty(diameterInitialLabelFound)
        missing = [missing ', ' p.Results.diameterInitialLabel];
    end
    if isempty(lengthInitialLabelFound)
        missing = [missing ', ' p.Results.lengthInitialLabel];
    end
    if ~isempty(missing) % if missing is not empty, there are labels that have not been found
        out = [];
        msgbox(['The ', num2str(i), '. file misses the following labels: ', missing, '.'])
        return;
    end
    % seperate the labels within the row containing the labels, using the
    % delimiter
    data{i,labelRow} = strsplit(data{i,labelRow},p.Results.delimiter);
    
    % determine size of data
    h = size(data);
    n = h(2);
    
    % Look for the column numbers of the labels and put the data within
    % these columns in one vector
    % ====================================================================
    % Search the column with the labels for the number of the columns
    for j = 1:length(data{i, labelRow})
        if contains(data{i, labelRow}(j), p.Results.timeLabel)
            timeColumnIn = j;
        elseif contains(data{i, labelRow}(j), p.Results.forceLabel)
            forceColumnIn = j;
        elseif contains(data{i, labelRow}(j), p.Results.displacementLabel)
            displacementColumnIn = j;
        end
    end
    
    % Read from the variable that the files have been put in and write
    % the data into a help variable while skipping empty entries in data
    time = [];
    force = [];
    displacement = [];
    for j = measuringDataColumn:n
        if ~isempty(data{i,j})
            time(end+1) = data{i,j}(timeColumnIn);
            force(end+1) = data{i,j}(forceColumnIn);
            displacement(end+1) = data{i,j}(displacementColumnIn);
        end
    end
    %% Output
    out{rows(1),i+1} = displacement;
    out{rows(2),i+1} = force;
    out{rows(3),i+1} = time;
    out{rows(4),i+1} = diameterInitial;
    out{rows(5),i+1} = lengthInitial;
    out{rows(6),i+1} = displacement;
    out{rows(7),i+1} = force;
    out{rows(8),i+1} = time;
    out{rows(9),i+1} = diameterInitial;
    out{rows(10),i+1} = lengthInitial;
    out{rows(11),i+1} = displacement;
    out{rows(12),i+1} = force;
    out{rows(13),i+1} = time;
    out{rows(14),i+1} = diameterInitial;
    out{rows(15),i+1} = lengthInitial;
end
end