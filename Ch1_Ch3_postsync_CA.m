%% Ch1_Ch3_postsync_CA
% By Carlos Alvarado 2.5.2021

% Load up the final states file after assignment using assign_states_blue,
% as well as the ttotal file. 

% This first part of the script will extract the states in the format
% necessary for postsyncing, and convert the ttotal into RS format.


[nFrames, nCols] = size(ttotal);
nmol = (nCols - 1)/3;
ttotal_old = ttotal;
ttotal = zeros(nFrames, nmol*4+1);
ttotal(:,1) = ttotal_old(:,1);
ttotal(:,2:4:end) = ttotal_old(:,2:3:end);
ttotal(:,4:4:end) = ttotal_old(:,3:3:end);
ttotal(:,5:4:end) = ttotal_old(:,4:3:end);

states_old = states;
states = zeros(nFrames, (nCols-1)/3);
states = states_old(:,4:3:end);
states(states == 1) = 140;

% The rest is taken is taken from the initial postsync script.

time = 0.1;

states_diff = diff(states);

time_length = 20; % how much to look forward and backward
n0=1;
n1=1;
post_states_Ch1_12 = [];
post_states_Ch1_23 = [];
post_states_Ch3_12 = [];
post_states_Ch3_23 = [];

for i = 1:nmol
    %blue_state_1to2 = find(states_diff(:,3*i+1) == 1);
    state_1to2 = find(states_diff(:,i) == 140);
    state_2to3 = find(states_diff(:,i) == 30);
    temp = [];
    current_trace = ttotal(:,4*i-2:4*i+1);
    
    if ~isempty(state_1to2)
        
        % Event: Transition from state 1 to state 2, i.e. mRNA arrival
        Current_Ch1 = current_trace(state_1to2-time_length:state_1to2+time_length,2);
        Ch1_min = prctile(Current_Ch1,15);
        Ch1_max = prctile(Current_Ch1,90);
        post_states_Ch1_12((1:2*time_length+1),n0) = (Current_Ch1 - Ch1_min)./(Ch1_max - Ch1_min);
%         Ch1_left = mean(Current_Ch1(1:time_length));
%         Ch1_right = mean(Current_Ch1(time_length+2:time_length*2+1));
%         post_states_Ch1_12((1:2*time_length+1),n0) = (Current_Ch1 - Ch1_left)./(Ch1_right - Ch1_left);
        
        
        Current_Ch3 = current_trace(state_1to2-time_length:state_1to2+time_length,3);
        Ch3_min = prctile(Current_Ch3,10);
        Ch3_max = prctile(Current_Ch3,85);
        post_states_Ch3_12((1:2*time_length+1),n0) = (Current_Ch3 - Ch3_min)./(Ch3_max - Ch3_min);
       % Ch3_left = mean(Current_Ch3(1:time_length));
       % Ch3_right = mean(Current_Ch3(time_length+2:time_length*2+1));
       % post_states_Ch3_12((1:2*time_length+1),n0) = (Current_Ch3 - Ch3_left)./(Ch3_right - Ch3_left);
        n0 = n0 + 1;
    end
    
    %if ~isempty(state_2to3)
        % Event: Transition from state 2 to state 3, i.e. eIF1 dissociation
     %   Current_Ch1 = current_trace(state_2to3-time_length:state_2to3+time_length,2);
     %   Ch1_min = prctile(Current_Ch1,10);
     %   Ch1_max = prctile(Current_Ch1,80);
     %   post_states_Ch1_23((1:2*time_length+1),n0) = (Current_Ch1 - Ch1_min)./(Ch1_max - Ch1_min);
        %post_states_Ch1_23((1:2*time_length+1),n1) = (Current_Ch1 - Ch1_left)./(Ch1_right - Ch1_left);
        
        
     %   Current_Ch3 = current_trace(state_2to3-time_length:state_2to3+time_length,3);
     %   Ch3_min = prctile(Current_Ch3,10);
     %   Ch3_max = prctile(Current_Ch3,85);
     %   post_states_Ch3_23((1:2*time_length+1),n1) = (Current_Ch3 - Ch3_min)./(Ch3_max - Ch3_min);
    %    n1 = n1 + 1;
  %  end
    
    
end


% Bleed Through correction
%post_states_Ch3_12 = post_states_Ch3_12 - post_states_Ch1_12 .* .05;
%post_states_Ch4_23 = post_states_Ch4_23 - post_states_Ch2_23 .* .2;


% Post synch
% Postsync_Choi(postsync_matrix,framerate in second, horizontal bins,
% vertical bins, where 0 point is)

figure() 
subplot(2,2,1)% Postsync of transition 1 to 2 events
Postsync_Choi(post_states_Ch1_12,0.1,1,20,time_length+1)
ylim([-.5,1.5]);
subplot(2,2,3)
Postsync_Choi(post_states_Ch3_12,0.1,1,20,time_length+1)
ylim([-.5,1.5]);
    
% subplot(2,2,2)% Postsync of transition 2 to 3 events
% Postsync_Choi(post_states_Ch1_23,0.1,1,20,time_length+1)
% ylim([-.5,1.5]);
% subplot(2,2,4)
% Postsync_Choi(post_states_Ch3_23,0.1,1,20,time_length+1)
% ylim([-.5,1.5]);
    



