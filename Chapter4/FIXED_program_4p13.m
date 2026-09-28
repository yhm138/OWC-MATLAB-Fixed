% FIXED version of Chapter4/NEEDFIX_program_4p13.m
% Program 4.13: BER of BPSK (subcarrier) modulation in AWGN.
%
% Fixes w.r.t. the original:
%  1. The correlator used the undefined variable MF_output; it must use the
%     demodulated signal Rx_output (= Rx_signal .* carrier).
%  2. A comment wrapped onto a code line ("is given in OOK simulation") -> syntax error.
%  3. 1000 bits cannot resolve BERs below 1e-3; the Monte-Carlo length is
%     now adaptive. Axis labels / legend added.
%  4. Toolbox-free (awgn, biterr, upsample -> util/owc_*).
%
% Check: sum(carrier.^2) over one bit = Eb, per-sample SNR = 2(Eb/N0)/nsamp,
% so awgn(...,EbN0+3-10log10(nsamp),'measured') gives BER = Q(sqrt(2Eb/N0)).
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

Eb = 1;                     % energy per bit
Rb = 1; Tb = 1/Rb;          % normalised bit rate
fc = 5*Rb;                  % carrier frequency
fsamp = 10*fc;              % sampling rate
nsamp = fsamp/Rb;           % samples per bit
Tsamp = Tb/nsamp;
SigLen = 1e4;               % bits per block
t = Tsamp:Tsamp:Tb*SigLen;
carrier_signal = sqrt(2*Eb/nsamp)*sin(2*pi*fc*t);
Eb_N0_dB = -3:10;
ber = zeros(size(Eb_N0_dB));
for ii = 1:numel(Eb_N0_dB)
    nerr = 0; nbit = 0;
    while nerr < 100 && nbit < 5e6
        bin_data = owc_randint(1, SigLen);
        bin_signal = owc_rectpulse(2*bin_data - 1, nsamp);   % BPSK +-1
        Tx_signal = bin_signal.*carrier_signal;
        Rx_signal = owc_awgn(Tx_signal, Eb_N0_dB(ii) + 3 - 10*log10(nsamp));
        Rx_output = Rx_signal.*carrier_signal;                % coherent demodulation
        output = sum(reshape(Rx_output, nsamp, SigLen), 1);   % integrate & dump (FIX 1)
        rx_bin_data = double(output > 0);
        nerr = nerr + owc_biterr(rx_bin_data, bin_data);
        nbit = nbit + SigLen;
    end
    ber(ii) = nerr/nbit;
end
figure;
semilogy(Eb_N0_dB, ber, 'bo', 'linewidth', 2); hold on;
semilogy(Eb_N0_dB, 0.5*erfc(sqrt(10.^(Eb_N0_dB/10))), 'r-', 'linewidth', 2);
legend('simulation', 'theory Q(\surd(2E_b/N_0))'); grid on;
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate'); title('BER of BPSK in AWGN');
