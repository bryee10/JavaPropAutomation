%{
Brian Yee
LiquidPiston Inc
7/15/2022
rev 8/1/2022

This is a test to call the DesignPropCustom function (not default DesignProp function). It will prompt the user to input all required parameters to design the propeller and will output plots showing performances at different pitch angles.

%}

clear;clc;close all;

%% Input parameters

% For blade profiles, check lines 58-73 for which value corresponds to which airfoil profile shape
% Additional information on the other parameters can be seen in lines 77-89 or in DesignPropCustom() function.

NumBlades = 3;                      % Number of blades
BladeProfile = [4 4 4 4];           % Profile of blade at 0r, 0.333r, 0.666r, and 1r, where r is radius of propeller (must be 4 value array)
BladeSections = 40;                 % Number of blade sections - more sections = more accurate but takes longer to run
BladeAngAttack = [8 8 7 7];         % Blade's angle of attack at equal intervals (array can be any length)
PropDiameter = 0.8;                 % Diameter of propeller in meters [m]
SpinDiameter = 0.1;                 % Diameter of spinner in meters [m]
Shroud = 0;                         % 0 for no shroud, 1 for shroud
SqTip = 0;                          % 0 for no square tips, 1 for square tips
AirSpeed = 35;                      % User defined optimal airspeed in meters per second [m/s]
RPM = 5250;                         % User defined optimal RPM [1/min]
Power = 15000;                      % User defined power generated at optimal RPM in watts [W]
Thrust = 0;                         % User defined thrust generated at optimal RPM in Newtons [N] (will not be used if Power ~= 0)
Torque = 0;                         % User defined torque generated at optimal RPM in Newton-meters [N*m] (will not be used if Power ~= 0 or Thrust ~= 0)
PitchAngle = [-2 7];                % Range of pitch angles from least to greatest [degrees]

%% User Inputs
% This section asks the user to input their own parameters, overwriting the parameters declared in the previous section.

YN = input("Would you like to enter the design parameters now? [Y/N] ",'s');

while YN ~= 'Y' || YN ~= 'N'
  if YN == 'N' || YN == 'Y'
    break
  else
  YN = input("Would you like to enter the design parameters now? [Y/N] ",'s');
  end
end

YN_2 = input("Would you like to hide propeller details during simulations? [Y/N] ",'s');

while YN_2 ~= 'Y' || YN_2 ~= 'N'
  if YN_2 == 'N' || YN_2 == 'Y'
    break
  else
  YN_2 = input("Would you like to hide propeller details during simulations? [Y/N] ",'s');
  end
end

if YN == 'Y'
  NumBlades = input("How many blades are in the propeller? ");

  fprintf('\n')
  fprintf('Blade Profile Selection \n')
  fprintf('1 - Flat plate, Re = 100,000 \n')
  fprintf('2 - Flat plate, Re = 500,000 \n')
  fprintf('3 - Clark Y, Re = 25,000 \n')
  fprintf('4 - Clark Y, Re = 100,000 \n')
  fprintf('5 - Clark Y, Re = 500,000 \n')
  fprintf('6 - E 193, Re = 100,000 \n')
  fprintf('7 - E 193, Re = 300,000 \n')
  fprintf('8 - ARA D 6%%, Re = 50,000 \n')
  fprintf('9 - ARA D 6%%, Re = 100,000 \n')
  fprintf('10 - MH 126, Re = 500,000 \n')
  fprintf('11 - MH 112 16.2%%, Re = 500,000 \n')
  fprintf('12 - MH 114 13%%, Re = 500,000 \n')
  fprintf('13 - MH 116 9.8%%, Re = 500,000 \n')
  fprintf('14 - MH 120 11.7%%, Re = 400,000, M = 0.75 \n')
  fprintf('15 - Read from file af_1.afl (or, if not found from af_1.xml) in JP directory \n')
  fprintf('16 - Read from file af_2.afl (or, if not found from af_2.xml) in JP directory \n \n')

  BladeProfile = input("What blade profiles are on the blades? Enter as a 4 number array referring to the numbers above [a b c d]. ");
  BladeSections = input("How many blade sections are going to be generated (20-50)? ");
  BladeAngAttack = input("What are the angles of attack [deg] of the blade at equidistant intervals? Enter as an array []. ");
  PropDiameter = input("What is the diameter [m] of the propeller? ");
  SpinDiameter = input("What is the diameter [m] of the spinner? ");
  Shroud = input("Is there a shroud? 0 for no, 1 for yes. ");
  SqTip = input("Are the tips square? 0 for no, 1 for yes. ");
  AirSpeed = input("What is the airspeed [m/s] of the aircraft? ");
  RPM = input("What is the optimal RPM of the propeller/engine? ");
  Power = input("What is the peak power [W] of the engine? ");
  Thrust = input("What is the peak thrust [N] of the engine? ");
  Torque = input("What is the peak torque [N*m] of the engine? ");
  PitchAngle = input("What is the range of pitches for this propeller? Enter as a two number array [a b]. ");
end

% This consolidates all previous declared parameters into a single array to use as parameters in the DesignPropCustom() function.

DesignParameters = [NumBlades, BladeSections, PropDiameter, SpinDiameter, Shroud, SqTip, AirSpeed, RPM, Power, Thrust, Torque];

% Create three figures for three plots
figure(1);
figure(2);
figure(3);
% set(gca,'Color','w')                                                    % For plot formatting

%% For loop to iterate through Pitch Angle range in 1 degree increments

for i = PitchAngle(1):1:PitchAngle(length(PitchAngle))

  DesignPropCustom(BladeProfile,BladeAngAttack,DesignParameters,YN_2,i);  % Call the DesignPropCustom function with the specific pitch angle

  v_AS = []; T_AS = []; R_AS = []; eta_AS = []; P_AS = [];                % Declare temp arrays to store airspeed, thrust, RPM, efficiency, power at indexed value

  for j = linspace(RPM/1.5,RPM*1.1,40)                                    % For loop for gathering data points in RPM range
    a = MultiAnalysis(PropDesignCustom,j);                                % Run MultiAnalysis function at that specific RPM
    v = []; T = []; R = []; eta = []; P =[];                              % Declare temp variables to hold airspeed, thrust, RPM, efficiency, power values at specified RPM
    v = [v a.V];                                                          % Assign results of MultiAnalysis to temp variables
    R = [R a.RPM];
    T = [T a.Thrust];
    eta = [eta a.Eta];
    P = [P a.Power];
    for k = 1:length(v)                                                   % For loop to find the index value that calls the airspeed closest to the user defined airspeed and records the airspeed, thrust, RPM, efficiency, power values at that index
      if abs(AirSpeed - v(k)) < 0.8
        v_AS = [v_AS v(k)];
        R_AS = [R_AS R(k)];
        T_AS = [T_AS T(k)];
        eta_AS = [eta_AS eta(k)];
        P_AS = [P_AS P(k)];
        break
      end
    end
  end


  figure(1,'Name','Thrust [N] vs RPM')                                    % Updates figures 1,2,3 for every pitch angle iteration
  temp = linspace(min(R_AS),max(R_AS),150);                               % Creates x axis data with RPM
  temp2 = interp1(R_AS,T_AS,temp);                                        % Creates y axis data
  plot(temp,temp2,'markersize',8);
  hold on
  pitchString = num2str(i);                                               % Creates string based on current pitch angle to label lines in plot
  pitchString = [pitchString ' deg Pitch Angle'];
  text(R_AS(length(R_AS))+25,T_AS(length(T_AS)),pitchString,'fontsize',15);

  figure(2,'Name','Efficiency [%] vs RPM')
  temp2 = interp1(R_AS,eta_AS,temp);
  plot(temp,temp2,'markersize',8);
  hold on
  text(R_AS(length(R_AS))+25,eta_AS(length(eta_AS)),pitchString,'fontsize',15);

  figure(3,'Name','Power [W] vs RPM')
  temp2 = interp1(R_AS,P_AS,temp);
  plot(temp,temp2,'markersize',8);
  hold on
  text(R_AS(length(R_AS))+25,P_AS(length(P_AS)),pitchString,'fontsize',15);

  % Prints to command window the percentage of progress
  fprintf('\n%2.2f%% done \n',100*(i-PitchAngle(1))/(PitchAngle(length(PitchAngle))-PitchAngle(1)));
end

%% Labelling plots

% Labelling figure 1 and drawing vertical dotted black line at user defined ideal RPM
figure(1);
xlabel('RPM [1/min]','fontsize',25);
ylabel('Thrust [N]','fontsize',25);
% For MATLAB only because Octave sucks
% xline(RPM,'--k');
plot(linspace(RPM,RPM,5),linspace(0,500,5),'--k')
text(RPM+40,0.95*max(T_AS),'Most efficient RPM');
zlabel('Airspeed Velocity');

% Labelling figure 2 and drawing vertical dotted black line at user defined ideal RPM
figure(2);
xlabel('RPM [1/min]','fontsize',25);
ylabel('Efficiency [%]','fontsize',25);
% For MATLAB only because Octave sucks
% xline(RPM,'--k');
plot(linspace(RPM,RPM,5),linspace(0,100,5),'--k')
text(RPM+40,0.95*max(eta_AS),'Most efficient RPM');
zlabel('Airspeed Velocity');

% Labelling figure 3 and drawing vertical dotted black line at user defined ideal RPM
figure(3);
xlabel('RPM [1/min]','fontsize',25);
ylabel('Power [W]','fontsize',25);
% For MATLAB only because Octave sucks
% xline(RPM,'--k');
plot(linspace(RPM,RPM,5),linspace(0,35000,5),'--k')
text(RPM+40,0.95*max(P_AS),'Most efficient RPM');
zlabel('Airspeed Velocity');
