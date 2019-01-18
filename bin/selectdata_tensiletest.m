%%%%%%%%%%%%%%% UI selectdata_tensiletest

% This function lets the user of the GUI select the data for the tensile test

% Inpunt:
% direction

% Output:
% filepath = cell array with columns: #1:direction #2:fn #3:path
    
function [ filepath, selection_made] = selectdata_tensiletest(direction)
    
    filepath = cell(1,3); %definition of the cell filepath (output)
  
    direction_name = [int2str(direction),' degree'];
    [fn, path, selection_made]=uigetfile('*.*',['Select the tensile test data for  ' direction_name],'MultiSelect','on');
    if ischar(fn) == 1 % Wenn nur eine Datei ausgew?hlt ist, ist das Ergebnis ein char
        h{1,1} = fn;
        fn = h;
    elseif iscell(fn) ==1 % Wenn mehr als eine Datei ausgew?hlt wird, ist das Ergebnis ein cell

    end
    
    filepath(1,1) = {direction};
    filepath(1,2) = {fn};
    filepath(1,3) = {path};

end

