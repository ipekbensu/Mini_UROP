function [LAT,LON,AREA,Cd,P,L,Cn] = city_texture_cd_model(lat,lon,area)

% assign building information
% -

X = lon;
Y = lat;
A = area;

% compute building-specific drag coefficients
% this section is work of Roxon et al. 2020
% -

var_x = 10000; 
% tranform LON and LAT (var_x may need experimenting for optimal performance)
cx = abs(X)*var_x;
cy = abs(Y)*var_x;
xmax = max(cx);
xmin = min(cx);
ymax = max(cy);
ymin = min(cy);
% find average building size 
avg_area = exp(nanmean(log(A)));
% avg_length = nanmean(sqrt(A));
avg_length = sqrt(avg_area);
% calculate box size (may need experimenting with the constant)
alpha = avg_length*10;
% move all the coordinates by xmin and ymin, such that (xmin, ymin)->(0,0)
cx_new = cx - xmin;
cy_new = cy - ymin;

Nx = ceil((xmax-xmin)/alpha);
Ny = ceil((ymax-ymin)/alpha);
avail = zeros(Nx, Ny);
% distribute buildings into a 3D matrix
counter = length(cx_new);
for h = 1:length(cx_new)
    if (rem(cx_new(h),alpha) == 0) && (cx_new(h)~=0)
        NNx = floor((cx_new(h))/alpha);
    else
        NNx = floor((cx_new(h))/alpha)+1;
    end 
    if (rem(cy_new(h),alpha) == 0) && (cy_new(h)~=0)
        NNy = floor((cy_new(h))/alpha);
    else
        NNy = floor((cy_new(h))/alpha)+1;
    end
    avail(NNx,NNy) = avail(NNx,NNy)+1;
    resv(NNx,NNy,avail(NNx,NNy)) = h;
    counter = counter -1;
    disp(counter);
end

timer = 0;
counter = length(cx);
radius = 6371;
Cd = ones(length(cx), 1);
P = zeros(length(cx), 1);
L = nan(length(cx), 1);
Cn = nan(length(cx), 1);
LAT = zeros(length(cx), 1);
LON = zeros(length(cx), 1);
AREA = nan(length(cx), 1);
for h = 1:size(avail, 1)
    for j = 1:size(avail, 2)
        if avail(h,j) > 0
            for k = 1:avail(h,j)
                lat1 = Y(resv(h,j,k))*pi/180;
                lon1 = X(resv(h,j,k))*pi/180;
                % reference building size
                B_ref_size = sqrt(A(resv(h,j,k)));
                B_neighbor_size = nan(1000, 1);
                dist_local = nan(1000, 1);
                nsur = 0;
                for l = -1:1
                    ii = h + l;
                    for m = -1:1
                        jj = j + m;
                        if (ii>0) && (ii<=size(avail,1)) && (jj>0) && (jj<=size(avail,2)) && (avail(ii,jj)>0)
                            for n = 1:avail(ii, jj)
                                if (isequal(cx(resv(h,j,k)), cx(resv(ii,jj,n))) == 0)...
                                        && (isequal(cy(resv(h,j,k)), cy(resv(ii,jj,n))) == 0)
                                    % calculate distance between two GPS
                                    % points
                                    lat2 = Y(resv(ii,jj,n))*pi/180;
                                    lon2 = X(resv(ii,jj,n))*pi/180;
                                    deltaLat = lat2-lat1;
                                    deltaLon = lon2-lon1;
                                    a = sin((deltaLat)/2).^2 + cos(lat1).*cos(lat2) .* sin(deltaLon/2).^2;
                                    c = 2*atan2(sqrt(a),sqrt(1-a));
                                    % distance in meters
                                    dist = radius*c*1000; 
                                    nsur = nsur + 1;
                                    B_neighbor_size(nsur) = sqrt(A(resv(ii,jj,n)));
                                    dist_local(nsur) = dist;      
                                end
                           end
                       end
                   end
                end
                % avg size for buildings within distance alpha 
                avg_length = nanmean([B_ref_size; B_neighbor_size]);
                % calculate cut off radius based on average L
                rcut = avg_length*3.5;
                area_circle = pi()*rcut^2;
                var = dist_local<=rcut;
                nsur = sum(var);
                timer = timer + 1;
                % allocate X to LON and Y to LAT
                LAT(timer) = Y(resv(h,j,k));
                LON(timer) = X(resv(h,j,k));
                AREA(timer) = A(resv(h,j,k));
                % calculate drag coefficient
                density_planar = ((B_ref_size^2)+sum(B_neighbor_size(var).^2))/(area_circle);                
                if nsur>0 && density_planar < 0.63
                    density_local = (1+nsur)/(area_circle);
                    density_length = (B_ref_size+sum(B_neighbor_size(var)))/(nsur+1);
                    Cd(timer) = nsur*(9.5*density_local*density_length)^0.5+1;
                    P(timer) = density_local;
                    L(timer) = density_length;
                    Cn(timer) = nsur;
                else
                    Cd(timer) = 2; % added
                    P(timer) = (1)/(area_circle);
                    L(timer) = B_ref_size;
                    Cn(timer) = 0;
                end
                counter = counter - 1;
                disp(counter);
            end 
        end
    end
end

% output building-specific drag coefficients
% -

% LAT, LON, AREA, Cd, P, L, Cn
% LAT: latitude (deg)
% LON: longitude (deg)
% Cd: drag coefficient
% P: local density
% L: local density length
% Cd: #surrounding bldgs

end
