% FIXED version of Chapter4/NEEDFIX_plot_Fig4p5.m
% Fig. 4.5: PSD of OOK-NRZ and OOK-RZ (analytical and simulated).
%
% Fixes w.r.t. the original:
%  1. OOK-NRZ continuous spectrum: for unipolar OOK with peak photocurrent
%     a = 2*R*Pavg the continuous PSD is (a^2*Tb/4)*sinc^2(f*Tb)
%     = (R*Pavg)^2*Tb*sinc^2(f*Tb). The original omitted the factor 1/4, so the
%     normalised PSD was 4x too large. The DC delta (R*Pavg)^2*delta(f) is shown.
%  2. OOK-RZ (duty 0.5) has peak a = 4*R*Pavg; the continuous part is
%     (R*Pavg)^2*Tb*sinc^2(f*Tb/2) and discrete lines (R*Pavg)^2*sinc^2(k/2)
%     appear at f = k*Rb (k = 0 and odd k). Line indices are computed with
%     round() (Rb/df+1 is not guaranteed to be an integer).
%  3. dspdata.psd has been removed from MATLAB; the simulated PSD is now
%     computed with util/owc_psd and normalised the same way as the theory, and
%     both are plotted (the original computed the theory but never plotted it).
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

p_avg = 1; R = 1; Rb = 1; Tb = 1/Rb;
df = Rb/100; f = 0:df:5*Rb;
norm_f = (R*p_avg)^2*Tb;                         % normalisation (R Pavg)^2 Tb
% ---------- analytical ----------
S_nrz = (R*p_avg)^2*Tb*owc_sinc(f*Tb).^2/norm_f; % continuous part, NRZ
S_rz  = (R*p_avg)^2*Tb*owc_sinc(f*Tb/2).^2/norm_f;
k = 0:5;                                         % discrete lines at f = k*Rb
w_rz = (R*p_avg)^2*owc_sinc(k/2).^2/((R*p_avg)^2);   % line powers / (R Pavg)^2
w_rz(abs(w_rz) < 1e-12) = 0;

% ---------- simulation ----------
SigLen = 2^16; nsamp = 16; fsamp = nsamp*Rb;
bits = owc_randint(1, SigLen);
nrz = owc_rectpulse(bits, nsamp)*2*R*p_avg;                         % peak 2 R Pavg
rz_pulse = [ones(1, nsamp/2) zeros(1, nsamp/2)];
rz = reshape(rz_pulse.'*bits, 1, [])*4*R*p_avg;                     % peak 4 R Pavg
nfft = 1024;
[P_nrz, fs_axis] = owc_psd(nrz - mean(nrz), fsamp, nfft);           % remove DC line
[P_rz, ~] = owc_psd(rz - mean(rz), fsamp, nfft);
P_nrz = P_nrz/2/norm_f; P_rz = P_rz/2/norm_f;                       % one-sided -> two-sided level

figure;
subplot(2,1,1);
plot(f/Rb, S_nrz, 'k', 'linewidth', 1.5); hold on;
plot(fs_axis/Rb, P_nrz, 'r--');
stem(0, 1/Tb, 'k^', 'filled');                                      % DC delta weight (R Pavg)^2
xlim([0 5]); ylim([0 1.4]); grid on;
xlabel('Normalised frequency f/R_b'); ylabel('S(f)/((RP_{avg})^2T_b)');
legend('theory (continuous part)', 'simulation', 'discrete component');
title('PSD of OOK-NRZ');
subplot(2,1,2);
plot(f/Rb, S_rz, 'k', 'linewidth', 1.5); hold on;
plot(fs_axis/Rb, P_rz, 'r--');
stem(k(w_rz > 0), w_rz(w_rz > 0)/Tb, 'k^', 'filled');
xlim([0 5]); ylim([0 1.4]); grid on;
xlabel('Normalised frequency f/R_b'); ylabel('S(f)/((RP_{avg})^2T_b)');
legend('theory (continuous part)', 'simulation', 'discrete components');
title('PSD of OOK-RZ (\gamma = 0.5)');
% (the simulated discrete lines of RZ at f = Rb, 3Rb, ... are clipped by ylim)
% numerical check of the continuous part at low frequency
fprintf('NRZ: sim %.3f vs theory %.3f at f ~ %.3f Rb\n', P_nrz(3), owc_sinc(fs_axis(3)*Tb)^2, fs_axis(3)/Rb);
