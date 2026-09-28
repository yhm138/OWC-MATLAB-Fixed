% FIXED version of Chapter3/CORRECT_plot_Fig3p28.m
% Program 3.6: log-normal pdf of the received irradiance.
%
% Fixes w.r.t. the original:
%  1. I = 0 gave 1/0*exp(-Inf) = NaN; the grid now starts at I > 0.
%  2. The variance in the legend is the LOG-irradiance variance sigma_l^2
%     (the pdf is written in terms of sigma_l^2), typo "Noramlsied" fixed.
%  3. Vectorised; no growing arrays.
clear; clc; close all;

Io = 1;                               % E[I]
I = 0.005:0.005:3;                    % irradiance values
Var_l = [0.1, 0.2, 0.5, 0.8];         % log-irradiance variances sigma_l^2
pdf = zeros(numel(Var_l), numel(I));
for i = 1:numel(Var_l)
    pdf(i,:) = 1./(I*sqrt(2*pi*Var_l(i))) .* ...
        exp(-(log(I/Io) + Var_l(i)/2).^2/(2*Var_l(i)));
end
figure; plot(I/Io, pdf);
xlabel('Normalised irradiance, I/E[I]'); ylabel('p(I)');
legend('\sigma_l^2 = 0.1', '\sigma_l^2 = 0.2', '\sigma_l^2 = 0.5', '\sigma_l^2 = 0.8');
title('Log-normal pdf');
grid on;
% sanity check: every pdf integrates to ~1 and has mean ~E[I]
fprintf('area = %s\n', mat2str(trapz(I, pdf, 2).', 3));
