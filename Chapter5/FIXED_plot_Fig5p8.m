% FIXED version of Chapter5/CORRECT_plot_Fig5p8.m
% Distribution of the matched-filter output of OOK-NRZ affected by baseline
% wander (first-order HPF, fc = 1e-3 Rb).
%
% Fixes w.r.t. the original:
%  1. The three bar() calls drew into the same axes, so only the last
%     histogram was visible; each histogram now has its own subplot.
%  2. expect_one could be a vector (several bins with the same count);
%     the peak is taken as a scalar.
%  3. set(0,'default...') was called after plotting (no effect) - removed.
%  4. The HPF impulse response is long enough (200 Tb is ~1.3 time constants
%     for fc = 1e-3 Rb; now ~12 time constants), toolbox-free random data.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

Rb = 1e6; Tb = 1/Rb;
nsamp = 10; Tsamp = Tb/nsamp;
Lsym = 1e5;                 % number of bits
fc_rb = 1e-3;               % normalised cut-on frequency
fc = fc_rb*Rb;
p_ave = 1; p_peak = 2*p_ave;
tx_impulse = ones(1, nsamp)*p_peak;
mf_impulse = ones(1, nsamp)*(1/sqrt(Tb));
Nh = ceil(12/(2*pi*fc_rb));                     % bits spanned by the HPF response
t = Tsamp:Tsamp:Nh*Tb;
hpf_impulse = -(exp(2*pi*fc*t(1)) - 1)*exp(-2*pi*fc*t);
hpf_impulse(1) = exp(-2*pi*fc*t(1));
temp = conv(conv(tx_impulse, hpf_impulse), mf_impulse)*Tsamp;
system_impulse = temp(nsamp:nsamp:Nh*nsamp);    % bit-spaced system response
expected_one = 0.5*p_peak*sqrt(Tb);
OOK = 2*owc_randint(1, Lsym) - 1;               % DC removed
mf_output = filter(system_impulse, 1, OOK)/(2*expected_one);   % ideal output = +-1
mf_output = mf_output(Nh+1:end); OOK = OOK(Nh+1:end);          % drop transient
mf_output_one = mf_output(OOK == 1);
mf_output_zero = mf_output(OOK == -1);
edges = linspace(-1.3, 1.3, 105); centres = (edges(1:end-1) + edges(2:end))/2;
n_zero = histc(mf_output_zero, edges); n_zero = n_zero(1:end-1);
n_one = histc(mf_output_one, edges);   n_one = n_one(1:end-1);
[~, ip] = max(n_one); expect_one = centres(ip);
[~, iz] = max(n_zero); expect_zero = centres(iz);
figure;
subplot(3,1,1); bar(centres, n_zero, 1); title('Transmitted "0" (-1)'); ylabel('Count');
subplot(3,1,2); bar(centres, n_one, 1);  title('Transmitted "1" (+1)'); ylabel('Count');
% both distributions shifted to zero and combined (identical shape once DC is removed)
w = centres(2) - centres(1);
comb = [mf_output_one - expect_one, mf_output_zero - expect_zero];
e2 = (-0.4:w:0.4); n_tot = histc(comb, e2);
subplot(3,1,3); bar(e2(1:end-1) + w/2, n_tot(1:end-1), 1);
title('Combined, shifted to zero'); xlabel('Normalised matched filter output'); ylabel('Count');
