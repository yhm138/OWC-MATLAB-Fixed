function [x, w] = owc_gh20()
% OWC_GH20  Nodes x and weights w of 20-point Gauss-Hermite quadrature:
%   int exp(-x^2) f(x) dx ~= sum(w.*f(x)).
%   Used to average BER expressions over log-normal fading:
%   E[f(I)] = 1/sqrt(pi) * sum w_i f(I0*exp(sqrt(2)*sigma_l*x_i - sigma_l^2/2)).
xp = [0.245340708301 0.737473728545 1.2340762154 1.73853771212 2.25497400209 ...
      2.78880605843 3.34785456738 3.94476404012 4.60368244955 5.38748089001];
wp = [0.462243669601 0.286675505363 0.10901720602 0.0248105208875 ...
      0.00324377334224 0.000228338636017 7.8025564785e-6 1.08606937077e-7 ...
      4.39934099226e-10 2.22939364554e-13];
x = [-fliplr(xp) xp];
w = [fliplr(wp) wp];
end
