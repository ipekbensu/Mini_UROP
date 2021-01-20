function [output] = Bldg2Hsng(input, type)
% type==0: convert #bldg to #hsng
% type==1: convert #hsng to #bldg

% define #minimum, #maximum
% -

% columns (8): RES1, RES2,... RES3F (HAZUS bldg type)
% unit: hsng/bldg
minimum = [1, 1, 2, 3, 5, 10, 20, 50];
maximum = [1, 1, 2, 4, 9, 19, 49, 100];

% compute #average
% -

% columns (8): RES1, RES2,... RES3F (HAZUS bldg type)
% unit: hsng/bldg
average = (minimum+maximum)/2;

% convert #bldg to #hsng
% -

if (type==0)
    output = input.*average;
else
    output = input./average;
end

end
