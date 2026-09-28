% FIXED version of Chapter4/program_4p14.m
% Program 4.14: OFDM (QPSK on 128 of 256 sub-carriers, cyclic prefix) over
% an AWGN or multipath channel.
%
% Fixes w.r.t. the original:
%  1. my_randint(N,1,M) called randi(M-1,...) -> symbols 1..3 only (symbol 0
%     was never sent). Random BITS are now generated and Gray-mapped to QPSK.
%  2. The simulated quantity was the SYMBOL error rate (symerr) but it was
%     compared with 0.5*erfc(sqrt(snr)), which is the Gray-QPSK BIT error
%     rate. BER is now simulated.
%  3. SNR bookkeeping: awgn(...,'measured') measures the power of the whole
%     time-domain OFDM symbol, in which only 128 of 256 sub-carriers are
%     active, so the per-active-sub-carrier Es/N0 = 2*snr, i.e. Eb/N0 = snr.
%     The theory curve is therefore Q(sqrt(2*Eb/N0)) with Eb/N0 = snr.
%  4. The random multipath channel was generated and then silently overwritten
%     with h = 1. A channel switch is provided; for the multipath case a
%     one-tap zero-forcing equaliser (possible because CP = 64 > L-1 = 15)
%     is applied, and the Rayleigh-fading theory is plotted.
%  5. Stray statements printing to the console (GI, snr, sum(abs(h))) removed.
%  6. Toolbox-free (qammod/qamdemod/awgn/symerr).
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

N = 256;                 % FFT size
N_data_symbol = 128;     % active sub-carriers
GI = N/4;                % cyclic prefix length
L = 16;                  % multipath channel length
N_Iteration = 500;       % OFDM symbols per SNR point
SNR = 0:1:12;            % dB (= Eb/N0 on the active sub-carriers, see FIX 3)
use_multipath = false;   % set true for a random L-tap Rayleigh channel
k0 = (N - N_data_symbol)/2;
ber = zeros(size(SNR));
for i = 1:numel(SNR)
    nerr = 0;
    for k = 1:N_Iteration
        tx_bits = owc_randint(N_data_symbol, 2);
        tx_sym = owc_qpsk_gray(tx_bits);
        input_symbol = [zeros(k0,1); tx_sym; zeros(k0,1)];
        ofdm_symbol_ifft = ifft(input_symbol, N);
        ofdm_symbol = [ofdm_symbol_ifft(N-GI+1:N); ofdm_symbol_ifft];   % add CP
        if use_multipath
            h = (randn(L,1) + 1i*randn(L,1)).*exp(-(0:L-1).'/4);     % exponential PDP
            h = h/sqrt(sum(abs(h).^2));  % unit average power gain
        else
            h = 1;
        end
        % noise level referred to the transmitted (unfaded) signal power
        n0 = sum(abs(ofdm_symbol).^2)/numel(ofdm_symbol)/10^(SNR(i)/10);
        y = filter(h, 1, ofdm_symbol);
        y = y + sqrt(n0/2)*(randn(size(y)) + 1i*randn(size(y)));
        rx_symbol_fft = fft(y(GI+1:N+GI), N);                         % remove CP, FFT
        H_f = fft(h, N);
        rx_equalized = rx_symbol_fft./H_f(:);                          % ZF equaliser
        rx = rx_equalized(k0+1:k0+N_data_symbol);
        rx_bits = [real(rx) < 0, imag(rx) < 0];
        nerr = nerr + sum(rx_bits(:) ~= tx_bits(:));
    end
    ber(i) = nerr/(2*N_data_symbol*N_Iteration);
end
snr_lin = 10.^(SNR/10);
figure;
semilogy(SNR, ber, 'bo-'); hold on;
if use_multipath
    theory = 0.5*(1 - sqrt(snr_lin./(1 + snr_lin)));   % Rayleigh, per sub-carrier
else
    theory = 0.5*erfc(sqrt(snr_lin));                   % AWGN, Gray QPSK
end
semilogy(SNR, theory, 'r--', 'linewidth', 2);
legend('simulation', 'theory'); grid on;
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate');
title('QPSK-OFDM, N = 256, 128 active sub-carriers, CP = N/4');
