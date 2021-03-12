function [PUMS_pi] = PUMS_estimate_pi(PUMS_p)

% define #rows, #columns

rows = size(PUMS_p,1);
columns = size(PUMS_p,2);

% initialize PUMS_pi
% rows (9): 1, 2,... 9 (BLD)
% columns (10): 1, 2,... 10 (HINCP bin)
% units: fractions

PUMS_pi = zeros(rows,columns);

% estimate PUMS_pi

for i=1:rows
    
    for j=1:columns
        
        PUMS_pi(i,j) = PUMS_p(i,j)/sum(PUMS_p(:,j));
        
    end
    clear j
    
end
clear i

% catch errors

PUMS_pi(isnan(PUMS_pi)) = 0;

end
