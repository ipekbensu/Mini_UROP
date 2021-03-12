for i=1:22
    
    % assign state information
    
    if i==1
        StateName = 'Alabama';
        StateAbbrev = 'AL';
        StateFIPS = '01';
        Regions = 6;
        disp(strcat('State:',StateName))
    elseif i==2
        StateName = 'Connecticut';
        StateAbbrev = 'CT';
        StateFIPS = '09';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==3
        StateName = 'Delaware';
        StateAbbrev = 'DE';
        StateFIPS = '10';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==4
        StateName = 'DistrictofColumbia';
        StateAbbrev = 'DC';
        StateFIPS = '11';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==5
        StateName = 'Florida';
        StateAbbrev = 'FL';
        StateFIPS = '12';
        Regions = 1:4;
        disp(strcat('State:',StateName))
    elseif i==6
        StateName = 'Georgia';
        StateAbbrev = 'GA';
        StateFIPS = '13';
        Regions = 6;
        disp(strcat('State:',StateName))
    elseif i==7
        StateName = 'Louisiana';
        StateAbbrev = 'LA';
        StateFIPS = '22';
        Regions = 6;
        disp(strcat('State:',StateName))
    elseif i==8
        StateName = 'Maine';
        StateAbbrev = 'ME';
        StateFIPS = '23';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==9
        StateName = 'Maryland';
        StateAbbrev = 'MD';
        StateFIPS = '24';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==10
        StateName = 'Massachusetts';
        StateAbbrev = 'MA';
        StateFIPS = '25';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==11
        StateName = 'Mississippi';
        StateAbbrev = 'MS';
        StateFIPS = '28';
        Regions = 6;
        disp(strcat('State:',StateName))
    elseif i==12
        StateName = 'NewHampshire';
        StateAbbrev = 'NH';
        StateFIPS = '33';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==13
        StateName = 'NewJersey';
        StateAbbrev = 'NJ';
        StateFIPS = '34';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==14
        StateName = 'NewYork';
        StateAbbrev = 'NY';
        StateFIPS = '36';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==15
        StateName = 'NorthCarolina';
        StateAbbrev = 'NC';
        StateFIPS = '37';
        Regions = 6;
        disp(strcat('State:',StateName))
    elseif i==16
        % @ipekbensu: included for visualization
        StateName = 'Pennsylvania';
        StateAbbrev = 'PA';
        StateFIPS = '42';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==17
        StateName = 'RhodeIsland';
        StateAbbrev = 'RI';
        StateFIPS = '44';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==18
        StateName = 'SouthCarolina';
        StateAbbrev = 'SC';
        StateFIPS = '45';
        Regions = 6;
        disp(strcat('State:',StateName))
    elseif i==19
        StateName = 'Texas';
        StateAbbrev = 'TX';
        StateFIPS = '48';
        Regions = 6;
        disp(strcat('State:',StateName))
    elseif i==20
        % @ipekbensu: included for visualization
        StateName = 'Vermont';
        StateAbbrev = 'VT';
        StateFIPS = '50';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==21
        StateName = 'Virginia';
        StateAbbrev = 'VA';
        StateFIPS = '51';
        Regions = 5;
        disp(strcat('State:',StateName))
    elseif i==22
        % @ipekbensu: included for visualization
        StateName = 'WestVirginia';
        StateAbbrev = 'WV';
        StateFIPS = '54';
        Regions = 5;
        disp(strcat('State:',StateName))
    end
    
    nRegions = length(Regions);
    
    for region=1:nRegions
        if Regions(region)==1
            RegionAbbrev = 'FL_Central';
            LoadName = strcat(StateAbbrev,'_',RegionAbbrev,'_Cd.mat');
            disp(strcat('Region:',RegionAbbrev))
        elseif Regions(region)==2
            RegionAbbrev = 'FL_N';
            LoadName = strcat(StateAbbrev,'_',RegionAbbrev,'_Cd.mat');
            disp(strcat('Region:',RegionAbbrev))
        elseif Regions(region)==3
            RegionAbbrev = 'FL_S';
            LoadName = strcat(StateAbbrev,'_',RegionAbbrev,'_Cd.mat');
            disp(strcat('Region:',RegionAbbrev))
        elseif Regions(region)==4
            RegionAbbrev = 'FL_SE';
            LoadName = strcat(StateAbbrev,'_',RegionAbbrev,'_Cd.mat');
            disp(strcat('Region:',RegionAbbrev))
        elseif Regions(region)==5
            RegionAbbrev = 'NE';
            LoadName = strcat(StateAbbrev,'_Cd.mat');
            disp(strcat('Region:',RegionAbbrev))
        elseif Regions(region)==6
            RegionAbbrev = 'SE';
            LoadName = strcat(StateAbbrev,'_Cd.mat');
            disp(strcat('Region:',RegionAbbrev))
        end
        
        % compute and save building-specific EALs
        
        load(LoadName);
        cutoff_check = 4000000;
        cutoff_part = 2500000;
        if (size(buildings_Cd,1)>cutoff_check)
            parts = ceil(size(buildings_Cd,1)/cutoff_part);
        else
            parts = 0;
        end
        if (parts>0)
            for part=1:parts
                if (part<parts)
                    part_Cd = buildings_Cd((1+(part-1)*cutoff_part):(part*cutoff_part),:);
                    run(StateAbbrev, StateFIPS, RegionAbbrev, part_Cd, part);
                else
                    part_Cd = buildings_Cd((1+(part-1)*cutoff_part):end,:);
                    run(StateAbbrev, StateFIPS, RegionAbbrev, part_Cd, part);
                end
            end
        else
            run(StateAbbrev, StateFIPS, RegionAbbrev, buildings_Cd, parts);
        end
    end
    
end
