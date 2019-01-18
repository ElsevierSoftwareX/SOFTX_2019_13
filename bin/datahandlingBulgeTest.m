%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datenhandling Bulgetests
% 11.07.2018 Tim Benkert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function reads data from files, that hold the results of bulge
% tests. There need to be the following entries for the function to work
% properly and the data has to be arranged in columns, seperated by the
% delimiter.
%
% [out] = datahandlingBulgeTest(filenames, path, database, varargin)
% 
% 
% Input Values
%
% filenames (required, cell array)
% cell array containing the filenames of the experimental data
% 
% path (required, char)
% path to the folder of the files from above
%
% database (required, cell)
% A cell array created by database.m. The results of the corresponding
% tensile tests have to be in there already.
% 
% delimiter (optional parameter, cell array)
% cell array containing the delimiters, e.g. delimiter = {',',';'}
% datahandlingBulgeTest(filenames, path, 'delimiter', {';'})
% Default delimiter: ;
% 
% trueStrainLabel, trueStressLabel, timeLabel (optional parameter, string)
% Labels of the columns containing the experimental data.
% datahandlingBulgeTest(filenames, path, 'timeLabel', 'time')
% Defaults:
% true stress: True Stress (YC1)
% true strain: True Strain (YC1)
% time:        Time
% 
% Output values
% 
% out (cell array)
% Is empty if something went wrong within this function.

function [out] = datahandlingBulgeTest(filenames, path, database, labels, varargin)
%% Check input data

trueStressLabel = labels{1,1};
trueStrainLabel = labels{2,1};
timeLabel = labels{3,1};

p = inputParser;
p.CaseSensitive = true;
addRequired(p,'filenames',@iscell);
addRequired(p,'path',@ischar);
addRequired(p,'database',@iscell);
addParameter(p, 'delimiter', {';'}, @iscell);
addParameter(p, 'trueStressLabel', trueStressLabel, @ischar);
addParameter(p, 'trueStrainLabel', trueStrainLabel, @ischar);
addParameter(p, 'timeLabel', timeLabel, @ischar);
parse(p,filenames, path, database, varargin{:});

out = database;
rows = checkLabels(out, 'epsilonTruePlBulgeOriginal', ...
                        'sigmaTruePlBulgeOriginal', ...
                        'timeBulgeOriginal', ...
                        'epsilonTruePlBulge', ...
                        'sigmaTruePlBulge', ...
                        'timeBulge', ...
                        'epsilonTruePlBulgeEdit', ...
                        'sigmaTruePlBulgeEdit', ...
                        'timeBulgeEdit');
if isempty(rows)
    msgbox('datahandlingTensileTest.m: Not all labels found.')
    out = [];
    return;
end

%% Read data from the submitted files
% Loop to go through the provided files
for i = 1:length(p.Results.filenames)
    % initiate variables
    labelRow = [];
    trueStressLabelFound = [];
    timeLabelFound = [];
    trueStrainLabelFound = [];
    
    % read file and write content into a variable
    datei = fullfile(p.Results.path, p.Results.filenames(i)); % build path to file
    fileID = fopen(datei{1},'r'); % open in file in read mode
    fullText = fread(fileID,'char=>char')'; % read file in a long character row vector
    fclose(fileID); % close file
    inp = splitlines(fullText); % split the long string at the newline characters
    h = size(inp);
    m = h(1);
    
    for j = 1:m % loop until there is no character anymore in inp at current position
        if isempty(inp{j})
            break;
        elseif strcmp(inp{j}(1), '#') % if first letter in current row is #
            data{i,j} = inp{j}; % write current row unconverted in data
        else
            h = replace(inp{j}, 'None', 'NaN'); % replace 'None' with 'NaN' in current row
            data{i,j} = str2num(h)'; 
        end
        % Check it there is something in data{i,j}
        if isempty(data{i,j})
            out = [];
            msgbox(['Error while reading the ', num2str(i), '. file']);
            return;
        end
        % Check if the current row contains labels
        if contains(inp{j}, p.Results.trueStressLabel) % Check if label occurs in the current line
            labelRow = j; % Set counter number as the column number where the labels are
            trueStressLabelFound = 1; % Set counter number as the column where the labels are
        end
        if contains(inp{j}, p.Results.trueStrainLabel)
            labelRow = j;
            trueStrainLabelFound = 1;
        end
        if contains(inp{j}, p.Results.timeLabel)
            labelRow = j;
            timeLabelFound = 1;
        end
    end
    
    % look for the first column that conatins measuring data --> is numeric
    j = 1;
    while ischar(data{i,j})
        j = j+1;
        measuringDataColumn = j; % Bei der Gr??e der Z?hlervariablen beginnen die Messdaten. In der n?chsten Runde der Schleifenauswertung wird die Schleife ?bersprungen, da der Header vorbei ist und nun die Messdaten kommen.
    end
    
    % Check if there are any labels that have not been found
    missing = [];
    if isempty(trueStressLabelFound)  % Check if label does not occur in the label row
        missing = [missing ', ' p.Results.trueStressLabel]; % write the label name in the variable "missing"
    end
    if isempty(trueStrainLabelFound)
        missing = [missing ', ' p.Results.trueStrainLabel];
    end
    if isempty(timeLabelFound)
        missing = [missing ', ' p.Results.timeLabel];
    end
    if ~isempty(missing) % if missing is not empty, there are labels that have not been found
        out = [];
        msgbox(['In der ', num2str(i), '-ten Datei konnten die Label ', missing, ' nicht gefunden werden.']);
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
        if contains(data{i, labelRow}(j), p.Results.trueStressLabel)
            trueStressColumnIn = j;
        elseif contains(data{i, labelRow}(j), p.Results.trueStrainLabel)
            trueStrainColumnIn = j;
        elseif contains(data{i, labelRow}(j), p.Results.timeLabel)
            timeColumnIn = j;
        end
    end
    
    % Read from the variable that the files have been put in and write
    % the data into a help variable while skipping empty entries in data
    trueStress = [];
    trueStrain = [];
    time = [];
    for j = measuringDataColumn:n
        if ~isempty(data{i,j})
            trueStress(end+1) = data{i,j}(trueStressColumnIn);
            trueStrain(end+1) = data{i,j}(trueStrainColumnIn);
            time(end+1) = data{i,j}(timeColumnIn);
        end
    end
    % Check if there is NaN within the result vectors, write the indices of
    % NaN in variables
    [~, colStress] = find(isnan(trueStress));
    [~, colStrain] = find(isnan(trueStrain));
    [~, colTime] = find(isnan(time));
    col = [colStress colStrain colTime]; % Put together indices in one vetor
    col = unique(col); % erase double entries from col
    % Erase entries from result vectors that contain NaN
    trueStress(col) = [];
    trueStrain(col) = [];
    time(col) = [];
       
    % Write results in out
    out{rows(1),i+1} = trueStrain;
    out{rows(2),i+1} = trueStress;
    out{rows(3),i+1} = time;
    out{rows(4),i+1} = trueStrain;
    out{rows(5),i+1} = trueStress;
    out{rows(6),i+1} = time;
    out{rows(7),i+1} = trueStrain;
    out{rows(8),i+1} = trueStress;
    out{rows(9),i+1} = time;
end
end