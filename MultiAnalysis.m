% A Matlab function to encapsulate the JavaProp propeller analysis code
% JavaProp is Copyright 2001-2008 Martin Hepperle
% http://www.mh-aerotools.de/airfoils/javaprop.htm
%
% History:
% --- 16/10/2007 ---
% The core function was written for Matlab by Ed Waugh, University of Southampton
% For Matlab version 7.4.0 (R2007a)
% --- 26/09/2009 ---
% This code was generalized so that it can also be run in Octave by Martin Hepperle.
%
% No support is offered with this code

% This function replicates the Multi-Analysis page of the JP GUI

function [PropAnalysis] = MultiAnalysis(PropDesign,RPM)

    start = 0;
    increment = 0.01;
    finish = 1;

    Omega = 2 * pi * (RPM / 60);    % Angular velocity

    % Set the RPM
    % performAnalysis() will calculate V so that
    % the given v/(nD) value is met.
    PropDesign.Omega = Omega;

    % Preallocate matrix for speed
    PropAnalysis = zeros(((finish - start) ./ increment + 1),0);
    index = 0;

    for vnd = start:increment:finish

        PropDesign.performAnalysis(vnd);

        % Results are provided in the PropAnalysis matrix

        % index = int32(( (vnd - start) ./ increment ) + 1);

        index = index+1;
        PropAnalysis(index).vnd    = vnd;
        PropAnalysis(index).CP     = PropDesign.CP;
        PropAnalysis(index).CT     = PropDesign.CT;
        PropAnalysis(index).Eta    = PropDesign.Eta * 100;
        PropAnalysis(index).EtaPossible = PropDesign.EtaPossible * 100;
        PropAnalysis(index).StalledPercentage = PropDesign.StalledPercentage;
        PropAnalysis(index).V      = PropDesign.V;
        PropAnalysis(index).RPM    = RPM;
        PropAnalysis(index).Power  = PropDesign.Power;
        PropAnalysis(index).Thrust = PropDesign.Thrust;
        % A measure of the aerodynamic quality of the design
        if abs(PropDesign.EtaPossible) > 1.0E-12
           PropAnalysis(index).EtaRelative = PropDesign.Eta / PropDesign.EtaPossible;
        else
           PropAnalysis(index).EtaRelative = 0.0;
        end


    end

    assignin('base','MultiAnalysisData',PropAnalysis);
end
