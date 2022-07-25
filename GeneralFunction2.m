% bruh

clear all;clc;close all;

pkg load io
%% Parameters

%{
FlightPlan
[Starting Altitude, Final Altitude, Duration, AirSpeed]
%}

fileName = 'N:\Brian\JavaProp\FlightPlan.xlsx';
FlightPlan = xlsread(fileName);

% FlightPlan = [0 30 30 0 0 0; 30 200 60 20 100 1; 200 3000 10*60 35 50 0; 3000 3000 40*60 35 0 0; 3000 3000 30*60 35 100 2; 3000 2000 3*60 35 0 0; 3000 4000 4*60 35 75 0; 4000 200 10*60 35 0 0; 200 30 60 20 100 1; 30 0 30 0 0 0];

% Aircraft Mass [kg]

AirMass = 70;

% Battery Count

BattCount = 20;

% Fuel Mass [kg]

FuelMass = 20;

% Battery Mass

BattMass = BattCount * 0.8675;

% Aircraft RPM (engine RPM is assumed constant)

EngRPM = 5250;

% Max Engine Power

EngineMaxPower = 18000;

% Calculates Battery Energy [kJ]

BattCapacity = BattCount * 182.4 * 3.6
MaxBattCapacity = BattCapacity;

% Propeller Pitch Angles

PitchAngle = [-4 4];
PitchAngleDeg = PitchAngle(1):1:PitchAngle(2);

% Drag Coefficent of Aircraft

DragCoefficient = 0.1;

% Motor Max Power

MotorMaxPower = 6000;

% Max Generator GenRate

MaxGenRate = 1000;

TotalDistance = 0;
TotalTime = 0;
FuelPlot = [FuelMass];
TimePlot = [0];
VelocityPlot = [0];
DistancePlot = [0];
BattPlot = [BattCapacity];
PitchTimePlot = [0];
PitchPlot = [0];
DistanceY = [0];

[RP,TP,PP] = PropGen(PitchAngle);

for i = 1:size(FlightPlan,1)

  AltDiff = FlightPlan(i,2) - FlightPlan(i,1)

  if FlightPlan(i,1) == 0 || FlightPlan(i,2) == 0

    % VTOL
    BattCapacity = BattCapacity - EnergyConsumption(100,MotorMaxPower,FlightPlan(i,5),FlightPlan(i,3));
    TotalTime = TotalTime + FlightPlan(i,3)
    DistancePlot = [DistancePlot TotalDistance]
    PitchTimePlot = [PitchTimePlot PitchTimePlot(length(PitchTimePlot)) TotalTime]
    PitchPlot = [PitchPlot 0 0]
    TimePlot = [TimePlot TotalTime]
    FuelPlot = [FuelPlot FuelMass]
    BattPlot = [BattPlot BattCapacity]

  elseif FlightPlan(i,6) == 1

    % VTOL Assisted Climb/Descent
    BattCapacity = BattCapacity - EnergyConsumption(50,MotorMaxPower,FlightPlan(i,5),FlightPlan(i,3));
    TotalTime = TotalTime + FlightPlan(i,3)
    TotalDistance = TotalDistance + Range(FlightPlan(i,4),FlightPlan(i,3))
    DistancePlot = [DistancePlot TotalDistance]
    VelocityPlot = [VelocityPlot FlightPlan(i,4)]
    % Pitch Angle not working yet here
    if AltDiff > 0
      % Ascent
      PitchTimePlot = [PitchTimePlot PitchTimePlot(length(PitchTimePlot)) TotalTime]
      PitchPlot = [PitchPlot PitchAngle(2) PitchAngle(2)]
    else
      % Descent
      PitchTimePlot = [PitchTimePlot PitchTimePlot(length(PitchTimePlot)) TotalTime]
      PitchPlot = [PitchPlot PitchAngle(1) PitchAngle(1)]
    end
    TimePlot = [TimePlot TotalTime]
    DistanceY = [DistanceY FlightPlan(i,2)]
    FuelPlot = [FuelPlot FuelMass]
    BattPlot = [BattPlot BattCapacity]

  elseif FlightPlan(i,6) == 2

    % Electric Cruise
    BattCapacity = BattCapacity - EnergyConsumption(0,MotorMaxPower,FlightPlan(i,5),FlightPlan(i,3));
    TotalTime = TotalTime + FlightPlan(i,3)
    TotalDistance = TotalDistance + Range(FlightPlan(i,4),FlightPlan(i,3))
    DistancePlot = [DistancePlot TotalDistance]
    VelocityPlot = [VelocityPlot FlightPlan(i,4)]
    % Pitch not working here yet
    TimePlot = [TimePlot TotalTime]
    FuelPlot = [FuelPlot FuelMass]
    BattPlot = [BattPlot BattCapacity]
    PitchTimePlot = [PitchTimePlot PitchTimePlot(length(PitchTimePlot)) TotalTime]
    PitchPlot = [PitchPlot PitchAngle(2) PitchAngle(2)]

  else

    if AltDiff > 0

      % Ascent
      [BattCapacity,FuelMass,PitchAng] = Ascent(AltDiff,FlightPlan(i,3),DragCoefficient,AirMass,FuelMass,BattCapacity,FlightPlan(i,4),RP,TP,PP,FlightPlan(i,5),MotorMaxPower,EngineMaxPower,EngRPM,BattMass)
      if BattCapacity > MaxBattCapacity
        BattCapacity = MaxBattCapacity
      end
      TotalDistance = TotalDistance + Range(FlightPlan(i,4),FlightPlan(i,3))
      TotalTime = TotalTime + FlightPlan(i,3)
      DistancePlot = [DistancePlot TotalDistance]
      VelocityPlot = [VelocityPlot FlightPlan(i,4)]
      PitchTimePlot = [PitchTimePlot PitchTimePlot(length(PitchTimePlot)) TotalTime]
      PitchPlot = [PitchPlot PitchAngleDeg(PitchAng) PitchAngleDeg(PitchAng)]
      TimePlot = [TimePlot TotalTime]
      DistanceY = [DistanceY FlightPlan(i,2)]
      FuelPlot = [FuelPlot FuelMass]
      BattPlot = [BattPlot BattCapacity]

    elseif AltDiff < 0

      % Descent
      [BattCapacity,FuelMass,PitchAng] = Descent(MaxGenRate,FlightPlan(i,3),EngRPM,FuelMass,BattCapacity)
      if BattCapacity > MaxBattCapacity
        BattCapacity = MaxBattCapacity
      end
      TotalDistance = TotalDistance + Range(FlightPlan(i,4),FlightPlan(i,3))
      TotalTime = TotalTime + FlightPlan(i,3)
      DistancePlot = [DistancePlot TotalDistance]
      VelocityPlot = [VelocityPlot FlightPlan(i,4)]
      PitchTimePlot = [PitchTimePlot PitchTimePlot(length(PitchTimePlot)) TotalTime]
      PitchPlot = [PitchPlot PitchAng PitchAng]
      TimePlot = [TimePlot TotalTime]
      DistanceY = [DistanceY FlightPlan(i,2)]
      FuelPlot = [FuelPlot FuelMass]
      BattPlot = [BattPlot BattCapacity]

    else

      % Cruise
      [FuelMass,BattCapacity,PitchAng] = Cruise(RP,TP,PP,DragCoefficient,AirMass,FuelMass,BattCapacity,FlightPlan(i,4),EngineMaxPower,EngRPM,FlightPlan(i,3),BattMass,MaxGenRate)
      if BattCapacity > MaxBattCapacity
        BattCapacity = MaxBattCapacity
      end
      TotalDistance = TotalDistance + Range(FlightPlan(i,4),FlightPlan(i,3))
      TotalTime = TotalTime + FlightPlan(i,3)
      DistancePlot = [DistancePlot TotalDistance]
      VelocityPlot = [VelocityPlot FlightPlan(i,4)]
      PitchTimePlot = [PitchTimePlot PitchTimePlot(length(PitchTimePlot)) TotalTime]
      PitchPlot = [PitchPlot PitchAngleDeg(PitchAng) PitchAngleDeg(PitchAng)]
      TimePlot = [TimePlot TotalTime]
      DistanceY = [DistanceY FlightPlan(i,2)]
      FuelPlot = [FuelPlot FuelMass]
      BattPlot = [BattPlot BattCapacity]

    end
  end
end



figure(1)
%figure(1,'name','Fuel Mass [kg] vs. Time [min]')
subplot(2,2,1)
plot(TimePlot/60,FuelPlot)
title('Fuel Mass [kg] vs. Time [min]')
xlabel('Time [min]')
ylabel('Fuel Mass [kg]')

%figure(2,'name','Battery Energy [kJ] vs. Time [min]')
subplot(2,2,2)
plot(TimePlot/60,BattPlot)
title('Battery Energy [kJ] vs. Time [min]')
xlabel('Time [min]')
ylabel('Battery Energy [kJ]')

%figure(3,'name','Distance Traveled [km] vs. Time [min]')
subplot(2,2,3)
plot(TimePlot/60,DistancePlot/1000)
title('Distance Traveled [km] vs. Time [min]')
xlabel('Time [min]')
ylabel('Distance Traveled [km]')

%figure(4,'name','Propeller Pitch Angle [deg] vs. Time [min]')
subplot(2,2,4)
plot(PitchTimePlot/60,PitchPlot)
title('Propeller Pitch Angle [deg] vs. Time [min]')
xlabel('Time [min]')
ylabel('Pitch Angle [deg]')
ylim([PitchAngle(1)-1 PitchAngle(2)+1])

