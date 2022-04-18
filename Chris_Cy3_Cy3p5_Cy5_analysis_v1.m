[r c d] = size(HMM);
%t = ttotal(:,1);

%States codes
% Cy3 [10 200]
% Cy3p5 [10 100]
% Cy5 [10 80]

Df = input('Enter desired Delivery Frame -> ');
Exposure = input('Enter the Exposure Time (1/framerate) -> ');

I_want_fast_analysis =1;

if I_want_fast_analysis == 1
    
    Cy3_uncorrected_arrivaltimes = zeros(1, c);
    Cy3_uncorrected_departuretimes = zeros(1,c);
    
    Cy3p5_uncorrected_arrivaltimes = zeros(1, c);
    Cy3p5_uncorrected_departuretimes = zeros(1,c);
    
    Cy5_uncorrected_arrivaltimes = zeros(1, c);
    Cy5_uncorrected_departuretimes = zeros(1,c);
    
    
    
    for n = 1:c
        if mean(HMM(:,n,1))>10 && mean(HMM(:,n,2))>10 &&mean(HMM(:,n,3))>10
            
            temp_1 = find(HMM(:, n, 1) == 200, 1, 'first');
            if isempty(temp_1) == 0
                Cy3_uncorrected_arrivaltimes(n) = find(HMM(:, n, 1) == 200, 1, 'first');
            end
            
            temp_2 = find(HMM(:, n, 1) == 200, 1, 'last');
            if isempty(temp_2) == 0
                Cy3_uncorrected_departuretimes(n) = find(HMM(:, n, 1) == 200, 1, 'last');
            end
            
            temp_5 = find(HMM(:, n, 2) == 100, 1, 'first');
            if isempty(temp_5) == 0
                Cy3p5_uncorrected_arrivaltimes(n) = find(HMM(:, n, 2) == 100, 1, 'first');
            end
            
            temp_6 = find(HMM(:, n, 2) == 100, 1, 'last');
            if isempty(temp_6) == 0
                Cy3p5_uncorrected_departuretimes(n) = find(HMM(:, n, 2) == 100, 1, 'last');
            end
            
            temp_3 = find(HMM(:, n, 3) == 80, 1, 'first');
            if isempty(temp_3) == 0
                Cy5_uncorrected_arrivaltimes(n) = find(HMM(:, n, 3) == 80, 1, 'first');
            end
            
            temp_4 = find(HMM(:, n, 3) == 80, 1, 'last');
            if isempty(temp_4) == 0
                Cy5_uncorrected_departuretimes(n) = find(HMM(:, n, 3) == 80, 1, 'last');
            end
        end
    end
%     i_zero = find(Cy3_uncorrected_arrivaltimes == 0)
    Cy3_uncorrected_arrivaltimes(Cy3_uncorrected_arrivaltimes == 0) = [];
    Cy3_uncorrected_departuretimes(Cy3_uncorrected_departuretimes == 0) = [];
    
    Cy3p5_uncorrected_arrivaltimes(Cy3p5_uncorrected_arrivaltimes == 0) = [];
    Cy3p5_uncorrected_departuretimes(Cy3p5_uncorrected_departuretimes == 0) = [];
   
    Cy5_uncorrected_arrivaltimes(Cy5_uncorrected_arrivaltimes == 0) = [];
    Cy5_uncorrected_departuretimes(Cy5_uncorrected_departuretimes == 0) = [];
    
    %Converting everything to time
    Cy3_uncorrected_arrivaltimes = (Cy3_uncorrected_arrivaltimes - Df)*Exposure;
    Cy3_uncorrected_departuretimes = (Cy3_uncorrected_departuretimes - Df)*Exposure;
    
    Cy3p5_uncorrected_arrivaltimes = (Cy3p5_uncorrected_arrivaltimes - Df)*Exposure;
    Cy3p5_uncorrected_departuretimes = (Cy3p5_uncorrected_departuretimes - Df)*Exposure;
    
    Cy5_uncorrected_arrivaltimes = (Cy5_uncorrected_arrivaltimes - Df)*Exposure;
    Cy5_uncorrected_departuretimes = (Cy5_uncorrected_departuretimes - Df)*Exposure;
    
    Cy3_lifetimes = Cy3_uncorrected_departuretimes - Cy3_uncorrected_arrivaltimes;
    Cy3p5_lifetimes = Cy3p5_uncorrected_departuretimes - Cy3p5_uncorrected_arrivaltimes;
    Cy5_lifetimes = Cy5_uncorrected_departuretimes - Cy5_uncorrected_arrivaltimes;
    
    % calculate association times relative to another binding event
    Cy3p5_corrected_arrivaltimes  = Cy3p5_uncorrected_arrivaltimes - Cy5_uncorrected_arrivaltimes;
    Cy5_corrected_arrivaltimes  = Cy5_uncorrected_arrivaltimes - Cy3_uncorrected_arrivaltimes;
    
    %Cy3_corrected_arrivaltimes(Cy3_corrected_arrivaltimes < Exposure) = [];
    
    %clear n mols t temp* Cy3_un* %Cy5_un*
  
   [P_lifetime_Cy3 X_lifetime_Cy3] = cdfcalc(Cy3_lifetimes);
    P_lifetime_Cy3(1) = []; 
   [P_association_Cy3 X_association_Cy3] = cdfcalc(Cy3_uncorrected_arrivaltimes);
    P_association_Cy3(1) = [];
    
   [P_lifetime_Cy3p5 X_lifetime_Cy3p5] = cdfcalc(Cy3p5_lifetimes);
    P_lifetime_Cy3p5(1) = []; 
   [P_association_Cy3p5 X_association_Cy3p5] = cdfcalc(Cy3p5_corrected_arrivaltimes);
    P_association_Cy3p5(1) = [];
    
    [P_lifetime_Cy5 X_lifetime_Cy5] = cdfcalc(Cy5_lifetimes);
    P_lifetime_Cy5(1) = []; 
   [P_association_Cy5 X_association_Cy5] = cdfcalc(Cy5_corrected_arrivaltimes);
    P_association_Cy5(1) = [];

end



