% FIXED version of Chapter5/CORRECT_demo_Fig5p38.m
% BER of unequalised OOK-NRZ over a diffuse (ceiling-bounce) channel with a
% matched-filter receiver (ISI penalty).
%
% Fixes w.r.t. the original:
%  1. Inconsistent parameters: Tsamp = 16 with Tb = 3 and nsamp = 16
%     (Tsamp must be Tb/nsamp), and a threshold Ep/2 = 0.25 that had nothing to
%     do with the actual matched filter output i_peak^2*Tb*... -> every bit
%     was detected as "1". Energies are now derived from the parameters.
%  2. The sampling instant uses the peak of the overall impulse response
%     (Tx filter * channel * matched filter), and the output is aligned with it.
%  3. The BER was never computed; BER vs Eb/N0 is now simulated for several
%     normalised delay spreads DT and compared with the ISI-free theory.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

Rb = 1; Tb = 1/Rb;          % normalised bit rate
nsamp = 16; Tsamp = Tb/nsamp;
sig_length = 2e5;
i_peak = 1;                 % peak photocurrent (normalised)
EbN0_dB = 0:1:14;
Dt_list = [0 0.05 0.1 0.15];
ber = nan(numel(Dt_list), numel(EbN0_dB));
OOK = owc_randint(1, sig_length);
Tx_signal = owc_rectpulse(OOK, nsamp)*i_peak;
pt = ones(1, nsamp)*i_peak; rt = pt;           % Tx filter and matched Rx filter
Ep = i_peak^2*Tb;                              % peak energy, Eb = Ep/2
for d = 1:numel(Dt_list)
    if Dt_list(d) == 0
        h = 1;
    else
        Drms = Dt_list(d)*Tb;
        a = 12*sqrt(11/13)*Drms;
        k = 0:30*nsamp;
        h = (6*a^6)./((k*Tsamp + a).^7);
        h = h/sum(h);                          % unit DC gain
    end
    c = conv(conv(pt, h), rt)*Tsamp;           % overall impulse response
    [~, delay] = max(c);                       % optimum sampling instant (FIX 2)
    channel_output = conv(Tx_signal, h);
    for e = 1:numel(EbN0_dB)
        N0 = (Ep/2)/10^(EbN0_dB(e)/10);
        sgma = sqrt(N0/2/Tsamp);
        Rx_signal = channel_output + sgma*randn(size(channel_output));
        MF_out = conv(Rx_signal, rt)*Tsamp;
        MF_out_downsamp = MF_out(delay:nsamp:end);
        MF_out_downsamp = MF_out_downsamp(1:sig_length);
        Rx_th = double(MF_out_downsamp > Ep/2);  % threshold at Ep/2 (FIX 1)
        [~, ber(d, e)] = owc_biterr(OOK, Rx_th);
    end
end
figure;
semilogy(EbN0_dB, ber, 'o-'); hold on;
semilogy(EbN0_dB, owc_Q(sqrt(10.^(EbN0_dB/10))), 'k--', 'linewidth', 1.5);
lg = arrayfun(@(x) sprintf('D_T = %.2f', x), Dt_list, 'UniformOutput', false);
legend([lg, {'theory, no ISI'}], 'location', 'southwest');
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate'); ylim([1e-5 1]); grid on;
title('Unequalised OOK-NRZ over the ceiling-bounce channel');
