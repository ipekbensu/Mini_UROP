function [HsngScheme_count, HsngScheme_p, HsngScheme_pi] = create_HsngScheme(StateAbbrev, StateFIPS)

% load PUMS_data

PUMS_data = strcat('PSAM_h',StateFIPS,'.mat');
load(PUMS_data);
ADJINC = PUMS_data.ADJINC;
BLD = PUMS_data.BLD;
if (ischar(BLD)||isstring(BLD))
    BLD = str2double(PUMS_data.BLD);
end
HINCP = PUMS_data.HINCP;
if (ischar(HINCP)||isstring(HINCP))
    HINCP = str2double(PUMS_data.HINCP);
end

% load ACS_DP03_data, ACS_DP04_data

ACS_DP03_data = strcat('ACS_DP03_',StateFIPS,'.mat');
load(ACS_DP03_data);
tracts = table2array(ACS_DP03_data(:,2));

ACS_DP04_data = strcat('ACS_DP04_',StateFIPS,'.mat');
load(ACS_DP04_data);

% "20+ units" instead of "50+ units"
% columns (8): 1, 2,... 8 (BLD)
% units: hsng
bld = zeros(size(tracts,1),8);
bld(:,1) = table2array(ACS_DP04_data(:,56));
for j=1:7
    
    bld(:,j+1) = table2array(ACS_DP04_data(:,28+4*(j-1)));
    
end
clear j

% columns (10): 1, 2,... 10 (HINCP bin)
% units: hsng
hincp = zeros(size(tracts,1),10);
for j=1:10
    
    hincp(:,j) = table2array(ACS_DP03_data(:,208+4*(j-1)));
    
end
clear j

% load Hazus data

exposure_count = strcat(lower(StateAbbrev),'_exposure_count.mat');
load(exposure_count);

% RES1: BLD==2 OR 3
% RES2: BLD==1
% RES3A: BLD==4
% RES3B: BLD==5
% RES3C: BLD==6
% RES3D: BLD==7
% RES3E: BLD==8 (use Hazus exposure to adjust)
% RES3F: BLD==8 (use Hazus exposure to adjust)
% columns (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: bldg
exposure_count_Hazus = table2array(exposure_count(:,2:9));
tracts_Hazus = exposure_count.CensusTract;
[tracts_exposure_count] = NN(StateAbbrev, tracts, tracts_Hazus, exposure_count_Hazus);

% initialize HsngScheme

% RES1: BLD==2 OR 3
% RES2: BLD==1
% RES3A: BLD==4
% RES3B: BLD==5
% RES3C: BLD==6
% RES3D: BLD==7
% RES3E: BLD==8 (use Hazus exposure to adjust)
% RES3F: BLD==8 (use Hazus exposure to adjust)
% rows (8): RES1, RES2,... RES3F (Hazus bldg type)
% columns (10): 1, 2,... 10 (HINCP bin)
% units: hsng or fractions
% pages represent different census tracts
HsngScheme_count = zeros(8,10,size(tracts,1));
HsngScheme_p = zeros(8,10,size(tracts,1));
HsngScheme_pi = zeros(8,10,size(tracts,1));

% adjust and filter PUMS data

HINCP = HINCP.*ADJINC/1000000;

BLD = BLD(~isnan(HINCP));
HINCP = HINCP(~isnan(HINCP));

HINCP = HINCP(~isnan(BLD));
BLD = BLD(~isnan(BLD));

HINCP = HINCP(BLD~=10);
BLD = BLD(BLD~=10);

% estimate PUMS_count, PUMS_p, PUMS_pi

% rows (8): 1, 2,... 8 (BLD)
% columns (10): 1, 2,... 10 (HINCP bin)
% units: hsng or fractions
[PUMS_count] = PUMS_estimate_count(BLD, HINCP);
[PUMS_p] = PUMS_estimate_p(PUMS_count); % used in IPF
[PUMS_pi] = PUMS_estimate_pi(PUMS_p);

% estimate IPF_count, IPF_p, IPF_pi, HsngScheme_count, HsngScheme_p, HsngScheme_pi

% "20+ units" instead of "50+ units"
% rows (8): 1, 2,... 8 (BLD)
% columns (10): 1, 2,... 10 (HINCP bin)
% units: hsng or fractions
% pages represent different census tracts
IPF_p = zeros(8,10,size(tracts,1));
IPF_pi = zeros(8,10,size(tracts,1));
IPF_count = zeros(8,10,size(tracts,1));

for k=1:size(tracts,1)
    
    tract = k;
    [IPF_p(:,:,k)] = PUMS_run_IPF(PUMS_p, tract, bld, hincp);
    [IPF_pi(:,:,k)] = PUMS_estimate_pi(IPF_p(:,:,k));
    IPF_count(:,:,k) = IPF_p(:,:,k)*sum(hincp(k,:));
    
    [exposure] = Bldg2Hsng(tracts_exposure_count(k,:),0);
    HsngScheme_count(1,:,k) = IPF_count(2,:,k)+IPF_count(3,:,k);
    HsngScheme_count(2,:,k) = IPF_count(1,:,k);
    HsngScheme_count(3:6,:,k) = IPF_count(4:7,:,k);
    HsngScheme_count(7,:,k) = IPF_count(8,:,k)*exposure(7)/sum(exposure);
    HsngScheme_count(8,:,k) = IPF_count(8,:,k)*exposure(8)/sum(exposure);
    if (isnan(HsngScheme_count(7,:,k)))
        HsngScheme_count(7,:,k) = 0;
    end
    if (isnan(HsngScheme_count(8,:,k)))
        HsngScheme_count(8,:,k) = 0;
    end
    HsngScheme_p(:,:,k) = PUMS_estimate_p(HsngScheme_count(:,:,k));
    HsngScheme_pi(:,:,k) = PUMS_estimate_pi(HsngScheme_p(:,:,k));
    
end
clear k

end
