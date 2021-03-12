function [tracts_x] = NN(StateAbbrev, tracts, tracts_Hazus, x_Hazus)

% load neighbors

census_tracts_neighbors = strcat(lower(StateAbbrev),'_census_tracts_neighbors.mat');
load(census_tracts_neighbors);
neighbors = table2array(census_tracts_neighbors);

% define #fields

fields = size(x_Hazus,2);

% initialize tracts_x

tracts_x = zeros(size(tracts,1),fields);

% run NN

for i=1:size(tracts,1)
    
    tract_Hazus = find(tracts_Hazus==tracts(i));
    tract_NN = find(neighbors(:,1)==tracts(i));
    
    if (tract_Hazus>0)
        tracts_x(i,:) = x_Hazus(tract_Hazus,:);
    else
        if (tract_NN>0)
            % check for first NN
            tract_Hazus = find(tracts_Hazus==neighbors(tract_NN(1),2));
            if (tract_Hazus>0)
                tracts_x(i,:) = x_Hazus(tract_Hazus,:);
            else
                % check for second NN
                tract_Hazus = find(tracts_Hazus==neighbors(tract_NN(2),2));
                if (tract_Hazus>0)
                    tracts_x(i,:) = x_Hazus(tract_Hazus,:);
                else
                    % check for third NN
                    tract_Hazus = find(tracts_Hazus==neighbors(tract_NN(3),2));
                    if (tract_Hazus>0)
                        tracts_x(i,:) = x_Hazus(tract_Hazus,:);
                    else
                        % assign mean
                        for j=1:fields
                            tracts_x(i,j) = mean(nonzeros(x_Hazus(:,j)));
                        end
                        clear j
                    end
                end
            end
        else
            % assign mean
            for j=1:fields
                tracts_x(i,j) = mean(nonzeros(x_Hazus(:,j)));
            end
            clear j
        end
    end
    
end
clear i

end
