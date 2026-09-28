% FIXED version of Chapter5/WRONG_plot_Fig5p6.m
% Normalised optical power requirement (NOPR) of DPIM vs data rate in an
% ideal channel and in the presence of fluorescent-light interference (FLI),
% relative to OOK at 1 Mbps in an ideal channel.
%
% Fixes w.r.t. the original ("PLOT NOT CORRECT"):
%  1. NOPR curves and power-penalty curves were drawn on the same axes with
%     no legend/labels, which made the figure unreadable. NOPR and the FLI
%     power penalty are now in separate panels, with legends and labels.
%  2. The simulated points (from which the fits are made) are shown as markers.
%  3. The regression is done vs log10(rate) (as in the book), but evaluated
%     on a dense grid so the fitted lines are smooth on the log axis.
%
% Model: ideal-channel NOPR scales as 5*log10(Rb) (power ~ sqrt(bandwidth)),
% DPIM gain over OOK = 5*log10(M*Lavg/4) dB (Lavg = (2^M+1)/2).
% With FLI: NOPR = (SNR_req - SNR_ref)/2 + 5*log10(Rb), SNR_req from simulation.
clear; clc; close all;

snr_ref = 10.54;                     % SNR of OOK at 1 Mbps, BER 1e-6, ideal channel
data_rate = [1 10 20 40 60 80 100 120 140 160 180 200];   % Mbps
nf = 5*log10(data_rate);
x = log10(data_rate);
xf = linspace(0, log10(200), 100); rf = 10.^xf;
M = [2 3 4]; Lavg = (2.^M + 1)/2;
snr_dpim = [41.7 32.2 29.2 26.45 24.96 23.75 23 22.46 21.81 21.4 20.6 20.6;   % 4-DPIM
            36.6 27   24.1 21.4  20    18.6  18.1 17.5 16.6 16.4  16.1 15.6;  % 8-DPIM
            31.1 21.5 18.6 16.1  14.7  13.5  13.1 12.4 11.7 11.2  11   10.5]; % 16-DPIM
col = {'b', 'r', 'k'};
figure;
for n = 1:3
    ideal = 5*log10(rf) - 5*log10(M(n)*Lavg(n)/4);
    nopr_fli = (snr_dpim(n,:) - snr_ref)/2 + nf;
    p = polyfit(x, nopr_fli, 1);
    subplot(2,1,1);
    semilogx(rf, ideal, [col{n} '-'], 'linewidth', 1.5); hold on;
    semilogx(rf, polyval(p, xf), [col{n} '--'], 'linewidth', 1.5);
    semilogx(data_rate, nopr_fli, [col{n} 'o'], 'HandleVisibility', 'off');
    subplot(2,1,2);
    semilogx(rf, polyval(p, xf) - ideal, col{n}, 'linewidth', 1.5); hold on;
end
subplot(2,1,1); grid on;
legend('4-DPIM ideal', '4-DPIM FLI', '8-DPIM ideal', '8-DPIM FLI', '16-DPIM ideal', '16-DPIM FLI', ...
       'location', 'eastoutside');
xlabel('Data rate (Mbps)'); ylabel('NOPR (dB)'); title('Normalised optical power requirement');
subplot(2,1,2); grid on;
legend('4-DPIM', '8-DPIM', '16-DPIM', 'location', 'eastoutside');
xlabel('Data rate (Mbps)'); ylabel('Power penalty (dB)'); title('Optical power penalty due to FLI');
