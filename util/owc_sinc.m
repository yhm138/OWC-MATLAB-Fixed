function y = owc_sinc(x)
% OWC_SINC  Normalised sinc, sin(pi*x)/(pi*x) with sinc(0) = 1
%   (sinc() is in the Signal Processing Toolbox in MATLAB).
y = ones(size(x));
k = (x ~= 0);
y(k) = sin(pi*x(k))./(pi*x(k));
end
