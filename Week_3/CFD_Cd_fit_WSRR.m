function [param] = CFD_Cd_fit_WSRR(range, WSR_1, WSR_2, WSR_3, WSR_4, type)
% type==0: dir_1 weibull, dir_2 and dir_3 beta
% type==1: dir_1, dir_2 and dir_3 weibull

% define WSR_min, WSR_max
% -

% units: WSR
WSR_min = CFD_Cd_compute_WSR([1:0.5:3.5])';
WSR_max = CFD_Cd_compute_WSR([1.5:0.5:4])';

% initialize fit
% -

% rows (2): a, b (parameters
% columns (3): 1, 2, 3 (rank)
% units: parameters
param = zeros(2,3);

% filter WSR
% -

WSR_1_select = WSR_1(WSR_4>=WSR_min(range));
WSR_2_select = WSR_2(WSR_4>=WSR_min(range));
WSR_3_select = WSR_3(WSR_4>=WSR_min(range));
WSR_4_select = WSR_4(WSR_4>=WSR_min(range));

WSR_1_select = WSR_1_select(WSR_4_select<WSR_max(range));
WSR_2_select = WSR_2_select(WSR_4_select<WSR_max(range));
WSR_3_select = WSR_3_select(WSR_4_select<WSR_max(range));
WSR_4_select = WSR_4_select(WSR_4_select<WSR_max(range));

% compute WSRR
% -

% units: WSRR (WSR_x / WSR_4)
[WSRR_1_select] = CFD_Cd_compute_WSRR(WSR_1_select, WSR_4_select);
[WSRR_2_select] = CFD_Cd_compute_WSRR(WSR_2_select, WSR_4_select);
[WSRR_3_select] = CFD_Cd_compute_WSRR(WSR_3_select, WSR_4_select);

% fit WSRR
% -

if (type==0)
    % units: parameters
    param(:,1) = [wblfit(WSRR_1_select)]';
    param(:,2) = [betafit(WSRR_2_select)]';
    param(:,3) = [betafit(WSRR_3_select)]';
elseif (type==1)
    % units: parameters
    param(:,1) = [wblfit(WSRR_1_select)]';
    param(:,2) = [wblfit(WSRR_2_select)]';
    param(:,3) = [wblfit(WSRR_3_select)]';
end
