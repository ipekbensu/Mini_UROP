function [output] = Bldg2Hsng(input, type)

% define #minimum, #maximum
% columns (8): RES1, RES2,... RES3F (Hazus bldg type)
% unit: hsng/bldg

minimum = [1, 1, 2, 3, 5, 10, 20, 50];
maximum = [1, 1, 2, 4, 9, 19, 49, 100];

% compute #average
% columns (8): RES1, RES2,... RES3F (Hazus bldg type)
% unit: hsng/bldg

average = (minimum+maximum)/2;

% convert #bldg to #hsng

if (type==0)
    % convert #bldg to #hsng
    output = input.*average;
else
    % convert #hsng to #bldg
    output = input./average;
end

end
