% This function splits a string like the one shown below. A blank is the
% delimiter. Further down the parts of the string that cannot be
% transformed into numbers are left out, the rest is transformed to numbers
% and the output is a vector containing those parts of the input string
% that can be transformed to numbers
%
% Example string
% inp = 'Prüfgeschwindigkeit                     0.0067 1/s 500 1200';
function [out] = strsplitConv2Num(inp)
    out = [];
    h = strsplit(inp);
    n = length(h);
    for j = 1:n
        temp = str2num(h{1,j});
        if ~isempty(temp)
            out(end+1) = temp;
        end
    end
end