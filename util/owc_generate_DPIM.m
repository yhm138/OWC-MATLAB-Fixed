function [DPIM, sym] = owc_generate_DPIM(M, nsym, NGS)
% OWC_GENERATE_DPIM  Random DPIM slot sequence.
%   Each symbol = one pulse slot followed by (k + NGS) empty slots, where
%   k in {0,...,2^M-1} is the decimal value of M random bits and NGS is the
%   number of guard slots (default 0).  Returns the slot sequence and k.
%   Fixed version of util/generate_DPIM.m (no toolbox functions, no
%   quadratic growth of the output array).
if nargin < 3
    NGS = 0;
end
sym = owc_randint(1, nsym, 2^M);
len = 1 + sym + NGS;                        % length of every symbol in slots
DPIM = zeros(1, sum(len));
DPIM(cumsum([1 len(1:end-1)])) = 1;         % pulse at the start of every symbol
end
