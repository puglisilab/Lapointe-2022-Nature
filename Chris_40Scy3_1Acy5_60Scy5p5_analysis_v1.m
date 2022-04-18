[r c d] = size(HMM);
%t = ttotal(:,1);

%States codes
% Cy3 [10 200]
% Cy5 [10 150 125 100]
    %off, 40S-coarrive, subsequent binding event w/o 60S, successful 60S
% Cy5p5 [10 175]
%Analyses kinetics of 40S, 1A, 60S events that lead to 40S-60S FRET

Df = input('Enter desired Delivery Frame -> ');
Exposure = input('Enter the Exposure Time (1/framerate) -> ');

I_want_fast_analysis =1;

if I_want_fast_analysis == 1
    
    Cy3_uncorrected_arrivaltimes = zeros(1, c);
    Cy3_uncorrected_departuretimes = zeros(1,c);
    
    Cy5_uncorrected_arrivaltimes = zeros(1, c);
    Cy5_uncorrected_departuretimes = zeros(1,c);
    
    Cy5p5_uncorrected_arrivaltimes = zeros(1, c);
    Cy5p5_uncorrected_departuretimes = zeros(1,c);
    
    
    for n = 1:c
        if mean(HMM(:,n,1))>10 && mean(HMM(:,n,3))>10 &&mean(HMM(:,n,4))>10
            
            temp_1 = find(HMM(:, n, 1) == 200, 1, 'first');
            if isempty(temp_1) == 0
                Cy3_uncorrected_arrivaltimes(n) = find(HMM(:, n, 1) == 200, 1, 'first');
            end
            
            temp_2 = find(HMM(:, n, 1) == 200, 1, 'last');
            if isempty(temp_2) == 0
                Cy3_uncorrected_departuretimes(n) = find(HMM(:, n, 1) == 200, 1, 'last');
            end
            
            temp_5 = find(HMM(:, n, 3) == 80, 1, 'first');
            if isempty(temp_5) == 0
                Cy5_uncorrected_arrivaltimes(n) = find(HMM(:, n, 3) == 80, 1, 'first');
            end
            
            temp_6 = find(HMM(:, n, 3) == 80, 1, 'last');
            if isempty(temp_6) == 0
                Cy5_uncorrected_departuretimes(n) = find(HMM(:, n, 3) == 80, 1, 'last');
            end
            
            temp_3 = find(HMM(:, n, 4) == 175, 1, 'first');
            if isempty(temp_3) == 0
                Cy5p5_uncorrected_arrivaltimes(n) = find(HMM(:, n, 4) == 175, 1, 'first');
            end
            
            temp_4 = find(HMM(:, n, 4) == 175, 1, 'last');
            if isempty(temp_4) == 0
                Cy5p5_uncorrected_departuretimes(n) = find(HMM(:, n, 4) == 175, 1, 'last');
            end
        end
    end
%     i_zero = find(Cy3_uncorrected_arrivaltimes == 0)
    Cy3_uncorrected_arrivaltimes(Cy3_uncorrected_arrivaltimes == 0) = [];
    Cy3_uncorrected_departuretimes(Cy3_uncorrected_departuretimes == 0) = [];
   
    Cy5_uncorrected_arrivaltimes(Cy5_uncorrected_arrivaltimes == 0) = [];
    Cy5_uncorrected_departuretimes(Cy5_uncorrected_departuretimes == 0) = [];
    
    Cy5p5_uncorrected_arrivaltimes(Cy5p5_uncorrected_arrivaltimes == 0) = [];
    Cy5p5_uncorrected_departuretimes(Cy5p5_uncorrected_departuretimes == 0) = [];
    
    %Converting everything to time
    Cy3_uncorrected_arrivaltimes = (Cy3_uncorrected_arrivaltimes - Df)*Exposure;
    Cy3_uncorrected_departuretimes = (Cy3_uncorrected_departuretimes - Df)*Exposure;
        
    Cy5_uncorrected_arrivaltimes = (Cy5_uncorrected_arrivaltimes - Df)*Exposure;
    Cy5_uncorrected_departuretimes = (Cy5_uncorrected_departuretimes - Df)*Exposure;
    
    Cy5p5_uncorrected_arrivaltimes = (Cy5p5_uncorrected_arrivaltimes - Df)*Exposure;
    Cy5p5_uncorrected_departuretimes = (Cy5p5_uncorrected_departuretimes - Df)*Exposure;
    
    Cy3_lifetimes = Cy3_uncorrected_departuretimes - Cy3_uncorrected_arrivaltimes;
    Cy5_total_lifetimes = Cy5_uncorrected_departuretimes - Cy5_uncorrected_arrivaltimes;
    Cy5p5_lifetimes = Cy5p5_uncorrected_departuretimes - Cy5p5_uncorrected_arrivaltimes;
    
    % calculate association times relative to another binding event
        %eIF1A association time relative to 40S recruitment
        Cy5_corrected_arrivaltimes  = Cy5_uncorrected_arrivaltimes - Cy3_uncorrected_arrivaltimes;
        Cy5_corrected_arrivaltimes(Cy5_corrected_arrivaltimes < 0.2) = [0];
        
        %60S subunit association time, eIF1A or 40S corrected
        Cy5p5_1Acorrected_arrivaltimes  = Cy5p5_uncorrected_arrivaltimes - Cy5_uncorrected_arrivaltimes;
        Cy5p5_1Acorrected_arrivaltimes(Cy5p5_1Acorrected_arrivaltimes < 0) = [0];
        Cy5p5_40Scorrected_arrivaltimes  = Cy5p5_uncorrected_arrivaltimes - Cy3_uncorrected_arrivaltimes;
        
        %80S-eIF5B complex lifetime
        eIF1A_80S_Lifetime = Cy5_uncorrected_departuretimes - Cy5p5_uncorrected_arrivaltimes;
        eIF1A_80S_Lifetime(eIF1A_80S_Lifetime < 0) =[0];
        eIF1A_80S_Lifetime = round(eIF1A_80S_Lifetime,4,'significant');
        eIF1A_40S_lifetime = Cy5_total_lifetimes - eIF1A_80S_Lifetime;
        eIF1A_40S_lifetime(eIF1A_40S_lifetime < 0) = [0];
        eIF1A_40S_lifetime = round(eIF1A_40S_lifetime,4,'significant');
    
    %Cy3_corrected_arrivaltimes(Cy3_corrected_arrivaltimes < Exposure) = [];
    
    %clear n mols t temp* Cy3_un* %Cy5_un*
   
   %40S calculations
   [P_lifetime_Cy3 X_lifetime_Cy3] = cdfcalc(Cy3_lifetimes);
    P_lifetime_Cy3(1) = []; 
   [P_association_Cy3 X_association_Cy3] = cdfcalc(Cy3_uncorrected_arrivaltimes);
    P_association_Cy3(1) = [];
   
   %eIF1A calculations
    [P_totallifetime_Cy5 X_totallifetime_Cy5] = cdfcalc(Cy5_total_lifetimes);
    P_totallifetime_Cy5(1) = []; 
   [P_raw_association_Cy5 X_raw_association_Cy5] = cdfcalc(Cy5_uncorrected_arrivaltimes);
    P_raw_association_Cy5(1) = [];
    [P_40Scorrected_association_Cy5 X_40Scorrected_association_Cy5] = cdfcalc(Cy5_corrected_arrivaltimes);
    P_40Scorrected_association_Cy5(1) = [];
    
    %60S calculations
    [P_lifetime_Cy5p5 X_lifetime_Cy5p5] = cdfcalc(Cy5p5_lifetimes);
    P_lifetime_Cy5p5(1) = []; 
   [P_raw_association_Cy5p5 X_raw_association_Cy5p5] = cdfcalc(Cy5p5_uncorrected_arrivaltimes);
    P_raw_association_Cy5p5(1) = [];
   [P_1Acorrected_association_Cy5p5 X_1Acorrected_association_Cy5p5] = cdfcalc(Cy5p5_1Acorrected_arrivaltimes);
    P_1Acorrected_association_Cy5p5(1) = [];
   [P_40Scorrected_association_Cy5p5 X_40Scorrected_association_Cy5p5] = cdfcalc(Cy5p5_40Scorrected_arrivaltimes);
    P_40Scorrected_association_Cy5p5(1) = [];
    
    %80S-eIF5B lifetime
   [P_eIF1A_80S_lifetime X_eIF1A_80S_lifetime] = cdfcalc(eIF1A_80S_Lifetime);
    P_eIF1A_80S_lifetime(1) = []; 
    
     [P_eIF1A_40S_lifetime X_eIF1A_40S_lifetime] = cdfcalc(eIF1A_40S_lifetime);
    P_eIF1A_40S_lifetime(1) = []; 

end



