function [] = run(StateAbbrev,buildings)

% assign building information
% Mini_UROP: this is why it's important to use standard labels in QGIS!
% Mini_UROP: 'lat', 'lon', 'area' assigned by us
% Mini_UROP: 'GEOID' from census bureau files
% -

lat = buildings.lat;
lon = buildings.lon;
area = buildings.area;
tract = buildings.GEOID;

% compute building-specific drag coefficients
% -

[Cd] = city_texture_cd_model(lat,lon,area);

% save building-specific drag coefficients
% -

buildings_Cd = array2table(horzcat(tract,lat,lon,area,Cd),...
    'VariableNames',{'tract','lat','lon','area','Cd'});
SaveName_mat = srtcat(StateAbbrev,'_Cd.mat');
SaveName_csv = strcat(StateAbbrev,'_Cd.csv');
save(SaveName_mat,'buildings_Cd');
writetable(buildings_Cd,SaveName_csv);

end
