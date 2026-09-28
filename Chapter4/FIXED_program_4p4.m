% FIXED version of Chapter4/CORRECT_program_4p4.m
% Program 4.4: BER of OOK-NRZ (sample-level simulation, matched-filter receiver).
%
% Fixes w.r.t. the original:
%  1. Removed the stray statement "sqrt(2)*sqrt(nsamp/(2*SNR(i)));" (a line
%     broken out of a comment) that printed "ans" at every iteration.
%  2. Toolbox-free (my_randint->randsrc, rectpulse, biterr, qfunc replaced
%     by util/owc_* functions), so it also runs in GNU Octave.
%  3. Monte-Carlo length adapts to the BER so high-SNR points are not zero.
%
% Model: y(t) = R*x(t) + n(t), n white with two-sided PSD N0/2, sampled at
% Tsamp -> noise variance N0/(2*Tsamp). Peak energy Ep = i_peak^2*Tb = 2*N0*SNR,
% threshold Ep/2  ==>  BER = Q(sqrt(SNR)) with SNR = Eb/N0 (Eb = Ep/2).
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

q = 1.6e-19;          % electron charge
Ib = 202e-6;          % background current (+ interference)
N0 = 2*q*Ib;          % noise spectral density
R = 1;                % photodetector responsivity
Rb = 1e6;             % bit rate
Tb = 1/Rb;            % bit duration
nsamp = 10;           % samples per bit
Tsamp = Tb/nsamp;     % sampling time
EbN0 = 1:12;          % Eb/N0 (dB)
SNR = 10.^(EbN0/10);
block = 1e5;          % bits per Monte-Carlo block
ber = zeros(size(SNR));
for i = 1:numel(SNR)
    P_avg = sqrt(N0*Rb*SNR(i)/(2*R^2));   % average transmitted optical power
    i_peak = 2*R*P_avg;                   % peak photocurrent
    Ep = i_peak^2*Tb;                     % peak energy (Eb = Ep/2)
    sgma = sqrt(N0/2/Tsamp);              % noise standard deviation per sample
    rt = ones(1, nsamp)*i_peak;           % Rx filter matched to the Tx pulse
    nerr = 0; nbit = 0;
    while nerr < 100 && nbit < 2e7
        OOK = owc_randint(1, block);
        Tx_signal = owc_rectpulse(OOK, nsamp)*i_peak;
        Rx_signal = R*Tx_signal + sgma*randn(1, numel(Tx_signal));
        MF_out = conv(Rx_signal, rt)*Tsamp;           % matched filter output
        MF_out_downsamp = MF_out(nsamp:nsamp:nsamp*block);  % sample at end of bit
        Rx_th = double(MF_out_downsamp > Ep/2);        % threshold detection
        nerr = nerr + owc_biterr(OOK, Rx_th);
        nbit = nbit + block;
    end
    ber(i) = nerr/nbit;
    fprintf('Eb/N0 = %2d dB: BER = %.3e (theory %.3e)\n', EbN0(i), ber(i), owc_Q(sqrt(SNR(i))));
end
figure;
semilogy(EbN0, ber, 'bo'); hold on;
semilogy(EbN0, owc_Q(sqrt(SNR)), 'r-', 'linewidth', 2);
grid on; legend('simulation', 'theory Q(\surd(E_b/N_0))');
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate');
title('BER of OOK-NRZ');
