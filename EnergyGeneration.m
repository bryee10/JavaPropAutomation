function [EnergyGen] = EnergyGeneration(minPowerGen,Time)
  % What is the efficiency of the generator, etc?
  Eff = 0.9;
  EnergyGen = minPowerGen * Time * Eff * 10^-3
end

