% FIXED version of Chapter4/program_4p11.m
% Program 4.11: slot error rate of DPIM (threshold detection) in AWGN.
%
% Fixes w.r.t. the original:
%  1. The quantity simulated with biterr on the slot stream is the SLOT error
%     rate, which is what Q(sqrt(M*Lavg*SNR/2)) predicts; labels corrected
%     ("Energy per slot" comment on EbN0 was wrong - it is Eb/N0).
%  2. Axis labels / legend added (the plot had none).
%  3. Toolbox-free (awgn, biterr, qfunc, bi2de -> util/owc_*), faster DPIM
%     generator; more symbols for a smooth curve.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

M = 4;                          % bit resolution
NGS = 0;                        % number of guard slots
Lavg = 0.5*(2^M + 1) + NGS;     % average symbol length (slots)
nsym = 5e4;                     % number of DPIM symbols
EbN0 = -10:4;                   % Eb/N0 (dB)
EsN0 = EbN0 + 10*log10(M);      % Es/N0 (dB)
SNR = 10.^(EbN0/10);
ser = zeros(size(EbN0));
for ii = 1:numel(EbN0)
    DPIM = owc_generate_DPIM(M, nsym, NGS);
    MF_out = owc_awgn(DPIM, EsN0(ii) + 3);   % MF output, unit pulse amplitude
    Rx_DPIM_th = double(MF_out > 0.5);         % threshold detection
    [~, ser(ii)] = owc_biterr(Rx_DPIM_th, DPIM);
end
Pse_DPIM = owc_Q(sqrt(M*Lavg*0.5*SNR));
figure;
semilogy(EbN0, ser, 'ko', 'linewidth', 2); hold on;
semilogy(EbN0, Pse_DPIM, 'r', 'linewidth', 2);
xlabel('E_b/N_0 (dB)'); ylabel('Slot error rate');
legend('simulation', 'theory'); grid on;
title(sprintf('%d-DPIM (%d guard slots) in AWGN', 2^M, NGS));
