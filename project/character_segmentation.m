function [seg] = character_segmentation(bw);
% character_segmentation: Returns the digit segments in the supplied binary image.
% The function uses the "segment" function, keeping only the seven
% segments in the result with largest area, and in case less than seven
% segments were found, it attempts to recall the function, making the
% separation between the already found segments clearer (by cleaning the 
% bits which are there.
DIGIT_WIDTH = 18;
MIN_AREA = 250;

load global_var.mat;
plot_vector(sum(bw), 4, 'Character Segmentation - Columns Sum Graph:', debug2);

seg = segment(bw, DIGIT_WIDTH, MIN_AREA);
[x y] = size(seg);

% If we got less than 7 digits, we try to make the sepration between them
% clearer by cleaning the bits between them, and we call the "segment"
% function again:
if x < 7
    for i = 1 : x
        bw(:,seg(i,2))=0;
    end;
    seg = segment(bw, DIGIT_WIDTH, MIN_AREA);
end;

% Keeping in the results the seven segments with the largest area:
area = [];
for i = 1 : x
    pic = bw(:, seg(i,1) : seg(i,2), :);
    area(i) = bwarea(pic);
end;

area1 = sort(area);
seg = seg';

for j = 1:(length(area1)-7)
    i = find(area == area1(j));
    len = length(area);
    if i == 1
        area = [area(2:len)];
        seg = [seg(:,2:len)];
    elseif i == len
        area = [area(1:i-1)];
        seg = [seg(:,1:i-1)];
    else
        area = [area(1:i-1) area(i+1:len)];
        seg = [seg(:,1:i-1) seg(:,i+1:len)];
    end;
end;

seg = seg';

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [segmentation] = segment(im, digit_width, min_area);
% segment: Segment the pictures in digit images according to the variable
% "digit_width" and returns a matrix containing the two bounds of the each
% digit segment. The function keeps in the result only segment whose
% "rectangular" areas is more than "min_area".

segmentation = [];
% Summing the colums of the pic:
t = sum(im);
% Getting the segments in the pic:
seg = clean(find_valleys(t, 2, 1, digit_width), 3);

% Keeping in the result only the segments whose rectangular areas is more than min_area:
j = 1;
for i = 1 : (length(seg) - 1)
    band_width = seg(i+1) - seg(i);
    maxi = max(t(1, seg(i):seg(i+1)));
    if(maxi * band_width > min_area)
        segmentation(j, 1) = seg(i);
        segmentation(j, 2) = seg(i+1);
        j = j + 1;
    end;
end;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [s] = find_valleys(t, val, offset, digit_width);
% find_valleys: Uses the method named peak-to-valleyin order to segment the 
% pictures in digit images getting the two bounds of the each digit segment
% according to the statistical parameter digit_width = 18.
% The function is recursive; it uses the vector of the sums of the columns 
% in the LP binary image supplied in the parameter "t". 
% The function passes over the graph corresponding to this vector from left 
% to right, bottom-up, incrementing at each recursive step the height that 
% is examined on the graph (val). It checks the bandwidth of the first part 
% of the signal: if it is greater than DIGIT_WIDTH, the function is 
% recursively called after incrementing the height which is examined on 
% the graph, (val). Otherwise, if the bandwidth is good, the two bounds of 
% the signal with this bandwidth are taken as a digit segment, and the 
% function is recursively called for the part of the image which is at 
% the right side of the digit segment just found. This is done until the
% whole width of the picture has been passed over.

% Determining the points which are inferior to the examined hieght:
s = find(t < val);

% If no more than one point is found, incrementing val and recursively calling the function again.
if(length(s) < 2)
    s = find_valleys(t, val + 1, offset, digit_width);
    return;
end;

% If no point is found terminating:
if length(s) == 0
    return;
end;

% Arranging the boundaries, so that if we have a big value at the beginning
% or the end of the picture the algorithm still works: in this case, the
% algorithm includes also those points.
if((t(1,1) >= val) && s(1) ~= 1)
    s = [1 s];
end;
if((t(1, length(t)) >= val) && s(length(s)) ~= length(t))
    s = [s length(t)];
end;

% Updating the real coordinates according to offset:
s = add(s, offset - 1);
% Cleaning points which are very close each other keeping only one of them.
s = clean(s, 3);

% While there is a bad segment in "s", (starting from the left side):
while bad_segm(s, digit_width) == 1
    for i = 1: (length(s) - 1)
        if (s(i + 1) - s(i)) > digit_width
            % The subvector which does not correspond to a valid digit
            % segemnt:
            sub_vec = t(1, s(i) - offset + 1 : s(i+1) - offset + 1);
            % Recursively, separating this bad segment in two or more valid
            % digit segments:
            s = [s(1 : i) find_valleys(sub_vec, val + 1, s(i), digit_width) s(i+1 : length(s))];
        end;
    end;
end;
   
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bool] = bad_segm(s, digit_width);
% bad_segm: Returns true (1) iff there is a bad digit segment in s, namely,
% two points that ar distant one from the other by more than "digit_width".
if length(s) == 0
    bool = 0;
    return;
end;
    
tmp = s(1);
bool = 0;
for i = 2 : length(s)
    if(s(i) - tmp) > digit_width
        bool = 1;
        return;
    end;
    tmp = s(i);
end;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [t] = clean(s, val);
% clean: Cleans form the vector s all the poins which are distant the one
% from the other by less than "val" keeping only one of them.
t = [];
len = length(s);
i = 2;
j = 1;
while i <= len
    while(s(i) - s(i-1) <= val)
        i = i + 1;
        if(i > len)
            return;
        end;
    end;
    if j == 1 || (s(i-1) - t(j-1)) > val
        t(j) = s(i-1);
        j = j + 1;
    end;
    t(j) = s(i);
    j = j + 1;
    i = i + 1;
end;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [t] = add(s, val); 
% add: Adds "val" to each one of the entries in the vector s and returns the new vector.
len = length(s);
t = [];
for i = 1:len
    t(i) = s(i) + val;
end;
return;