%%%%%%%%%%%%%%% UI selectdata_tensiletest

% This function lets the user of the GUI select the data for the bulge test

% Inpunt:
% -

% Output:
% filepath = cell array with columns: #1:fn #2:path

function [ filepath, selection_made ] = selectdata_bulgetest( )
    
    filepath = cell(1,2); %definition of the cell filepath (output)
  
    [fn, path, selection_made]=uigetfile('*.*',['Select the bulge test data'],'MultiSelect','on');
    if ischar(fn) == 1 % Wenn nur eine Datei ausgew?hlt ist, ist das Ergebnis ein char
        h{1,1} = fn;
        fn = h;
    elseif iscell(fn) ==1 % Wenn mehr als eine Datei ausgew?hlt wird, ist das Ergebnis ein cell

    end
    
    filepath(1,1) = {path};
    filepath(1,2) = {fn};
    
end

