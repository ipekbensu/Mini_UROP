function [] = run(StateAbbrev, StateFIPS, RegionAbbrev, buildings_Cd, part)

% assign building information

tract = buildings_Cd.tract;
lat = buildings_Cd.lat;
lon = buildings_Cd.lon;
Cd = buildings_Cd.Cd;

% compute building-specific EALs

[EAL, PerValue_EAL, PerInc_EAL] = compute_EAL(tract, Cd, StateAbbrev, StateFIPS, RegionAbbrev);

% save building-specific EALs

buildings_EAL = array2table(horzcat(tract,lat,lon,Cd,EAL),...
    'VariableNames',{'tract','lat','lon','Cd',...
    'Case0_RES1_Hazus','Case0_RES2_Hazus','Case0_RES3A_Hazus','Case0_RES3B_Hazus','Case0_RES3C_Hazus','Case0_RES3D_Hazus','Case0_RES3E_Hazus','Case0_RES3F_Hazus','Case0_RES_Hazus',...
    'Case1_RES1_Hazus','Case1_RES2_Hazus','Case1_RES3A_Hazus','Case1_RES3B_Hazus','Case1_RES3C_Hazus','Case1_RES3D_Hazus','Case1_RES3E_Hazus','Case1_RES3F_Hazus','Case1_RES_Hazus',...
    'Case0_RES1_New','Case0_RES2_New','Case0_RES3A_New','Case0_RES3B_New','Case0_RES3C_New','Case0_RES3D_New','Case0_RES3E_New','Case0_RES3F_New','Case0_RES_New',...
    'Case1_RES1_New','Case1_RES2_New','Case1_RES3A_New','Case1_RES3B_New','Case1_RES3C_New','Case1_RES3D_New','Case1_RES3E_New','Case1_RES3F_New','Case1_RES_New'});
if (str2double(StateFIPS)==12)
    SaveName_mat = strcat(StateAbbrev,'_',RegionAbbrev,'_EAL.mat');
    SaveName_csv = strcat(StateAbbrev,'_',RegionAbbrev,'_EAL.csv');
elseif (part>0)
    SaveName_mat = strcat(StateAbbrev,'_',num2str(part),'_EAL.mat');
    SaveName_csv = strcat(StateAbbrev,'_',num2str(part),'_EAL.csv');
else
    SaveName_mat = strcat(StateAbbrev,'_EAL.mat');
    SaveName_csv = strcat(StateAbbrev,'_EAL.csv');
end
% save(SaveName_mat,'buildings_EAL');
writetable(buildings_EAL,SaveName_csv);

buildings_EAL_PerValue = array2table(horzcat(tract,lat,lon,Cd,PerValue_EAL),...
    'VariableNames',{'tract','lat','lon','Cd',...
    'Case0_RES1_Hazus','Case0_RES2_Hazus','Case0_RES3A_Hazus','Case0_RES3B_Hazus','Case0_RES3C_Hazus','Case0_RES3D_Hazus','Case0_RES3E_Hazus','Case0_RES3F_Hazus','Case0_RES_Hazus',...
    'Case1_RES1_Hazus','Case1_RES2_Hazus','Case1_RES3A_Hazus','Case1_RES3B_Hazus','Case1_RES3C_Hazus','Case1_RES3D_Hazus','Case1_RES3E_Hazus','Case1_RES3F_Hazus','Case1_RES_Hazus',...
    'Case0_RES1_New','Case0_RES2_New','Case0_RES3A_New','Case0_RES3B_New','Case0_RES3C_New','Case0_RES3D_New','Case0_RES3E_New','Case0_RES3F_New','Case0_RES_New',...
    'Case1_RES1_New','Case1_RES2_New','Case1_RES3A_New','Case1_RES3B_New','Case1_RES3C_New','Case1_RES3D_New','Case1_RES3E_New','Case1_RES3F_New','Case1_RES_New'});
if (str2double(StateFIPS)==12)
    SaveName_mat = strcat(StateAbbrev,'_',RegionAbbrev,'_EAL_PerValue.mat');
    SaveName_csv = strcat(StateAbbrev,'_',RegionAbbrev,'_EAL_PerValue.csv');
elseif (part>0)
    SaveName_mat = strcat(StateAbbrev,'_',num2str(part),'_EAL_PerValue.mat');
    SaveName_csv = strcat(StateAbbrev,'_',num2str(part),'_EAL_PerValue.csv');
else
    SaveName_mat = strcat(StateAbbrev,'_EAL_PerValue.mat');
    SaveName_csv = strcat(StateAbbrev,'_EAL_PerValue.csv');
end
% save(SaveName_mat,'buildings_EAL_PerValue');
writetable(buildings_EAL_PerValue,SaveName_csv);

buildings_EAL_PerInc = array2table(horzcat(tract,lat,lon,Cd,PerInc_EAL),...
    'VariableNames',{'tract','lat','lon','Cd',...
    'Case0_RES1_Hazus','Case0_RES2_Hazus','Case0_RES3A_Hazus','Case0_RES3B_Hazus','Case0_RES3C_Hazus','Case0_RES3D_Hazus','Case0_RES3E_Hazus','Case0_RES3F_Hazus','Case0_RES_Hazus',...
    'Case1_RES1_Hazus','Case1_RES2_Hazus','Case1_RES3A_Hazus','Case1_RES3B_Hazus','Case1_RES3C_Hazus','Case1_RES3D_Hazus','Case1_RES3E_Hazus','Case1_RES3F_Hazus','Case1_RES_Hazus',...
    'Case0_RES1_New','Case0_RES2_New','Case0_RES3A_New','Case0_RES3B_New','Case0_RES3C_New','Case0_RES3D_New','Case0_RES3E_New','Case0_RES3F_New','Case0_RES_New',...
    'Case1_RES1_New','Case1_RES2_New','Case1_RES3A_New','Case1_RES3B_New','Case1_RES3C_New','Case1_RES3D_New','Case1_RES3E_New','Case1_RES3F_New','Case1_RES_New'});
if (str2double(StateFIPS)==12)
    SaveName_mat = strcat(StateAbbrev,'_',RegionAbbrev,'_EAL_PerInc.mat');
    SaveName_csv = strcat(StateAbbrev,'_',RegionAbbrev,'_EAL_PerInc.csv');
elseif (part>0)
    SaveName_mat = strcat(StateAbbrev,'_',num2str(part),'_EAL_PerInc.mat');
    SaveName_csv = strcat(StateAbbrev,'_',num2str(part),'_EAL_PerInc.csv');
else
    SaveName_mat = strcat(StateAbbrev,'_EAL_PerInc.mat');
    SaveName_csv = strcat(StateAbbrev,'_EAL_PerInc.csv');
end
% save(SaveName_mat,'buildings_EAL_PerInc');
writetable(buildings_EAL_PerInc,SaveName_csv);

end
