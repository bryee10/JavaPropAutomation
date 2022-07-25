function [BattCapacity,FuelMass,PitchAng] = Ascent(AltDiff,Time,DragCoefficient,AirMass,FuelMass,BattCapacity,AirSpeed,RP,TP,PP,MotorPowerPercent,MotorMaxPower,EngineMaxPower,EngRPM,BattMass)
  disp('Ascent')
  RC = AltDiff/Time
  Drag = DragCalc(DragCoefficient,AirMass,FuelMass,BattMass,AirSpeed)
  Thrust = ( RC*AirMass*9.81 / AirSpeed ) + Drag
  PowerNeeded = EngineMaxPower
  PitchAng = size(RP,2)
  for j = 1:size(RP,1)
    if abs(EngRPM - RP(j,1)) < 50
      temp = j
      break
    end
  end
  for i = 1:size(RP,2)
    if TP(temp,i) > Thrust && PP(temp,i) < EngineMaxPower && PP(temp,i) < PowerNeeded
      PowerNeeded = PP(temp,i)
      PitchAng = i
    end
  end

  % if motor assisted
  PowerNeeded = PowerNeeded - MotorPowerPercent * MotorMaxPower * 10^-2
  BattCapacity = BattCapacity - EnergyConsumption(0,MotorMaxPower,MotorPowerPercent,Time)
  FuelMass = BSFC_Calc(EngRPM,FuelMass,Time,PowerNeeded)
end

