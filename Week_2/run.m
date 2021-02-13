function [] = run(StateAbbrev,buildings)

% assign building information
% -

lat = buildings.lat;
lon = buildings.lon;
area = buildings.area;

% compute building-specific drag coefficients
% -

% LAT, LON, AREA, Cd, P, L, Cn
% LAT: latitude (deg)
% LON: longitude (deg)
% Cd: drag coefficient
% P: local density
% L: local density length
% Cd: #surrounding bldgs
[LAT,LON,AREA,Cd,P,L,Cn] = city_texture_cd_model(lat,lon,area);

% save building-specific drag coefficients
% -

buildings_Cd = array2table(horzcat(LAT,LON,AREA,Cd,P,L,Cn),...
    'VariableNames',{'lat','lon','area','Cd',...
    'density','density_length','nsur'});
SaveName_mat = strcat(StateAbbrev,'_Cd.mat');
SaveName_csv = strcat(StateAbbrev,'_Cd.csv');
save(SaveName_mat,'buildings_Cd');
writetable(buildings_Cd,SaveName_csv);

end
