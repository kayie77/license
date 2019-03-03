function [angle, lines] = find_angle(rgb_image);
% find_angle: Determines the angle of the supplied picture: it is supposed
% that the picture contains parallel lines or at least one large line. 
% The function uses the Radon transform in order to find lines on the picture, 
% and returns the angle of the most visible line, and a matrix representation of 
% the largest lines on the picture. 
gray_image = rgb2gray(rgb_image);
theta = (0:179)';
% Determining the lines on the picture using the Radon Transform:
[R, xp] = radon(edge(gray_image), theta);

% Determining the largest lines on the picture:
i = find(R > (max(R(:)) - 25));
[foo, ind] = sort(-R(i));
[y, x] = ind2sub(size(R), i);
t = -theta(x)*pi/180;
r = xp(y);

% Forming a matrix representation of the found lines:
lines = [cos(t) sin(t) -r];
cx = size(gray_image, 2)/2 - 1;
cy = size(gray_image, 1)/2 - 1;
lines(:,3) = lines(:,3) - lines(:,1)*cx - lines(:,2)*cy;

% Finding the angle of the most visible line on the picture:
[r,c] = find(R == max(R(:)));
thetap = theta(c(1));
angle = 90 - thetap;
return;
