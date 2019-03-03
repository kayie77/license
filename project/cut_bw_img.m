function [image] = cut_bw_img(bwImage, noise_amp, direction);
% cut_bw_img: Cuts from the supplied pictures all the corners until a
% signal with intensity greater than "moise_amp" is encountered. If
% direction is zero the corners correspond to the left and right sides of
% the image, otherwise, they correspond to the up and down corners.

% summing colums/lines:
if direction == 0
    hist = sum(bwImage);
else
    hist = sum(bwImage');
end;

left = 1;
right = 1;

% treating one side:
for i = 1 : length(hist)
    if(hist(i) > noise_amp)
        left = i;
        break;
    end;
end;

% treating the other side:
for j = length(hist) : -1 : 1
    if(hist(j) > noise_amp)
        right = j;
        break;
    end;
end;

% returning the result:
if direction == 0
    image = bwImage(:, left : right);
else
    image = bwImage(left : right, :);
end;
    
return;
