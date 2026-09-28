% FIXED version of Chapter4/program_4p8.m
% Program 4.8: slot/symbol error rate of L-PPM with hard- (HDD) and
% soft-decision decoding (SDD) in AWGN.
%
% Fixes w.r.t. the original:
%  1. The simulated error rates were computed but never plotted, and the two
%     theory curves were drawn without "hold on" (the SDD curve replaced the
%     HDD one). Simulation and theory are now plotted together.
%  2. SDD is evaluated per symbol (max-likelihood slot = largest sample); its
%     symbol error rate is compared with the exact expression
%     1 - int phi(u) Phi(u + 1/sigma)^(L-1) du and the book's union-bound
%     approximation (L-1) Q(sqrt(M L SNR)).
%  3. 500 symbols were far too few for the SNR range; more symbols are used.
%  4. Toolbox-free (awgn/biterr/qfunc/bi2de replaced by util/owc_*).
%
% Normalisation (as in the book): MF output = 1 for a pulse slot, 0 otherwise;
% SNR = Eb/N0 with the book's average-power definition gives a slot noise
% variance sigma^2 = 1/(2*M*L*SNR), i.e. awgn(...,EsN0+3,'measured') on the
% 0/1 slot sequence (measured power 1/L).
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

M = 3; L = 2^M;               % bit resolution, symbol length
nsym = 2e5;                   % number of PPM symbols per SNR point
EbN0 = -10:6;                 % Eb/N0 (dB)
EsN0 = EbN0 + 10*log10(M);    % Es/N0 (dB)
SNR = 10.^(EbN0/10);
ser_hdd = zeros(size(EbN0)); ser_sdd = ser_hdd;
for ii = 1:numel(EbN0)
    [PPM, sym] = owc_generate_PPM(M, nsym);
    MF_out = owc_awgn(PPM, EsN0(ii) + 3);
    % hard decision: threshold every slot at 0.5 -> slot error rate
    Rx_PPM_th = double(MF_out > 0.5);
    [~, ser_hdd(ii)] = owc_biterr(Rx_PPM_th, PPM);
    % soft decision: pick the largest slot in every frame -> symbol error rate
    [~, pos] = max(reshape(MF_out, L, nsym), [], 1);
    ser_sdd(ii) = mean((pos - 1) ~= sym);
end
% theory
Pse_hard = owc_Q(sqrt(M*L*0.5*SNR));                      % slot error, HDD
Pse_soft_ub = min(1, (L-1)*owc_Q(sqrt(M*L*SNR)));          % union bound, SDD
sigma = 1./sqrt(2*M*L*SNR);
u = linspace(-10, 10, 4001);
Pse_soft = zeros(size(SNR));
for ii = 1:numel(SNR)                                       % exact SDD SER
    Pc = trapz(u, exp(-u.^2/2)/sqrt(2*pi).*(1 - owc_Q(u + 1/sigma(ii))).^(L-1));
    Pse_soft(ii) = 1 - Pc;
end
figure;
semilogy(EbN0, ser_hdd, 'ko', EbN0, Pse_hard, 'k--', ...
         EbN0, ser_sdd, 'rs', EbN0, Pse_soft, 'r-', EbN0, Pse_soft_ub, 'r:', 'linewidth', 1.5);
legend('HDD slot error, sim.', 'HDD theory Q(\surd(MLSNR/2))', ...
       'SDD symbol error, sim.', 'SDD exact', 'SDD union bound', 'location', 'southwest');
xlabel('E_b/N_0 (dB)'); ylabel('Error probability');
title(sprintf('%d-PPM in AWGN', L)); grid on; ylim([1e-6 1]);
