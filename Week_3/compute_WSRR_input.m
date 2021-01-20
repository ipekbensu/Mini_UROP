function [WSRR_input] = compute_WSRR_input()

% define Cd_min, Cd_max
% -

% units: NA (since drag coefficient)
Cd_min = 1;
Cd_max = 4;

% load CFD results
% -

load('CFD_Cd.mat')

% columns (4): 1, 2, 3, 4 (reading)
% units: NA (since drag coefficient)
CFD_Cd = table2array(CFD_Cd);

% initialize WSRR_input
% -

% rows (4): 25, 50, 75, 100 (%ile mean)
% columns (4): 1, 2, 3, 4 (rank)
% pages (6): 1-1.5, 1.5-2,... 3.5-4 (Cd range)
% units: WSRR (WSR_x / WSR_4)
WSRR_input = zeros(4,4,6);

for i=1:size(CFD_Cd,1)
    
    % rank Cd
    % -
    
    CFD_Cd(i,:) = sort(CFD_Cd(i,:));
    
end
clear i

% compute WSR
% -

% units: WSR
WSR_1 = CFD_Cd_compute_WSR(CFD_Cd(:,1));
WSR_2 = CFD_Cd_compute_WSR(CFD_Cd(:,2));
WSR_3 = CFD_Cd_compute_WSR(CFD_Cd(:,3));
WSR_4 = CFD_Cd_compute_WSR(CFD_Cd(:,4));

% filter WSR
% -

WSR_1 = WSR_1(~isnan(WSR_1)); % filters out 2
WSR_2 = WSR_2(~isnan(WSR_2)); % filters out 2
WSR_3 = WSR_3(~isnan(WSR_3)); % filters out 2
WSR_4 = WSR_4(~isnan(WSR_4)); % filters out 2

WSR_1 = WSR_1(WSR_4~=0); % filters out 25
WSR_2 = WSR_2(WSR_4~=0); % filters out 25
WSR_3 = WSR_3(WSR_4~=0); % filters out 25
WSR_4 = WSR_4(WSR_4~=0); % filters out 25

WSR_1 = WSR_1(WSR_4>=CFD_Cd_compute_WSR(Cd_min));
WSR_2 = WSR_2(WSR_4>=CFD_Cd_compute_WSR(Cd_min));
WSR_3 = WSR_3(WSR_4>=CFD_Cd_compute_WSR(Cd_min));
WSR_4 = WSR_4(WSR_4>=CFD_Cd_compute_WSR(Cd_min));

WSR_1 = WSR_1(WSR_4<=CFD_Cd_compute_WSR(Cd_max));
WSR_2 = WSR_2(WSR_4<=CFD_Cd_compute_WSR(Cd_max));
WSR_3 = WSR_3(WSR_4<=CFD_Cd_compute_WSR(Cd_max));
WSR_4 = WSR_4(WSR_4<=CFD_Cd_compute_WSR(Cd_max));

% fit WSRR
% -

% rows (2): alpha, beta (parameters)
% columns (3): 1, 2, 3 (rank)
% pages (6): 1-1.5, 1.5-2,... 3.5-4 (Cd range)
% units: parameters
param = zeros(2,3,6);

for k=1:6
    
    range = k;
    if (range==1)
        [param(:,:,k)] = CFD_Cd_fit_WSRR(range, WSR_1, WSR_2, WSR_3, WSR_4,1);
    else
        [param(:,:,k)] = CFD_Cd_fit_WSRR(range, WSR_1, WSR_2, WSR_3, WSR_4,0);
    end
end
clear k

% compute WSRR_input
% -

for k=1:6
    
    if (k==1)
        [WSRR_input(:,:,k)] = CFD_Cd_compute_means(param(:,:,k),1);
    else
        [WSRR_input(:,:,k)] = CFD_Cd_compute_means(param(:,:,k),0);
    end
    
end
clear k

end
