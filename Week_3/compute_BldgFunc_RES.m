function [BldgFunc_RES_Case0, BldgFunc_RES_Case1] = compute_BldgFunc_RES(StateAbbrev, RegionAbbrev)

% load BldgFunc

load('BldgFunc.mat')
BldgID = BldgFunc.BldgID;

% TerrainID==1: z0=0
% TerrainID==2: z0=0.03
% TerrainID==3: z0=0.35
% TerrainID==4: z0=0.7
% TerrainID==5: z0=1
TerrainID = BldgFunc.TerrainID;

% FuncID==1: Slight damage
% FuncID==2: Moderate damage
% FuncID==3: Severe damage
% FuncID==4: Total damage
% FuncID==5: Bldg loss (%)
% FuncID==6: Content loss (%)
% FuncID==7: Loss of use (days)
% FuncID==8: Brick/wood debris (lbs/sf)
% FuncID==9: Concrete/steel debris (lbs/sf)
% @ipekbensu: choose 5 for bldg loss
FuncID = BldgFunc.FuncID;

% columns (41): 50, 55,... 250 mph (peak gust)
% units: fractions
BldgFunc = table2array(BldgFunc(:,5:45));

% load BldgFunc_RES_BldgID
% @ipekbensu: produced in spreadsheet

load('BldgFunc_RES_BldgID.mat')

% units: ID#
% @ipekbensu: rows represent different structure
RES_Case0_CONCRETE = table2array(BldgFunc_RES_BldgID(14:16,2));
RES_Case0_MASONRY = table2array(BldgFunc_RES_BldgID(6:13,2));
RES_Case0_MH = table2array(BldgFunc_RES_BldgID(23:27,2));
RES_Case0_STEEL = table2array(BldgFunc_RES_BldgID(17:22,2));
RES_Case0_WOOD = table2array(BldgFunc_RES_BldgID(1:5,2));

% units: ID#
% @ipekbensu: rows represent different structure
RES_Case1_CONCRETE = table2array(BldgFunc_RES_BldgID(14:16,3));
RES_Case1_MASONRY = table2array(BldgFunc_RES_BldgID(6:13,3));
RES_Case1_MH = table2array(BldgFunc_RES_BldgID(23:27,3));
RES_Case1_STEEL = table2array(BldgFunc_RES_BldgID(17:22,3));
RES_Case1_WOOD = table2array(BldgFunc_RES_BldgID(1:5,3));

% load BldgScheme_(state), BldgScheme_(region)_(material)

BldgScheme = strcat('BldgScheme_',StateAbbrev,'1.mat');
load(BldgScheme);
BldgScheme = table2array(BldgScheme);

% rows (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: fractions
RES_CONCRETE_frac = str2double(BldgScheme(1:8,5))/100;
RES_MASONRY_frac = str2double(BldgScheme(1:8,4))/100;
RES_MH_frac = str2double(BldgScheme(1:8,7))/100;
RES_STEEL_frac = str2double(BldgScheme(1:8,6))/100;
RES_WOOD_frac = str2double(BldgScheme(1:8,3))/100;

BldgScheme_CONCRETE = strcat('BldgScheme_',RegionAbbrev,'_CONCRETE.mat');
load(BldgScheme_CONCRETE);
BldgScheme_CONCRETE = table2array(BldgScheme_CONCRETE);
% rows (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: fractions
% @ipekbensu: columns represent different structure
RES_CONCRETE = str2double(BldgScheme_CONCRETE(1:8,3:5))/100;

BldgScheme_MASONRY = strcat('BldgScheme_',RegionAbbrev,'_MASONRY.mat');
load(BldgScheme_MASONRY)
BldgScheme_MASONRY = table2array(BldgScheme_MASONRY);
% rows (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: fractions
% @ipekbensu: columns represent different structure
RES_MASONRY = str2double(horzcat(...
    BldgScheme_MASONRY(1:8,3:7),...
    BldgScheme_MASONRY(1:8,11:13)...
    ))/100;

BldgScheme_MH = strcat('BldgScheme_',RegionAbbrev,'_MH.mat');
load(BldgScheme_MH)
BldgScheme_MH = table2array(BldgScheme_MH);
% rows (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: fractions
% @ipekbensu: columns represent different structure
RES_MH = str2double(BldgScheme_MH(1:8,3:7))/100;

BldgScheme_STEEL = strcat('BldgScheme_',RegionAbbrev,'_STEEL.mat');
load(BldgScheme_STEEL)
BldgScheme_STEEL = table2array(BldgScheme_STEEL);
% rows (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: fractions
% @ipekbensu: columns represent different structure
RES_STEEL = str2double(BldgScheme_STEEL(1:8,3:8))/100;

BldgScheme_WOOD = strcat('BldgScheme_',RegionAbbrev,'_WOOD.mat');
load(BldgScheme_WOOD)
BldgScheme_WOOD = table2array(BldgScheme_WOOD);
% rows (8): RES1, RES2,... RES3F (Hazus bldg type)
% units: fractions
% @ipekbensu: columns represent different structure
RES_WOOD = str2double(BldgScheme_WOOD(1:8,3:7))/100;

% initialize BldgFunc_RES_Case0, BldgFunc_RES_Case1

% rows (8): RES1, RES2,... RES3F (Hazus bldg type)
% columns (41): 50, 55,... 250 mph (peak gust)
% pages (5): 0, 0.03, 0.35, 0.7, 1 m (roughness length)
% units: fractions
BldgFunc_RES_Case0 = zeros(8,41,5);
BldgFunc_RES_Case1 = zeros(8,41,5);

% compute BldgFunc_RES_Case0_(material), BldgFunc_RES_Case1_(material)

% columns (41): 50, 55,... 250 mph (peak gust)
% pages (5): 0, 0.03, 0.35, 0.7, 1 m (roughness length)
% units: fractions
% @ipekbensu: rows represent different structures
BldgFunc_RES_Case0_CONCRETE = zeros(3,41,5);
BldgFunc_RES_Case0_MASONRY = zeros(8,41,5);
BldgFunc_RES_Case0_MH = zeros(5,41,5);
BldgFunc_RES_Case0_STEEL = zeros(6,41,5);
BldgFunc_RES_Case0_WOOD = zeros(5,41,5);

% columns (41): 50, 55,... 250 mph (peak gust)
% pages (5): 0, 0.03, 0.35, 0.7, 1 m (roughness length)
% units: fractions
% @ipekbensu: rows represent different structure
BldgFunc_RES_Case1_CONCRETE = zeros(3,41,5);
BldgFunc_RES_Case1_MASONRY = zeros(8,41,5);
BldgFunc_RES_Case1_MH = zeros(5,41,5);
BldgFunc_RES_Case1_STEEL = zeros(6,41,5);
BldgFunc_RES_Case1_WOOD = zeros(5,41,5);

FuncID_ind = find(FuncID==5);
BldgID_select = BldgID(FuncID==5);
TerrainID_select = TerrainID(FuncID==5);

for k=1:5
    
    TerrainID_ind = find(TerrainID_select==k);
    BldgID_temp = BldgID_select(TerrainID_select==k);
    
    for i=1:3
        
        BldgID_temp0 = find(BldgID_temp==RES_Case0_CONCRETE(i));
        BldgFunc_RES_Case0_CONCRETE(i,:,k) = BldgFunc(FuncID_ind(TerrainID_ind(BldgID_temp0)),:);
        
        BldgID_temp1 = find(BldgID_temp==RES_Case1_CONCRETE(i));
        BldgFunc_RES_Case1_CONCRETE(i,:,k) = BldgFunc(FuncID_ind(TerrainID_ind(BldgID_temp1)),:);
        
    end
    clear i
    
    for i=1:8
        
        BldgID_temp0 = find(BldgID_temp==RES_Case0_MASONRY(i));
        BldgFunc_RES_Case0_MASONRY(i,:,k) = BldgFunc(FuncID_ind(TerrainID_ind(BldgID_temp0)),:);
        
        BldgID_temp1 = find(BldgID_temp==RES_Case1_MASONRY(i));
        BldgFunc_RES_Case1_MASONRY(i,:,k) = BldgFunc(FuncID_ind(TerrainID_ind(BldgID_temp1)),:);
        
    end
    clear i
    
    for i=1:5
        
        BldgID_temp0 = find(BldgID_temp==RES_Case0_MH(i));
        BldgFunc_RES_Case0_MH(i,:,k) = BldgFunc(FuncID_ind(TerrainID_ind(BldgID_temp0)),:);
        
        BldgID_temp1 = find(BldgID_temp==RES_Case1_MH(i));
        BldgFunc_RES_Case1_MH(i,:,k) = BldgFunc(FuncID_ind(TerrainID_ind(BldgID_temp1)),:);
        
    end
    clear i
    
    for i=1:6
        
        BldgID_temp0 = find(BldgID_temp==RES_Case0_STEEL(i));
        BldgFunc_RES_Case0_STEEL(i,:,k) = BldgFunc(FuncID_ind(TerrainID_ind(BldgID_temp0)),:);
        
        BldgID_temp1 = find(BldgID_temp==RES_Case1_STEEL(i));
        BldgFunc_RES_Case1_STEEL(i,:,k) = BldgFunc(FuncID_ind(TerrainID_ind(BldgID_temp1)),:);
        
    end
    clear i
    
    for i=1:5
        
        BldgID_temp0 = find(BldgID_temp==RES_Case0_WOOD(i));
        BldgFunc_RES_Case0_WOOD(i,:,k) = BldgFunc(FuncID_ind(TerrainID_ind(BldgID_temp0)),:);
        
        BldgID_temp1 = find(BldgID_temp==RES_Case1_WOOD(i));
        BldgFunc_RES_Case1_WOOD(i,:,k) = BldgFunc(FuncID_ind(TerrainID_ind(BldgID_temp1)),:);
        
    end
    clear i
    
end
clear k

% compute BldgFunc_RES_Case0, BldgFunc_RES_Case1

for k=1:5
    
    BldgFunc_RES_Case0(:,:,k) =...
        RES_CONCRETE_frac.*RES_CONCRETE*BldgFunc_RES_Case0_CONCRETE(:,:,k)+...
        RES_MASONRY_frac.*RES_MASONRY*BldgFunc_RES_Case0_MASONRY(:,:,k)+...
        RES_MH_frac.*RES_MH*BldgFunc_RES_Case0_MH(:,:,k)+...
        RES_STEEL_frac.*RES_STEEL*BldgFunc_RES_Case0_STEEL(:,:,k)+...
        RES_WOOD_frac.*RES_WOOD*BldgFunc_RES_Case0_WOOD(:,:,k);
    
    BldgFunc_RES_Case1(:,:,k) =...
        RES_CONCRETE_frac.*RES_CONCRETE*BldgFunc_RES_Case1_CONCRETE(:,:,k)+...
        RES_MASONRY_frac.*RES_MASONRY*BldgFunc_RES_Case1_MASONRY(:,:,k)+...
        RES_MH_frac.*RES_MH*BldgFunc_RES_Case1_MH(:,:,k)+...
        RES_STEEL_frac.*RES_STEEL*BldgFunc_RES_Case1_STEEL(:,:,k)+...
        RES_WOOD_frac.*RES_WOOD*BldgFunc_RES_Case1_WOOD(:,:,k);
    
end
clear k

% catch errors

for k=1:5
    
    BldgFunc_RES_Case0_temp = BldgFunc_RES_Case0(:,:,k);
    BldgFunc_RES_Case1_temp = BldgFunc_RES_Case1(:,:,k);
    BldgFunc_RES_Case1_temp(BldgFunc_RES_Case1_temp>BldgFunc_RES_Case0_temp) = BldgFunc_RES_Case0_temp(BldgFunc_RES_Case1_temp>BldgFunc_RES_Case0_temp);
    
    if (k>1)
        BldgFunc_RES_Case0_prev = BldgFunc_RES_Case0(:,:,k-1);
        BldgFunc_RES_Case0_temp(BldgFunc_RES_Case0_temp>BldgFunc_RES_Case0_prev) = BldgFunc_RES_Case0_prev(BldgFunc_RES_Case0_temp>BldgFunc_RES_Case0_prev);
        
        BldgFunc_RES_Case1_prev = BldgFunc_RES_Case1(:,:,k-1);
        BldgFunc_RES_Case1_temp(BldgFunc_RES_Case1_temp>BldgFunc_RES_Case1_prev) = BldgFunc_RES_Case1_prev(BldgFunc_RES_Case1_temp>BldgFunc_RES_Case1_prev);
    end
    
    BldgFunc_RES_Case0(:,:,k) = BldgFunc_RES_Case0_temp;
    BldgFunc_RES_Case1(:,:,k) = BldgFunc_RES_Case1_temp;
    
end
clear k

end
