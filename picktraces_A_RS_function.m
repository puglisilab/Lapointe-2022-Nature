function [ttotal seq] = picktraces_A_RS_function(settings, colors)
% This function is a generalization of the pick traces scripts to allow for
% picking data sets with an arbitrary number of colors. The color displayed
% for each color can be defined as an RGB vector and smoothing via the
% filtfilt matlab function can be applied as needed. The function can be
% interrupted if needed and it will store its progress as a temp file.
% Picking can be resumed from that temp file. The function will return the
% ttotal matrix of the picked set and the (seq)uence of picked molecules
% from the original set. The ttotal and seq variables can be saved as the
% original filename with a '-p' or just 'p' appended if that option is set.
% The function takes only one parameter: settings, which is a structure.
% 
% While picking traces, this function shows 2 windows. Both have the x-axis
% set by the observation time in the data set. The top has the y-axis set
% to the maximum intensity for the given trace and the bottom has its
% y-axis fixed to 5000. The title over the top window shows the following
% numbers from left to right: 1) the current molecule number of the
% displayed trace 2) number of remaining molecules after the current
% molecule 3) number of molecules currently picked from this set
% 
% The key presses recognized in this function are the same as the original
% picktraces scripts:
% 1) ',' ('<')
% go back to the last molecule and unselect it if originally picked
% 2) '.' ('>')
% go to the next molecule without selecting the current molecule
% 3) 'y'
% select the current molecule and go to the next molecule
% 4) 'q'
% quit/interrupt the current session and save the current session progress
% to a temp file ([settings.filename '_picktraces_temp'])
% 
%The parameters from settings used are: 
% 1) filename
% the filename of the file containing the ttotal matrix
% 2) colors
% the RGB row vectors for all the color packed into a matrix starting from
% the first color as row 1
% 3) filterFlag
% set to 1 if smoothing by filtfilt is desired, otherwise set to 0
% 4) filterFrames
% number of frames to smooth, only active if filterFlag is set to 1
% 5) resumeFlag
% set to 1 if resuming an interrupted session, set to 0 if starting a new
% session
% 6) saveFlag
% set to 1 if a saved file of ttotal and seq is desired, set to 0 otherwise
% 7) filenameResume
% the filename of the resume file, only used if resumeFlag is set to 1

% just in case that there is an error or someone does something
% unexpected...
try

% loads the resume file and jump directly to the pick trace loop if
% resumeFlag is set
if settings.resumeFlag
    load(settings.filenameResume);

    
% goes through the preporcessing needed for a new session
else
    % loads the color information and the ttotal file
    colorsMatrixSize = size(settings.colors);
    numColors = colorsMatrixSize(1);
    colorRGB = settings.colors;
    load(settings.filename);
    
    % extract time vector and dataset size from the ttotal matrix
    data = ttotal;
    clear ttotal;
    t = data(:,1);
    data(:,1) = [];
    [nframes,ncol] = size(data);
    nmol = (1:ncol/numColors);
    molecules = max(nmol);
    
    % store the traces in a rank 3 array, separated by color
    colorTraces = zeros(nframes,molecules,numColors);
    for k=1:numColors
        colorTraces(:,:,k) = data(:,nmol * numColors - numColors + k);
    end
    clear data;
    
    colorTraces_unfilt = colorTraces;
    
    % filter the traces is the filterFlag is set
    if settings.filterFlag
        for k=1:numColors
            colorTraces(:,:,k) = filtfilt(ones(1,settings.filterFrames)',settings.filterFrames',colorTraces(:,:,k));
        end
    end
    
    % initiate seq (the sequence of molecules picked) and the picktrace
    % loop counter
    seq = zeros(1,molecules);
    c = 1;
end



% all of the actual picking is done in this while loop
while c <= molecules
    
    % find the max and min intensities in each color to set the y-axis, the
    % max is always at or above 1000 and the min is always at or below 0;
    % this is to prevent an error from traces that have all 0's (like that
    % from a check pattern well of the ZMW
    maxx = max([max(max(colorTraces(:,c,:))) 50]);
    minn = min([min(min(colorTraces(:,c,:))) 0]);
    maxx2 = max([max(max(colorTraces_unfilt(:,c,:))) 50]);
    minn2 = min([min(min(colorTraces_unfilt(:,c,:))) 0]);
    scrsz = get(0,'ScreenSize');
    figure(1);
    ax(1) = subplot(2,1,1);
    ax(2) = subplot(2,1,2);
    currentColorTraces_plot =  reshape(colorTraces(:,c,colors),[],length(colors));    
    currentColorTraces =  reshape(colorTraces_unfilt(:,c,:),[],numColors);
    

    
    % plotting 2 windows
    ph1 = plot(ax(1),t,currentColorTraces_plot);
    ph2 = plot(ax(2),t,currentColorTraces);

    % plots where you are on the chip
    th = 0:pi/50:2*pi;
    xunit = 161 * cos(th);
    yunit = 161 * sin(th);
    figure(2); set(gcf, 'Position', [1600 100 200 200]);
%     set(hFig2, 'Position', [scsrz(3)*0.7 scsrz(4)*0.1 scrsz(3)*0.2 scrsz(4)*0.25]); % sets the figure window size and position.
    plot(xunit, yunit, 'b', ttotal_xy(c,1), ttotal_xy(c,2), 'ro');
    
    % set the title, axes, and trace colors for the top window
    set(ax(1),'Xcolor',[0.3 0.3 0.3],'YColor',[0.3 0.3 0.3],'Color',[0 0 0]);
    title(ax(1),['molecule ' num2str(c) '; ' num2str(ncol/numColors-c) ' remaining; ' num2str(length(find(seq>0))) ' picked; (' num2str(ttotal_xy(c,1)) ','  num2str(ttotal_xy(c,2)) ')' ], 'FontSize',14, 'FontName', 'Arial')
    xlim(ax(1),[0 t(end)])
%     xlim(ax(1),[0 300])
    ylabel(ax(1),'Fluorescence Intensity','fontsize',14, 'FontName', 'Arial')
    ylim(ax(1),[30 maxx])

    for k=1:length(colors)  
        set(ph1(k),'Color',colorRGB(colors(k),:));
    end
    grid(ax(1),'on');
    
    % set the title, axes, and trace colors for the bottom window
    set(ax(2),'Xcolor',[0.3 0.3 0.3],'YColor',[0.3 0.3 0.3],'Color',[0 0 0]);
    xlabel(ax(2),'Time (s)','fontsize',14, 'FontName', 'Arial')
    ylabel(ax(2),'Fluorescence Intensity','fontsize',14, 'FontName', 'Arial')
    ylim(ax(2),[20 maxx])
    grid(ax(2),'on');
    for k=1:numColors
        set(ph2(k),'Color',colorRGB(k,:));
    end
    

    
    % link the x-axes of the 2 plot
    linkaxes(ax(1:2),'x')
    
    % wait until a key or mouse button is pressed
    check = waitforbuttonpress;
    
    % do nothing if a mouse key is pressed and then waits for another
    % button press to resume the loop (to allow for using the zoome tools,
    % for example)
    if check == 0
        beep
        check = waitforbuttonpress;
    end
    
    % select the current trace and goto the next trace if 'y' is pressed,
    % will end the function if going past the last trace
    if strcmpi(get(gcf,'CurrentCharacter'),'y') == 1
        seq(c) = c;
        c = c + 1;
        
    % goto the next trace without selecting the current one if '.' ('>') is
    % pressed, will end the function if going past the last trace
    elseif strcmpi(get(gcf,'CurrentCharacter'),'.') == 1
        c = c + 1;
        
    % go back to the previous trace and unselect it if ',' ('<') is
    % pressed, beep if already at the first trace
    elseif strcmpi(get(gcf,'CurrentCharacter'),',') == 1
        if c == 1
            beep
        else
            c = c - 1;
            seq(c) = 0;
        end
    
    % interrupt the current session and save the resume file if 'q' is
    % pressed
    elseif strcmpi(get(gcf,'CurrentCharacter'),'q') == 1
        close(gcf); close(gcf);
        settings.filename = strrep(settings.filename,'.mat','');
        save([settings.filename '_picktraces_temp'], '-v7.3');
        return
    
    % beep if no valid key is pressed
    else
        beep
        check = waitforbuttonpress;
    end
end

% post processing to reconstruct ttotal from the vector of picked traces
seq(seq==0) = [];
close(gcf);
close(gcf);
ttotal = zeros(nframes,numColors*length(seq));
ttotal_unfilt = zeros(nframes,numColors*length(seq));
seqlenVec = 1:length(seq);
for k=1:numColors
    ttotal(:,seqlenVec*numColors-numColors+k) = colorTraces(:,seq,k);
end
for k=1:numColors
    ttotal_unfilt(:,seqlenVec*numColors-numColors+k) = colorTraces_unfilt(:,seq,k);
end
ttotal = [t ttotal];
ttotal_unfilt = [t ttotal_unfilt];
ttotal_xy = ttotal_xy(seq,:);

% save ttotal and seq to a file if saveFlag is set, naming convention the
% same as Colin's scripts
if settings.saveFlag
    settings.filename = strrep(settings.filename,'.mat','');
    if isempty(strfind(settings.filename,'-')) == 1
        settings.filename = [settings.filename '-'];
    end
    settings.filename = [settings.filename 'p'];
    save(settings.filename,'ttotal','seq', 'ttotal_unfilt', 'holeXY', 'ttotal_xy', 'FrameRate', '-v7.3');
    return
end

return

% dump all current variables of the function to an error file    
catch errorObj
    save('picktraces_A_v2_function_error', '-v7.3')
end
end
