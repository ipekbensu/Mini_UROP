function [EAL, PerValue_EAL, PerInc_EAL] = compute_EAL(tract, Cd, StateAbbrev, StateFIPS, RegionAbbrev)

% load Census Bureau data
% @ipekbensu: data on scale of census tracts

ACS_DP03_data = strcat('ACS_DP03_',StateFIPS,'.mat');
load(ACS_DP03_data);
tracts = table2array(ACS_DP03_data(:,2));

% load Hazus data
% @ipekbensu: data on scale of census tracts
% @ipekbensu: some census tracts can be missing

surface_roughness = strcat(lower(StateAbbrev),'_surface_roughness.mat');
load(surface_roughness);
peak_gusts = strcat(lower(StateAbbrev),'_peak_gusts.mat');
load(peak_gusts);
exposure_1000USD = strcat(lower(StateAbbrev),'_exposure_1000USD.mat');
load(exposure_1000USD);
exposure_count = strcat(lower(StateAbbrev),'_exposure_count.mat');
load(exposure_count);

% units: m
surface_roughness_Hazus = surface_roughness.SURFACEROUGHNESS;
tracts_Hazus = surface_roughness.Tract;
[tracts_surface_roughness] = NN(StateAbbrev, tracts, tracts_Hazus, surface_roughness_Hazus);

% columns (7): 10, 20, 50, 100, 200, 500, 1000 (yr return period)
% units: mph
peak_gusts_Hazus = table2array(peak_gusts(:,12:18));
tracts_Hazus = peak_gusts.Tract;
[tracts_peak_gusts] = NN(StateAbbrev, tracts, tracts_Hazus, peak_gusts_Hazus);
[tracts_Weibull] = estimate_Weibull(tracts_peak_gusts);

% columns (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: 1000 USD
exposure_1000USD_Hazus = table2array(exposure_1000USD(:,2:9));
tracts_Hazus = exposure_1000USD.CensusTract;
[tracts_exposure_1000USD] = NN(StateAbbrev, tracts, tracts_Hazus, exposure_1000USD_Hazus);

% columns (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: bldg or fractions
exposure_count_Hazus = table2array(exposure_count(:,2:9));
tracts_Hazus = exposure_count.CensusTract;
[tracts_exposure_count] = NN(StateAbbrev, tracts, tracts_Hazus, exposure_count_Hazus);

% convert #bldg to #hsng
% columns (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: hsng

[exposure] = Bldg2Hsng(tracts_exposure_count,0);

% compute exposure_1000SF_avg, exposure_1000USD_avg
% columns (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: 1000 USD / hsng

tracts_avg_1000USD = tracts_exposure_1000USD./exposure;

% compute BldgFunc_RES_Case0, BldgFunc_RES_Case1
% rows (8): RES1, RES2,... RES3F (Hazus bldg type)
% columns (41): 50, 55,... 250 mph (peak gust)
% pages (5): 0, 0.03, 0.35, 0.7, 1 m (roughness length)
% units: fractions

[BldgFunc_RES_Case0, BldgFunc_RES_Case1] = compute_BldgFunc_RES(StateAbbrev, RegionAbbrev);

% estimate HsngScheme_count, HsngScheme_p, HsngScheme_pi
% rows (8): RES1, RES2,... RES3F (Hazus bldg type)
% columns (10): 1, 2,... 10 (HINCP bin)
% units: hsng or fractions
% @ipekbensu: pages represent different census tracts

[HsngScheme_count, HsngScheme_p, HsngScheme_pi] = create_HsngScheme(StateAbbrev, StateFIPS);

% estimate BldgScheme_count, BldgScheme_p, HsngInc_avg_1000USD
% columns (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: bldg or fractions

BldgScheme_count = zeros(size(tracts,1),size(HsngScheme_count,1));
BldgScheme_p = zeros(size(tracts,1),size(HsngScheme_p,1));

% columns (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: 1000USD / hsng
HsngInc_avg_1000USD = zeros(size(tracts,1),size(HsngScheme_count,1));

% units: 1000USD
IncGroup_min = [0,10,15,25,35,50,75,100,150,200];
IncGroup_max = [10,15,25,35,50,75,100,150,200,250];
IncGroup_avg = (IncGroup_min+IncGroup_max)/2;

for i=1:size(tracts,1)
    
    BldgScheme_count(i,:) = Bldg2Hsng([sum(HsngScheme_count(:,:,i),2)]',2);
    BldgScheme_p(i,:) = BldgScheme_count(i,:)./sum(BldgScheme_count(i,:));
    
    for j=1:8
        
        HsngInc_avg_1000USD(i,j) = sum(HsngScheme_p(j,:,i).*IncGroup_avg)/sum(HsngScheme_p(j,:,i));
        
    end
    clear j
    
end
clear i

% check errors

tracts_avg_1000USD(isnan(tracts_avg_1000USD)) = 0;
BldgScheme_count(isnan(BldgScheme_count)) = 0;
BldgScheme_p(isnan(BldgScheme_p)) = 0;
HsngInc_avg_1000USD(isnan(HsngInc_avg_1000USD)) = 0;

% compute building-specific WSRs

WSR = sqrt(Cd/2);
WSR(WSR<sqrt(1/2)) = sqrt(1/2);
WSR(WSR>sqrt(4/2)) = sqrt(4/2);

% rows (4): 0-.25, .25-.5, .5-.75, .75-1 (quartile)
% columns (4): 1, 2, 3, 4 (directional severity)
% pages (6): 1-1.5, 1.5-2.0,... 3.5-4 (Cd range)
load('WSRR_input.mat');

% compute building-specific EALs
% @ipekbensu: input on different scales

% define ranges

% units: NA (since drag coefficient)
CFD_Cd_min = [1:0.5:3.5]';
CFD_Cd_max = [1.5:0.5:4]';

% units: m
surface_roughness_min = [0,0.03,0.35,0.7];
surface_roughness_max = [0.03,0.35,0.7,1];

% load input

bldg_WSRR = zeros(size(tract,1),size(WSRR_input,1),size(WSRR_input,2));
bldg_surface_roughness = zeros(size(tract,1),size(tracts_surface_roughness,2));
bldg_Weibull = zeros(size(tract,1),size(tracts_Weibull,2));
bldg_avg_1000USD = zeros(size(tract,1),size(tracts_avg_1000USD,2));
bldg_BldgFunc_RES_Case0 = zeros(size(tract,1),size(BldgFunc_RES_Case0,2),size(BldgFunc_RES_Case0,1));
bldg_BldgFunc_RES_Case1 = zeros(size(tract,1),size(BldgFunc_RES_Case1,2),size(BldgFunc_RES_Case1,1));
bldg_BldgScheme_p = zeros(size(tract,1),size(BldgScheme_p,2));
bldg_HsngInc_avg_1000USD = zeros(size(tract,1),size(HsngInc_avg_1000USD,2));

for k=1:size(WSRR_input,2)
    
    for j=1:size(WSRR_input,1)
        
        bldg_WSRR_jk = zeros(size(tract,1),1);
        
        for range=1:size(WSRR_input,3)
            
            bldg_WSRR_jk(Cd>=CFD_Cd_min(range)) = WSRR_input(j,k,range);
            
        end
        clear range
        
        bldg_WSRR(:,j,k) = bldg_WSRR_jk;
        
    end
    clear j
    
end
clear k

for i=1:size(tracts,1)
    
    if (sum(tract==tracts(i))>0)
        for j=1:size(tracts_surface_roughness,2)

            bldg_surface_roughness_j = zeros(size(tract,1),1);
            bldg_surface_roughness_j(tract==tracts(i)) = tracts_surface_roughness(i,j);
            bldg_surface_roughness(:,j) = bldg_surface_roughness(:,j)+bldg_surface_roughness_j;

        end
        clear j
        
        for j=1:size(tracts_Weibull,2)

            bldg_Weibull_j = zeros(size(tract,1),1);
            bldg_Weibull_j(tract==tracts(i)) = tracts_Weibull(i,j);
            bldg_Weibull(:,j) = bldg_Weibull(:,j)+bldg_Weibull_j;

        end
        clear j

        for j=1:size(tracts_avg_1000USD,2)

            bldg_avg_1000USD_j = zeros(size(tract,1),1);
            bldg_avg_1000USD_j(tract==tracts(i)) = tracts_avg_1000USD(i,j);
            bldg_avg_1000USD(:,j) = bldg_avg_1000USD(:,j)+bldg_avg_1000USD_j;

        end
        clear j

        for j=1:size(BldgScheme_p,2)

            bldg_BldgScheme_p_j = zeros(size(tract,1),1);
            bldg_BldgScheme_p_j(tract==tracts(i)) = BldgScheme_p(i,j);
            bldg_BldgScheme_p(:,j) = bldg_BldgScheme_p(:,j)+bldg_BldgScheme_p_j;

        end
        clear j
        
        for j=1:size(HsngInc_avg_1000USD,2)

            bldg_HsngInc_avg_1000USD_j = zeros(size(tract,1),1);
            bldg_HsngInc_avg_1000USD_j(tract==tracts(i)) = HsngInc_avg_1000USD(i,j);
            bldg_HsngInc_avg_1000USD(:,j) = bldg_HsngInc_avg_1000USD(:,j)+bldg_HsngInc_avg_1000USD_j;

        end
        clear j
    end
    disp(size(tracts,1)-i)
end
clear i

for k=1:size(BldgFunc_RES_Case0,1)
    
    for j=1:size(BldgFunc_RES_Case0,2)
        
        bldg_BldgFunc_RES_Case0_jk = zeros(size(tract,1),1);
        bldg_BldgFunc_RES_Case1_jk = zeros(size(tract,1),1);
        
        for range=1:(size(BldgFunc_RES_Case0,3)-1)
            
            bldg_surface_roughness_temp = bldg_surface_roughness(bldg_surface_roughness>=surface_roughness_min(range));
            bldg_BldgFunc_RES_Case0_jk(bldg_surface_roughness>=surface_roughness_min(range)) = BldgFunc_RES_Case0(k,j,range)+(BldgFunc_RES_Case0(k,j,range+1)-BldgFunc_RES_Case0(k,j,range))*(bldg_surface_roughness_temp-surface_roughness_min(range))/(surface_roughness_max(range)-surface_roughness_min(range));
            bldg_BldgFunc_RES_Case1_jk(bldg_surface_roughness>=surface_roughness_min(range)) = BldgFunc_RES_Case1(k,j,range)+(BldgFunc_RES_Case1(k,j,range+1)-BldgFunc_RES_Case1(k,j,range))*(bldg_surface_roughness_temp-surface_roughness_min(range))/(surface_roughness_max(range)-surface_roughness_min(range));
            
        end
        clear range
        
        bldg_BldgFunc_RES_Case0(:,j,k) = bldg_BldgFunc_RES_Case0_jk;
        bldg_BldgFunc_RES_Case1(:,j,k) = bldg_BldgFunc_RES_Case1_jk;
        
    end
    clear j
    
end
clear k

% initialize loss_RES_Case0, loss_RES_Case1
% columns (8): RES1, RES2,... RES3F (Hazus bldg type)
% pages (6): baseline, dir_1, dir_2, dir_3, dir_4, dir_avg
% units: fractions (EAL / value)

loss_RES_Case0 = zeros(size(tract,1),8,6);
loss_RES_Case1 = zeros(size(tract,1),8,6);

% compute loss_RES_Case0, loss_RES_Case1

% rows (41): 50, 55,... 250 mph (peak gust)
% units: mph
peak_gusts = ones(size(tract,1),1)*[50:5:250];

P_baseline = wblcdf(peak_gusts+2.5,bldg_Weibull(:,1),bldg_Weibull(:,2))-wblcdf(peak_gusts-2.5,bldg_Weibull(:,1),bldg_Weibull(:,2));
P_dir_1 = zeros(size(tract,1),41,4);
P_dir_2 = zeros(size(tract,1),41,4);
P_dir_3 = zeros(size(tract,1),41,4);
P_dir_4 = zeros(size(tract,1),41,4);

for k=1:4
    
    P_dir_1(:,:,k) = wblcdf((peak_gusts+2.5)./(1+WSR.*bldg_WSRR(:,k,1).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2))-...
        wblcdf((peak_gusts-2.5)./(1+WSR.*bldg_WSRR(:,k,1).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2));
    P_dir_2(:,:,k) = wblcdf((peak_gusts+2.5)./(1+WSR.*bldg_WSRR(:,k,2).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2))-...
        wblcdf((peak_gusts-2.5)./(1+WSR.*bldg_WSRR(:,k,2).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2));
    P_dir_3(:,:,k) = wblcdf((peak_gusts+2.5)./(1+WSR.*bldg_WSRR(:,k,3).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2))-...
        wblcdf((peak_gusts-2.5)./(1+WSR.*bldg_WSRR(:,k,3).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2));
    P_dir_4(:,:,k) = wblcdf((peak_gusts+2.5)./(1+WSR.*bldg_WSRR(:,k,4).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2))-...
        wblcdf((peak_gusts-2.5)./(1+WSR.*bldg_WSRR(:,k,4).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2));
    
end
clear k

for j=1:8
    
    loss_RES_Case0(:,j,1) = sum(P_baseline.*bldg_BldgFunc_RES_Case0(:,:,j),2);
    loss_RES_Case1(:,j,1) = sum(P_baseline.*bldg_BldgFunc_RES_Case1(:,:,j),2);
    
    dir_1_Case0 = zeros(size(tract,1),4);
    dir_2_Case0 = zeros(size(tract,1),4);
    dir_3_Case0 = zeros(size(tract,1),4);
    dir_4_Case0 = zeros(size(tract,1),4);
    dir_1_Case1 = zeros(size(tract,1),4);
    dir_2_Case1 = zeros(size(tract,1),4);
    dir_3_Case1 = zeros(size(tract,1),4);
    dir_4_Case1 = zeros(size(tract,1),4);
    
    for range=1:4
        
        dir_1_Case0(:,range) = sum(P_dir_1(:,:,range).*bldg_BldgFunc_RES_Case0(:,:,j),2);
        dir_2_Case0(:,range) = sum(P_dir_2(:,:,range).*bldg_BldgFunc_RES_Case0(:,:,j),2);
        dir_3_Case0(:,range) = sum(P_dir_3(:,:,range).*bldg_BldgFunc_RES_Case0(:,:,j),2);
        dir_4_Case0(:,range) = sum(P_dir_4(:,:,range).*bldg_BldgFunc_RES_Case0(:,:,j),2);
        dir_1_Case1(:,range) = sum(P_dir_1(:,:,range).*bldg_BldgFunc_RES_Case1(:,:,j),2);
        dir_2_Case1(:,range) = sum(P_dir_2(:,:,range).*bldg_BldgFunc_RES_Case1(:,:,j),2);
        dir_3_Case1(:,range) = sum(P_dir_3(:,:,range).*bldg_BldgFunc_RES_Case1(:,:,j),2);
        dir_4_Case1(:,range) = sum(P_dir_4(:,:,range).*bldg_BldgFunc_RES_Case1(:,:,j),2);
        
    end
    clear range
    
    loss_RES_Case0(:,j,2) = mean(dir_1_Case0,2);
    loss_RES_Case0(:,j,3) = mean(dir_2_Case0,2);
    loss_RES_Case0(:,j,4) = mean(dir_3_Case0,2);
    loss_RES_Case0(:,j,5) = mean(dir_4_Case0,2);
    loss_RES_Case0(:,j,6) = (...
        loss_RES_Case0(:,j,2)+...
        loss_RES_Case0(:,j,3)+...
        loss_RES_Case0(:,j,4)+...
        loss_RES_Case0(:,j,5)...
        )/4;
    loss_RES_Case1(:,j,2) = mean(dir_1_Case1,2);
    loss_RES_Case1(:,j,3) = mean(dir_2_Case1,2);
    loss_RES_Case1(:,j,4) = mean(dir_3_Case1,2);
    loss_RES_Case1(:,j,5) = mean(dir_4_Case1,2);
    loss_RES_Case1(:,j,6) = (...
        loss_RES_Case1(:,j,2)+...
        loss_RES_Case1(:,j,3)+...
        loss_RES_Case1(:,j,4)+...
        loss_RES_Case1(:,j,5)...
        )/4;
    
end
clear j

% initialize Case0_RES, Case1_RES
% columns (1-8): RES1, RES2,... RES3F (Hazus bldg type)
% columns (9): RES
% unit: 1000USD / hsng

Case0_RES_Hazus = zeros(size(tract,1),9);
Case0_RES_New = zeros(size(tract,1),9);
Case1_RES_Hazus = zeros(size(tract,1),9);
Case1_RES_New = zeros(size(tract,1),9);

% compute Case0_RES, Case1_RES

Case0_RES_Hazus(:,1:8) = loss_RES_Case0(:,:,1);
Case1_RES_Hazus(:,1:8) = loss_RES_Case1(:,:,1);
Case0_RES_New(:,1:8) = loss_RES_Case0(:,:,6);
Case1_RES_New(:,1:8) = loss_RES_Case1(:,:,6);

Case0_RES_Hazus(:,9) = sum(Case0_RES_Hazus(:,1:8).*bldg_BldgScheme_p,2);
Case1_RES_Hazus(:,9) = sum(Case1_RES_Hazus(:,1:8).*bldg_BldgScheme_p,2);
Case0_RES_New(:,9) = sum(Case0_RES_New(:,1:8).*bldg_BldgScheme_p,2);
Case1_RES_New(:,9) = sum(Case1_RES_New(:,1:8).*bldg_BldgScheme_p,2);

PerValue_EAL = [Case0_RES_Hazus, Case1_RES_Hazus, Case0_RES_New, Case1_RES_New];

Case0_RES_Hazus(:,1:8) = Case0_RES_Hazus(:,1:8).*bldg_avg_1000USD;
Case1_RES_Hazus(:,1:8) = Case1_RES_Hazus(:,1:8).*bldg_avg_1000USD;
Case0_RES_New(:,1:8) = Case0_RES_New(:,1:8).*bldg_avg_1000USD;
Case1_RES_New(:,1:8) = Case1_RES_New(:,1:8).*bldg_avg_1000USD;

Case0_RES_Hazus(:,9) = sum(Case0_RES_Hazus(:,1:8).*bldg_BldgScheme_p,2);
Case1_RES_Hazus(:,9) = sum(Case1_RES_Hazus(:,1:8).*bldg_BldgScheme_p,2);
Case0_RES_New(:,9) = sum(Case0_RES_New(:,1:8).*bldg_BldgScheme_p,2);
Case1_RES_New(:,9) = sum(Case1_RES_New(:,1:8).*bldg_BldgScheme_p,2);

EAL = [Case0_RES_Hazus, Case1_RES_Hazus, Case0_RES_New, Case1_RES_New];

Case0_RES_Hazus(:,1:8) = Case0_RES_Hazus(:,1:8)./bldg_HsngInc_avg_1000USD;
Case1_RES_Hazus(:,1:8) = Case1_RES_Hazus(:,1:8)./bldg_HsngInc_avg_1000USD;
Case0_RES_New(:,1:8) = Case0_RES_New(:,1:8)./bldg_HsngInc_avg_1000USD;
Case1_RES_New(:,1:8) = Case1_RES_New(:,1:8)./bldg_HsngInc_avg_1000USD;

% check errors

Case0_RES_Hazus(~isfinite(Case0_RES_Hazus)) = 0;
Case1_RES_Hazus(~isfinite(Case1_RES_Hazus)) = 0;
Case0_RES_New(~isfinite(Case0_RES_New)) = 0;
Case1_RES_New(~isfinite(Case1_RES_New)) = 0;

Case0_RES_Hazus(:,9) = sum(Case0_RES_Hazus(:,1:8).*bldg_BldgScheme_p,2);
Case1_RES_Hazus(:,9) = sum(Case1_RES_Hazus(:,1:8).*bldg_BldgScheme_p,2);
Case0_RES_New(:,9) = sum(Case0_RES_New(:,1:8).*bldg_BldgScheme_p,2);
Case1_RES_New(:,9) = sum(Case1_RES_New(:,1:8).*bldg_BldgScheme_p,2);

PerInc_EAL = [Case0_RES_Hazus, Case1_RES_Hazus, Case0_RES_New, Case1_RES_New];

end
