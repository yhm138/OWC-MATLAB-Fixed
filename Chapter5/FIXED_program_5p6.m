% FIXED version of Chapter5/program_5p6.m
% Program 5.6: ceiling-bounce model of a diffuse channel and the eye diagram
% of the received OOK-NRZ signal.
%
% Fixes w.r.t. the original:
%  1. "pt = ones(1,nsamp)" had no semicolon (printed the vector); the unused
%     variable c was removed.
%  2. eyediagram() (Communications Toolbox) replaced by a plain plot of
%     overlaid 2-bit traces; the ceiling-bounce impulse response is plotted too.
%  3. Several normalised delay spreads are shown so the ISI can be compared.
%
% Ceiling-bounce model: h(t) = 6 a^6/(t+a)^7 u(t), a = 12 sqrt(11/13) Drms.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

Rb = 200e6; Tb = 1/Rb;    % bit rate / duration
sig_length = 1e3;         % number of bits
nsamp = 10; Tsamp = Tb/nsamp;
Dt_list = [0.1 0.3 0.5];  % normalised delay spread Drms/Tb
OOK = owc_randint(1, sig_length);
Tx_signal = owc_rectpulse(OOK, nsamp);
figure;
for n = 1:numel(Dt_list)
    Drms = Dt_list(n)*Tb;
    a = 12*sqrt(11/13)*Drms;
    k = 0:30*nsamp;                            % channel taps
    h = (6*a^6)./((k*Tsamp + a).^7);
    h = h/sum(h);                              % unit DC gain (energy conservation)
    channel_output = conv(Tx_signal, h);
    subplot(2, numel(Dt_list), n);
    plot(k*Tsamp/Tb, h, 'k'); xlim([0 5]);
    xlabel('t/T_b'); ylabel('h(t) (normalised)');
    title(sprintf('D_T = %.1f', Dt_list(n)));
    % eye diagram: 2-bit windows, skipping the first 10 bits (transient)
    subplot(2, numel(Dt_list), numel(Dt_list) + n);
    seg = 2*nsamp;
    first = 10*nsamp + 1; nseg = floor((numel(Tx_signal) - first - seg)/nsamp);
    idx = first + (0:seg).' + (0:nseg-1)*nsamp;
    plot((0:seg)/nsamp, channel_output(idx), 'b');
    xlabel('t/T_b'); ylabel('Amplitude'); ylim([-0.1 1.1]);
    title(sprintf('Eye diagram, D_T = %.1f', Dt_list(n)));
end
