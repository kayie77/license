function go(image, imName)
% go: Runs the LPR Software for the picture which is given as parameter. 

cleanScreen;
display_picture(image, 1, strcat('Captured Frame:  ', imName), 1);
pause(0);

% Checks that the simulation has not been stopped, and if yes
% return immediately:
load global_var.mat;
if is_killed == 1
    close all;
    return;
end;

% Extract the LP from the picture:
[bw, crop] = extract_LP(image);

% Runs the Charaters Segmentation machine:
seg = character_segmentation(bw);

% Runs the OCR machine on the Crop LP using the characters segmentations found below:"
load net.mat;
number = OCR(bw, seg, net);

% Display the Crop LP:
display_picture(crop, 1, '', 3, 0);
display_picture('internal_images/black.jpg', 1, '', 2, 0);
display_picture('internal_images/black.jpg', 1, '', 4, 0);

% Display the found LP Number:
text(370, 290, ['LP Number = ', number],...
     'HorizontalAlignment','center',... 
     'BackgroundColor',[.9 .9 .9]);

% let user have a look:
pause(speed);
cleanScreen;
return;