%{
Brian Yee
LiquidPiston Inc
7/15/2022

This is a test to call the DesignProp function. It will prompt the user to input all required parameters to design the propeller.
%}

function [RP,TP,PP] = PropGen(PitchAngle)

% Input parameters
NumBlades = 3;
BladeProfile = [4 4 4 4];
BladeSections = 40;
BladeAngAttack = [8 8 7 7];
PropDiameter = 0.8;
SpinDiameter = 0.1;
Shroud = 0;
SqTip = 0;
AirSpeed = 35;
RPM = 5250;
Power = 15000;
Thrust = 0;
Torque = 0;

YN_2 = 'Y';

DesignParameters = [NumBlades, BladeSections, PropDiameter, SpinDiameter, Shroud, SqTip, AirSpeed, RPM, Power, Thrust, Torque];

##DesignPropCustom(BladeProfile,BladeAngAttack,DesignParameters)

RP = []; TP = []; PP = [];
for i = PitchAngle(1):1:PitchAngle(length(PitchAngle))
  PropDesignCustom = DesignPropCustom(BladeProfile,BladeAngAttack,DesignParameters,YN_2,i);
  v_AS = []; T_AS = []; R_AS = []; eta_AS = []; P_AS = [];
  for j = linspace(RPM/1.5,RPM*1.1,40)
    a = MultiAnalysis(PropDesignCustom,j);
    v = []; T = []; R = []; eta = []; P =[];
    v = [v a.V];
    R = [R a.RPM];
    T = [T a.Thrust];
    eta = [eta a.Eta];
    P = [P a.Power];
    for k = 1:length(v)
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
  RP = [RP R_AS'];
  TP = [TP T_AS'];
  PP = [PP P_AS'];
  fprintf('\n%2.2f%% done \n',100*(i-PitchAngle(1))/(PitchAngle(length(PitchAngle))-PitchAngle(1)));
end
