%% assign_states_vbFRET_multi
% Carlos Alvarado 5.25.2021

% This script takes a ttotal file and vbFRET state assignments and produces
% a state array that can be modified using the script assign_states_blue.
% 
% To begin, load the ttotal file and the vbFRET analysis summary.

disp(' ')
threshold = input('Set a threshold -> ','s');
threshold = str2double(threshold);

%For path arrays of different dimensions
% nFrames = size(ttotal,1);
% for j = 1:size(path,2)
%     currPath = path{1,j};
%     currPath = [currPath; zeros(nFrames - size(currPath,1),1)];
%     path{1,j} = currPath;
% end
    

assignedStates = cell2mat(path);
assignedStates(assignedStates < threshold) = 0;

states = ttotal;
states(:,:) = 0;

for i = 1:size(assignedStates, 2)
    states(:, 3*i+1) = assignedStates(:,i);
end

clear data FRET labels path path2D threshold vbFRETsummary vbFRETunanalyzed
clear assignedStates i
clear currPath nFrames j