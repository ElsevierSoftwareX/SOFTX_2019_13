%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datahandling results of crush tests           %
%                29.08.2018 Tim Benkert           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datahandling of crush test data
% 
% This function reads data from files, that hold the results of stiffness
% tests. There need to be the following entries for the function to work
% properly and the data has to be arranged in columns, seperated by the
% delimiter. Every column needs to have a label which must stand
% somewhere above the column. All labels need to be in the same row of the
% file.
%
% [out] = datahandlingCrushTest(filenames, path, database)
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
% displacementLabel, forceLabel (character, optional parameter)
% Labels of the columns containing the experimental data.
% datahandlingStiffnessTest(filenames, path, database, 'timeLabel', 'time')
% Defaults:
% displacement:     Standardweg
% force:            Standardkraft
%
% maxForce (numeric, optional)
% As the stiffness data have to have higher force values as your
% experimental data for the stiffness corrction to, your stiffness data are
% extrapolated from the last 10 force points available. Use maxForce to
% set the maximum value for that extrapolation. Meaningful values are a
% little higher than the maximum force your testing machine is able to
% apply.
% Default: 300000
% datahandlingStiffnessTest(filenames, path, database, 'maxForce', 205000)
% 
% Output values
% 
% out
% Is empty if something goes wrong.

function [out] = datahandlingStiffnessTest(filenames, path, database,labels, varargin)
%% Check input data
displacementLabel = labels{1,1};
forceLabel = labels{2,1};

p = inputParser;
p.CaseSensitive = true;
addRequired(p,'filenames',@iscell);
addRequired(p,'path',@ischar);
addRequired(p,'database',@iscell);
addParameter(p, 'delimiter', {';'}, @iscell);
addParameter(p, 'displacementLabel', displacementLabel, @ischar);
addParameter(p, 'forceLabel', forceLabel, @ischar);
addParameter(p, 'maxForce', 300000, @isnumeric);
parse(p,filenames, path, database, varargin{:});
out = p.Results.database;
rows = checkLabels(out, 'lengthStiffness', ...
                        'forceStiffness');

%% Read data from the submitted files
% Loop to go through the provided files
for i = 1:length(p.Results.filenames)
    % initiate variables
    forceLabelFound = [];
    displacementLabelFound = [];

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
        if contains(inp{j}, p.Results.displacementLabel)
            labelRow = j;
            displacementLabelFound = 1;
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
    if isempty(displacementLabelFound)
        missing = [missing ', ' p.Results.displacementLabel];
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
        if contains(data{i, labelRow}(j), p.Results.forceLabel)
            forceColumnIn = j;
        elseif contains(data{i, labelRow}(j), p.Results.displacementLabel)
            displacementColumnIn = j;
        end
    end
    
    % Read from the variable that the files have been put in and write
    % the data into a help variable while skipping empty entries in data
    force = [];
    displacement = [];
    for j = measuringDataColumn:n
        if ~isempty(data{i,j})
            force(end+1) = data{i,j}(forceColumnIn);
            displacement(end+1) = data{i,j}(displacementColumnIn);
        end
    end
    % Extrapolate the stiffness data
    [xData, yData] = prepareCurveData(displacement(end-10:end), force(end-10:end));
    forceFit = fit(xData, yData, 'poly1');
    force = [force p.Results.maxForce];
    displacement = [displacement (p.Results.maxForce-forceFit.p2)/forceFit.p1];
    %% Output
    out{rows(1),i+1} = displacement;
    out{rows(2),i+1} = force;
end
end