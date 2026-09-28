% FIXED version of Chapter4/CORRECT_program_4p5.m
% Program 4.5: BER of OOK-NRZ, symbol-level simulation of the matched filter output.
%
% Fixes w.r.t. the original:
%  1. The theoretical curve Q(sqrt(SNR)) is added so the simulation can be verified.
%  2. Vectorised noise generation (the original called gngauss 1e5 times per point).
%  3. Toolbox-free (biterr / randsrc) -> runs in GNU Octave.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

q = 1.6e-19; Ib = 202e-6; N0 = 2*q*Ib;   % shot-noise PSD from background light
Rb = 1e6; Tb = 1/Rb; R = 1;
sig_length = 1e6;                        % bits per SNR point
snr_dB = 0:10;
SNR = 10.^(snr_dB/10);
ber = zeros(size(SNR));
for i = 1:numel(SNR)
    P_avg = sqrt(N0*Rb*SNR(i)/(2*R^2));  % average optical power
    i_peak = 2*R*P_avg;                  % peak photocurrent
    Ep = i_peak^2*Tb;                    % peak energy
    sgma = sqrt(N0*Ep/2);                % noise std at the matched filter output
    Tx = owc_randint(1, sig_length);
    MF = Tx*Ep + sgma*randn(1, sig_length);
    Rx = double(MF > 0.5*Ep);
    [~, ber(i)] = owc_biterr(Tx, Rx);
end
figure;
semilogy(snr_dB, ber, 'o'); hold on;
semilogy(snr_dB, owc_Q(sqrt(SNR)), 'r-', 'linewidth', 2);
xlabel('SNR = E_b/N_0 (dB)'); ylabel('Bit error rate');
legend('simulation', 'theory'); title('BER of OOK-NRZ (matched filter receiver)');
grid on;
