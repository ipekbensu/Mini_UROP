for i=1:22
    % assign state information
    % -
    
    if i==1
        StateName = 'Alabama';
        StateAbbrev = 'AL';
        StateFIPS = '01';
        Regions = 6;
    elseif i==2
        StateName = 'Connecticut';
        StateAbbrev = 'CT';
        StateFIPS = '09';
        Regions = 5;
    elseif i==3
        StateName = 'Delaware';
        StateAbbrev = 'DE';
        StateFIPS = '10';
        Regions = 5;
    elseif i==4
        % update loss model to include
        StateName = 'DistrictofColumbia';
        StateAbbrev = 'DC';
        StateFIPS = '11';
        Regions = null;
    elseif i==5
        StateName = 'Florida';
        StateAbbrev = 'FL';
        StateFIPS = '12';
        Regions = 1:4;
    elseif i==6
        StateName = 'Georgia';
        StateAbbrev = 'GA';
        StateFIPS = '13';
        Regions = 6;
    elseif i==7
        StateName = 'Louisiana';
        StateAbbrev = 'LA';
        StateFIPS = '22';
        Regions = 6;
    elseif i==8
        StateName = 'Maine';
        StateAbbrev = 'ME';
        StateFIPS = '23';
        Regions = 5;
    elseif i==9
        StateName = 'Maryland';
        StateAbbrev = 'MD';
        StateFIPS = '24';
        Regions = 5;
    elseif i==10
        StateName = 'Massachusetts';
        StateAbbrev = 'MA';
        StateFIPS = '25';
        Regions = 5;
    elseif i==11
        StateName = 'Mississippi';
        StateAbbrev = 'MS';
        StateFIPS = '28';
        Regions = 6;
    elseif i==12
        StateName = 'NewHampshire';
        StateAbbrev = 'NH';
        StateFIPS = '33';
        Regions = 5;
    elseif i==13
        StateName = 'NewJersey';
        StateAbbrev = 'NJ';
        StateFIPS = '34';
        Regions = 5;
    elseif i==14
        StateName = 'NewYork';
        StateAbbrev = 'NY';
        StateFIPS = '36';
        Regions = 5;
    elseif i==15
        StateName = 'NorthCarolina';
        StateAbbrev = 'NC';
        StateFIPS = '37';
        Regions = 6;
    elseif i==16
        % not included in hurricane-prone states
        % included for visualization
        % update loss model to include
        StateName = 'Pennsylvania';
        StateAbbrev = 'PA';
        StateFIPS = '42';
        Regions = null;
    elseif i==17
        StateName = 'RhodeIsland';
        StateAbbrev = 'RI';
        StateFIPS = '44';
        Regions = 5;
    elseif i==18
        StateName = 'SouthCarolina';
        StateAbbrev = 'SC';
        StateFIPS = '45';
        Regions = 6;
    elseif i==19
        StateName = 'Texas';
        StateAbbrev = 'TX';
        StateFIPS = '48';
        Regions = 6;
    elseif i==20
        % not included in hurricane-prone states
        % included for visualization
        % update loss model to include
        StateName = 'Vermont';
        StateAbbrev = 'VT';
        StateFIPS = '50';
        Regions = null;
    elseif i==21
        StateName = 'Virginia';
        StateAbbrev = 'VA';
        StateFIPS = '51';
        Regions = 5;
    elseif i==22
        % not included in hurricane-prone states
        % included for visualization
        % update loss model to include
        StateName = 'WestVirginia';
        StateAbbrev = 'WV';
        StateFIPS = '54';
        Regions = null;
    end
    
    nRegions = length(Regions);
    
    for region=1:rRegions
        if Regions(region)==1
            RegionAbbrev = 'FL_Central';
            LoadName = strcat(StateAbbrev,'_',RegionAbbrev,'_Cd.mat');
        elseif Regions(region)==2
            RegionAbbrev = 'FL_N';
            LoadName = strcat(StateAbbrev,'_',RegionAbbrev,'_Cd.mat');
        elseif Regions(region)==3
            RegionAbbrev = 'FL_S';
            LoadName = strcat(StateAbbrev,'_',RegionAbbrev,'_Cd.mat');
        elseif Regions(region)==4
            RegionAbbrev = 'FL_SE';
            LoadName = strcat(StateAbbrev,'_',RegionAbbrev,'_Cd.mat');
        elseif Regions(region)==5
            RegionAbbrev = 'NE';
            LoadName = strcat(StateAbbrev,'_Cd.mat');
        elseif Regions(region)==6
            RegionAbbrev = 'SE';
            LoadName = strcat(StateAbbrev,'_Cd.mat');
        end
        
        % compute and save building-specific EALs
        % -
        
        load(LoadName);
        run(StateAbbrev, StateFIPS, RegionAbbrev, buildings_Cd);
    end
    
end
