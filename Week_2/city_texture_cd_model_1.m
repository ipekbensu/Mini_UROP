function [Cd] = city_texture_cd_model(lat,lon,area)

% assign building information
% -

X = lon;
Y = lat;
A = area;

% compute building-specific drag coefficients
% this section is work of Roxon et al. 2020
% -

var_x = 10000;
cx = abs(X)*var_x;
cy = abs(Y)*var_x;
xmax = max(cx);
xmin = min(cx);
ymax = max(cy);
ymin = min(cy);
% find average building size
% avg_area = exp(mean(log(area)));
% avg_length = sqrt(avg_area);

avg_length = nanmean(sqrt(A));
% calculate box size
alpha = avg_length*15;
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
% calculate cut off radius based on average L
rcut = avg_length*3.5;

timer = 0;
counter = length(cx);
radius=6371;
damage = ones(length(cx), 1);
P = zeros(length(cx), 1);
L = sqrt(A);
Cn = zeros(length(cx), 1);

for h = 1:size(avail, 1)
    for j = 1:size(avail, 2)
        if avail(h,j) > 0
            for k = 1:avail(h,j)
                lat1 = Y(resv(h,j,k))*pi/180;
                lon1 = X(resv(h,j,k))*pi/180;
                area_ref = A(resv(h,j,k));
                rdf_l = zeros(20, 1);
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
                                    deltaLat=lat2-lat1;
                                    deltaLon=lon2-lon1;
                                    a=sin((deltaLat)/2).^2 + cos(lat1).*cos(lat2) .* sin(deltaLon/2).^2;
                                    c=2*atan2(sqrt(a),sqrt(1-a));
                                    d1m=radius*c*1000;
                                    if d1m <= rcut
                                        nsur = nsur + 1;
                                        rdf_l(nsur,1) = A(resv(ii,jj,n));
                                    end
                                end
                           end
                       end
                   end
                end
                timer = timer + 1;
                % calculate drag coefficient
                if nsur>0
                    density_local = (1+nsur)/(pi()*rcut^2);
                    density_length = (sqrt(area_ref)+sum(sqrt(rdf_l(1:nsur))))/(nsur+1);
                    damage(timer) = nsur*(9.5*density_local*density_length)^0.5+1;
                    P(timer) = density_local;
                    L(timer) = density_length;
                    Cn(timer) = nsur;
                else
                    L(timer) = sqrt(area_ref);
                    %damage(timer) = 1;
                    damage(timer) = 2; % added
                    P(timer) = (1)/(pi()*rcut^2);
                    %L(timer) = density_length;
                    Cn(timer) = 0;
                end
                counter = counter - 1;
                disp(counter);
            end
        end
    end
end
%A = A_b;
den = P;

% output building-specific drag coefficients
% -

Cd = damage;

end