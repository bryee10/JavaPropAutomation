%-------------------------------------------------------------------------------
%
% A function to encapsulate the JavaProp propeller design code
%
%-------------------------------------------------------------------------------
% Can be used with MatLab as well as with GNU Octave.
%
% NOTE: For Octave the package java-1.2.8 is required.
%
% Martin Hepperle
% September 2011
%-------------------------------------------------------------------------------
%
% JavaProp is Copyright 2001-2011 Martin Hepperle
% http://www.mh-aerotools.de/airfoils/javaprop.htm
%
% History:
% --- 16/10/2007 ---
% The core function was written for Matlab by Ed Waugh, University of Southampton
% For Matlab version 7.4.0 (R2007a)
% --- 26/09/2009 ---
% This code was generalized so that it can also be run in Octave by Martin Hepperle.
%
% No support is offered with this code and it comes without any guarantee.
%
%-------------------------------------------------------------------------------
% Adapt the fields in this function and then execute to create a
% PropDesignCustom object that can then be used by the AnalyseProp function
%-------------------------------------------------------------------------------

%% DesignProp
function [PropDesignCustom] = DesignPropCustom(BladeProfiles,BladeAngAttack,DesignParameters,YN_2)

   % add the archive to the Java classpath (must be done only once per session, but can be called multiple times)
   basepath = ['..',filesep(),'..',filesep(),'java'];
   % adapt to your installation
   javaaddpath('C:\Program Files (x86)\Java\');
   basepath = ['B:\JavaProp'];
   javaaddpath([basepath, filesep(), 'JavaProp.jar']);
   javaaddpath([basepath, filesep(), 'MHClasses.jar']);


   % Number of blade sections, increasing this means a longer run time but greater accuracy
   % Sufficiently accurate results are obtained with 25 to 50 blade elements.
   blade_sections = DesignParameters(2);

   % Create a Propeller object to work on and name it
   PropDesignCustom = javaObject('MH.JavaProp.Propeller',blade_sections);

   PropDesignCustom.Name = 'JavaProp-Test';

   % Constants to use in calculations

   PropDesignCustom.Density = 1.2210;                       % kg/m^3
   PropDesignCustom.KinematicViscosity = 0.000014607;       % m^2/s
   PropDesignCustom.SpeedOfSound = 340.29;                  % m/s

   % Define the airfoil distribution by AIRFOIL_SECTIONS
   % Syntax:   addAirfoil( r/R, Section)
   %   r/R - Position ratio of the foil, R = Radius, r = position
   %       0.0 = root, 0.5 = centre, 1.0 = tip
   %   Section - A number into the following list of airfoil sections
   %        1 - Flat plate, Re = 100'000
   %        2 - Flat plate, Re = 500'000
   %        3 - Clark Y, Re = 25'000
   %        4 - Clark Y, Re = 100'000
   %        5 - Clark Y, Re = 500'000
   %        6 - E 193, Re = 100'000
   %        7 - E 193, Re = 300'000
   %        8 - ARA D 6%, Re = 50'000
   %        9 - ARA D 6%, Re = 100'000
   %       10 - MH 126, Re = 500'000
   %       11 - MH 112 16.2%, Re = 500'000
   %       12 - MH 114 13%, Re = 500'000
   %       13 - MH 116 9.8%, Re = 500'000
   %       14 - MH 120 11.7%, Re = 400'000, M = 0.75
   %       15 - Read from file af_1.afl (or, if not found from af_1.xml) in JP directory
   %       16 - Read from file af_2.afl (or, if not found from af_2.xml) in JP directory

   % Example is a simple Clark Y Propeller using two different airfoil polars

   % The propeller comes equipped with default airfoil sections of airfoil #1.
   % These default sections are at 0, 1/3, 2/3 and 1 of the radius.
   % If we would used exactly the same radial stations addAirfoil() would replace the existing airfoil.
   % however 0.3333 is not exactly 1/3, therefore to be sure we first remove the default airfoils.
   PropDesignCustom.removeAirfoils();

   theAirfoil = createAirfoil ( BladeProfiles(1) );
   PropDesignCustom.addAirfoil( 0.000, theAirfoil);

   theAirfoil = createAirfoil ( BladeProfiles(2) );
   PropDesignCustom.addAirfoil( 0.3333, theAirfoil);

   theAirfoil = createAirfoil ( BladeProfiles(3) );
   PropDesignCustom.addAirfoil( 2/3, theAirfoil);

   theAirfoil = createAirfoil ( BladeProfiles(4) );
   PropDesignCustom.addAirfoil( 1.000, theAirfoil);

   % Define the design angles of attack (degrees).
   % These stations are independent of the airfoil loft but
   % accidentally we use the same stations here.

  for i = 0:length(BladeAngAttack)-1
    PropDesignCustom.addAlfa(i/(length(BladeAngAttack)-1),BladeAngAttack(i+1));
    if YN_2 == 'N'
      disp(PropDesignCustom.getAirfoilName(i/(length(BladeAngAttack)-1)));
    end
  end

   % output the names of the airfoil sections

   %disp('Airfoil sections in use :');
##   disp(PropDesignCustom.getAirfoilName(0.000));
##   disp(PropDesignCustom.getAirfoilName(0.3333));
##   disp(PropDesignCustom.getAirfoilName(0.6667));
##   disp(PropDesignCustom.getAirfoilName(1.000));

   % Set prop dimensions (metres)
   Diameter = DesignParameters(3);
   Radius = Diameter / 2;

   PropDesignCustom.BladeCount = DesignParameters(1);     % Number of blades

   % Set the spinner size (m)
   SpinDiameter = DesignParameters(4);
   PropDesignCustom.rRSpinner = SpinDiameter / Diameter;

   % Set if the blade is operating in a shroud
   % If set to 1 Prandtl tip loss modelling is switched off
   if DesignParameters(5) == 0
    PropDesignCustom.removeShroud();
    end

   % Set if the blade has a square tip
   PropDesignCustom.hasSquareTips = DesignParameters(6);

   % Set the design conditions for the propeller
   % The geometry of the resulting prop will be optimised to give the maximum
   % efficiency at the point specified. Either Thrust or Power can be defined
   % but not both. One must be set to zero. To use a torque value, set both
   % power and thrust to zero.

   Airspeed = DesignParameters(7);                  % Metres / Second
   RPM = DesignParameters(8);                       % revolutions per minute

   Frequency = (RPM / 60);         % Frequency in Hz
   Omega = 2 * pi * Frequency;     % Angular velocity rad/s

   Power = DesignParameters(9);                      % Watts
   Thrust = DesignParameters(10);                     % Newtons
   Torque = DesignParameters(11);                 % Nm
   if Torque == 0
     Torque = Power/Omega;
   end
##   if Power == 0                   % If power and thrust are zero use torque
##      if Thrust == 0
##         Power = Torque * Omega;
##      end
##   end

   % Additional options ( here they do nothing)
   PropDesignCustom.incrementBladeAngle(0);         % Increases the local blade angle Beta but constant dBeta
   PropDesignCustom.multiplyBladeAngle(1);          % Multiplies local blade angle Beta by a constant
   PropDesignCustom.incrementChord(0);              % Increments local chord c/R by constant c/R
   PropDesignCustom.multiplyChord(1);               % Multiplies local chord c/R by constant c/R factor
   PropDesignCustom.taperChord(1);                  % Multiplies local chord c/R by a linear varying c/R factor

   % Finally: create the propeller
   PropDesignCustom.performPropellerDesign(Airspeed, Omega, Radius, Power, Thrust);

   % Perform an analysis to get some of the parameters we need

   PropDesignCustom.performAnalysis(Airspeed / (Frequency * Diameter));
   %PropDesignCustom.performAnalysis(Airspeed, Omega, Radius, 1.2210, 0.000014607, 340.29);

   % Display some details
if YN_2  == 'N'
   disp(sprintf('\r\r\r\r'));
   disp(PropDesignCustom.Name);
   disp(sprintf('\tBlades: %1.0f\r\tRPM: %4.0f\r\tVelocity: %3.1f m/s', PropDesignCustom.BladeCount,  RPM, PropDesignCustom.V));
   disp(sprintf('\tDiameter: %1.3f metres, %2.1f"\r\tSpinner Dia: %1.3f metres, %2.1f"', Diameter, Diameter * 39.3700787, SpinDiameter, SpinDiameter * 39.3700787));

   disp(sprintf('\r\tThrust: %3.2f Newtons\r\tPower: %4.2f Watts\r\tTorque: %2.3f Nm', Thrust, Power, Torque));

   disp(sprintf('\r\tV/nD: %1.3f',Airspeed / (RPM / 60.0 * Diameter)));
   disp(sprintf('\tAdvance: %1.3f metres, %2.1f', PropDesignCustom.getBladePitch, (PropDesignCustom.getBladePitch * 39.3700787)));
   disp(sprintf('\tPitch: %2.1f degrees', PropDesignCustom.getBladeAngle));
   disp(sprintf('\tPower coefficient  Cp: %1.4f\r\tThrust coefficient Ct: %1.4f', PropDesignCustom.CP, PropDesignCustom.CT));
   disp(sprintf('\tEfficiency: %2.2f%%',PropDesignCustom.Eta * 100));
   disp(sprintf('\tThrust: %3.2f Newtons', PropDesignCustom.Thrust));
   disp(sprintf('\tPower: %3.2f Watts', PropDesignCustom.Power));
   disp(sprintf('\r\r'));
end
   % Assign the PropDesignCustom object to the base workspace
   assignin('base','PropDesignCustom',PropDesignCustom);

end

%-------------------------------------------------------------------------------

function [theAirfoil] = createAirfoil ( AirfoilNo )
   %
   % Generate and initialize and airfoil.
   %
   % It is also possible to set a base directory which is later used,
   % when Init(n) is called with n >= 14  to read airfoil polars
   % from file af_1.afl (or, if not found from af_1.xml) in JP directory
   %
   % theAirfoil.setBaseDir("c:/...");
   % theAirfoil.Init ( 14 );
   %

   theAirfoil = javaObject('MH.AeroTools.Airfoils.Airfoil');
   theAirfoil.Init ( AirfoilNo );

end
