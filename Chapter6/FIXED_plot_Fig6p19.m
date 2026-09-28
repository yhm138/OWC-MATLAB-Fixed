% FIXED version of Chapter6/CORRECT_plot_Fig6p19.m
% Outage probability vs power margin for a log-normal turbulent channel
% (Chernoff upper bound), sigma_l^2 = 0.1, 0.3, 0.5, 1.
%
% Fixes w.r.t. the original:
%  1. The power margin m = E[I]/I_th is a RATIO; the original computed
%     10*log10(m*1e3) and called it "dBm" (a constant +30 dB offset). The
%     margin is now in dB.
%  2. Pout = logspace(0,...) started at Pout = 1: the Chernoff bound
%     Pout <= 0.5*exp(-(ln m - sigma^2/2)^2/(2 sigma^2)) only has a solution
%     for Pout <= 0.5; at Pout = 1 sqrt(-2 sigma^2 ln 2) is complex.
%  3. The exact outage Q((ln m - sigma^2/2)/sigma) is also plotted.
%  4. Legend uses the log-irradiance variance symbol sigma_l^2.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

var_l = [0.1 0.3 0.5 1];
Pout = logspace(log10(0.5), -10, 60);
figure;
for j = 1:numel(var_l)
    s2 = var_l(j);
    ln_m = sqrt(-2*s2*log(2*Pout)) + s2/2;   % Chernoff bound solved for ln(m)
    margin_dB = 10*log10(exp(ln_m));
    semilogy(margin_dB, Pout, 'linewidth', 1.5); hold on;
end
set(gca, 'ColorOrderIndex', 1);
mdB = linspace(0, 30, 301);
for j = 1:numel(var_l)
    s2 = var_l(j);
    semilogy(mdB, owc_Q((log(10.^(mdB/10)) - s2/2)/sqrt(s2)), ':');   % exact
end
xlabel('Power margin (dB)'); ylabel('Outage probability'); ylim([1e-10 1]); grid on;
legend('\sigma_l^2 = 0.1', '\sigma_l^2 = 0.3', '\sigma_l^2 = 0.5', '\sigma_l^2 = 1', 'location', 'southwest');
title('SISO outage probability (solid: Chernoff bound, dotted: exact)');
