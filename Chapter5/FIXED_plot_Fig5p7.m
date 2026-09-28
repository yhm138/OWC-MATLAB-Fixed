% FIXED version of Chapter5/CORRECT_plot_Fig5p7.m
% Program 5.3: effect of a first-order high-pass filter (HPF) on OOK-NRZ:
% baseline wander.
%
% Fixes w.r.t. the original:
%  1. Figure had no axis labels/titles; time axis in units of Tb.
%  2. The HPF impulse response is truncated at 10*Tb where exp(-2*pi*fc*t)
%     is still ~4% (fc = 0.05Rb); it is now long enough (<1e-6 residual)
%     so its DC gain is really zero.
%  3. Toolbox-free (my_randint/randsrc, upsample).
%
% Discrete HPF: h[0] = exp(-2 pi fc Tsamp),
%               h[n] = -(exp(2 pi fc Tsamp)-1) exp(-2 pi fc n Tsamp), n >= 1
% (impulse-invariant version of H(s) = s/(s + 2 pi fc)), sum(h) = 0.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

Rb = 1e6; Tb = 1/Rb;        % bit rate / duration
nsamp = 10; Tsamp = Tb/nsamp;
Lsym = 1e3;                 % number of bits
fc_rb = 5e-2;               % normalised HPF cut-on frequency fc/Rb
A = 1;                      % normalised amplitude
tx_impulse = ones(1, nsamp)*A;
fc = fc_rb*Rb;
t = Tsamp:Tsamp:ceil(14/(2*pi*fc_rb))*Tb;      % FIX 2: exp(-14) ~ 1e-6
hpf_impulse = -(exp(2*pi*fc*t(1)) - 1)*exp(-2*pi*fc*t);
hpf_impulse(1) = exp(-2*pi*fc*t(1));
OOK = 2*owc_randint(1, Lsym) - 1;              % bipolar (DC removed)
signal = filter(tx_impulse, 1, owc_upsample(OOK, nsamp));
hpf_output = filter(hpf_impulse, 1, signal);
plotstart = 10*nsamp + 1;
plotfinish = plotstart + 15*nsamp;
tt = (0:plotfinish-plotstart)*Tsamp/Tb;
figure;
subplot(311); plot(tt, signal(plotstart:plotfinish), 'k'); ylabel('Tx'); title('OOK-NRZ signal'); ylim([-1.5 1.5]);
subplot(312); plot(tt, hpf_output(plotstart:plotfinish), 'k'); ylabel('HPF out');
title(sprintf('HPF output, f_c = %.2g R_b', fc_rb));
subplot(313); plot(tt, hpf_output(plotstart:plotfinish) - signal(plotstart:plotfinish), 'k');
ylabel('Wander'); xlabel('t/T_b'); title('Baseline wander (HPF output - input)');
