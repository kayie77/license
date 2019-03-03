function run()
% run: The driver program for the demo. Defines the GUI, and when the button 
% "Start" is pressed, loads the images in the directory "images" and 
% runs the program for each one of them.

% remove NN warnings:
NNTWARN OFF

% GUI settings:
gcf = figure(1); % defining the frame:
scrsz = get(0,'ScreenSize'); % the size of the screen.
set(gcf, 'Position', [0 0 scrsz(3) scrsz(4)/1.1]);
set(gcf,'color','white');

load 'global_var.mat'; % global variable...
% resetting "is_killed" to false, (if it was true).
update_global_var(speed, debug1, debug2, 0);

% presentation pictures shown on the 4 subplots of the GUI:
display_picture('internal_images/title.jpg',1,'',1, 1);
display_picture('internal_images/title2.jpg',1,'',2, 1);
display_picture('internal_images/title3.jpg',1,'',3, 1);
display_picture('internal_images/title4.jpg',1,'',4, 2);

% Defining the GUI componenets located at the left side of the frame from 
% which the demo settings may be set, and the simulation can be started,
% paused or stopped:
h_label = uicontrol(gcf,...
    'Style','text',...
    'Units','characters',...
    'FontWeight', 'bold', ...
    'Position',[3 35 25 1],...
    'String','Simulation Settings:');
h_popup_label = uicontrol(gcf,...
    'Style','text',...
    'Units','characters',...
    'Position',[5 32 20 2],...
    'String','Level of Details:');
h_details_popup = uicontrol(gcf,...
    'Style','popupmenu',...
    'Units','characters',...
    'Position',[5 31 20 2],...
    'BackgroundColor','white',...
    'String',{'Very Detailed','Detailed','Straight'});
h_popup_label = uicontrol(gcf,...
    'Style','text',...
    'Units','characters',...
    'Position',[5 28 20 2],...
    'String','Demo Speed:');
h_speed_popup = uicontrol(gcf,...
    'Style','popupmenu',...
    'Units','characters',...
    'Position',[5 27 20 2],...
    'BackgroundColor','white',...
    'String',{'1','2','3','4','5','6','7','8','9','10'});
h_update_button = uicontrol(gcf,...
    'Style','pushbutton',...
    'Units','characters',...
    'Position',[5 25 20 2],...
    'String','Update',...
    'Callback',{@update_button_callback, h_details_popup, h_speed_popup});
h_pause_button = uicontrol(gcf,...
    'Style','pushbutton',...
    'Units','characters',...
    'Position',[5 13 20 2],...
    'String','Pause',...
    'Visible', 'off',...
    'Callback',{@pause_button_callback});
 % The button which permits the simulation to be started.
h_start_button = uicontrol(gcf,...
    'Style','pushbutton',...
    'Units','characters',...
    'Position',[5 13 20 2],...
    'String','Start',...
    'Callback',{@start_button_callback, h_pause_button});
h_exit_button = uicontrol(gcf,...
    'Style','pushbutton',...
    'Units','characters',...
    'Position',[5 10 20 2],...
    'String','Exit',...
    'Callback',{@exit_button_callback});

% Showing on the GUI the level of details which is set upon the demo
% start-up.
if debug2 == 1
    set(h_details_popup, 'Value', 1); 
elseif debug1 == 1
    set(h_details_popup, 'Value', 2); 
else
    set(h_details_popup, 'Value', 3); 
end;

% Showing on the GUI the speed of the demo which is set upon
% start-up.
set(h_speed_popup, 'Value', 10 - speed); 

% relocating the frame...
set(gcf, 'Position', [0 0 scrsz(3) scrsz(4)/1.05]);
        
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback for update button
function  update_button_callback(obj, eventdata, h_details_popup, h_speed_popup)
% Get chosen level of details:
selected_details_level = get(h_details_popup, 'Value');
% Get chosen speed:
selected_speed = get(h_speed_popup, 'Value');

% Perform appropriate command based on what user selected
load 'global_var.mat';
switch selected_details_level
case 1 % user selected Very detailed
    debug2 = 1;
    debug1 = 0;
case 2 % user selected Detailed
    debug2 = 0;
    debug1 = 1;
case 3 % user selected Straight
    debug2 = 0;
    debug1 = 0;
end
update_global_var(10-selected_speed, debug1, debug2, is_killed);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback for Pause button: (Pauses the demo)
function  pause_button_callback(obj, eventdata)
text = get(obj, 'String');
% If the simulation were running:
if strcmp(text, 'Pause') == 1
    set(obj, 'String', 'Resume');
    % pause it:
    waitforbuttonpress;
    set(obj, 'String', 'Pause');
else
    % otherwise, "resume" it:
    set(obj, 'String', 'Pause');
end;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback for Exit button: (Pauses the demo)
function  exit_button_callback(obj, eventdata)
load global_var.mat;

% if stand alone application:
if isruntime
    close all
    quit force
else
    % close only the application: (not Matlab)
    % by setting is_killed to true...
    update_global_var(speed, debug1, debug2, 1);
    close all;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback for Start button: (Starts the demo)
function  start_button_callback(obj, eventdata, h_pause_button)
% Removes the button from the GUI
set(obj, 'Visible', 'off');
% Make the "Pause" buttn visible:
set(h_pause_button, 'Visible', 'on');
% Run the simulation for the 45 images located in the "/images" directory:
for i = 1:45
    % Checks that the simulation has not been stopped, and if yes
    % return immediately:
    load 'global_var.mat';
    if is_killed == 1
        close all;
        return;
    end;
    
    % run the simulation ofr the current image:
    im = imread(strcat('images/im',strcat(num2str(i),'.jpg')));
    go(im, num2str(i));
end;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the changes made by the user on the GUI which are given as parameters:
function update_global_var(speed1, debug11, debug22, is_killed1);
% save values given as parameters:
load 'global_var.mat';
debug1 = debug11;
debug2 = debug22;
speed = speed1;
is_killed = is_killed1;
save global_var.mat;
load 'global_var.mat';
% clear unwanted values found in this function workspace:
clear speed1;
clear debug11;
clear debug22;
clear is_killed1;
save global_var.mat;
return;