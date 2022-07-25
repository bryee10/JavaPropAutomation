function [FuelMass,BattCapacity,PitchAng] = Cruise(RP,TP,PP,DragCoefficient,AirMass,FuelMass,BattCapacity,AirSpeed,EngineMaxPower,EngRPM,Time,BattMass,MaxGenRate)
  disp('Cruise')
  DragCoefficient
  AirMass
  BattMass
  AirSpeed
  FuelMass
  PowerNeeded = EngineMaxPower
  PitchAng = round(size(RP,2)/2);
  Thrust = DragCalc(DragCoefficient,AirMass,FuelMass,BattMass,AirSpeed)
  for j = 1:size(RP,1)
    if abs(EngRPM - RP(j,1)) < 50
      temp = j
      break
    end
  end
  for i = 1:size(RP,2)
    if TP(temp,i) > Thrust && PP(temp,i) < EngineMaxPower && PP(temp,i) < PowerNeeded
      PowerNeeded = PP(temp,i)
      PitchAng = i;
    end
  end
  EngineCruisePower = EngineMaxPower;
  PowerGen = EngineCruisePower - PowerNeeded
  if PowerGen > MaxGenRate
    PowerGen = MaxGenRate
  end
  FuelMass = BSFC_Calc(EngRPM,FuelMass,Time,EngineCruisePower)
  BattCapacity = BattCapacity + EnergyGeneration(PowerGen,Time)
end

