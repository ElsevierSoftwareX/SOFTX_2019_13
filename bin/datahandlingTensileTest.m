%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datahandling results of tensile tests           %
%                15.03.2018 Tim Benkert           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datahandling of tensile test data
% 
% This function reads data from files, that hold the results of tensile
% tests. There need to be the following entries for the function to work
% properly and the data has to be arranged in columns, seperated by the
% delimiter. Every column needs to have a label which must stand
% somewhere above the column. All labels need to be in the same row of the
% file.
%
% [out] = datahandlingTensileTest(filenames, path, database, varargin)
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
% datahandlingTensileTest(filenames, path, database, 'delimiter', {';'})
% Default delimiter: ;
% 
% displacementLabel, forceLabel, widthLabel, timeLabel, widthInitialLabel,
% lengthInitialLabel, thicknessInitialLabel (character, optional parameter)
% Labels of the columns containing the experimental data. Must be a string.
% datahandlingTensileTest(filenames, path, 'timeLabel', 'time')
% Defaults:
% displacement:     Standardweg
% force:            Standardkraft
% width:            Probenbreite
% time:             Pr?fzeit
% widthInitial:     Anfangsprobenbreite
% lengthInitial:    Markierte Anfangsmessl?nge
% thicknessInitial: Anfangsprobendicke
% 
% Output values
% 
% out
% Is empty if something goes wrong.

function [out] = datahandlingTensileTest(filenames, path, database, labels, varargin)
%% Check input data
% displacementLabel = 'Standardweg';
% forceLabel = 'Standardkraft';
% widthLabel = ['Breiten',char(65533),'nderung'];
% timeLabel = ['Pr',char(65533),'fzeit'];
% widthInitialLabel = 'Anfangsprobenbreite';
% lengthInitialLabel = ['Markierte Anfangsmessl',char(65533),'nge'];
% thicknessInitialLabel = 'Anfangsprobendicke';

displacementLabel = labels{1,1};
forceLabel = labels{2,1};
widthLabel = labels{3,1};
timeLabel = labels{4,1};
widthInitialLabel = labels{5,1};
lengthInitialLabel = labels{6,1};
thicknessInitialLabel = labels{7,1};

p = inputParser;
p.CaseSensitive = true;
addRequired(p,'filenames',@iscell);
addRequired(p,'path',@ischar);
addRequired(p,'database',@iscell);
addParameter(p, 'delimiter', {';'}, @iscell);
addParameter(p, 'displacementLabel', displacementLabel, @ischar);
addParameter(p, 'forceLabel', forceLabel, @ischar);
addParameter(p, 'widthLabel', widthLabel, @ischar);
addParameter(p, 'timeLabel', timeLabel, @ischar);
addParameter(p, 'widthInitialLabel', widthInitialLabel, @ischar);
addParameter(p, 'lengthInitialLabel', lengthInitialLabel, @ischar);
addParameter(p, 'thicknessInitialLabel', thicknessInitialLabel, @ischar);
parse(p,filenames, path, database, varargin{:});
out = p.Results.database;
rows = checkLabels(out, 'lengthTensileTestOriginal', ...
                        'forceTensileTestOriginal', ...
                        'widthTensileTestOriginal', ...
                        'timeTensileTestOriginal', ...
                        'widthInitialTensileTestOriginal', ...
                        'lengthInitialTensileTestOriginal', ...
                        'thicknessInitialTensileTestOriginal', ...
                        'lengthTensileTest', ...
                        'forceTensileTest', ...
                        'widthTensileTest', ...
                        'timeTensileTest', ...
                        'widthInitialTensileTest', ...
                        'lengthInitialTensileTest', ...
                        'thicknessInitialTensileTest', ...
                        'lengthTensileTestEdit', ...
                        'forceTensileTestEdit', ...
                        'widthTensileTestEdit', ...
                        'timeTensileTestEdit', ...
                        'widthInitialTensileTestEdit', ...
                        'lengthInitialTensileTestEdit', ...
                        'thicknessInitialTensileTestEdit', ...
                        'specimenTypeTensileTest');

%% Read data from the submitted files
% Loop to go through the provided files
data{length(p.Results.filenames), 1} = 1; % preallocate data

for i = 1:length(p.Results.filenames)
    % initiate variables
    forceLabelFound = [];
    timeLabelFound = [];
    displacementLabelFound = [];
    widthLabelFound = [];
    widthInitialLabelFound = [];
    lengthInitialLabelFound = [];
    thicknessInitialLabelFound = [];
    % read file and write content into a variable
    datei = fullfile(p.Results.path, p.Results.filenames(i)); % build path to file
    fileID = fopen(datei{1},'r'); % open in file in read mode
    fullText = fread(fileID,'char=>char')'; % read file in a long character row vector
    fclose(fileID); % close file
    inp = splitlines(fullText); % split the long string at the newline characters
    h = size(inp);
    m = h(1);
    clear h;
    h = size(data);
    nData = h(2);
    clear h;
    if nData<m
        data{1,m}=1; % Preallocate space for data
    end
    
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
        if contains(inp{j}, p.Results.widthLabel)
            labelRow = j;
            widthLabelFound = 1;
        end
        if contains(inp{j}, p.Results.widthInitialLabel)
            labelRow = j;
            widthInitial = strsplitConv2Num(inp{j});
            widthInitialLabelFound = 1;
        end
        if contains(inp{j}, p.Results.lengthInitialLabel)
            labelRow = j;
            lengthInitial = strsplitConv2Num(inp{j});
            lengthInitialLabelFound = 1;
        end
        if contains(inp{j}, p.Results.thicknessInitialLabel) && strcmp(out{rows(22),2}, 'flat')
            labelRow = j;
            thicknessInitial = strsplitConv2Num(inp{j});
            thicknessInitialLabelFound = 1;
        end
    end
    
    % look for the first column that conatins measuring data --> is numeric
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
    if isempty(widthLabelFound)
        missing = [missing ', ' p.Results.widthLabel];
    end
    if isempty(widthInitialLabelFound)
        missing = [missing ', ' p.Results.widthInitialLabel];
    end
    if isempty(lengthInitialLabelFound)
        missing = [missing ', ' p.Results.lengthInitialLabel];
    end
    if isempty(thicknessInitialLabelFound)  && strcmp(out{rows(22),2}, 'flat')
        missing = [missing ', ' p.Results.thicknessInitialLabel];
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
        elseif contains(data{i, labelRow}(j), p.Results.widthLabel)
            widthColumnIn = j;
        end
    end
    
    % Read from the variable that the files have been put in and write
    % the data into a help variable while skipping empty entries in data
    time = [];
    force = [];
    displacement = [];
    width = [];
    for j = measuringDataColumn:n
        if ~isempty(data{i,j})
            time(end+1) = data{i,j}(timeColumnIn);
            force(end+1) = data{i,j}(forceColumnIn);
            displacement(end+1) = data{i,j}(displacementColumnIn);
            width(end+1) = data{i,j}(widthColumnIn);
        end
    end
    %% Output
    out{rows(1),i+1} = displacement;
    out{rows(2),i+1} = force;
    out{rows(3),i+1} = width;
    out{rows(4),i+1} = time;
    out{rows(5),i+1} = widthInitial;
    out{rows(6),i+1} = lengthInitial;
    if strcmp(out{rows(22),2}, 'flat')
        out{rows(7),i+1} = thicknessInitial;
    end
    out{rows(8),i+1} = displacement;
    out{rows(9),i+1} = force;
    out{rows(10),i+1} = width;
    out{rows(11),i+1} = time;
    out{rows(12),i+1} = widthInitial;
    out{rows(13),i+1} = lengthInitial;
    if strcmp(out{rows(22),2}, 'flat')
        out{rows(14),i+1} = thicknessInitial;
    end
    out{rows(15),i+1} = displacement;
    out{rows(16),i+1} = force;
    out{rows(17),i+1} = width;
    out{rows(18),i+1} = time;
    out{rows(19),i+1} = widthInitial;
    out{rows(20),i+1} = lengthInitial;
    if strcmp(out{rows(22),2}, 'flat')
        out{rows(21),i+1} = thicknessInitial;
    end
end
end