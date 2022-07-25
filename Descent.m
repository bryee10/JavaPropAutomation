function [BattCapacity,FuelMass,PitchAng] = Descent(MaxGenRate,Time,EngRPM,FuelMass,BattCapacity)
  disp('Descent')
  DescentEnginePower = 6000;
  PowerNeeded = 5000;
  PowerGen = DescentEnginePower - PowerNeeded
  if PowerGen > MaxGenRate
    PowerGen = MaxGenRate
  end
  BattCapacity = BattCapacity + EnergyGeneration(PowerGen,Time)
  FuelMass = BSFC_Calc(EngRPM,FuelMass,Time,DescentEnginePower)
  PitchAng = 0;
end

