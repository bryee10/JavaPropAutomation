%{
This function calculates and returns the total energy used by the VTOL motors and engine motors for a given time.
Its parameters are the throttle % of the VTOL motors and the thrust motor and the elapsed time of throttle.
%}

function [EnergyUsed] = EnergyConsumption(VTOL,MotorPower,MotorPowerPercent,Time)

  % VTOL motor data
  EnergyUsed = 0;
  VTOLPercent = [40:5:80 90 100];
  VTOLPower = [1161 1374 1589 1854 2125 2512 2955 3450 4156 5392 6727];
  for i = 1:length(VTOLPercent)
    if VTOLPercent(i) == round(VTOL/5)*5
      EnergyUsed = 4 * VTOLPower(i) * Time;
    end
  end

  % Shaft Motor data (need to fill in later)
  EnergyUsed = EnergyUsed + MotorPowerPercent*Time*MotorPower*10^-2;

  % Auxillary electronics data
  Cube = 14; %W
  CarrierBoard =0; %W
  Lidar = 0; %W
  PilotServos = 0; %W

  TotalAuxPower = Cube + CarrierBoard + Lidar + PilotServos;
  EnergyUsed = (EnergyUsed + TotalAuxPower*Time) * 10^-3
end

