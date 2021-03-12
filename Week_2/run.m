function [] = run(StateAbbrev,buildings)

% assign building information

tract = buildings.tract;
lat = buildings.lat;
lon = buildings.lon;
area = buildings.area;

% compute building-specific drag coefficients
% @ipekbensu: Cd relates to building (b)
% @ipekbensu: P, L, Cn relate to neighbors of building (b)
% @ipekbensu: P is density (per m^2)
% @ipekbensu: L is density length (m)
% @ipekbensu: Cn is #neighbors

[tract,lat,lon,area,Cd,P,L,Cn] = city_texture_cd_model(tract,lat,lon,area);

% save building-specific drag coefficients

buildings_Cd = array2table(horzcat(tract,lat,lon,area,Cd,P,L,Cn),...
    'VariableNames',{'tract','lat','lon','area','Cd',...
    'density','density_length','nsur'});
SaveName_mat = strcat(StateAbbrev,'_Cd.mat');
SaveName_csv = strcat(StateAbbrev,'_Cd.csv');
save(SaveName_mat,'buildings_Cd');
writetable(buildings_Cd,SaveName_csv);

end
