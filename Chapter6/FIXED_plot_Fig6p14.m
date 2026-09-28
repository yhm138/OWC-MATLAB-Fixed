% FIXED version of Chapter6/WRONG_plot_Fig6p14.m
% BER of SISO BPSK-SIM FSO under weak (log-normal) turbulence for different
% noise-limited regimes (quantum, thermal, background, thermal+background),
% Gauss-Hermite quadrature.
%
% Fixes w.r.t. the original ("PLOT NOT CORRECT"):
%  1. Sky background power: the solid angle of a receiver with (full) FOV
%     theta is pi*theta^2/4, so P_sky = N(lambda)*dLambda*pi*FOV^2/4 * A. The
%     original used 4/pi instead of pi/4.
%  2. util/Q.m computed Q(|x|) and was not vectorised; util/owc_Q is used.
%  3. Axis labels, legend and y-limits added; turbulence-free reference
%     curves (dashed) added so the turbulence penalty is visible.
%
% Electrical SNR of BPSK-SIM, gamma(I) = (R*m*I)^2*Pd/sigma^2, Pd = A^2/2:
%   quantum    : sigma^2 = 2qR I Rb          -> gamma = K1*I
%   thermal    : sigma^2 = 4kT Rb/RL         -> gamma = K2*I^2
%   background : sigma^2 = 2qR (Psun+Psky) Rb -> gamma = K3*I^2
% BER = E_I[ Q(sqrt(gamma(I))) ], I = Io*exp(l), l ~ N(-sigma_l^2/2, sigma_l^2).
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

Rb = 155e6; R = 1; M_ind = 1; A = 1; RL = 50; Temp = 300; wavl = 850e-9;
% background (1 cm^2 receiving aperture)
sky_irra = 1e-3;          % sky spectral radiance at 850 nm, W/cm^2/um/sr
sun_irra = 550e-4;        % sun spectral irradiance at 850 nm, W/cm^2/um
FOV = 0.6;                % receiver field of view (rad)
OBP = 1e-3;               % optical filter bandwidth (um)
Isky = sky_irra*OBP*(pi/4)*FOV^2;   % FIX 1
Isun = sun_irra*OBP;
% turbulence (Rytov variance, plane wave; Cn2 is the structure parameter Cn^2)
Range = 1e3; Cn2 = 0.75e-14;
Varl = 1.23*Cn2*(2*pi/wavl)^(7/6)*Range^(11/6);   % log-irradiance variance (<1)
r = sqrt(Varl);
E_c = 1.602e-19; B_c = 1.38e-23;
Pd = A^2/2;
K1 = (M_ind^2*R*Pd)/(2*E_c*Rb);
K2 = (R*M_ind)^2*Pd*RL/(4*B_c*Temp*Rb);
K3 = (Pd*R*M_ind^2)/(2*E_c*Rb*(Isun + Isky));
K4 = (R*M_ind)^2*Pd/((4*B_c*Temp*Rb/RL) + (2*E_c*R*Rb*(Isun + Isky)));
[x20, w20] = owc_gh20();
Io = logspace(-10, -4, 61);           % average received irradiance/power (W)
IodBm = 10*log10(Io*1e3);
fade = exp(sqrt(2)*r*x20 - Varl/2);   % I/Io at the quadrature nodes (row)
BER1 = (owc_Q(sqrt(K1*Io(:)*fade))*w20.')/sqrt(pi);   % quantum limit
BER2 = (owc_Q(sqrt(K2)*Io(:)*fade)*w20.')/sqrt(pi);   % thermal
BER3 = (owc_Q(sqrt(K3)*Io(:)*fade)*w20.')/sqrt(pi);   % background
BER4 = (owc_Q(sqrt(K4)*Io(:)*fade)*w20.')/sqrt(pi);   % thermal + background
figure;
semilogy(IodBm, BER2, 'o-', IodBm, BER3, '+-', IodBm, BER4, 's-', IodBm, BER1, '.-'); hold on;
set(gca, 'ColorOrderIndex', 1);
semilogy(IodBm, owc_Q(sqrt(K2)*Io), '--', IodBm, owc_Q(sqrt(K3)*Io), '--', ...
         IodBm, owc_Q(sqrt(K4)*Io), '--', IodBm, owc_Q(sqrt(K1*Io)), '--');
% legend below the axes: inside it would hide the lower end of the quantum-limit curve
hl = legend('Thermal noise', 'Background noise', 'Thermal + background', 'Quantum limit', ...
            'location', 'southoutside');
set(hl, 'NumColumns', 2);
xlabel('Average received power (dBm)'); ylabel('BER'); ylim([1e-10 1]); grid on;
title(sprintf('BPSK-SIM, \\sigma_l^2 = %.2f (dashed: no turbulence)', Varl));
