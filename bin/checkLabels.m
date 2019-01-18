%% checkLabels
% 
% This function checks array if they contain the supplied strings in the
% array's first column.
% It returns the row numbers as a vector. The numbers within the vector
% are sorted in the same way as the input strings are sorted.
% 
% Input
%
% inp (cell array)
% Is the variable created by database.m
%
% varargin
% Put in as many search strings as desired like this:
% checkLabels(inp, 'string1,'string2',string3','...')
%
% Output
%
% out
% out is a vector of the length of the number of supplied search strings.
% If there where 10 search strings supplied, out will be of the length 10.
% The entries in out are sorted in the same order as the search strings are
% supplied. If not all search strings are found within inp, out is empty.

function [out] = checkLabels(inp, varargin)
%% determine size of inp and varargin
h = size(varargin);
n = h(2);
clear h;
out = [];
missing = varargin;

%% look for labels in the first column of inp
for jj = 1:n % walk through columns of varargin
    if ~isempty(find(strcmp(inp(:,1)', varargin{1,jj})))
        if length(find(strcmp(inp(:,1)', varargin{1,jj})))==1
            out(end+1)=find(strcmp(inp(:,1)', varargin{1,jj})); % returns index in inp of the string in varargin(jj)
            h = find(strcmp(missing(1,:), varargin{1,jj})); % returns index in missing of string in varargin(jj)
            missing(:,h) = []; % deletes the entry in missing
            clear h;
        else
            out = [];
            msgbox([varargin{1,jj} ' occurs more than one time in database.']);
            return;
        end
    end
end

%% Check if all labels have been found
if ~isempty(missing)
    out = [];
    msgbox(['checkLabel.m could not find the labels:' missing])
end
end