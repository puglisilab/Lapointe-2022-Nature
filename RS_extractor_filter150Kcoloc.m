% New RS extractor. Finds immobilized molecules for multiple channels, and
% finds common traces
% For example: can input 1, [1 3]....etc
% Extracts chunks based on distance from center of chip.
% Jin Chen 
% 04.23.2014
% =======================================================================
clear all; close all;

colors_input = input('What channel(s) to analyze (written as an array)? [1 = Cy3, 2 = Cy3.5, 3 = Cy5, 4 = Cy5.5] -> '); % Chose channel to analyze. 1 = Cy3, 2 = Cy3.5, 3 = Cy5, 4 = Cy5.5
chunk_size = 1000;

% EDIT HERE ====================
intensity_time = [300 150 5 50];
sigma_correction = [5 4 4 4];
% ==============================

intensity_time = intensity_time(colors_input);
sigma_correction = sigma_correction(colors_input);
%tic
stackList = dir('*.upd.h5');
if isempty(stackList)
    disp('No compatible files are present in this directory');
    return
end
info_name = stackList(1).name;

stackList = dir('*.trc.h5');
if isempty(stackList)
    disp('No compatible files are present in this directory');
    return
end
file_name = stackList(1).name;

hfile = hdf5info(file_name);
hinfo = hdf5info(info_name);

disp('==Reading h5 file==')

Traces = hdf5read(hfile.GroupHierarchy.Groups.Datasets); %three-D matrix, variable 1 = location, 2 = Color, 3 = Time
FrameRate = hinfo.GroupHierarchy.Groups(1,1).Groups(1,1).Attributes(1,2).Value;
try % Pre-150K and post-150K upgrade datas have holeXY in different locations
    holeXY = hdf5read(hinfo.GroupHierarchy.Groups(1,2).Datasets(1,5))';
catch exception
    holeXY = hdf5read(hinfo.GroupHierarchy.Groups(1,2).Datasets(1,7))';
end

SpikeFrame = hinfo.GroupHierarchy.Groups(1,1).Groups(1,1).Attributes(1,6).Value;
LaserOnFrame = hinfo.GroupHierarchy.Groups(1,1).Groups(1,1).Attributes(1,4).Value;
clear stackList hfile hinfo
disp(['FrameRate is ' num2str(FrameRate)])
disp(['SpikeFrame is ' num2str(SpikeFrame)])
disp(['LaserOnFrame is ' num2str(LaserOnFrame)])
disp('h5 file has been read')


[r, c, d] = size(Traces);

time = ((1:r)/FrameRate)';

clear hfile hinfo
newdir = 'Analysis_coloc';
mkdir(newdir);
cd(newdir);
% =======================================================================
for i = 1:length(colors_input)
    disp(['----------------Analyzing Channel ' num2str(colors_input(i)) '---------------------']);
    data = Traces;
    color = colors_input(i);
    color_trace = Traces(:,color,:);%

    color_trace = reshape(color_trace, r, d);
    color_trace = color_trace';
    color_trace(:, 1:30*FrameRate) = []; % remove the portion before laser turns on
    mean_color_trace = mean(color_trace, 2); % calculates the mean intensity of each trace

    background = prctile(mean_color_trace, 30); % background estimated as lowest 30% of traces

    bkg_traces = color_trace(mean_color_trace < background, :); % find the "background traces"
    bkg_traces = reshape(bkg_traces, [], 1);
    bkg_traces = double(bkg_traces);
    bkg_mean(i) = mean(bkg_traces); % initial estimate of background intensity
    bkg_std(i) = std(bkg_traces);

    clear mean_color_trace background

%=======================================================================
    disp('==Filtering by intensity==')
    data = data(:, color, :);
    
    num_molecules = zeros(1, 10);
    for iter = 1:10

        threshold = sum(sum(data > bkg_mean(i) + iter*bkg_std(i), 2), 1);
        molecules_above_threshold = find(threshold > FrameRate*intensity_time(i));
        num_molecules(iter) = size(molecules_above_threshold, 1);
    end
    
    diff_temp = diff(num_molecules);
    best_sigma(i) = find(diff_temp==min(diff_temp))+sigma_correction(i);
    figure; plot(1:10, num_molecules); title('number of molecules vs. sigma');  ylabel('Number of molecules '); xlabel('Sigma'); title(['Channel ' num2str(colors_input(i))]);

    fprintf( 'best sigma = %d\n',best_sigma(i));
    fprintf( 'mean background = %d\n',int32(bkg_mean(i)));

    threshold = sum(sum(data > bkg_mean(i) + best_sigma(i)*bkg_std(i), 2), 1);
    molecules_above_threshold = find(threshold > FrameRate*intensity_time(i));
%     data = data(:, :, molecules_above_threshold);

    molecules_picked{i} = molecules_above_threshold;
    fprintf( 'Approximation of immobilized molecules = %d\n', size(molecules_picked{i}, 1));

    clear threshold iter
    %=======================================================================

end

data_diff = diff(mean(reshape(Traces(:,1,:), r, d)'));
laser_on_frame = find(data_diff(:,:,1)==max(data_diff(:,:,1)));
laser_on_time = laser_on_frame/FrameRate;
fprintf('Laser on time = %f\n', laser_on_time);
    
if length(colors_input) == 1
    molecules_picked{2} =  molecules_picked{1};
    molecules_picked{3} =  molecules_picked{1};
    molecules_picked{4} =  molecules_picked{1};
elseif length(colors_input) == 2
    molecules_picked{3} =  molecules_picked{1};
    molecules_picked{4} =  molecules_picked{1};
elseif length(colors_input) == 3
    molecules_picked{4} =  molecules_picked{1};
end

common_molecules = intersect(molecules_picked{1}, intersect(molecules_picked{2}, intersect(molecules_picked{3}, molecules_picked{4})));
data_xy = holeXY(common_molecules, :);

fprintf( 'Approximation of common molecules = %d\n', size(common_molecules, 1));

% if filter_by_distance == 'y'
disp('==Saving files by distance==')
% Filters the traces first by distance (pick only traces a certain distance
% from the center)
distances = sqrt(sum(double(data_xy).^2, 2));
% Anything > ~150 is the entire chip
i = 0; j = 0;
coordinates = [];
while i < 161
    while length(coordinates) < chunk_size && i < 161 % Change the number to get different size chunks
        
        i = i+1;
        coordinates = find(distances < i & distances >= j);
        
    end
    j = i;
    fprintf('Extracting molecules at distance %f\n', j);
    picked = common_molecules(coordinates);
    ttotal_xy = holeXY(picked, :);
    ttotal = Traces(:, :, picked);
    ttotal = reshape(ttotal, r, [],1);
    ttotal = double(ttotal);
    ttotal = [time ttotal];
    
    slice_name = ['Run_filter_' num2str(j) '.mat'];
    save(slice_name, 'ttotal','FrameRate', 'holeXY', 'ttotal_xy', 'laser_on_time', 'SpikeFrame', 'LaserOnFrame', 'bkg_mean', 'best_sigma')
    coordinates = [];
end

     

cd ..

clear all
disp('Extraction has been completed');
