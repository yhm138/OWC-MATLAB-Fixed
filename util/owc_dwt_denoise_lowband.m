function y = owc_dwt_denoise_lowband(x, Lev)
% OWC_DWT_DENOISE_LOWBAND  Remove the low-frequency (approximation) band of
%   x after an Lev-level periodised Daubechies-4 (D4, 4-tap) DWT, then
%   reconstruct. This is the "set approximation coefficients to zero"
%   denoising used for fluorescent-light interference in book Program 5.5,
%   implemented without the Wavelet Toolbox. numel(x) must be divisible by 2^Lev.
h = [1+sqrt(3), 3+sqrt(3), 3-sqrt(3), 1-sqrt(3)]/(4*sqrt(2));  % low-pass
g = h(end:-1:1).*[1 -1 1 -1];                                 % high-pass (QMF)
x = x(:).';
N = numel(x);
if mod(N, 2^Lev) ~= 0
    error('owc_dwt_denoise_lowband: length must be divisible by 2^Lev');
end
details = cell(1, Lev);
a = x;
for lev = 1:Lev
    [a, details{lev}] = analysis(a, h, g);
end
a = zeros(size(a));                     % kill approximation band
for lev = Lev:-1:1
    a = synthesis(a, details{lev}, h, g);
end
y = a;
end

function [a, d] = analysis(x, h, g)
N = numel(x);
n = 0:N/2-1;
a = zeros(1, N/2); d = a;
for k = 0:numel(h)-1
    idx = mod(2*n + k, N) + 1;
    a = a + h(k+1)*x(idx);
    d = d + g(k+1)*x(idx);
end
end

function x = synthesis(a, d, h, g)
N = 2*numel(a);
n = 0:N/2-1;
x = zeros(1, N);
for k = 0:numel(h)-1
    idx = mod(2*n + k, N) + 1;
    x(idx) = x(idx) + h(k+1)*a + g(k+1)*d;
end
end
