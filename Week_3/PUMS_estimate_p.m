function [PUMS_p] = PUMS_estimate_p(PUMS_count)

% define #rows, #columns

rows = size(PUMS_count,1);
columns = size(PUMS_count,2);

% initialize PUMS_p
% rows (9): 1, 2,... 9 (BLD)
% columns (10): 1, 2,... 10 (HINCP bin)
% units: fractions

PUMS_p = zeros(rows,columns);

% estimate PUMS_p

for i=1:rows
    
    for j=1:columns
        
        PUMS_p(i,j) = PUMS_count(i,j)/sum(sum(PUMS_count));
        
    end
    clear j
    
end
clear i

% catch errors

PUMS_p(isnan(PUMS_p)) = 0;

end
