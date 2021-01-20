function [WSRR_input] = CFD_Cd_compute_means(param, type)
% type==0: dir_1 weibull, dir_2 and dir_3 beta
% type==1: dir_1, dir_2 and dir_3 weibull

% define quart
% -

% rows (3): 25, 50, 75, 100 (%ile)
% units: %ile
quart = [...
    [0.01:0.01:0.25];...
    [0.26:0.01:0.50];...
    [0.51:0.01:0.75];...
    [0.76:0.01:1]...
    ];

% initialize WSRR_input
% -

% rows (4): 25, 50, 75, 100 (%ile mean)
% columns (4): 1, 2, 3, 4 (rank)
% units: WSRR (WSR_x / WSR_4)
WSRR_input = zeros(4,4);
WSRR_input(:,4) = ones(4,1);

% compute WSRR_input
% -

% rows (3): 25, 50, 75, 100 (%ile)
% pages (3): 1, 2, 3 (rank)
% units: WSRR (WSR_x / WSR_4)
WSRR_quart = zeros(4,25,3);

if (type==0)
    WSRR_quart(:,:,1) = wblinv(quart,param(1,1),param(2,1));
    WSRR_quart(:,:,2) = betainv(quart,param(1,2),param(2,2));
    WSRR_quart(:,:,3) = betainv(quart,param(1,3),param(2,3));
elseif (type==1)
    WSRR_quart(:,:,1) = wblinv(quart,param(1,1),param(2,1));
    WSRR_quart(:,:,2) = wblinv(quart,param(1,2),param(2,2));
    WSRR_quart(:,:,3) = wblinv(quart,param(1,3),param(2,3));
end

for i=1:4
    
    for j=1:3
        
        WSRR_temp = WSRR_quart(i,:,j);
        WSRR_input(i,j) = mean(WSRR_temp(isfinite(WSRR_temp)));
        
    end
    clear j
    
end
clear i

end
