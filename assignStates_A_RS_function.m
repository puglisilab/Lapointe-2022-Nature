function [HMM] = assignStates_A_RS_function(settings,HMM)

% Change log:
% v1
% First iteration with all functions from the previous 4 color assignHMM
% scripts: (s)et level to assign state, x-(z)ooming
%
% v2
% Added (y)-zooming, changed (x)-zooming key assignment
% pressing x or y during zooming now unzooms that asix
%
% This function is a generalization of the correct HMM and assign states
% scripts to deal with data sets with an arbitrary number of colors. The
% color displayed for each color can be defined as an RGB vector and
% smoothing via the filtfilt matlab function can be applied as needed. The
% initial states of the molecules can be all off by default or can be
% dropped-in from another program/script. The function can be interrupted
% if needed and it will store its progress as a temp file. Assignment can
% be resumed from that temp file. The function will return the state array
% (HMM, a rank 3 array, the first 2 dimensions follow the standard (frame,
% molecule) format of the hmm assignment scripts and the 3rd dimension is
% the color). The HMM array can be saved as the original filename with a
% '_state_assign_HMM' appended if that option is set. The function takes
% only one parameter: settings, which is a structure.
%
% While assigning traces, this function shows 2 windows. Both have the
% x-axis set by the observation time in the data set. The top window has
% the actual trace and the bottom has the assigned state matrix displayed.
% The title over the top window shows the following numbers from left to
% right: 1) the current molecule number of the displayed trace 2) number of
% remaining molecules after the current molecule 3) the color number
% current assigning
%
% The key presses recognized in this function are derived from the original
% correctHMM scripts: 1) ',' ('<') go back to the last molecule and
% unselect it if originally picked 2) '.' ('>') go to the next molecule
% without selecting the current molecule 3) 'q' quit/interrupt the current
% session and save the current session progress to a temp file
% ([settings.filename '_state_assign_temp']) 4) mouse click starts
% correcting states; takes 2 mouse clicks to specify the x-axis values of
% the region to correct followed by a keypress from a number key to assign
% that region to the state identified by that number 5) 'z' takes 2 mouse
% clicks to specify the x-axis values of the region to zoom into; functions
% normally after zooming 6) 'u' unzoom back to the full x-axis of the trace
% 7) 's' assign state by setting a threshold; takes 3 mouse clicks followed
% by a number pressed on the keyboard; the first 2 clicks specify the
% region to correct and the last specifies the y-axis threshold; the number
% key pressed assigns the state identified by that number to the portion of
% the trace in the correction region that is above the high-pass threshold
%
%The parameters from settings used are:
% 1) filename the filename of the file containing the ttotal matrix 2)
% colors the RGB row vectors for all the color packed into a matrix
% starting from the first color as row 1 3) filterFlag set to 1 if
% smoothing by filtfilt is desired, otherwise set to 0 4) filterFrames
% number of frames to smooth, only active if filterFlag is set to 1 5)
% resumeFlag set to 1 if resuming an interrupted session, set to 0 if
% starting a new session 6) saveFlag set to 1 if a saved file of ttotal and
% seq is desired, set to 0 otherwise 7) filenameResume the filename of the
% resume file, only used if resumeFlag is set to 1 8) statesInt a matrix
% containing the number of states to assign to each color (all color must
% currently have the same number of states in this script) and the
% intensity of those states. The format is: [ color_1_state_1,
% color_1_state_2, ..., color_1_state_last;
%   color_2_state_1, color_2_state_2, ..., color_2_state_last; . . .
%   color_last_state_1, color_last_state_2, ..., color_last_state_last]
% The intensities are primarily used to display the state assignment array
% in the bottom plot during state assignment 9) hmmFlag set to 1 if
% dropping in a preassigned HMM array from outside, otherwise set to 0 and
% this function will generate an all-zero HMM matrix to begin with

% just in case that there is an error or someone does something
% unexpected...
try
    
    % loads the resume file and jump directly to the assign states loop if
    % resumeFlag is set
    if settings.resumeFlag
        load(settings.filenameResume);
        
        % goes through the preporcessing needed for a new session
    else
        % loads the color information, the ttotal file, and the state
        % assignment information
        colorsMatrixSize = size(settings.colors);
        numColors = colorsMatrixSize(1);
        colorRGB = settings.colors;
        statesMatrixSize = size(settings.statesInt);
        numStates = statesMatrixSize(2);
        colorIntensity = settings.statesInt;
        load(settings.filename)
        data = ttotal;
        data_unfilt = ttotal_unfilt; %UNFILTERED DATA
        clear ttotal;
        
        % extract time vector and dataset size from the ttotal matrix
        t = data(:,1);
        data(:,1) = [];
        data_unfilt(:,1) = [];
        [nframes,ncol] = size(data);
        nmol = (1:ncol/numColors);
        molecules = max(nmol);
        
        % store the traces in a rank 3 array, separated by color
        colorTraces = zeros(nframes,molecules,numColors);
        for k=1:numColors
            colorTraces(:,:,k) = data(:,nmol * numColors - numColors + k);
        end
        clear data;
        
        colorTraces_unfilt = zeros(nframes,molecules,numColors);
        for k=1:numColors
            colorTraces_unfilt(:,:,k) = data_unfilt(:,nmol * numColors - numColors + k);
        end
        clear data_unfilt;
        
        % generate an all-zero HMM array if hmmFlag is 0
        if ~settings.hmmFlag
            HMM = zeros(nframes,molecules,numColors);
            for k=1:numColors
                HMM(:,:,k) = colorIntensity(k,1);
            end
        end
        
        % filter the traces is the filterFlag is set
        if settings.filterFlag
            for k=1:numColors
                colorTraces(:,:,k) = filtfilt(ones(1,settings.filterFrames)',settings.filterFrames',colorTraces(:,:,k));
            end
        end
        
        % initiate the assign state loop
        n=1;
        zoomingX = 0;
        zoomingY = 0;
        zoomZoneX = [min(t) max(t)];
        zoomZoneY = [30 100]; % CHANGE HERE
        currentColor = 1;
    end
    
    % all of the actual assignment is done in this while loop
    while n <= molecules
        
        % find the max and min intensities in each color to set the y-axis, the
        % max is always at or above 1000 and the min is always at or below 0;
        % this is to prevent an error from traces that have all 0's (like that
        % from a check pattern well of the ZMW
        maxx = max([max(max(colorTraces(:,n,:))) 50]);
%         minn = min([min(min(colorTraces(:,n,:))) 40]);
        minn = 30;
%         maxx2 = max([max(max(colorTraces_unfilt(:,n,:))) 50]);
%         minn2 = min([min(min(colorTraces_unfilt(:,n,:))) 0]);
        ax(1) = subplot(2,1,1);
        ax(2) = subplot(2,1,2);
        currentColorTraces =  reshape(colorTraces(:,n,:),[], numColors); % <---- CHANGE
%         currentColorTraces_unfilt =  reshape(colorTraces_unfilt(:,n,1:2),[],2); % <--- CHANGE
        currentHMM = reshape(HMM(:,n,:),[], numColors); %<-- CHANGE
        
        % plotting 2 windows
        ph1 = plot(ax(1),t,currentColorTraces);
        ph2 = plot(ax(2),t,currentHMM, 'LineWidth',2);
        
        % set the title, axes, and trace colors for the top window
        set(ax(1),'Xcolor',[0.3 0.3 0.3],'YColor',[0.3 0.3 0.3],'Color',[0.8 0.8 0.8]);
        %title(ax(1),['molecule ' num2str(n) '; ' num2str(ncol/numColors-n) ' remaining; ' num2str(length(find(seq>0))) ' picked; (' num2str(ttotal_xy(n,1)) ','  num2str(ttotal_xy(n,2)) '); '  ' current color ' num2str(currentColor)], 'FontSize',14, 'FontName', 'Arial')
        title(ax(1),['molecule ' num2str(n) '; ' num2str(ncol/numColors-n) ' remaining; ' num2str(length(find(seq>0))) ' picked; (' num2str(ttotal_xy(n,1)) ','  num2str(ttotal_xy(n,2)) '); '  ' current color ' num2str(currentColor)], 'FontSize',14, 'FontName', 'Arial')
        xlim(ax(1),[t(1) t(end)])
        ylabel(ax(1),'Fluorescence Intensity','FontSize', 14, 'FontName', 'Arial')
        ylim(ax(1),[minn maxx])
        for k=1:numColors %<-- CHANGE HERE!
            set(ph1(k),'Color',colorRGB(k,:));
        end
        grid(ax(1),'on');
        
        % set the title, axes, and HMM colors for the bottom window
        set(ax(2),'Xcolor',[0.3 0.3 0.3],'YColor',[0.3 0.3 0.3],'Color',[0.8 0.8 0.8]);
        xlabel(ax(2),'time (s)', 'FontSize', 14, 'FontName', 'Arial')
        ylabel(ax(2),'Fluorescence Intensity','FontSize', 14, 'FontName', 'Arial')
        ylim(ax(2),[-1 210])
        grid(ax(2),'on');
%         for k=1:2 %<-- CHANGE HERE
%             set(ph2(k+2),'Color',colorRGB(k,:));
%         end
        for k=1:numColors
            set(ph2(numColors + 1 - k),'Color',colorRGB(numColors + 1 - k,:));  % To make the green trace on top
        end
%         set(ph2(2),'Color',[1 1 0]);
        % link the x-axes of the 2 plot
        linkaxes(ax(1:2),'x')
        
        % if not zooming, display the complete length in time of the current
        % trace; if zooming, only plot the zoomed region
        if ~zoomingX
            xlim(ax(1),[min(t) max(t)])
        else
            if zoomZoneX(1) < zoomZoneX(2)
                xlim(ax(1),[zoomZoneX(1) zoomZoneX(2)]);
            elseif zoomZoneX(1) == zoomZoneX(2)
                
                xlim(ax(1),[zoomZoneX(1) zoomZoneX(2)+t(1)]);
            else
                xlim(ax(1),[zoomZoneX(2) zoomZoneX(1)]);
            end
        end
        
        if ~zoomingY
            ylim(ax(1),[minn maxx])
        else
            if zoomZoneY(1) < zoomZoneY(2)
                ylim(ax(1),[zoomZoneY(1) zoomZoneY(2)]);
                ylim(ax(2),[zoomZoneY(1) zoomZoneY(2)]);
            elseif zoomZoneY(1) == zoomZoneY(2)
                ylim(ax(1),[zoomZoneY(1) zoomZoneY(2)+1]);
                ylim(ax(2),[zoomZoneY(1) zoomZoneY(2)+1]);
            else
                ylim(ax(1),[zoomZoneY(2) zoomZoneY(1)]);
                ylim(ax(2),[zoomZoneY(2) zoomZoneY(1)]);
            end
        end
        
        % wait until a key or mouse button is pressed
        check1 = waitforbuttonpress;
        
        % a mouse click initiates the HMM correction sequence
        if check1 == 0
            correction = ginput(2);
            check2 = waitforbuttonpress;
            newstate = str2num(get(gcf,'CurrentCharacter'));
            
            % checks that the keyboard input is within parameter
            while isempty(newstate) || newstate == 0 | newstate > numStates
                beep
                check2 = waitforbuttonpress;
                newstate = str2num(get(gcf,'CurrentCharacter'));
            end
            
            % round the start and end times to the closest frame numbers
            start = round(correction(1)/t(1));
            if start < 1
                start = 1;
            end
            finish = round(correction(2)/t(1));
            if finish > length(t)
                finish = length(t);
            end
            
            % write the corrected state to the HMM array
            HMM(start:finish,n,currentColor) = colorIntensity(currentColor,newstate);
            
            % goto the next trace if 'r' ('r') is pressed, will end the function if
            % going past the last trace
        elseif strcmpi(get(gcf,'CurrentCharacter'),'r') == 1
            n = n+1;
            zoomingX = 0;
            zoomingY = 0;
            
            % go back to the previous trace if 'e' ('e') is pressed, beep if
            % already at the first trace
        elseif strcmpi(get(gcf,'CurrentCharacter'),'e') == 1 && n>1
            n = n-1;
            zoomingX = 0;
            zoomingY = 0;
            
            % select the color for state assignment if 'c' is pressed
        elseif strcmpi(get(gcf,'CurrentCharacter'),'c') == 1
            check2 = waitforbuttonpress;
            newColor = str2num(get(gcf,'CurrentCharacter'));
            
            % check that keybord input in within parameter
            while isempty(newColor) || newColor == 0 | newColor > 4 %<--- CHANGE
                beep
                check2 = waitforbuttonpress;
                newColor = str2num(get(gcf,'CurrentCharacter'));
            end
            currentColor = newColor;
            
            % start x-zooming mode if 'x' is pressed
        elseif strcmpi(get(gcf,'CurrentCharacter'),'x') == 1
            if ~zoomingX
                zoomZoneX = ginput(2);
                zoomingX = 1;
            else
                zoomingX = 0;
            end
            
            % start y-zooming mode if 'y' is pressed
        elseif strcmpi(get(gcf,'CurrentCharacter'),'y') == 1
            if ~zoomingY
                [~, zoomZoneY] = ginput(2);
                zoomingY = 1;
            else
                zoomingY = 0;
            end
            
            % end zooming mode if 'u' is pressed
        elseif strcmpi(get(gcf,'CurrentCharacter'),'u') == 1
            zoomingX = 0;
            zoomingY = 0;
            
            % enter state assignment by threshold if 't' is pressed
        elseif strcmpi(get(gcf,'CurrentCharacter'),'t') == 1
            [setLevelX,setLevelY] = ginput(3);
            check2 = waitforbuttonpress;
            newstate = str2num(get(gcf,'CurrentCharacter'));
            while isempty(newstate) || newstate == 0 | newstate > numStates
                beep
                check2 = waitforbuttonpress;
                newstate = str2num(get(gcf,'CurrentCharacter'));
            end
            
            % find the frames that need to be changed
            curTrace = colorTraces(:,n,currentColor);
            changedIndices = curTrace >= setLevelY(3);
            
            % round to the closest frame numbers
            start = round(setLevelX(1)/t(1));
            if start < 1
                start = 1;
            end
            finish = round(setLevelX(2)/t(1));
            if finish > length(t)
                finish = length(t);
            end
            
            % use a mask to change only the regions above the threshold
            onMask = zeros(length(t),1);
            onMask(start:finish) = 1;
            changedIndices = changedIndices & onMask == 1;
            
            % writes the change to the HMM array
            HMM(changedIndices,n,currentColor) = colorIntensity(currentColor,newstate);
            
            % interrupt the current session and save the resume file if 'q' is
            % pressed
        elseif strcmpi(get(gcf,'CurrentCharacter'),'q') == 1
            close(gcf);
            settings.filename = strrep(settings.filename,'.mat','');
            save([settings.filename '_state_assign_temp']);
            return
            
            % beep if no valid key is pressed
        else
            beep
        end
    end
    
    close(gcf);
    
    % save HMM to file if the saveFlag is set
    if settings.saveFlag
        settings.filename = strrep(settings.filename,'.mat','');
        save([settings.filename '_state_assign_HMM'],'HMM');
        return
    end
    
    return
    
% dump all current variables of the function to an error file    
catch errorObj
    save assignStates_A_v1_function_error;
end
end