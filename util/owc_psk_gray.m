function s = owc_psk_gray(sym, M, phase0)
% OWC_PSK_GRAY  Gray-coded M-PSK mapping (unit amplitude), toolbox-free
%   replacement for comm.PSKModulator(M,'PhaseOffset',phase0,'SymbolMapping','Gray').
if nargin < 3
    phase0 = 0;
end
k = 0:M-1;
g = bitxor(k, floor(k/2));             % Gray code of phase index
pos = zeros(1, M);
pos(g + 1) = k;                        % symbol -> phase index
s = exp(1i*(2*pi*pos(sym + 1)/M + phase0));
s = reshape(s, size(sym));
end
