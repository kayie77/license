function threshold = find_optimal_threshold(gray_image)
%*********************************************************************************
% find_optimal_threshold: Finds the optimal threshold corresponding to the supplied 
% intensity image I. If the histogram of image I is purely bimodal, the threshold 
% will take a value in the middle of the valley between the 2 modes (the logical 
% election). In other difficult cases, when the modes are overlapped, the threshold 
% will minimize the error of interpreting background pixels as objects pixels, 
% and vice versa. This algorithm is a small version of a more complex statistical 
% method, offering good results and normally using a reduced number of iterations.
%*********************************************************************************

%Image size
[rows, cols] = size(gray_image);

%Initial consideration: each corner of the image has background pixels.
%This provides an initial threshold calculated as the mean of the gray levels contained
%in the corners. The width and height of each corner is a tenth of the image's width 
%and height, respectively.
col_c = floor(cols/10);
rows_c = floor(rows/10);
corners = [gray_image(1:rows_c,1:col_c); gray_image(1:rows_c,(end-col_c+1):end);...
         gray_image((end-rows_c+1):end,1:col_c);gray_image((end-rows_c+1):end,(end-col_c+1):end)];
threshold = mean(mean(corners));

while 1
  %1. The mean of gray levels corresponding to objects in the image is calculated.
  %The actual threshold is used to determine the boundary between objects and
  %background.
  mean_obj = sum(sum((gray_image > threshold).*gray_image))/length(find(gray_image > threshold));
  %2. The same is done for the background pixels.
  mean_backgnd = sum(sum( (gray_image <= threshold).*gray_image ))/length(find(gray_image <= threshold));
  %3. A new threshold is calculated as the mean of the last results:
  new_threshold = (mean_obj + mean_backgnd)/2;
  %4. A new iteration starts only if the threshold has changed.
  if(new_threshold == threshold)
     break;   
  else
     threshold = new_threshold;
  end
end
return;