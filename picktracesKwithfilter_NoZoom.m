% Magdalena 02/15/06
%KOLINOS EDITED

% This program reads ttotal matrix from mm000.mat file
% The first column contains time points in seconds
% The following triplets of columns contain information
% for all molecules (green, red, fret)
% The program displays all traces and allows you
% to pick the ones you like

% First load the mat file containing raw traces

disp(' ')
filename = input('Enter name of mat file you want to load -> ','s');
load(filename)

data = ttotal;
clear ttotal

filterCHECK=input('Smooth data?\n(y/n):','s');
if filterCHECK=='y'
    filterNUM=input('Smooth over how many frames?\n-->');
end

% Define the first column as time points in seconds
% Then remove the first column from data matrix

t = data(:,1);
data(:,1) = [];

% Figure out number of rows and columns in data matrix
% Number of frames = number of rows
% Number of molecules = number of columns/3

[nframes,ncol] = size(data);
nmol = (1:ncol/3);

% From the first time point given in seconds
% we can determine exposure time in millisecons

exp = t(1,1)*1000;

% Give user information on number of molecules,
% exposure time, number of frames and movie duration

disp(' ')
disp(['This data set contains ' num2str(ncol/3) ' molecules'])
disp(['The exposure time was ' num2str(exp) ' ms'])
disp(['The movie was recorded over ' num2str(nframes) ' frames'])
disp(['It took ' num2str(exp*nframes/1000) ' seconds'])
disp(' ')

if filterCHECK=='y'
    data=filtfilt(ones(1,filterNUM),filterNUM,data);
end


% Now define the first column as green intensity
% Define the second column as red intensity
% Define the third column as uncorrected fret

green = data(:,nmol*3-2);
red = data(:,nmol*3-1);
fret = data(:,nmol*3);


% Now create three empty matrices (greenpk, redpk, fretpk)
% For each molecule you pick, its green intensity, red intensity
% and fret values will be added as a new column to the relevant matrix

greenpk = zeros(nframes,0);
redpk = zeros(nframes,0);
fretpk = zeros(nframes,0);
subset = 0;

% Graph fluorescence intensity and fret for each molecule
% First we are going to define y axis range on the intensity graph
% by finding the maximum and minimum green and red intensities



% if minn >= 0
%     a = 0;
% else
%     a = 1;
% end
% 
% ymin = -50;
% ymax = 500;

% Just for graphing purposes, we will subtract an approximate baseline
% from both dye intensities and calculate fretb value that is more
% representative of real fret value than raw uncorrected fret
% Approximate baseline values must be determined experimentally

% appgb = 8000;
% apprb = 7500;

% for x = 1:nframes
%     for y = 1:ncol/3
%         if (green(x,y)-appgb) + (red(x,y)-apprb) == 0
%             fretb(x,y) = nan;
%         else
%             fretb(x,y) = (red(x,y)-apprb)./((green(x,y)-appgb) + (red(x,y)-apprb));
%         end
%     end
% end

% Now allow user to toggle back and forth and accept or reject traces
% Parameter seq allows us to monitor if trace was accepted or
% rejected, so when we go back to previous trace we can redefine
% the subset of picked traces and their intensity matrices

seq = zeros(1,ncol/3);

figure;
set(gcf, 'Position',[1 57 1920 1049]);

c = 1;
while c <= ncol/3
    
    maxg = max(max(green(:,c)));
    ming = min(min(green(:,c)));
    maxr = max(max(red(:,c)));
    minr = min(min(red(:,c)));

    maxx = max([maxg maxr]);
    minn = min([ming minr]);
    
    ax(1) = subplot(2,1,1);
    plot(ax(1),t,green(:,c),'g',t,red(:,c),'r')
    
    title(['molecule ' num2str(c) ' --> ' num2str(ncol/3-c) ' remaining'])
    xlim([0 exp*nframes/1000])
    ylabel('fluorescence intensity')
    ylim([minn maxx])
    grid on
    %zoom on
    ax(2) = subplot(2,1,2);
    plot(ax(2),t,fret(:,c),'b')
    xlabel('time (s)')
    xlim([0 exp*nframes/1000])
    ylabel('FRET')
    ylim([-0.2 1.2])
    grid on
    %zoom on
    linkaxes(ax(1:2),'x')
    
    
    
%     answ = input('accept trace (y), reject trace (enter) or back to previous trace (p) -> ','s');
%     while strcmp(answ,'y') == 0 & strcmp(answ,'p') == 0 & isempty(answ) == 0
%         beep
%         answ = input('you must enter valid answer (y or p or enter) -> ','s');
%     end
    
check = waitforbuttonpress;

if check == 0
    beep
    check = waitforbuttonpress;
end

    if strcmp(get(gcf,'CurrentCharacter'),'y') == 1
%         disp('trace accepted')
%         disp(' ')
        greenpk = [greenpk green(:,c)];
        redpk = [redpk red(:,c)];
        fretpk = [fretpk fret(:,c)];
        subset = subset + 1;
        seq(c) = 1;
        seqc = seq(c);
        c = c + 1;
    elseif strcmp(get(gcf,'CurrentCharacter'),'.') == 1
        %         disp('trace rejected')
        %         disp(' ')
        
        ax(1) = subplot(2,1,1);
        plot(ax(1),t,green(:,c),'k',t,red(:,c),'k')
        %set(gcf, 'Position',[-70 277 1190 400])
        title(['molecule ' num2str(c) ' --> ' num2str(ncol/3-c) ' remaining'])
        xlim([0 exp*nframes/1000])
        ylabel('fluorescence intensity')
        ylim([minn maxx])
        grid on
        %zoom on
        ax(2) = subplot(2,1,2);
        plot(ax(2),t,fret(:,c),'k')
        xlabel('time (s)')
        xlim([0 exp*nframes/1000])
        ylabel('FRET')
        ylim([-0.2 1.2])
        grid on
        %zoom on
        linkaxes(ax(1:2),'x')
        
        pause(0.1);
        
        seq(c) = 2;
        seqc = seq(c);
        c = c + 1;
    elseif strcmp(get(gcf,'CurrentCharacter'),',') == 1
        if c == 1
            beep
%             disp('this is the first trace')
%             disp(' ')
        else
%             disp('back to previous trace')
%             disp(' ')
            if seqc == 1
                greenpk(:,subset) = [];
                redpk(:,subset) = [];
                fretpk(:,subset) = [];
                subset = subset - 1;
            end
            if c == 2
                seqc = nan;
            else
                seqc = seq(c-2);
            end
            c = c - 1;
        end
        
    else
        beep
        check = waitforbuttonpress;
    end
end

disp(['You have picked ' num2str(subset) ' out of ' num2str(ncol/3) ' molecules'])
disp(' ')
close;

% Now redefine nmol and create big matrix with green intensity,
% red intensity and uncorrected fret values

nmol = (1:subset);
totalpk = zeros(nframes,3*subset);
totalpk(:,nmol*3-2) = greenpk(:,nmol);
totalpk(:,nmol*3-1) = redpk(:,nmol);
totalpk(:,nmol*3) = fretpk(:,nmol);

% Finally define matrix ttotal and save it as a mat file
% Then clear all variables

ttotal = [t totalpk];

filename = strrep(filename,'.mat','');
if isempty(findstr(filename,'-')) == 1
    filename = [filename '-'];
end

filename = [filename 'p'];
save(filename,'ttotal')
clear