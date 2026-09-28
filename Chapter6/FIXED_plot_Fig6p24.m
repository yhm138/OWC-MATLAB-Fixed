% FIXED version of Chapter6/WRONG_plot_Fig6p24.m
% BER of BPSK-SIM FSO vs electrical SNR under weak log-normal turbulence
% (Gauss-Hermite quadrature).
%
% Fixes w.r.t. the original ("PLOT NOT CORRECT"):
%  1. util/Q.m computed Q(|x|) for scalars only; util/owc_Q is used.
%  2. Only one turbulence level (sigma_l^2 = 0.1) was drawn with no reference;
%     the figure now shows several log-irradiance variances plus the AWGN
%     (no turbulence) curve, so the turbulence-induced penalty can be read.
%  3. Quadrature nodes/weights defined once (util/owc_gh20), SNR on a linear
%     dB grid, labels/legend added.
%
% BER = 1/sqrt(pi) sum_i w_i Q( K*exp(sqrt(2)*sigma_l*x_i - sigma_l^2/2) ),
% K = R*E[I]/(N*sqrt(2*N0)), SNR = (R*E[I])^2/N0, N = number of subcarriers.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

R = 1; Io = 1; N = 1;
var_l = [0.1 0.2 0.3 0.5];            % log-irradiance variances
SNR_dB = 0:0.5:50;
No = (R*Io)^2./10.^(SNR_dB/10);       % noise variance for each SNR
K = (R*Io)./(sqrt(2*No)*N);
[x20, w20] = owc_gh20();
figure;
semilogy(SNR_dB, owc_Q(K), 'k--', 'linewidth', 1.5); hold on;
lg = {'no turbulence'};
for v = var_l
    r = sqrt(v);
    BER = (owc_Q(K(:)*exp(sqrt(2)*r*x20 - v/2))*w20.')/sqrt(pi);
    semilogy(SNR_dB, BER, 'linewidth', 1.5);
    lg{end+1} = sprintf('\\sigma_l^2 = %.1f', v); %#ok<SAGROW>
end
legend(lg, 'location', 'southwest');
xlabel('SNR = (R E[I])^2/N_0 (dB)'); ylabel('BER'); ylim([1e-10 1]); grid on;
title('BPSK-SIM under log-normal turbulence');
