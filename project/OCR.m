function number = OCR(bw, seg, net)

load global_var.mat;

XSIZE = 50;
YSIZE = 150;
MIN_HEIGHT = 30;
MAX_HEIGHT = 50;
HORIZONTAL_NOISE = 5;
VERTICAL_NOISE = 2;
DIGIT_DIMENSION_PIC = [45 15];
DIGIT_DIMENSION_NET = [20 10];

number = [];

for i = 1:size(seg, 1)
    pic = bw(:, seg(i,1) : seg(i,2), :);
    display_picture(pic, debug1 + debug2, 'Digit:', 2);
    
    pic = dilate_picture(pic);
    display_picture(pic, debug1 + debug2, 'Dilated Digit:', 2);

    hist = sum(pic');
    plot_vector(hist, 4, 'Determining Digit Horizontal Contours - Lines Sum Graph:', debug2);

    pic = adjust_contours(pic, MIN_HEIGHT, MAX_HEIGHT, HORIZONTAL_NOISE, VERTICAL_NOISE);
    display_picture(pic, debug1 + debug2, 'Contours Adjusted Digit:', 2);
    display_picture('internal_images/black.jpg', debug2, '', 4, 0);

    pic = imresize(pic, DIGIT_DIMENSION_PIC);
    display_picture(pic, debug1 + debug2, 'Resized Digit:', 2);

    
    rec = recognize(net, pic, DIGIT_DIMENSION_NET);
    if rec == -1
        return;
    end;
    number = strcat(number, rec);
    if (debug1 + debug2) ~= 0
        load global_var.mat;
        if is_killed == 1
            close all;
            number = 0;
            return;
        end;
        subplot(2,2,2);
        text(30,30,['LP digit = ', rec],...
             'HorizontalAlignment','center',... 
             'BackgroundColor',[.7 .9 .7]);
         pause(speed);
     end;
 end;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pic = adjust_contours(pic, min_height, max_height, horiz_noise, vertical_noise);
pic = cut_bw_img(pic, horiz_noise, 0);
pic = horizontal_crop(pic, min_height, max_height, 0);
pic = cut_bw_img(pic, vertical_noise, 1);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pic] = dilate_picture(pic);
% dilate_picture: Dilates the supplied picture using a line structuring
% element whose width is 2 pixels.
pic = imdilate(pic, strel('line', 2, 0));
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function digit = recognize(net, im, digit_dimension_net)
% recognize: Recognizes the digit in the supplied digit picture, after 
% resizing it to the supplied dimensions which are the dimension of the 
% digit in the neural network.
load global_var.mat;
if is_killed == 1
    close all;
    digit = -1;
    return;
end;

im = imresize(im, digit_dimension_net, 'nearest');
vec = double(im2col(im, size(im), 'distinct'));

rslt = sim(net, vec);
[Y,I] = max(rslt);
num = mod(I(1), 10);
digit = char('0' + num);
return;