function [tract,lat,lon,area,Cd,P,L,Cn] = city_texture_cd_model(tract,Y,X,A)

% compute building-specific drag coefficients
% @ipekbensu: work of Roxon, et al.

var_x = 10000; 
cx = abs(X) * var_x;
cy = abs(Y) * var_x;

% move all coordinates by xmin and ymin, such that (xmin,ymin)->(0,0)

xmax = max(cx);
xmin = min(cx);
ymax = max(cy);
ymin = min(cy);
cx_new = cx - xmin;
cy_new = cy - ymin;

% calculate avg building size
% @ipekbensu: defines local neighborhood (a box)

avg_area = exp(nanmean(log(A)));
avg_length = sqrt(avg_area);

% calculate box size (may need experimenting with constant)
% @ipekbensu: box = avg_length*20 x avg_length*20
% @ipekbensu: alpha = avg_length*10

alpha = avg_length * 10;

% distribute buildings into 3D matrix
% @ipekbensu: avail() is #buildings at (NNx,NNy)
% @ipekbensu: resv() is building index
% @ipekbensu: use resv() to call building information

Nx = ceil((xmax - xmin) / alpha);
Ny = ceil((ymax - ymin) / alpha);
avail = zeros(Nx, Ny);
counter = length(cx_new);

for h=1:length(cx_new)
    if (rem(cx_new(h),alpha)==0) && (cx_new(h)~=0)
        NNx = floor((cx_new(h)) / alpha);
    else
        NNx = floor((cx_new(h)) / alpha) + 1;
    end 
    if (rem(cy_new(h),alpha)==0) && (cy_new(h)~=0)
        NNy = floor((cy_new(h)) / alpha);
    else
        NNy = floor((cy_new(h)) / alpha) + 1;
    end
    avail(NNx,NNy) = avail(NNx,NNy) + 1;
    resv(NNx,NNy,avail(NNx,NNy)) = h;
    counter = counter - 1;
    disp(counter);
end

% @ipekbensu: initialize tract, lat, lon, area

tract_b = zeros(length(cx), 1); % edit: not in original
lat = zeros(length(cx), 1); % edit: name changed
lon = zeros(length(cx), 1); % edit: name changed
area = nan(length(cx), 1); % edit: name changed

% @ipekbensu: initialize Cd, P, L, Cn
% @ipekbensu: Cd relates to building (b)
% @ipekbensu: P, L, Cn relate to neighbors of building (b)
% @ipekbensu: P is density (per m^2)
% @ipekbensu: L is density length (m)
% @ipekbensu: Cn is #neighbors
% @ipekbensu: timer is new building index

Cd = ones(length(cx), 1);
P = zeros(length(cx), 1);
L = nan(length(cx), 1);
Cn = nan(length(cx), 1);
radius = 6371;
counter = length(cx);
timer = 0;

for h=1:size(avail,1)
    for j=1:size(avail,2)
        if avail(h,j)>0
            for k=1:avail(h,j)
                lat1 = Y(resv(h,j,k)) * pi / 180;
                lon1 = X(resv(h,j,k)) * pi / 180;
                % reference building size
                B_ref_size = sqrt(A(resv(h,j,k)));
                B_neighbor_size = nan(1000, 1);
                dist_local = nan(1000, 1);
                nsur = 0;
                for l=-1:1
                    ii = h + l;
                    for m=-1:1
                        jj = j + m;
                        if (ii>0) && (ii<=size(avail,1)) && (jj>0) && (jj<=size(avail,2)) && (avail(ii,jj)>0)
                            for n=1:avail(ii, jj)
                                if (isequal(cx(resv(h,j,k)),cx(resv(ii,jj,n)))==0)...
                                        && (isequal(cy(resv(h,j,k)),cy(resv(ii,jj,n)))==0)
                                    % calculate distance between two GPS
                                    % points
                                    lat2 = Y(resv(ii,jj,n)) * pi / 180;
                                    lon2 = X(resv(ii,jj,n)) * pi / 180;
                                    deltaLat = lat2 - lat1;
                                    deltaLon = lon2 - lon1;
                                    a = sin((deltaLat)/2).^2+cos(lat1).*cos(lat2).* sin(deltaLon/2).^2;
                                    c = 2*atan2(sqrt(a),sqrt(1-a));
                                    % distance in meters
                                    dist = radius * c * 1000; 
                                    nsur = nsur + 1;
                                    B_neighbor_size(nsur) = sqrt(A(resv(ii,jj,n)));
                                    dist_local(nsur) = dist;      
                                end
                           end
                       end
                   end
                end
                % avg building size within distance alpha
                % @ipekbensu: defines neighbors (a circle)
                avg_length = nanmean([B_ref_size; B_neighbor_size]);
                % calculate cut-off radius based on average L
                % @ipekbensu: rcut = avg_length*3.5
                % @ipekbensu: circle = pi*rcut^2
                % @ipekbensu: var is T/F is/n't neighbor
                rcut = avg_length * 3.5;
                area_circle = pi() * rcut^2;
                var = dist_local<=rcut;
                nsur = sum(var);
                timer = timer + 1;
                % allocate X to lon and Y to lat
                tract_b(timer) = tract(resv(h,j,k)); % edit: not in original
                lat(timer) = Y(resv(h,j,k));
                lon(timer) = X(resv(h,j,k));
                area(timer) = A(resv(h,j,k));
                % calculate drag coefficient
                density_planar = ((B_ref_size^2) + sum(B_neighbor_size(var).^2)) / (area_circle);                
                if nsur>0 && density_planar<0.63
                    density_local = (1 + nsur) / (area_circle);
                    density_length = (B_ref_size + sum(B_neighbor_size(var))) / (nsur + 1);
                    Cd(timer) = nsur * (9.5 * density_local * density_length)^0.5 + 1;
                    P(timer) = density_local;
                    L(timer) = density_length;
                    Cn(timer) = nsur;
                else
                    Cd(timer) = 2; % edit: not in original
                    P(timer) = (1) / (area_circle);
                    L(timer) = B_ref_size / (1);
                    Cn(timer) = 0;
                end
                counter = counter - 1;
                disp(counter);
            end 
        end
    end
end

tract = tract_b;

end
