function [y_image] = extract_yellow_region(image);
% extract_yellow_region: Determines the yellow regions in the picture using
% the CIE-XYZ color system, and returns a black and white picture which is
% set on the yellow regions only.

% Define the lines in CIE-XYZ space, use to determine yellow color 
lower_A = 0.87; lower_B = 0.04;
upper_A = 1.5 ; upper_B = -0.125;

% Convert 8-bit format of org_pic pixels to double format
pic = double(image)+1;
pic = pic.*1.6;

% Conversion from RGB709 to CIE-XYZ
x = ( pic(:,:,1).*0.412453 + pic(:,:,2).*0.35758 + pic(:,:,3).* 0.180423);
y = ( pic(:,:,1).*0.212671 + pic(:,:,2).*0.715160 + pic(:,:,3).* 0.072169);
z = ( pic(:,:,1).*0.019334 + pic(:,:,2).*0.119193 + pic(:,:,3).*0.950227);

sum = x + y + z;
x_bar = x./sum;
y_bar = y./sum;

% Define yellow color in CIE-XYZ space
x_sum_conds = ( ((x_bar > 0.34) & (sum > 400) & (sum < 500) ) | ((x_bar > 0.37) & (sum > 200) & (sum < 500)) );
xy_conds = ( (y_bar > 0.35) & (y_bar < 0.5) & (y_bar > (lower_A*x_bar + lower_B)) & (y_bar < (upper_A*x_bar + upper_B)) );

y_image = (x_sum_conds & xy_conds);
return;