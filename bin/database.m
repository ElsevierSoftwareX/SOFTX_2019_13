%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% database MaterialModeler
% 31.08.2018 Tim Benkert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function creates the database cell array for the software
% MaterialModeler.
%
% database
%
% Output values
% 
% out (cell array)
% Contains two rows. The second row contains empty values, the first row
% contains the name of the database entry.
%
% Description of the database entries -> see code

function [out] = database
out = [];
% Type of Test
% ============
m = size(out, 1);
out{m+1,1} = 'tensileTest';
out{m+1,2} = [];
out{m+2,1} = 'bulgeTest';
out{m+2,2} = [];
out{m+3,1} = 'crushTest';
out{m+3,2} = [];
% specimen type
% =============
m = size(out, 1);
out{m+1,1} = 'specimenTypeTensileTest';
out{m+1,2} = [];
% Input files
m = size(out, 1);
out{m+1,1} = 'fnTensileTest';
out{m+1,2} = [];
out{m+2,1} = 'pathTensileTest';
out{m+2,2} = [];
out{m+3,1} = 'fnBulgeTest';
out{m+3,2} = [];
out{m+4,1} = 'pathBulgeTest';
out{m+4,2} = [];
out{m+5,1} = 'fnCrushTest';
out{m+5,2} = [];
out{m+6,1} = 'pathCrushTest';
out{m+6,2} = [];
% Tensile Test measuring data
% ===========================
% time dependent values orignal
% These values stay unchanged during the whole runtime of MaterialModeler
m = size(out, 1);
out{m+1,1} = 'lengthTensileTestOriginal';
out{m+1,2} = [];
out{m+2,1} = 'forceTensileTestOriginal';
out{m+2,2} = [];
out{m+3,1} = 'widthTensileTestOriginal';
out{m+3,2} = [];
out{m+4,1} = 'timeTensileTestOriginal';
out{m+4,2} = [];
% initial values original
% These values stay unchanged during the whole runtime of MaterialModeler
out{m+5,1} = 'widthInitialTensileTestOriginal';
out{m+5,2} = [];
out{m+6,1} = 'lengthInitialTensileTestOriginal';
out{m+6,2} = [];
out{m+7,1} = 'thicknessInitialTensileTestOriginal';
out{m+7,2} = [];
% time dependent values 
% These values are changed after reading Original data
m = size(out, 1);
out{m+1,1} = 'lengthTensileTestEdit';
out{m+1,2} = [];
out{m+2,1} = 'forceTensileTestEdit';
out{m+2,2} = [];
out{m+3,1} = 'widthTensileTestEdit';
out{m+3,2} = [];
out{m+4,1} = 'timeTensileTestEdit';
out{m+4,2} = [];
% initial values
% These values may be changed during runtime, e.g to cut away unwanted data
out{m+5,1} = 'widthInitialTensileTestEdit';
out{m+5,2} = [];
out{m+6,1} = 'lengthInitialTensileTestEdit';
out{m+6,2} = [];
out{m+7,1} = 'thicknessInitialTensileTestEdit';
out{m+7,2} = [];
% time dependent values 
% These values are changed to create average from multiple specimen
m = size(out, 1);
out{m+1,1} = 'lengthTensileTest';
out{m+1,2} = [];
out{m+2,1} = 'forceTensileTest';
out{m+2,2} = [];
out{m+3,1} = 'widthTensileTest';
out{m+3,2} = [];
out{m+4,1} = 'timeTensileTest';
out{m+4,2} = [];
% initial values
% These values are changed to create average from multiple specimen
out{m+5,1} = 'widthInitialTensileTest';
out{m+5,2} = [];
out{m+6,1} = 'lengthInitialTensileTest';
out{m+6,2} = [];
out{m+7,1} = 'thicknessInitialTensileTest';
out{m+7,2} = [];
% Bulge Measuring Data
% ====================
% time dependent values orignal
% These values stay unchanged during the whole runtime of MaterialModeler
m = size(out, 1);
out{m+1,1} = 'epsilonTruePlBulgeOriginal'; 
out{m+1,2} = [];           
out{m+2,1} = 'sigmaTruePlBulgeOriginal';         
out{m+2,2} = [];          
out{m+3,1} = 'timeBulgeOriginal';
out{m+3,2} = [];
% These values may be changed during runtime, e.g to cut away unwanted data
out{m+4,1} = 'epsilonTruePlBulgeEdit';      
out{m+4,2} = [];
out{m+5,1} = 'sigmaTruePlBulgeEdit'; 
out{m+5,2} = [];       
out{m+6,1} = 'timeBulgeEdit';
out{m+6,2} = [];
out{m+7,1} = 'epsilonTruePlBulge';      
out{m+7,2} = [];
out{m+8,1} = 'sigmaTruePlBulge'; 
out{m+8,2} = [];       
out{m+9,1} = 'timeBulge';
out{m+9,2} = [];
% Crush Test Measuring Data
% ====================
% time dependent values orignal
% These values stay unchanged during the whole runtime of MaterialModeler
m = size(out, 1);
out{m+1,1} = 'lengthCrushTestOriginal'; 
out{m+1,2} = [];           
out{m+2,1} = 'forceCrushTestOriginal';         
out{m+2,2} = [];          
out{m+3,1} = 'widthCrushTestOriginal';
out{m+3,2} = [];
out{m+4,1} = 'timeCrushTestOriginal';      
out{m+4,2} = [];
% Initial values crush test original
out{m+5,1} = 'diameterInitialCrushTestOriginal'; 
out{m+5,2} = [];       
out{m+6,1} = 'lengthInitialCrushTestOriginal';
out{m+6,2} = [];
% time dependent values Edit
% These values may be changed during runtime, e.g to cut away unwanted data
out{m+7,1} = 'lengthCrushTestEdit'; 
out{m+7,2} = [];           
out{m+8,1} = 'forceCrushTestEdit';         
out{m+8,2} = [];          
out{m+9,1} = 'widthCrushTestEdit';
out{m+9,2} = [];
out{m+10,1} = 'timeCrushTestEdit';      
out{m+10,2} = [];
% Initial values crush test Edit
out{m+11,1} = 'diameterInitialCrushTestEdit'; 
out{m+11,2} = [];       
out{m+12,1} = 'lengthInitialCrushTestEdit';
out{m+12,2} = [];
% time dependent values 
% These values may be changed during runtime, e.g for averaging
out{m+13,1} = 'lengthCrushTest'; 
out{m+13,2} = [];           
out{m+14,1} = 'forceCrushTest';         
out{m+14,2} = [];          
out{m+15,1} = 'widthCrushTest';
out{m+15,2} = [];
out{m+16,1} = 'timeCrushTest';      
out{m+16,2} = [];
% Initial values crush test Edit
out{m+17,1} = 'diameterInitialCrushTest'; 
out{m+17,2} = [];       
out{m+18,1} = 'lengthInitialCrushTest';
out{m+18,2} = [];
% Stiffness of experimental setup
out{m+19,1} = 'lengthStiffness';
out{m+19,2} = [];
out{m+20,1} = 'forceStiffness';
out{m+20,2} = [];
% Averaging experimental data
% ===========================
m = size(out, 1);
out{m+1,1} = 'baseVectorMin'; % mimimum of base vector
out{m+1,2} = [];
out{m+2,1} = 'baseVectorStepSize'; % step size of base vector
out{m+2,2} = [];
out{m+3,1} = 'baseVectorMax'; % maximum of base vector
out{m+3,2} = [];
% Data after reading input
% =======================
m = size(out, 1);
out{m+1,1} = 'A0'; % Initial cross section area 
out{m+1,2} = [];
out{m+2,1} = 'A'; % Current cross section area, time dependent
out{m+2,2} = [];
out{m+3,1} = 'l'; % Current length, time dependent
out{m+3,2} = [];
out{m+4,1} = 'epsilonLEng'; % engineering strain in longitudinal direction
out{m+4,2} = [];
out{m+5,1} = 'sigmaLEng'; % engineering stree in longitudinal direction
out{m+5,2} = [];
out{m+6,1} = 'epsilonLTrue'; % true strain in longitudinal direction
out{m+6,2} = [];
out{m+7,1} = 'sigmaLTrue'; % true stress in longitudinal direction
out{m+7,2} = [];
out{m+8,1} = 'AOriginal'; % Current cross section area, time dependent
out{m+8,2} = [];
out{m+9,1} = 'lOriginal'; % Current length, time dependent
out{m+9,2} = [];
out{m+10,1} = 'epsilonLEngOriginal'; % engineering strain in longitudinal direction
out{m+10,2} = [];
out{m+11,1} = 'sigmaLEngOriginal'; % engineering stree in longitudinal direction
out{m+11,2} = [];
out{m+12,1} = 'epsilonLTrueOriginal'; % true strain in longitudinal direction
out{m+12,2} = [];
out{m+13,1} = 'sigmaLTrueOriginal'; % true stress in longitudinal direction
out{m+13,2} = [];
% Rm
% ==
m = size(out, 1);
out{m+1,1} = 'Rm'; % tensile strength (engineering stress)
out{m+1,2} = [];
out{m+2,1} = 'indexRm'; % tensile strength (engineering stress)
out{m+2,2} = [];
% EModulus
% ========
m = size(out, 1);
out{m+1,1} = 'EExp'; % E-Modulus determined from Experiments
out{m+1,2} = [];
out{m+2,1} = 'EFit';
out{m+2,2} = [];
out{m+3,1} = 'ELit'; % E-Modulus from Literature, user input
out{m+3,2} = [];
% yield curve
% ===========
% All values indicated by Rp02 may use a different value than 0.2%. The
% nomenclature is just like this.
m = size(out, 1);
out{m+1,1} = 'epsilonLEngRp'; % engineering strain for Rp0.2
out{m+1,2} = []; 
out{m+2,1} = 'epsilonXRp'; % engineering strain when directly going down from Rp
out{m+2,2} = [];           % might be calculated from Rp0.2, so it is not necessarly zero!
out{m+3,1} = 'Rp';         % engineering stress when directly going left from Rp 
out{m+3,2} = [];           % might be calculated from Rp0.2, so it is not necessarly yield begin!
out{m+4,1} = 'epsilonLEng0Theo'; % Theoretical point where engineering strain should be zero
out{m+4,2} = [];                 % but is not due problems with stiffness in experiments
out{m+5,1} = 'indexTheo';        % index right after epsilonLEng0Theo
out{m+5,2} = [];
out{m+6,1} = 'fTheo';   % Factor to position epsilonLEng0Theo between 
out{m+6,2} = [];        % epsilonLEng(indexTheo-1) and epsilonLEng(indexTheo)
out{m+7,1} = 'indexRp'; % index in epsilonLEng right after epsilonXRp
out{m+7,2} = [];
out{m+8,1} = 'fRp';     % Factor to position epsilonXRp between 
out{m+8,2} = [];        % epsilonLEng(indexRp-1) and epsilonLEng(indexRp)
out{m+9,1} = 'forceRp'; % External Force applied to the specime at Rp
out{m+9,2} = [];
out{m+10,1} = 'epsilonXTrueRp'; % true strain when directly going down from Rp
out{m+10,2} = [];
out{m+11,1} = 'ARp'; % current cross section at Rp
out{m+11,2} = [];
out{m+12,1} = 'sigmaLTrueRp'; % true stress at Rp
out{m+12,2} = [];
out{m+13,1} = 'epsilonLTrueEl'; % true elastic strain, time dependent
out{m+13,2} = [];
out{m+14,1} = 'epsilonLTruePl'; % true plastic strain, time dependent
out{m+14,2} = [];
out{m+15,1} = 'sigmaLTruePl'; % true plastic stress, time dependent
out{m+15,2} = [];             % just the shortend version of sigmaLTrue
out{m+16,1} = 'evalMaxYieldBegin'; % max value of the evaluation range to
out{m+16,2} = [];           % calculate yield begin if Rp0.2 is provided 
out{m+17,1} = 'epsilonYieldCurve'; % true plastic stress of yield curve, time dependent
out{m+17,2} = [];    
out{m+18,1} = 'sigmaYieldCurve'; % true plastic stress of yield curve, time dependent
out{m+18,2} = [];  
% yield curve extrapolation
% =========================
m = size(out, 1);
out{m+1,1} = 'fitLudwik';   % fit Ludwik's equation to sigmaYieldCurveBulge
out{m+1,2} = [];
out{m+2,1} = 'gofLudwik';        % goodness of fit of fitLudwikBulge
out{m+2,2} = [];
out{m+3,1} = 'fitGhosh'; % fit Ghosh's equation to sigmaYieldCurve
out{m+3,2} = [];
out{m+4,1} = 'gofGhosh'; % goodness of fit of fitGhoshBulge
out{m+4,2} = [];
out{m+5,1} = 'fitHockettSherby'; % fit Hockett-Sherby's equation to sigmaYieldCurveBulge
out{m+5,2} = [];
out{m+6,1} = 'gofHockettSherby'; % goodness of fit of fitHockettSherbyBulge
out{m+6,2} = [];
out{m+7,1} = 'fitSwift'; % fit Swift's equation to sigmaYieldCurveBulge
out{m+7,2} = [];
out{m+8,1} = 'gofSwift'; % goodness of fit of fitSwiftBulge
out{m+8,2} = [];
out{m+9,1} = 'fitVoce'; % fit Voce's equation to sigmaYieldCurveBulge
out{m+9,2} = [];
out{m+10,1} = 'gofVoce'; % goodness of fit of fitVoceBulge
out{m+10,2} = [];
out{m+11,1} = 'fitEpsilonYieldCurve'; % true plastic stress of yield curve, time dependent
out{m+11,2} = [];                     % fitted e.g. with HockettSherby's approach
out{m+12,1} = 'fitSigmaYieldCurve'; % true plastic stress of yield curve, time dependent
out{m+12,2} = [];                   % fitted e.g. with HockettSherby's approach
% r value
% =======
m = size(out, 1);
out{m+1,1} = 'b'; % current width
out{m+1,2} = [];          
out{m+2,1} = 'epsilonBTrue'; % true stress in transverse direction
out{m+2,2} = [];           
out{m+3,1} = 'epsilonBTrueEl'; % elastic true stress in transverse direction
out{m+3,2} = [];
out{m+4,1} = 'epsilonBTruePl'; % plastic true stress in transverse direction
out{m+4,2} = [];
out{m+5,1} = 'nue';   % Poisson's number
out{m+5,2} = [];
out{m+6,1} = 'r';     % r Value
out{m+6,2} = [];
out{m+7,1} = 'slope'; % slope of the regression to determine r value
out{m+7,2} = [];       
% n value
% =======
m = size(out, 1);
out{m+1,1} = 'nValue'; % n value
out{m+1,2} = [];          
out{m+2,1} = 'nValueC'; % Ludwik's equation: sigma=C*epsilon^n -> log(sigma)=log(C)+n*log(epsilon)
out{m+2,2} = [];        % nValueC = log(C) fromt equation above, see DIN EN ISO 10275
% Bulge Test evaluation
% =====================
m = size(out, 1);
out{m+1,1} = 'trueStrainRateBulge'; % true strain rate in bulge test
out{m+1,2} = [];          
out{m+2,1} = 'epsilonYieldCurveBulge'; % true strain of the bulgeextrapolated yield curve
out{m+2,2} = [];           
out{m+3,1} = 'sigmaYieldCurveBulge'; % true stress of the bulgeextrapolated yield curve
out{m+3,2} = [];                     % see DIN EN ISO 16808
out{m+4,1} = 'indexBulgeDataBegin'; % index in epsilonYieldCurvebulge of the
out{m+4,2} = [];                    % first data point of the bulge data 
out{m+5,1} = 'alpha'; % weighing factor to superpose two of the above approaches
out{m+5,2} = [];           % to fit sigmaYieldCurveBulge
out{m+6,1} = 'fitEpsilonYieldCurveBulge'; % true plastic stress of bulgeextrapolated yield curve, time dependent
out{m+6,2} = [];                          
out{m+7,1} = 'fitSigmaYieldCurveBulge'; % true plastic stress of bulgeextrapolated yield curve, time dependent
out{m+7,2} = [];                        % fitted with two approaches from above and alpha
% Yield Curve final
% =================
m = size(out, 1);
out{m+1,1} = 'epsilonYieldCurveExport'; % strain if yield curve for export
out{m+1,2} = [];          
out{m+2,1} = 'sigmaYieldCurveExport'; % stress if yield curve for export
out{m+2,2} = [];           
end