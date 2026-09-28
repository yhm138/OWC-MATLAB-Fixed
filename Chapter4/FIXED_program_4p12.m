% FIXED version of Chapter4/program_4p12.m
% Program 4.12: bandwidth requirement vs. average optical power requirement
% of OOK (RZ, various duty cycles), PPM (hard/soft) and DPIM, normalised to OOK-NRZ.
%
% Fixes w.r.t. the original:
%  1. The legend order did not match the plotting order (the hard-decision
%     PPM curve was labelled "PPM (soft)" and vice versa).
%  2. Duty cycle 0.33 -> 1/3; axis labels in dB made explicit.
%
% Derivation (same BER as OOK-NRZ, Gaussian noise, average-power constraint):
%   PPM-HDD : P/P_OOK = sqrt(4/(M*2^M)),     BW/BW_OOK = 2^M/M
%   PPM-SDD : P/P_OOK = sqrt(2/(M*2^M))
%   DPIM    : P/P_OOK = sqrt(8/(M*(2^M+1))), BW/BW_OOK = (2^M+1)/(2M)
%   OOK-RZ  : P/P_OOK = sqrt(gamma),          BW/BW_OOK = 1/gamma
clear; clc; close all;

M = 1:5;
P_req_PPM_hard = 10*log10(sqrt(4./(M.*2.^M)));
P_req_PPM_soft = 10*log10(sqrt(2./(M.*2.^M)));
BW_PPM = 2.^M./M;
P_req_DPIM = 10*log10(sqrt(8./(M.*(2.^M+1))));
BW_DPIM = (2.^M+1)./(2*M);
duty_cycle = [1 1/2 1/3 1/4];
BW_OOK = 1./duty_cycle;
P_req_OOK = 10*log10(sqrt(duty_cycle));

figure;
plot(BW_OOK, P_req_OOK, '-kv', 'LineWidth', 2, 'MarkerSize', 8); hold on;
plot(BW_PPM, P_req_PPM_hard, '-rs', 'LineWidth', 2, 'MarkerSize', 8);
plot(BW_PPM, P_req_PPM_soft, '-ro', 'LineWidth', 2, 'MarkerSize', 8);
plot(BW_DPIM, P_req_DPIM, '-bd', 'LineWidth', 2, 'MarkerSize', 8);
legend('OOK-RZ (\gamma = 1, 1/2, 1/3, 1/4)', 'PPM (hard)', 'PPM (soft)', 'DPIM (hard)');   % FIX 1
xlabel('Normalised bandwidth requirement'); ylabel('Normalised average optical power requirement (dB)');
xlim([0.5 7]);   % keep the OOK-NRZ point (1, 0 dB) off the y-axis tick labels
grid on; title('Power vs. bandwidth efficiency (M = 1..5)');
