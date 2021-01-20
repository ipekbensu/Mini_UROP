function [WSR] = CFD_Cd_compute_WSR(CFD_Cd)

% define Cd_design, Cd_min, Cd_max
% -

% units: NA (since drag coefficient)
Cd_design = 2;
Cd_min = 1;
Cd_max = 4;

% filter CFD_Cd
% -

CFD_Cd(CFD_Cd<Cd_min) = Cd_min;
CFD_Cd(CFD_Cd>Cd_max) = Cd_max;

% compute WSR
% -

% units: WSR
WSR = sqrt(CFD_Cd/Cd_design);

end
