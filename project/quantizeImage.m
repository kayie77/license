function [grayImage, quantImage, bw] = quantizeImage(rgbImage);
% quantizeImage: Quantizes the supplied gray image, and returns the
% quantized gray image, and a black and white image determined using an
% adaptive threshold.

grayImage = rgb2gray(rgbImage);

% First adjust the image intensity values: 
% calculates the histogram of the image and determines the adjustment limits 
% low_in and high_in then, maps the values in the supplied intensity image 
% to new values such that values between low_in and high_in map to values between 0 and 1, 
% values below low_in map to 0, and those above high_in map to 1.
quantImage = imadjust(grayImage, stretchlim(grayImage), [0 1]);

% Adaptive threshold Black and White image:
quantImage = im2double(quantImage);
op = find_optimal_threshold(quantImage);
bw = im2bw(quantImage, op);

return;