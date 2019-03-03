function display_picture(pic, debug, title_str, frame_num, time);
load global_var.mat;

if is_killed == 1
    close all;
    return;
end;
   
if debug == 0
    return;
end;

if nargin < 2
    imshow(pic);
elseif nargin < 3
    imshow(pic); title(title_str);
else
    subplot(2,2, frame_num); imshow(pic); title(title_str);
end;

if nargin == 5
    tt = time;
else
    tt = speed;
end;
if tt ~= 0
    pause(tt);
end;

return;

