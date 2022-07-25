%{
This function calculates and returns the new total fuel mass after running at a certain RPM for a certain time.
Its parameters are the specified RPM, the fuel mass at the start of consumption, and the time at that RPM.
%}

function [NewFuelMass] = BSFC_Calc(RPM,FuelMass,Time,EnginePower)
  if EnginePower > 0
    RPM1 = [4000 5000 6000]; BSFC = [515.6 640.6 672.1];
    RPM2 = linspace(RPM1(1),RPM1(length(RPM1)),100);
    BSFC2 = interp1(RPM1,BSFC,RPM2);
    for i = 1:length(RPM2)
      if abs(RPM-RPM2(i)) < 100
        BSFC3 = BSFC2(i)
        break
      end
    end
    NewFuelMass = FuelMass - (10^-3 * 1/3600 * BSFC3 * EnginePower * Time * 10^-3)
  else
    NewFuelMass = FuelMass;
  end
end
