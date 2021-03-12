function [PUMS_count] = PUMS_estimate_count(BLD, HINCP)

% initiliaze PUMS_count
% rows (9): 1, 2,... 9 (BLD)
% columns (10): 1, 2,... 10 (HINCP bin)
% units: hsng

PUMS_count = zeros(9,10);

% estimate PUMS_count

for i=1:9
    
    hincp = HINCP(BLD==i);
    
    for j=1:10
        
        if (j==1)
            hincp_min = -inf;
            hincp_max = 10000;
        elseif (j==2)
            hincp_min = 10000;
            hincp_max = 15000;
        elseif (j==3)
            hincp_min = 15000;
            hincp_max = 25000;
        elseif (j==4)
            hincp_min = 25000;
            hincp_max = 35000;
        elseif (j==5)
            hincp_min = 35000;
            hincp_max = 50000;
        elseif (j==6)
            hincp_min = 50000;
            hincp_max = 75000;
        elseif (j==7)
            hincp_min = 75000;
            hincp_max = 100000;
        elseif (j==8)
            hincp_min = 100000;
            hincp_max = 150000;
        elseif (j==9)
            hincp_min = 150000;
            hincp_max = 200000;
        else
            hincp_min = 200000;
            hincp_max = inf;
        end
        
        PUMS_count(i,j) = sum((hincp>hincp_min).*(hincp<=hincp_max));
        
    end
    clear j
    
end
clear i

end
