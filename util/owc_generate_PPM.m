function [PPM, sym] = owc_generate_PPM(M, nsym)
% OWC_GENERATE_PPM  Random L-PPM slot sequence, L = 2^M.
%   [PPM, sym] = owc_generate_PPM(M, nsym) returns the 0/1 slot sequence
%   (row vector, length nsym*2^M) and the transmitted symbol values 0..L-1.
%   Fixed version of util/generate_PPM.m (no echo of every symbol, no
%   bi2de/randsrc toolbox dependency, preallocated).
L = 2^M;
sym = owc_randint(1, nsym, L);              % equivalent to M random bits, MSB first
frame = zeros(L, nsym);
frame(sym + 1 + (0:nsym-1)*L) = 1;          % one pulse in slot (sym+1) of each frame
PPM = frame(:).';
end
