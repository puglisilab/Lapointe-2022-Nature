%% TIRF_to_trace by Carlos Alvarado 08.04.2020
%Converts TIRF format files into .trace files usable by SPARTAN

[datafile,datapath] = uigetfile( '*.mat', 'Choose a file', 'Multiselect', 'on');
load(datafile);

[nRows, nCols] = size(ttotal);
nMols = (nCols-1)/3;
nFrames = nRows;
frameRate = ttotal(1,1)*1000;
dataNames = {'donor','acceptor','fret'};

% Create traces object, where the data will be stored.
data = TracesFret(nMols,nFrames,dataNames);
data.time = (ttotal(:,1)-ttotal(1,1))'*1000;

%% Adds in the data to the object

%Extracts the data from the TIRF array
green = zeros(nFrames, nMols);
red = zeros(nFrames, nMols);
blue = zeros(nFrames, nMols);
for i=1:nMols
    green(:,i) = ttotal(:,3*i-1);
    red(:,i) = ttotal(:,3*i);
    blue(:,i) = ttotal(:,3*i+1);
end

% Adds the data into the traces object
data.donor = green';
data.acceptor = red';

%Corrects the traces and recalculates FRET using SPARTAN functions
data = correctTraces( bgsub(data), [0,0;0,0], to_col([1,1]));
data.recalculateFret();

[fp, n, e] = fileparts(datafile);
outname = fullfile(datapath,[n '.traces']);

saveTraces(outname, data);
clear
