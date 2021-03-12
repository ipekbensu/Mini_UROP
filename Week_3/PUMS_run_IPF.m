function [IPF_p] = PUMS_run_IPF(PUMS_p, tract, bld, hincp)

% define #trials

trials = 1000;
trial = 0;
quit = 0;

% adjust PUMS_p
% "20+ units" instead of "50+ units"
% rows (8): 1, 2,... 8 (BLD)
% columns (10): 1, 2,... 10 (HINCP bin)
% units: fractions

PUMS_p_adj = zeros(8,10);
PUMS_p_adj(1:7,:) = PUMS_p(1:7,:);
PUMS_p_adj(8,:) = PUMS_p(8,:)+PUMS_p(9,:);

% initialize IPF_p
% "20+ units" instead of "50+ units"
% rows (8): 1, 2,... 8 (BLD)
% columns (10): 1, 2,... 10 (HINCP bin)
% units: fractions

IPF_p = PUMS_p_adj;

% estimate IPF_p

p_bld = bld(tract,:)/sum(bld(tract,:));
p_bld(isnan(p_bld)) = 0;

p_hincp = hincp(tract,:)/sum(hincp(tract,:));
p_hincp(isnan(p_hincp)) = 0;

while (trial<trials && quit<trials)
    
    for i=1:8
        
        IPF_p(i,:) = IPF_p(i,:)*p_bld(1,i)/sum(IPF_p(i,:));
        IPF_p(isnan(IPF_p)) = 0;
        
    end
    clear i
    
    for j=1:10
        
        IPF_p(:,j) = IPF_p(:,j)*p_hincp(1,j)/sum(IPF_p(:,j));
        IPF_p(isnan(IPF_p)) = 0;
        
    end
    clear j
    
    for i=1:9
        
        if (i==9)
            quit = trials;
        else
            if (abs(sum(IPF_p(i,:))-p_bld(1,i))>0.001)
                break;
            end
        end
        
    end
    clear i
    
    trial = trial+1;
    
end

% catch nonconvergence

if (trial==trials)
    IPF_p = PUMS_p_adj;
end

end
