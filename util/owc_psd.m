function [P, f] = owc_psd(x, fs, nfft)
% OWC_PSD  Two-sided-folded (one-sided) PSD estimate by averaging periodograms
%   of non-overlapping rectangular-windowed segments (Bartlett method).
%   Units: (units of x)^2 / Hz. Toolbox-free replacement for
%   periodogram/dspdata.psd.
x = x(:).';
nseg = floor(numel(x)/nfft);
X = reshape(x(1:nseg*nfft), nfft, nseg);
S = mean(abs(fft(X, [], 1)).^2, 2).'/(fs*nfft);   % two-sided PSD
P = S(1:nfft/2+1);
P(2:end-1) = 2*P(2:end-1);                         % one-sided
f = (0:nfft/2)*fs/nfft;
end
