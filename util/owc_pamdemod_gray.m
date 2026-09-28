function sym = owc_pamdemod_gray(y, L)
% OWC_PAMDEMOD_GRAY  Minimum-distance demodulation of Gray-coded L-PAM
%   (inverse of owc_pam_gray; levels -(L-1),...,(L-1) with spacing 2).
idx = round((real(y) + (L-1))/2);
idx = min(max(idx, 0), L-1);
sym = bitxor(idx, floor(idx/2));       % level index -> Gray-coded symbol
end
