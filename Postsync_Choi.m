function [] = Postsync_Choi(data,exposure,tBinSize,iBins,PostSyncPoint)
% This plot builds 2D representation of time traces
% Exposure, sec (0.1), Length of time bin, frames (1), Input number of
% intensity bins (50), Input post-synch time point (1)
% X - Time
% Y - Intensity
% Z - Frequency
% This script plots already synchronized data. It uses synchronized traces stored in 'data' variable as input.

% Input format is different from what is normally utilized by our scripts
% Intensity(t) are placed along verical dimention of the matrix, while
% traces are stacked along horizontal axis of the matrix:
% trace1(t1) trace2(t1) trace3(t1) ...
% trace1(t2) trace2(t2) trace3(t2) ...
% trace1(t3) trace2(t3) trace3(t3) ...

% Extracting run information
[nframes,~]=size(data);

%Replace zeros with NaN. NaN values will not be graphed. If you want zeros
%to be graphed comment the bext line.
data(data==0)=NaN;
data(data==1.1)=NaN;

% Exposure during data acquisition
% exposure = input('Exposure, sec ->');

% Define length of the time bin, i.e. for how many frames do you want
% average your data. Must be more than 0. Note, that if nframes is
% not equally dividable on the tBinSize the last bin will be smaller in
% size.
% tBinSize=input('Length of time bin, frames ->');

% Calculate number of time bins
tBins = ceil(nframes/tBinSize);

% Input number of intesity bins (Number of bins along Y axis) Is should be natural number.
% iBins = input('Input number of intensity bins - >');
iBins = ceil(iBins);

% Calculate centers of intensity bins
data_lin = reshape(data, [],1);
[~, bin_centers] = hist(data_lin,iBins);

% Add one more bin at both sides of intensity axis. It makes nicer plots
bin_centers = [(2*bin_centers(1) - bin_centers(2)) bin_centers (max(bin_centers) + (bin_centers(2) - bin_centers(1)))];

% New X axis zero point. It is used only for graphing purposes
% PostSyncPoint=input('Input post-synchronization time point in FRAMES ->');

% Calculate postsync_Plot
postsync_Plot = zeros(length(bin_centers), tBins);
for n = 1:tBins
    % Failproof the last bin calculation
    if n*tBinSize > nframes
        time_slice =data(((n-1)*tBinSize+1):nframes,:);
    else
        time_slice =data(((n-1)*tBinSize+1):n*tBinSize,:);
    end
    time_slice = reshape(time_slice, [],1);
    postsync_Plot(:,n) = (hist(time_slice, bin_centers))';

    % Calculate new X axis (Preallocate for speed if necessary)
    time_axis_sync(n) = exposure*(n*tBinSize) - exposure*PostSyncPoint;
end

% Plot it
contourf(time_axis_sync, bin_centers, postsync_Plot,25,'LineStyle','none');

% Make it nice
% Load colormaps. Change colormaps that more suit your needs.
load('AndyMap','MAP');
set(gcf,'Colormap',MAP);
set (gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold')

% remove temporary variables
clear data_lin exposure n nframes tBinSize postsync_Plot MAP PostSyncPoint bin_centers time_axis_sync time_slice iBins tBins
end
    