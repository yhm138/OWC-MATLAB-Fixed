% FIXED version of Chapter5/program_5p1.m
% Program 5.1: BER of OOK-NRZ in the presence of fluorescent-light
% interference (FLI, electronic ballast, Moreira model).
%
% Fixes w.r.t. the original:
%  1. fl_model was sampled at Tb instead of Tsamp and over a duration of
%     Tb*nsamp*sig_length; the FLI vector then had ~sig_length+1 samples while
%     Rx_signal had sig_length*nsamp -> "index out of bound" error. The FLI is
%     now generated at Tsamp over exactly the frame duration.
%  2. The variable Ib (background current used for N0) was overwritten by the
%     FLI current; separate names are used (Ib_bg, Ib_fl).
%  3. Reference curve without FLI (Q(sqrt(SNR))) added; vectorised FLI model.
%
% Note: the FLI photocurrent (2 uA) is much larger than the signal, hence
% the high SNR needed; the BER floor is set by the FLI, not the noise.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

q = 1.6e-19;              % electron charge
Ib_bg = 202e-6;           % background current
N0 = 2*q*Ib_bg;           % noise spectral density
R = 1;                    % responsivity
Rb = 1e6; Tb = 1/Rb;      % bit rate / duration
sig_length = 2e4;         % bits per frame (20 ms, one FLI "snapshot")
nsamp = 10; Tsamp = Tb/nsamp;
Ib_fl = 2e-6;             % average photocurrent due to the fluorescent lamp
maxerr = 50;              % errors to count per SNR point
maxbits = 1e6;
EbN0_db = 30:1:55;
ber = nan(size(EbN0_db));
for k = 1:numel(EbN0_db)
    SNR = 10^(EbN0_db(k)/10);
    P_avg = sqrt(N0*Rb*SNR/(2*R^2));
    i_peak = 2*R*P_avg;
    Ep = i_peak^2*Tb;
    sgma = sqrt(N0/2/Tsamp);
    rt = ones(1, nsamp)*i_peak;
    terr = 0; tsym = 0;
    while terr < maxerr && tsym < maxbits
        OOK = owc_randint(1, sig_length);
        Tx_signal = owc_rectpulse(OOK, nsamp)*i_peak;
        Rx_signal = R*Tx_signal + sgma*randn(1, numel(Tx_signal));
        start_time = rand*10e-3;                                   % random lamp phase
        end_time = start_time + (sig_length*nsamp - 1)*Tsamp;      % FIX 1
        i_fl = owc_fl_model(Ib_fl, Tsamp, start_time, end_time);
        Rx_OOK_fl = Rx_signal + i_fl(1:numel(Rx_signal));
        MF_out = conv(Rx_OOK_fl, rt)*Tsamp;
        MF_out_downsamp = MF_out(nsamp:nsamp:nsamp*sig_length);
        Rx_th = double(MF_out_downsamp > Ep/2);
        terr = terr + owc_biterr(OOK, Rx_th);
        tsym = tsym + sig_length;
    end
    ber(k) = terr/tsym;
    fprintf('Eb/N0 = %4.1f dB: BER = %.3e\n', EbN0_db(k), ber(k));
    if ber(k) < 1e-5, break; end
end
figure;
semilogy(EbN0_db, ber, 'o-'); hold on;
% Without FLI the BER is < 1e-200 for Eb/N0 >= 30 dB, so the theory curve is
% drawn over its own range (0...15 dB); the gap shows the FLI penalty.
EbN0_th = 0:0.25:15;
semilogy(EbN0_th, owc_Q(sqrt(10.^(EbN0_th/10))), 'k--');
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate'); xlim([0 55]); ylim([1e-6 1]);
legend('OOK with FLI (simulation)', 'OOK without FLI (theory)', 'location', 'southeast');
title('OOK-NRZ, 1 Mbps, with fluorescent-light interference'); grid on;
