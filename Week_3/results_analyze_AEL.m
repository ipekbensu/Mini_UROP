function [...
    loss_RES_Case0_PerValue, loss_RES_Case1_PerValue,...
    loss_RES_Case0_1000USD, loss_RES_Case1_1000USD,...
    loss_RES_Case0_PerInc, loss_RES_Case1_PerInc...
    ] = results_analyze_AEL(...
    bldg_tracts, bldg_CFD_Cd, bldg_WSR,...
    BldgFunc_RES_Case0, BldgFunc_RES_Case1,...
    BldgScheme_count, BldgScheme_p,...
    HsngInc_avg_1000USD,...
    tracts,...
    tracts_surface_roughness,...
    tracts_peak_gusts, tracts_Weibull,...
    tracts_avg_1000SF, tracts_avg_1000USD,...
    WSRR_input...
    )

% define ranges
% -

% units: NA (since drag coefficient)
CFD_Cd_min = [1:0.5:3.5]';
CFD_Cd_max = [1.5:0.5:4]';

% units: m
surface_roughness_min = [0,0.03,0.35,0.7];
surface_roughness_max = [0.03,0.35,0.7,1];

% load inputs
% -

bldg_WSRR = zeros(size(bldg_tracts,1),size(WSRR_input,1),size(WSRR_input,2));
bldg_surface_roughness = zeros(size(bldg_tracts,1),size(tracts_surface_roughness,2));
bldg_peak_gusts = zeros(size(bldg_tracts,1),size(tracts_peak_gusts,2));
bldg_Weibull = zeros(size(bldg_tracts,1),size(tracts_Weibull,2));
bldg_avg_1000SF = zeros(size(bldg_tracts,1),size(tracts_avg_1000SF,2));
bldg_avg_1000USD = zeros(size(bldg_tracts,1),size(tracts_avg_1000USD,2));
bldg_BldgFunc_RES_Case0 = zeros(size(bldg_tracts,1),size(BldgFunc_RES_Case0,2),size(BldgFunc_RES_Case0,1));
bldg_BldgFunc_RES_Case1 = zeros(size(bldg_tracts,1),size(BldgFunc_RES_Case1,2),size(BldgFunc_RES_Case1,1));
bldg_BldgScheme_count = zeros(size(bldg_tracts,1),size(BldgScheme_count,2));
bldg_BldgScheme_p = zeros(size(bldg_tracts,1),size(BldgScheme_p,2));
bldg_HsngInc_avg_1000USD = zeros(size(bldg_tracts,1),size(HsngInc_avg_1000USD,2));

for k=1:size(WSRR_input,2)
    
    for j=1:size(WSRR_input,1)
        
        bldg_WSRR_input_jk = zeros(size(bldg_tracts,1),1);
        
        for range=1:size(WSRR_input,3)
            
            bldg_WSRR_input_jk(bldg_CFD_Cd>=CFD_Cd_min(range)) = WSRR_input(j,k,range);
            
        end
        clear range
        
        bldg_WSRR(:,j,k) = bldg_WSRR_input_jk;
        
    end
    clear j
    
end
clear k

for tract=1:size(tracts,1)
    
    if (sum(bldg_tracts==tracts(tract))>0)
        for j=1:size(tracts_surface_roughness,2)

            bldg_surface_roughness_j = zeros(size(bldg_tracts,1),1);
            bldg_surface_roughness_j(bldg_tracts==tracts(tract)) = tracts_surface_roughness(tract,j);
            bldg_surface_roughness(:,j) = bldg_surface_roughness(:,j)+bldg_surface_roughness_j;

        end
        clear j

        for j=1:size(tracts_peak_gusts,2)

            bldg_peak_gusts_j = zeros(size(bldg_tracts,1),1);
            bldg_peak_gusts_j(bldg_tracts==tracts(tract)) = tracts_peak_gusts(tract,j);
            bldg_peak_gusts(:,j) = bldg_peak_gusts(:,j)+bldg_peak_gusts_j;

        end
        clear j

        for j=1:size(tracts_Weibull,2)

            bldg_Weibull_j = zeros(size(bldg_tracts,1),1);
            bldg_Weibull_j(bldg_tracts==tracts(tract)) = tracts_Weibull(tract,j);
            bldg_Weibull(:,j) = bldg_Weibull(:,j)+bldg_Weibull_j;

        end
        clear j

        for j=1:size(tracts_avg_1000SF,2)

            bldg_avg_1000SF_j = zeros(size(bldg_tracts,1),1);
            bldg_avg_1000SF_j(bldg_tracts==tracts(tract)) = tracts_avg_1000SF(tract,j);
            bldg_avg_1000SF(:,j) = bldg_avg_1000SF(:,j)+bldg_avg_1000SF_j;

        end
        clear j

        for j=1:size(tracts_avg_1000USD,2)

            bldg_avg_1000USD_j = zeros(size(bldg_tracts,1),1);
            bldg_avg_1000USD_j(bldg_tracts==tracts(tract)) = tracts_avg_1000USD(tract,j);
            bldg_avg_1000USD(:,j) = bldg_avg_1000USD(:,j)+bldg_avg_1000USD_j;

        end
        clear j

        for j=1:size(BldgScheme_count,2)

            bldg_BldgScheme_count_j = zeros(size(bldg_tracts,1),1);
            bldg_BldgScheme_count_j(bldg_tracts==tracts(tract)) = BldgScheme_count(tract,j);
            bldg_BldgScheme_count(:,j) = bldg_BldgScheme_count(:,j)+bldg_BldgScheme_count_j;

        end
        clear j

        for j=1:size(BldgScheme_p,2)

            bldg_BldgScheme_p_j = zeros(size(bldg_tracts,1),1);
            bldg_BldgScheme_p_j(bldg_tracts==tracts(tract)) = BldgScheme_p(tract,j);
            bldg_BldgScheme_p(:,j) = bldg_BldgScheme_p(:,j)+bldg_BldgScheme_p_j;

        end
        clear j
        
        for j=1:size(HsngInc_avg_1000USD,2)

            bldg_HsngInc_avg_1000USD_j = zeros(size(bldg_tracts,1),1);
            bldg_HsngInc_avg_1000USD_j(bldg_tracts==tracts(tract)) = HsngInc_avg_1000USD(tract,j);
            bldg_HsngInc_avg_1000USD(:,j) = bldg_HsngInc_avg_1000USD(:,j)+bldg_HsngInc_avg_1000USD_j;

        end
        clear j
    end
    
end
clear tract

for k=1:size(BldgFunc_RES_Case0,1)
    
    for j=1:size(BldgFunc_RES_Case0,2)
        
        bldg_BldgFunc_RES_Case0_jk = zeros(size(bldg_tracts,1),1);
        bldg_BldgFunc_RES_Case1_jk = zeros(size(bldg_tracts,1),1);
        
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
% -

% columns (8): RES1, RES2,... RES3F (HAZUS bldg type)
% pages (6): baseline, dir_1, dir_2, dir_3, dir_4, dir_avg
% units: fractions (AEL / value)
loss_RES_Case0 = zeros(size(bldg_tracts,1),8,6);
loss_RES_Case1 = zeros(size(bldg_tracts,1),8,6);

% compute loss_RES_Case0, loss_RES_Case1
% -

% rows (41): 50, 55,... 250 mph (peak gust)
% units: mph
peak_gusts = ones(size(bldg_tracts,1),1)*[50:5:250];

P_baseline = wblcdf(peak_gusts+2.5,bldg_Weibull(:,1),bldg_Weibull(:,2))-wblcdf(peak_gusts-2.5,bldg_Weibull(:,1),bldg_Weibull(:,2));
P_dir_1 = zeros(size(bldg_tracts,1),41,4);
P_dir_2 = zeros(size(bldg_tracts,1),41,4);
P_dir_3 = zeros(size(bldg_tracts,1),41,4);
P_dir_4 = zeros(size(bldg_tracts,1),41,4);

for k=1:4
    
    P_dir_1(:,:,k) = wblcdf((peak_gusts+2.5)./(1+bldg_WSR.*bldg_WSRR(:,k,1).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2))-...
        wblcdf((peak_gusts-2.5)./(1+bldg_WSR.*bldg_WSRR(:,k,1).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2));
    P_dir_2(:,:,k) = wblcdf((peak_gusts+2.5)./(1+bldg_WSR.*bldg_WSRR(:,k,2).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2))-...
        wblcdf((peak_gusts-2.5)./(1+bldg_WSR.*bldg_WSRR(:,k,2).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2));
    P_dir_3(:,:,k) = wblcdf((peak_gusts+2.5)./(1+bldg_WSR.*bldg_WSRR(:,k,3).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2))-...
        wblcdf((peak_gusts-2.5)./(1+bldg_WSR.*bldg_WSRR(:,k,3).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2));
    P_dir_4(:,:,k) = wblcdf((peak_gusts+2.5)./(1+bldg_WSR.*bldg_WSRR(:,k,4).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2))-...
        wblcdf((peak_gusts-2.5)./(1+bldg_WSR.*bldg_WSRR(:,k,4).*z0_compute_WSR(bldg_surface_roughness)-z0_compute_WSR(bldg_surface_roughness)),bldg_Weibull(:,1),bldg_Weibull(:,2));
    
end
clear k

for j=1:8
    
    loss_RES_Case0(:,j,1) = sum(P_baseline.*bldg_BldgFunc_RES_Case0(:,:,j),2);
    loss_RES_Case1(:,j,1) = sum(P_baseline.*bldg_BldgFunc_RES_Case1(:,:,j),2);
    
    dir_1_Case0 = zeros(size(bldg_tracts,1),4);
    dir_2_Case0 = zeros(size(bldg_tracts,1),4);
    dir_3_Case0 = zeros(size(bldg_tracts,1),4);
    dir_4_Case0 = zeros(size(bldg_tracts,1),4);
    dir_1_Case1 = zeros(size(bldg_tracts,1),4);
    dir_2_Case1 = zeros(size(bldg_tracts,1),4);
    dir_3_Case1 = zeros(size(bldg_tracts,1),4);
    dir_4_Case1 = zeros(size(bldg_tracts,1),4);
    
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

% initialize loss_RES_Case0_PerValue, loss_RES_Case1_PerValue, loss_RES_Case0_1000USD, loss_RES_Case1_1000USD, loss_RES_Case0_PerInc, loss_RES_Case1_PerInc
% -

% columns (6): baseline, dir_1, dir_2, dir_3, dir_4, dir_avg
% units: fractions (loss / value)
% for avg structure
loss_RES_Case0_PerValue = zeros(size(bldg_tracts,1),6);
loss_RES_Case1_PerValue = zeros(size(bldg_tracts,1),6);

% columns (6): baseline, dir_1, dir_2, dir_3, dir_4, dir_avg
% units: 1000 USD
% for avg structure
loss_RES_Case0_1000USD = zeros(size(bldg_tracts,1),6);
loss_RES_Case1_1000USD = zeros(size(bldg_tracts,1),6);

% columns (6): baseline, dir_1, dir_2, dir_3, dir_4, dir_avg
% units: fractions (loss / income)
% for avg structure
loss_RES_Case0_PerInc = zeros(size(bldg_tracts,1),6);
loss_RES_Case1_PerInc = zeros(size(bldg_tracts,1),6);

% compute loss_RES_Case0_PerValue, loss_RES_Case1_PerValue, loss_RES_Case0_1000USD, loss_RES_Case1_1000USD, loss_RES_Case0_PerInc, loss_RES_Case1_PerInc
% -

for j=1:6
    
    loss_RES_Case0_PerValue(:,j) = sum(loss_RES_Case0(:,:,j).*bldg_BldgScheme_p,2);
    loss_RES_Case1_PerValue(:,j) = sum(loss_RES_Case1(:,:,j).*bldg_BldgScheme_p,2);
    
    loss_RES_Case0_1000USD(:,j) = sum((loss_RES_Case0(:,:,j).*bldg_BldgScheme_p).*bldg_avg_1000USD,2);
    loss_RES_Case1_1000USD(:,j) = sum((loss_RES_Case1(:,:,j).*bldg_BldgScheme_p).*bldg_avg_1000USD,2);
    
    loss_RES_Case0_PerInc(:,j) = nansum(((loss_RES_Case0(:,:,j).*bldg_BldgScheme_p).*bldg_avg_1000USD)./bldg_HsngInc_avg_1000USD,2);
    loss_RES_Case1_PerInc(:,j) = nansum(((loss_RES_Case1(:,:,j).*bldg_BldgScheme_p).*bldg_avg_1000USD)./bldg_HsngInc_avg_1000USD,2);
    
end
clear j

end