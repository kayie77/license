function [bw, crop] = extract_LP(pic1);
% extract_LP: Extracts the License Plate from the supplied picture. Returns
% a binary image which contains the normalized LP, and the rgb picture of
% the LP precisely cropped from the image given in parameter.

load global_var.mat;

% chosen size for the normalized LP.
XSIZE = 50;
YSIZE = 150;

% Yellow region extraction:
yellow_pic = extract_yellow_region(pic1);
display_picture(yellow_pic, debug1 + debug2, 'Yellow Regions Filter:', 3);

% Fixing the LP Region:
[x, x2, y, y2] = detect_lp_area(yellow_pic, 50);
lp_area = pic1(y:y2, x:x2, :);
display_picture(lp_area, debug1 + debug2, 'License Plate Region:', 3);

% Fixing the LP angle and rotating the ROI accordingly:
[angle, lines] = find_angle(lp_area);
if(debug1 + debug2 ~= 0)
    load global_var.mat;
    if is_killed == 1
        close all;
        return;
    end;
    subplot(2,2,3), imshow(pic1(y:y2, x:x2, :)); draw_lines(lines); title('Determining the angle of the plate using the Radon transform:');
    pause(speed);
end;
pic = imrotate(yellow_pic(y:y2, x:x2), angle, 'bilinear'); % Used to show the rotation on the GUI only..
display_picture(pic, debug1 + debug2, 'Yellow Region Rotated:', 3);

% improving the LP region on the smaller rotated region obtained before:
[small_pic, xx, xx2, yy, yy2] =  improved_lp_area(pic, angle);
display_picture(small_pic, debug2, 'Improved License Plate region:', 4);
display_picture('internal_images/black.jpg', debug2, '', 4, 0);
display_picture(small_pic, debug1 + debug2, 'Improved License Plate region:', 3, 0);
display_picture('internal_images/black.jpg', debug2, '', 2, 0);
    
% cropping the LP:
[image, RECTx, RECTy] = crop_lp(small_pic, lp_area, xx, xx2, yy, yy2, angle);
display_picture('internal_images/black.jpg', debug2, '', 2, 0);
crop = image; % output...
display_picture(image, debug2, 'LP Crop:', 4);
display_picture('internal_images/black.jpg', debug2, '', 4, 0);
display_picture(image, 1, 'LP Crop:', 3);

% Image quantization:
[grayImage, quantImage, bw] = quantizeImage(image);
display_picture(grayImage, debug1 + debug2, 'Gray Scale LP:', 3);
display_picture(quantImage, debug2, 'LP Quantisation and Equalization:', 4);
display_picture('internal_images/black.jpg', debug2, '', 4, 0);
display_picture(quantImage, debug1 + debug2, 'LP Quantisation and Equalization:', 3);
display_picture(bw, debug1 + debug2, 'Binary LP:', 3);

% Normalized LP:
bw = normalized_lp(bw, RECTx, RECTy, XSIZE, YSIZE);
display_picture(imcomplement(bw), debug2, 'Normalized LP:', 4);
display_picture('internal_images/black.jpg', debug2, '', 4, 0);
display_picture(imcomplement(bw), debug1 + debug2, 'Normalized LP:', 3);

% Adjusting the LP horizontal contours: (the vertical contours are not
% adjusted in order not to cut digits: this will be done transparently by
% the segmentation machine.
bw = normalized_lp_contour(bw, [XSIZE, YSIZE]);
display_picture(bw, debug2, 'LP Horizontal Contours Adjusted:', 4);
display_picture('internal_images/black.jpg', debug2, '', 4, 0);
display_picture(bw, debug1 + debug2, 'LP Horizontal Contours Adjusted:', 3);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% detect_lp_area
% Finds the License Plate region in a RGB picture with the supplied safety
% spacing around the plate, and returns the coordinates of the found region.
function  [x, x2, y, y2] = detect_lp_area (yellow_pic, spacing);
    LP_MIN_AREA = 2670;
    LP_MAX_RATIO = 0.67;
    LP_MIN_RATIO = 0.16;
    
    % Dilating the yellow regions:
    dilated_pic = imdilate(yellow_pic, strel('diamond', 5));
    load global_var.mat;
    display_picture(dilated_pic, debug1 + debug2, 'Yellow Region Dilated:', 3);

    % Separating the pictures into connected components:
    stat = imfeature(bwlabel(dilated_pic));
    % Selecting the license plates from the candidates in stat.
    % The chosen area is the deepest region in the frame which has the
    % following properties:
    %   area > LP_MIN_AREA
    %   LP_MIN_RATIO <= height/width <= LP_MAX_RATIO 
    %   area >= max(areas of the candidates)/3.5
    depth = -1;
    for i = 1 : length([stat.Area])
        if stat(i).BoundingBox(2) >= depth && stat(i).Area > LP_MIN_AREA && ...
           stat(i).BoundingBox(4) <= LP_MAX_RATIO*stat(i).BoundingBox(3) && ...
           stat(i).BoundingBox(4) >= (LP_MIN_RATIO)*stat(i).BoundingBox(3) && stat(i).Area >= max([stat.Area])/3.5
           depth = stat(i).BoundingBox(2);
        end;
    end;
    % finding the components which are at the depth "depth":
    r = [];
    for i = 1 : length([stat.Area])
        if stat(i).BoundingBox(2) == depth && stat(i).Area > LP_MIN_AREA && ...
           stat(i).BoundingBox(4) <= LP_MAX_RATIO*stat(i).BoundingBox(3) && ...
           stat(i).BoundingBox(4) >= (LP_MIN_RATIO)*stat(i).BoundingBox(3) && stat(i).Area >= max([stat.Area])/3.5
            r = [r stat(i).Area];
        end;
    end;
    % if we did not find any region with the above criterion, taking the
    % candidate of maximum area.
    if(length(r) == 0)
        index = (find([stat.Area] == max([stat.Area])));
    else
        % otherwise, taking the candidate with maximum area from the
        % filtered candidates:
        index = (find([stat.Area] == max(r)));
    end;
    
    % set the coordinates of the supposed license plate region:
    x = max(floor(stat(index).BoundingBox(1) - spacing), 1);
    y = max(floor(stat(index).BoundingBox(2) - spacing), 1);
    width = ceil(stat(index).BoundingBox(3) + 2*spacing);
    height = ceil(stat(index).BoundingBox(4) + 2*spacing);
    y2 = min(y + height, size(yellow_pic, 1));
    x2 = min(x + width, size(yellow_pic, 2));
        
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Returns an improved LP area running again the algorithm in the function 
% detect_lp_area with zero spacing and on the smaller rotated pictures
% given as parameter.
function [pic, x1, x2, y1, y2] =  improved_lp_area(image, angle);
[x1,x2,y1,y2] = detect_lp_area(image, 0);
pic = image(y1:y2, x1:x2);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [image, RECTx, RECTy] = crop_lp(pic, lp_area, x1, x2, y1, y2, angle);
rec = find_lp_location(pic);
image = imrotate(lp_area, angle, 'bilinear');
image = image(y1:y2, x1:x2, :);
RECTy = [rec(2), rec(2), rec(2) + rec(4), rec(2) + rec(4)];
RECTx = [rec(1), rec(1) + rec(3), rec(1) + rec(3), rec(1)];
image = imcrop(image, rec);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find_lp_location: Returns the coordinates of the LP rectangle inside the
% supplied small picture: uses "find_contours" for the sum of the lines and of the 
% columns in the picture. 
function [rec] = find_lp_location(im);
load global_var.mat;

p1 = sum(im);
plot_vector(p1, 4, 'Adjusting the LP Vertical Contours - Columns Sum Graph:', debug2);
[x1, x2] = find_contours(p1);

p2 = sum(im');
plot_vector(p2, 2, 'Adjusting the LP Horizontal Contours - Lines Sum Graph:', debug2);
[y1, y2] = find_contours(p2);

rec = [x1, y1, x2-x1, y2-y1];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find_contours: Returns the x-coordinates respectively of the first point at 
% the left and the first point at the right of the vector which is superior 
% or equal to the average of the vector. This permits to delimit the plate
% eliminating noises around it.
function [index1, index2] = find_contours(vec);
avg = mean(vec);
% left side:
for j = 1 : length(vec)
    if(vec(1,j) <= avg)
        continue;
    end;
    index1 = j - 1;
    break;
end;
% right side:
for j = length(vec) : -1 : 1
    if(vec(1,j) <= avg)
        continue;
    end;
    index2 = j + 1;
    break;
end;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pic = normalized_lp(bw, rectx, recty, xsize, ysize);
% Make a rectange matrix (by turning and stretching) of an image, 
% using points p1(x(1),y(1)) p2(x(2),y(2)) p3(x(3),y(3)) p4(x(4),y(4))
% pic - bw or gray image
% x, y - vectors of point coordinates in 'pic'
% xSize - The number of lines
% ySize - The number of columns
% assuming given     p1          p2
%                    p4          p3
x = recty - min(recty) + 1;
y = rectx - min(rectx) + 1;
for xindex = 1:1:xsize
   xxPos1 = round(x(1) + xindex / xsize * (x(4) - x(1)));
   xyPos1 = round(y(1) + xindex / xsize * (y(4) - y(1)));
   xxPos2 = round(x(2) + xindex / xsize * (x(3) - x(2)));
   xyPos2 = round(y(2) + xindex / xsize * (y(3) - y(2)));
   for yindex = 1:1:ysize
      xPos = round(xxPos1 + yindex / ysize * (xxPos2 - xxPos1));
      yPos = round(xyPos1 + yindex / ysize * (xyPos2 - xyPos1));
      pic(xindex,yindex) = bw(xPos, yPos);
   end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% normalized_lp_contour: Determines the LP horizontal contours by computing
% the sum of the lines in the supplied image, and using the function
% "horizontal_crop" with noise, minimum height and maximum height which are
% defined in this function. Then it cuts some noise from the resulting
% picture in both directions using the function "cut_bw_img". Finally, the
% image is resized to the normalized dimensions given in parameter.
function [im] = normalized_lp_contour(bwImage, dimension);
load global_var.mat;
NOISE = 20;
MIN_HEIGHT = 26;
MAX_HEIGHT = 48;
VERTICAL_NOISE = 6;
HORIZONTAL_NOISE = 1;

hist = sum((imcomplement(bwImage))');
plot_vector(hist, 4, 'Determining LP Horizontal Contours - Lines Sum Graph:', debug2);

bwImage = horizontal_crop(imcomplement(bwImage), MIN_HEIGHT, MAX_HEIGHT, NOISE);
bwImage = cut_bw_img(bwImage, HORIZONTAL_NOISE, 1);
bwImage = cut_bw_img(bwImage, VERTICAL_NOISE, 0);

im = bwImage;
im = imresize(im, dimension);

return;