%Chunkonator

stackList = dir('*.trc.h5');
distance_trsh = 100;

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
file_name = 'Run';
% 
% file_name = input('Enter file name ->','s');

%Getting data
%============
disp('reading h5 file')

Traces = hdf5read(hfile.GroupHierarchy.Groups.Datasets);
holeXY = hdf5read(hinfo.GroupHierarchy.Groups(1,2).Datasets(1,7))';
% holeXY = hdf5read(hinfo.GroupHierarchy.Groups(1,2).Datasets(1,5))';
FrameRate = hinfo.GroupHierarchy.Groups(1,1).Groups(1,1).Attributes(1,2).Value;
SpikeFrame = hinfo.GroupHierarchy.Groups(1,1).Groups(1,1).Attributes(1,6).Value;
LaserOnFrame = hinfo.GroupHierarchy.Groups(1,1).Groups(1,1).Attributes(1,4).Value;
% Traces = hdf5read(hfile.GroupHierarchy.Groups.Datasets);
%IFVarianceScale = hdf5read(hinfo.GroupHierarchy.Groups(1,3).Datasets(1,6));
%OFBackgroundMean = hdf5read(hinfo.GroupHierarchy.Groups(1,3).Datasets(1,7));
%OFBackgroundVariance = hdf5read(hinfo.GroupHierarchy.Groups(1,3).Datasets(1,8));
%ReadVariance = hdf5read(hinfo.GroupHierarchy.Groups(1,3).Datasets(1,10));
%Spectra = hdf5read(hinfo.GroupHierarchy.Groups(1,3).Datasets(1,11));
%Variance = hdf5read(hinfo.GroupHierarchy.Groups(1,3).Datasets(1,14));
 
%FrameRate = hdf5read(hinfo.GroupHierarchy.Groups(1,2).Groups(1,1).Attributes(1,2));
%LaserOnFrame = hdf5read(hinfo.GroupHierarchy.Groups(1,2).Groups(1,1).Attributes(1,4));

disp('h5 file has been read')

disp('==Filtering by distance==')
% Filters the traces first by distance (pick only traces a certain distance
% from the center). Anything >~ 161 is the entire chip
distances = sqrt(sum(double(holeXY).^2, 2));

Traces(:,:, distances > distance_trsh) = [];
holeXY(distances > distance_trsh,:) = [];

%Slicing data
%============

[r c d] = size(Traces);

time = ((1:r)/FrameRate)';

n = 1;
slice_size = 3000;

newdir = 'Analysis_distance_filtered';
mkdir(newdir);

cd(newdir);


while n*slice_size < d
disp(['Processing chunk number ' num2str(n)])
    
ttotal = Traces(:, :, (n-1)*slice_size+1:slice_size*n);
ttotal = reshape(ttotal, r, [],1);
ttotal = double(ttotal);
ttotal = [time ttotal];
ttotal_xy = holeXY((n-1)*slice_size+1:n*slice_size, :);

num_string = ['000' num2str(n)];
num_string = num_string((length(num_string)-2):length(num_string));
slice_name = [file_name '_' num_string '.mat'];
slice_number = n;
%save(slice_name, 'ttotal', 'slice_number','slice_size','FrameRate','HoleXY','IFVarianceScale','LaserOnFrame','OFBackgroundMean','OFBackgroundVariance','ReadVariance','Spectra','Variance')
save(slice_name, 'ttotal','FrameRate', 'holeXY', 'ttotal_xy', 'SpikeFrame', 'LaserOnFrame', '-v7.3')
n = n + 1;
end

cd ..

clear all
disp('Chunking has been completed');