function s = owc_qpsk_gray(bits)
% OWC_QPSK_GRAY  Gray-mapped QPSK: bit pairs [b1 b2] -> (1-2*b1) + 1j*(1-2*b2).
%   bits: N-by-2 matrix. Unit-energy normalisation is NOT applied
%   (|s|^2 = 2), matching qammod(...,4) default constellation energy.
s = (1 - 2*bits(:,1)) + 1i*(1 - 2*bits(:,2));
end
