% FIXED version of Chapter8/NEO_program_8p4.m (and OLD_program_8p4.m)
% Program 8.4: 4x4 optical MIMO (imaging-diversity) link with L-PAM and
% zero-forcing (pseudo-inverse) detection.
%
% Fixes w.r.t. the original:
%  1. Bit counting: every iteration transmits TxN*nsym symbols of M bits,
%     but only nsym*M bits were counted -> BER overestimated by a factor TxN (4x).
%  2. OLD_program_8p4 used the removed modem.pammod/modem.pamdemod API and
%     had statements broken across lines; NEO_program_8p4 needs the
%     Communications Toolbox (comm.PAMModulator). A Gray-PAM mapper/demapper
%     from util/ is used instead, so it runs in base MATLAB and GNU Octave.
%  3. biterr on symbol values counted symbol errors only for M = 1; bit
%     errors are now counted for any M (owc_biterr with M bits/symbol).
%  4. clc inside the Monte-Carlo loop removed; the ideal channel (H = I) is
%     plotted for comparison.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

TxN = 4; RxN = 4;
M = 1;                      % bits per symbol per channel
L = 2^M;                    % PAM levels
nsym = 1000;
min_BitsToTest = 1e6;
max_BitError = 100;
SNR_dB = 1:1:30;
Hmat = [0.4961 0.4936 0.4906 0.4931; ...
        0.1995 0.6526 0.4115 0.0529; ...
        0      0.0879 0.5623 0.2001; ...
        0.0075 0      0.0538 0.4057];
Hmat = Hmat./sum(Hmat(:));
channels = {Hmat, eye(4)/4};              % measured channel, ideal (same total gain)
names = {'MIMO channel H', 'ideal channel (H = I/4)'};
figure;
for c = 1:numel(channels)
    H = channels{c};
    BER = nan(1, numel(SNR_dB));
    for jj = 1:numel(SNR_dB)
        total_nbit = 0; total_nerr = 0;
        while total_nbit < min_BitsToTest && total_nerr <= max_BitError
            DataSymbolIn = owc_randint(TxN, nsym, L);
            Tx_signal = owc_pam_gray(DataSymbolIn, L) + (L-1);    % unipolar (intensity)
            Rx_bit = owc_awgn(H*Tx_signal, SNR_dB(jj) + 3);
            received_signal = pinv(H)*Rx_bit;                     % ZF
            received_signal = received_signal - mean(received_signal, 2);   % remove DC
            DataSymbolOut = owc_pamdemod_gray(received_signal, L);
            nerr = owc_biterr(DataSymbolOut, DataSymbolIn, M);
            total_nbit = total_nbit + TxN*nsym*M;                 % FIX 1
            total_nerr = total_nerr + nerr;
        end
        BER(jj) = total_nerr/total_nbit;
        if BER(jj) == 0, break; end
    end
    semilogy(SNR_dB, BER, 'o-', 'DisplayName', names{c}); hold on;
end
xlabel('SNR (dB)'); ylabel('BER'); grid on; legend('show');
title(sprintf('4x4 optical MIMO, %d-PAM, zero-forcing', L));
