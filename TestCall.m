%{
Brian Yee
LiquidPiston Inc
7/15/2022

This is a test to call the DesignProp function. It will prompt the user to input all required parameters to design the propeller.
%}

clear;clc;close all;

% Input parameters
NumBlades = 3;
BladeProfile = [4 4 4 4];
BladeSections = 30;
BladeAngAttack = [8 8 7 7];
PropDiameter = 0.8;
SpinDiameter = 0.1;
Shroud = 0;
SqTip = 0;
AirSpeed = 45;
RPM = 5250;
Power = 18000;
Thrust = 0;
Torque = 0;
PitchAngle = [0 9];

YN = input("Would you like to enter the design parameters now? [Y/N] ",'s');

while YN ~= 'Y' || YN ~= 'N'
  if YN == 'N' || YN == 'Y'
    break
  else
  YN = input("Would you like to enter the design parameters now? [Y/N] ",'s');
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

DesignParameters = [NumBlades, BladeSections, PropDiameter, SpinDiameter, Shroud, SqTip, AirSpeed, RPM, Power, Thrust, Torque];

##DesignPropCustom(BladeProfile,BladeAngAttack,DesignParameters)

figure
set(gca,'Color','w')
for i = PitchAngle(1):1:PitchAngle(length(PitchAngle))
  BladeAngAttackPitch = BladeAngAttack + i;
  DesignPropCustom(BladeProfile,BladeAngAttackPitch,DesignParameters);
  v_AS = []; T_AS = []; R_AS = [];
  for j = linspace(RPM/1.5,RPM*1.2,50)
    a = MultiAnalysis(PropDesignCustom,j);
    v = []; T = []; R = [];
    v = [v a.V];
    R = [R a.RPM];
    T = [T a.Thrust];
##  v_AS = ones(1,length(v));
##  R_AS = ones(1,length(R));
##  T_AS = ones(1,length(T));
    for k = 1:length(v)
      if abs(AirSpeed - v(k)) < 0.8
        v_AS = [v_AS v(k)];
        R_AS = [R_AS R(k)];
        T_AS = [T_AS T(k)];
        break
      end
  end
  end
  plot(R_AS,T_AS,'markersize',8);
  hold on
  RPMstring = num2str(i);
  RPMstring = [RPMstring ' deg Pitch Angle']
  text(R_AS(length(R_AS))+25,T_AS(length(T_AS)),RPMstring,'fontsize',15)
end

xlabel('RPM','fontsize',25);
ylabel('Thrust [N]','fontsize',25);
% For MATLAB only because Octave sucks
##xline(RPM,'--k');
plot(linspace(RPM,RPM,50),linspace(0,500,50),'--k')
text(RPM+40,400,'Most efficient RPM');
zlabel('Airspeed Velocity');
