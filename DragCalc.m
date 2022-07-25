function [Drag] = DragCalc(DragCoefficient,AirMass,FuelMass,BattMass,AirSpeed)

  AirDensity = 1.225;
  WingSpan = 6;
  WingArea = 3.12;
  AR = WingSpan^2/WingArea;
  OswaldEff = 0.7;
  TotalMass = AirMass + FuelMass + BattMass;
  ControlSurfaceDrag = 0.1;
  Lift = TotalMass * 9.81;
  LiftCoefficient = 2*Lift/(AirDensity*AirSpeed^2*WingArea)
  InducedDragCoeff = LiftCoefficient^2/(pi*AR*OswaldEff);
  TotalDragCoefficient = (InducedDragCoeff + DragCoefficient) * (1+ControlSurfaceDrag)

  Drag = .5 * TotalDragCoefficient * AirDensity * AirSpeed^2 * WingArea;
end

