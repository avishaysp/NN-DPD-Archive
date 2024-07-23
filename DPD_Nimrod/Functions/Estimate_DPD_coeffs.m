function inv_coeffs =Estimate_DPD_coeffs(Y_Matrix,Input_signal)
    %% Estimate DPD coefficients from Pseudo Inverse
    
    %% initializing
    y= Y_Matrix ;
    H = Y_Matrix'*Y_Matrix;

    
    %% Estimate PA coefficients
    inv_coeffs = H\Y_Matrix'*Input_signal;
end