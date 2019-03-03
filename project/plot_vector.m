function plot_vector(vec, su, tit, yes_no, time);
load global_var.mat;
if is_killed == 1
    close all;
    return;
end;

if yes_no == 1
    subplot(2, 2, su); 
    plot(vec); 
    title(tit);
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
