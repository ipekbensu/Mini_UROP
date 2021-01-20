function [WSRR] = CFD_Cd_compute_WSRR(CFD_Cd_x, CFD_Cd_4)

% compute WSRR
% -

% units: WSRR (WSR_x / WSR_4)
WSRR = CFD_Cd_x./CFD_Cd_4;

end
