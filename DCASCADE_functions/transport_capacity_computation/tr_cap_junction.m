function [ Qtr_cap , pci ]= tr_cap_junction( indx_tr_cap , indx_partition , Fi_r_reach , D50 ,  Slope, Q, Wac, v , h )

%TR_CAP_JUNCTION refers to the transport capacity equation and partitioning
%formula chosen by the  user and return the value of the transport capacity
% and the relative Grain Size Distrubution (pci)
%for each sediment class in the reach  

%% calculate transport capacity

global psi
dmi = 2.^(-psi)./1000; %sediment classes diameter (m)
 
%choose transport capacity formula
switch indx_tr_cap
    case 1
        tr_cap_formula = @(D50)Parker_Klingeman_formula( Fi_r_reach, D50, Slope, Wac , h);
        indx_partition = 4;
    case 2
        tr_cap_formula = @(D50)Wilcock_Crowe_formula(Fi_r_reach, D50, Slope, Wac , h);
        indx_partition = 4;        
    case 3
        tr_cap_formula = @(D50)Engelund_Hansen_formula( D50 , Slope , Wac, v , h );
    case 4
        tr_cap_formula = @(D50)Yang_formula( Fi_r_reach, D50 , Slope , Q, v, h );
    case 5
        tr_cap_formula = @(D50)Wong_Parker_formula( D50 ,Slope, Wac ,h );
    case 6
        tr_cap_formula = @(D50)Ackers_White_formula( D50,  Slope , Q, v, h);
end

%% choose partitioning formula for computation of sediment transport rates for individual size fractions
% formulas from Molinas, A., & Wu, B. (2000). Comparison of fractional bed material load computation methods in sand?bed channels. Earth Surface Processes and Landforms: The Journal of the British Geomorphological Research Group

Qtr_cap = zeros(size(psi));

switch indx_partition
    
    case 1 % Direct computation by the size fraction approach  
     
        Qtr_cap = arrayfun(tr_cap_formula,dmi);
        pci = Fi_r_reach;

    case 2 %The BMF approach (Bed Material Fraction)
        
        Qtr_cap = Fi_r_reach .* arrayfun(tr_cap_formula,dmi);
        pci = Fi_r_reach;
        
    case 3 %The TCF approach (Transport Capacity Fraction) with the Molinas formula (Molinas and Wu, 2000)
        
        pci = Molinas_rates (Fi_r_reach, h, v, Slope, dmi * 1000 , D50 * 1000);
        Qtr_cap = pci.*tr_cap_formula(D50);
    
    case 4 %Shear stress correction approach (for fractional transport formulas)
        
        Qtr_cap = tr_cap_formula(D50); %these formulas returns already partitioned results;
        pci = Qtr_cap./sum(Qtr_cap);
        
end

end

