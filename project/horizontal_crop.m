function [image] = horizontal_crop(bwImage, min_height, max_height, noise);
% horizontal_crop: Cuts the supplied binary image at its up and down
% levels. The function cuts the image until it finds a signal which is larger (in time)
% than "min_height" and less than "max_height" ignoring all the values which
% are less than "noise".

% Summinng the lines of the picture:
hist = sum(bwImage');

res = -1;
found = 0;

% iterative process until finding a "good" signal as explained before:
while res == -1
    if noise > 40
        break;
    end;
    % if the signal is high, higher than noise, we increment noise and
    % repeat the process..
    noise = noise + 1;
    s = find(hist < noise);
    
    % no signal wich satisfies the conditions found..
    if(length(s) < 1)
        break;
    end;
    % left boundary correction: (in case the first signal value is high)
    if s(1) ~= 1 && s(1) - 1 >= min_height && s(1) - 1 < max_height
        s = [1 s];
    end;
    % right boundary correction:
    if s(length(s)) ~= length(hist) && length(hist) - s(length(s)) >= min_height   && length(hist) - s(length(s)) < max_height 
        s = [s length(hist)];
    end;
    % searching for signal with wanted bandwidth: (in case the last signal value is high)
    for i = 2:length(s)
        if s(i)-s(i-1) >= min_height && s(i)-s(i-1) < max_height
            res = i-1;
            found = 1;
            break;
        end;
    end;
    if found == 1
        break;
    end;
end;

% on success, return the image at the found region.
if res ~= -1
    low = s(res);
    high = s(res+1);
    image = bwImage(low: high, :);
else
    % otherwise, return the original image
    image = bwImage;
end;

return;
