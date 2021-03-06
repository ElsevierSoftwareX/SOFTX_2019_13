%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Tim Benkert                                %
%                              09.08.2018                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function exports the processed experimental data into an -inp-File
% that can be used in Abaqus.
%
% exportAbaqus(datbase, density)
%
% Input
% 
% database (cell, required)
% This input contains all data that have been generated by any of the eval
% functions. If a tensile test in multiple directions was performs,
% database corresponds to the results of the specimen in rolling direction.
% 
% density (numeric)
% Since the density of the material has not played a role yet, it needs to
% be provided. Make sure it is submitted in t/mm^3. Exponential description
% is possible, e.g. 7.8e-9.
%
% degree45 (cell, optional)
% This input contains all data that have been generated by the function
% evalTensileTest for test specimens taken at a 45 degree angle to the rolling
% direction.
% Default: empty
% exportAbaqus(database, density, 'degree45', degree45)
%
% degree90 (cell, optional)
% This input contains all data that have been generated by the function
% evalTensileTest for test specimens taken at a 90 degree angle to the rolling
% direction.
% Default: empty
% exportAbaqus(database, density, 'degree90', degree90)
%
% name (character, optional)
% The name the material shall be named with in Abaqus, e.g. 'DC04'.
% Default: material
% exportAbaqus(database, density, 'name', 'DC04')
%
% filename (character, optional)
% Provide a filename you want the results to be saved in.
% Default: abaqusExport.inp
% exportAbaqus(database, density, 'filename', 'DC04.inp')
%
% path
% Provide a path where you want the results to be saved in.
% Default: current working directory.
% exportAbaqus(database, density, 'path', 'D:\Export')

function exportAbaqus(degree0, density, varargin)
%% Check input
% Define the input parser
p = inputParser;
p.CaseSensitive = true;
addRequired(p, 'degree0', @iscell);
addRequired(p, 'density', @isnumeric);
addParameter(p, 'degree45', [], @iscell);
addParameter(p, 'degree90', [], @iscell);
addParameter(p, 'materialName', 'material', @ischar);
addParameter(p, 'filename', 'exportAbaqus.inp', @ischar);
addParameter(p, 'path', pwd, @ischar);
addParameter(p, 'strainLabel', 'epsilonYieldCurveExport', @ischar);
addParameter(p, 'stressLabel', 'sigmaYieldCurveExport', @ischar);
parse(p, degree0, density, varargin{:});

degree0 = p.Results.degree0;
degree45 = p.Results.degree45;
degree90 = p.Results.degree90;
density = p.Results.density;
materialName = p.Results.materialName;
datei = fullfile(p.Results.path, p.Results.filename);
strainLabel = p.Results.strainLabel;
stressLabel = p.Results.stressLabel;

% Initialise Variables
r0 = [];
r45 = [];
r90 = [];
EExp45 = [];
EExp90 = [];

% Get data to export out of the input data
% From degree0
rows = checkLabels(degree0, 'EExp', 'ELit', 'nue', strainLabel, stressLabel);
EExp0 = degree0{rows(1),2};
ELit0 = degree0{rows(2),2};
nue0 = degree0{rows(3),2};
fitEpsilonYieldCurve = degree0{rows(4),2};
fitSigmaYieldCurve = degree0{rows(5),2};
yieldBegin = fitSigmaYieldCurve(1);
epsilonXTrueRp = fitEpsilonYieldCurve(2);
sigmaXTrueRp = fitSigmaYieldCurve(2);

% Check if r-Values are present 
rowsR = checkLabels(degree0, 'r');
if ~isempty(degree0{rowsR(1),2})
    r0 = degree0{rowsR(1),2};
end


% From degree45
if ~isempty(degree45)
    rows45 = checkLabels(degree45, 'EExp');
    EExp45 = degree45{rows45(1),2};
    % Check if r-Values are present 
    rows45R = checkLabels(degree45, 'r');
    if ~isempty(degree45{rows45R(1),2})
        r45 = degree45{rows45R(1),2};
    end
end

% From degree90
if ~isempty(degree90)
    rows90 = checkLabels(degree90, 'EExp');
    EExp90 = degree90{rows90(1),2};
    % Check if r-Values are present 
    rows90R = checkLabels(degree90, 'r');
    if ~isempty(degree90{rows90R(1),2})
        r90 = degree90{rows90R(1),2};
    end
end

%% Calculations
% E-Modulus
if isempty(ELit0)
    if ~isempty(EExp45) && ~isempty(EExp90)
        EModulus = mean([EExp0 EExp45 EExp90]);
    else
        EModulus = EExp0;
    end
else
    EModulus = ELit0;
end

% Shorten the yieldCurve vectors in length. Usually there are several
% thousand data points, which is unnecessary for Abaqus.
% Generate query vector
h = fitEpsilonYieldCurve(end)-fitEpsilonYieldCurve(1); % Range of epsilon data points
noStep = 200;    % Number of data points in the final vector
epsilonYield = ceil(epsilonXTrueRp/(h/noStep))*h/noStep:h/noStep:fitEpsilonYieldCurve(end);
% epsilonYield = fitEpsilonYieldCurve(1):h/noStep:fitEpsilonYieldCurve(end);
% epsilonYield = [epsilonYield epsilonXTrueRp]; % Attach Rp to xq, to have it definitly in the output
% epsilonYield = sort(epsilonYield); % Sort xq so that epsilonLEngRp falls at the right position
% Use interp1 to interpolate between the data points
sigmaYield = interp1(fitEpsilonYieldCurve, fitSigmaYieldCurve, epsilonYield);
% Write sigma and epsilon in matrix, put yieldBegin in front
exportYieldCurve(1,:) = [yieldBegin sigmaXTrueRp sigmaYield];
exportYieldCurve(2,:) = [0 epsilonXTrueRp epsilonYield];
% exportYieldCurve(1,:) = sigmaYield;
% exportYieldCurve(2,:) = epsilonYield;

% Calculate R Values from r values (Lankford)
if ~isempty(r0) && ~isempty(r45) && ~isempty(r90)
    R11 = 1;
    R22 = sqrt((r90*(r0+1)) / (r0*(r90+1)));
    R33 = sqrt((r90*(r0+1)) / (r0+r90));
    R12 = sqrt((3*(r0+1)*r90) / ...
                ((2*r45+1) * (r0+r90)));
    R13 = 1;
    R23 = 1;
end

%% Write input file
% Open file for writing, if not there yet create file, overwrite exisiting
% content
fID = fopen(datei, 'w');
fprintf(fID, '%s\r\n', '** MATERIALS');
fprintf(fID, '%s\r\n', '**');
fprintf(fID, '%s\r\n', ['*Material, name=' materialName]);
fprintf(fID, '%s\r\n', '*Density');
fprintf(fID, '%.3e\r\n', density);
fprintf(fID, '%s\r\n', '*Elastic');
fprintf(fID, '%8.1f, %.3f\r\n', EModulus, nue0);
fprintf(fID, '%s\r\n', '*Plastic');
fprintf(fID, '%.6f, %.6f\r\n', exportYieldCurve);
if ~isempty(r0) && ~isempty(r45) && ~isempty(r90)
    fprintf(fID, '%s\r\n', '*Potential');
    fprintf(fID, '%.5f, %.5f, %.5f, %.5f, %.5f, %.5f', [R11 R22 R33 R12 R13 R23]);
end
fclose(fID);
end