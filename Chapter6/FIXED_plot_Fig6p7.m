% FIXED version of Chapter6/WRONG_plot_Fig6p7.m
% BER of binary PPM (BPPM) FSO with an APD receiver under weak (log-normal)
% turbulence, eq. (6.16), averaged by Gauss-Hermite quadrature.
%
% Fixes w.r.t. the original ("PLOT NOT CORRECT"):
%  1. Typo in the 4th Gauss-Hermite weight: 7.8025564785e6 instead of
%     7.8025564785e-6 (a weight of ~8 million!) -> nonsense BER > 1.
%  2. The quadrature loop started at j = i (the scintillation-index loop
%     counter) instead of j = 1, so nodes were skipped.
%  3. Q-function argument: the decision statistic is the photon-count
%     difference Ks with variance F*(Ks+2Kb) + 2*sigma_th^2/(qG)^2, so
%     BER = Q( Ks / sqrt(F*(Ks+2Kb) + Kth) ). The original used Ks^2/var
%     (missing square root).
%  4. The ambient temperature variable "Temp" was re-used as the
%     quadrature accumulator. Labels/legend added; nodes/weights from util/owc_gh20.
%
% Ks: mean signal photon count per slot, Kb: background count per slot,
% F = 2 + G*zeta (APD excess noise factor, approximation), G: APD gain.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

[x20, w20] = owc_gh20();
Rb = 155e6;             % bit rate
RL = 50;                % load resistance (ohm)
T_amb = 300;            % ambient temperature (K)
E_c = 1.602e-19;        % electron charge
B_c = 1.38e-23;         % Boltzmann constant
Ts = 1/(2*Rb);          % BPPM slot duration
NoTh = 2*B_c*T_amb*Ts/RL;  % thermal-noise charge variance per slot (C^2)
zeta = 0.028;           % APD ionisation ratio
Kb = 10;                % background photon count per slot
gain = 150;             % APD average gain
F = 2 + gain*zeta;      % excess noise factor
Kn = 2*NoTh/(gain*E_c)^2 + 2*F*Kb;   % count variance independent of Ks
Ks1 = [140 180 220 260 300];
S_I = 0.1:0.1:0.9;      % scintillation index
BER = zeros(numel(Ks1), numel(S_I));
for i1 = 1:numel(Ks1)
    Ks = Ks1(i1);
    for i = 1:numel(S_I)
        Sk = log(S_I(i) + 1);            % log-intensity variance sigma_l^2
        Mk = log(Ks) - Sk/2;             % mean of ln(Ks) (E[Ks] = Ks)
        acc = 0;
        for j = 1:numel(x20)             % FIX 2
            ks = exp(sqrt(2*Sk)*x20(j) + Mk);          % faded signal count
            acc = acc + w20(j)*owc_Q(ks/sqrt(F*ks + Kn));   % FIX 3
        end
        BER(i1, i) = acc/sqrt(pi);
    end
end
figure;
semilogy(S_I, BER, 'o-');
legend(arrayfun(@(k) sprintf('K_s = %d', k), Ks1, 'UniformOutput', false), 'location', 'southeast');
xlabel('Scintillation index'); ylabel('BER'); grid on;
title(sprintf('BPPM, APD (G = %d, K_b = %d), log-normal turbulence', gain, Kb));
