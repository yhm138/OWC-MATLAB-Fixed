% FIXED version of Chapter5/NEEDFIX_program_5p5.m
% Program 5.5: DWT-based mitigation of fluorescent-light interference (FLI)
% on OOK-NRZ.
%
% Fixes w.r.t. the original (which could not run):
%  1. Undefined variables: rt (matched filter), Lev and wname (wavelet level/name).
%  2. Inconsistent parameters (Tb = Tsamp = 10, i_peak/sgma arbitrary) -> the
%     physical model of Program 5.1 is used (shot-noise N0, 2 uA FLI), at
%     Rb = 100 Mbps.
%  3. wavedec/appcoef/waverec (Wavelet Toolbox) and mapminmax (Deep Learning
%     Toolbox) replaced by util/owc_dwt_denoise_lowband (periodised D4 DWT,
%     approximation band set to zero). After removing the approximation band
%     the signal is zero-mean, so the decision threshold is 0.
%  4. BER is actually computed and compared: no FLI / FLI / FLI + DWT.
%
% Choice of the level: the approximation band that is removed is roughly
% 0 ... Rb/2^(Lev+1). The FLI energy is dominated by the ballast harmonics at
% 37.5 kHz x {1,2,4,...} (up to ~1 MHz) and the mains harmonics (< 2 kHz).
% With Rb = 100 Mbps and Lev = 6 the removed band is ~0-780 kHz: all strong
% FLI components are removed while the data loses only ~0.8% of its
% bandwidth (small baseline-wander penalty). Too high a level leaves FLI,
% too low a level causes baseline wander. At Rb = 1 Mbps the FLI and data
% spectra overlap and no DWT level is effective.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

q = 1.6e-19; Ib_bg = 202e-6; N0 = 2*q*Ib_bg; R = 1;
Rb = 100e6; Tb = 1/Rb; nsamp = 10; Tsamp = Tb/nsamp;
sig_length = 2^16;        % bits per frame (divisible by 2^Lev)
Ib_fl = 2e-6;             % FLI average photocurrent
Lev = 6;                  % DWT decomposition level
EbN0_db = 0:1:18;
nframes = 8;
ber = nan(3, numel(EbN0_db));
for k = 1:numel(EbN0_db)
    SNR = 10^(EbN0_db(k)/10);
    P_avg = sqrt(N0*Rb*SNR/(2*R^2));
    i_peak = 2*R*P_avg; Ep = i_peak^2*Tb;
    sgma = sqrt(N0/2/Tsamp);
    rt = ones(1, nsamp)*i_peak;                       % FIX 1: matched filter
    nerr = zeros(3, 1);
    for fr = 1:nframes
        OOK = owc_randint(1, sig_length);
        Rx_signal = R*owc_rectpulse(OOK, nsamp)*i_peak + sgma*randn(1, sig_length*nsamp);
        start_time = rand*10e-3;
        i_fl = owc_fl_model(Ib_fl, Tsamp, start_time, start_time + (sig_length*nsamp-1)*Tsamp);
        mf = @(x) conv(x, rt)*Tsamp;
        MF0 = mf(Rx_signal);              MF0 = MF0(nsamp:nsamp:nsamp*sig_length);
        MF1 = mf(Rx_signal + i_fl);       MF1 = MF1(nsamp:nsamp:nsamp*sig_length);
        MF2 = owc_dwt_denoise_lowband(MF1, Lev);                 % DWT denoising
        nerr(1) = nerr(1) + owc_biterr(OOK, double(MF0 > Ep/2)); % no FLI
        nerr(2) = nerr(2) + owc_biterr(OOK, double(MF1 > Ep/2)); % FLI, no mitigation
        nerr(3) = nerr(3) + owc_biterr(OOK, double(MF2 > 0));    % FLI + DWT (zero-mean)
    end
    ber(:, k) = nerr/(nframes*sig_length);
end
figure;
semilogy(EbN0_db, ber(1,:), 'k-o', EbN0_db, ber(2,:), 'r-s', EbN0_db, ber(3,:), 'b-d');
hold on; semilogy(EbN0_db, owc_Q(sqrt(10.^(EbN0_db/10))), 'k:');
legend('no FLI', 'FLI, no mitigation', sprintf('FLI + DWT (D4, level %d)', Lev), 'theory, no FLI');
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate'); ylim([1e-5 1]); grid on;
title(sprintf('OOK-NRZ at %g Mbps with FLI: DWT-based mitigation', Rb/1e6));
