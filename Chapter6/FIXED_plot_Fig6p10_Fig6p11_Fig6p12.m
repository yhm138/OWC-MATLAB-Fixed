% FIXED version of Chapter6/CORRECT_plot_Fig6p10_Fig6p11_Fig6p12.m
% Subcarrier intensity modulation (SIM) with M-PSK: constellations of the
% input symbols, of the received symbols with noise only, and with noise +
% log-normal turbulence (Figs. 6.10-6.12).
%
% Fixes w.r.t. the original:
%  1. Only two of the three figures were produced (input and one received
%     constellation); the noise-only and noise+turbulence cases are now both
%     simulated from the same transmitted signal.
%  2. Broken comment line "consecutive subcarriers" (command-syntax call to an
%     undefined function if N_sub > 1) and the stray statement
%     "filter(B2,A2,Q_Dem_out);" removed.
%  3. Local functions in a script are not portable to GNU Octave; the PSK
%     mapper and turbulence model are in util/ (owc_psk_gray) or inline.
%  4. comm.PSKModulator / butter / scatterplot (toolboxes) replaced by a Gray
%     M-PSK mapper and a coherent correlation (integrate-and-dump) receiver,
%     which is the matched filter for rectangular-pulse subcarrier symbols
%     (the original 1st-order BPF + per-symbol 2nd-order LPF restarted from
%     zero state every symbol and sampled a transient).
%  5. Carrier frequencies are integer multiples of Rb and a symbol has exactly
%     Fs*T samples (t = 0:1/Fs:T had one extra sample -> phase slip).
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

N_sub = 1;              % number of subcarriers
symb = 500;             % number of symbols per subcarrier
Rb = 155e6;             % symbol rate
M = 4;                  % M-PSK
Responsivity = 1;
T = 1/Rb;
fmin = 7*Rb;            % first subcarrier (integer multiple of Rb, ~1.1 GHz)
Fs = 50*fmin;           % sampling frequency
ns = round(Fs*T);       % samples per symbol (FIX 5)
t = (0:ns-1)/Fs;
delta = 2*Rb*(N_sub > 1)*ceil((fmin/(Rb))/max(N_sub-1, 1));   % spacing (multiple of Rb)
Ac = 1;                 % subcarrier amplitude
Mod_index = 1/(Ac*N_sub);
% ---------- transmitter ----------
Datain = owc_randint(symb, N_sub, M);
S = owc_psk_gray(Datain, M, pi/4);              % symb x N_sub complex symbols
SIM = zeros(1, symb*ns);
for k = 1:N_sub
    fc = fmin + (k-1)*delta;
    I_sig = kron(real(S(:,k)).', Ac*cos(2*pi*fc*t));
    Q_sig = kron(imag(S(:,k)).', Ac*sin(2*pi*fc*t));
    SIM = SIM + I_sig - Q_sig;
end
SCM_Tx = 1 + Mod_index*SIM;                     % intensity must stay >= 0
% ---------- channel ----------
Io = 1;
SNR_dB = 15;                                     % electrical SNR per symbol at the
                                                 % correlator output (per I/Q branch)
% correlator output noise variance per branch = 2*Noise_var/ns
Noise_var = ns*(Mod_index*Responsivity*Io*Ac)^2/(2*10^(SNR_dB/10));
var_l = 0.1;                                     % log-irradiance variance
l = sqrt(var_l)*randn(1, symb) - var_l/2;        % log-normal, E[I] = Io
I_turb = kron(Io*exp(l), ones(1, ns));           % constant over a symbol
noise = sqrt(Noise_var)*randn(1, symb*ns);
Rx_noise = Responsivity*Io*SCM_Tx + noise;               % noise only
Rx_turb  = Responsivity*I_turb.*SCM_Tx + noise;          % noise + turbulence
% ---------- coherent correlation receiver ----------
demod = @(r, fc) (2/ns)*reshape(r, ns, symb).'*(cos(2*pi*fc*t).') ...
         - 1i*(2/ns)*reshape(r, ns, symb).'*(sin(2*pi*fc*t).');
fc = fmin;                                       % display subcarrier 1
Y_noise = demod(Rx_noise, fc)/(Mod_index*Responsivity*Io*Ac);
Y_turb  = demod(Rx_turb, fc)/(Mod_index*Responsivity*Io*Ac);
figure;   % Fig. 6.10
plot(real(S(:,1)), imag(S(:,1)), 'o'); axis equal; axis([-2 2 -2 2]); grid on;
title('Input symbols constellation'); xlabel('In-phase'); ylabel('Quadrature');
figure;   % Fig. 6.11
plot(real(Y_noise), imag(Y_noise), '.'); axis equal; axis([-2 2 -2 2]); grid on;
title(sprintf('Received constellation, noise only (SNR = %d dB)', SNR_dB));
xlabel('In-phase'); ylabel('Quadrature');
figure;   % Fig. 6.12
plot(real(Y_turb), imag(Y_turb), '.'); axis equal; axis([-2 2 -2 2]); grid on;
title(sprintf('Received constellation, noise + turbulence (\\sigma_l^2 = %.1f)', var_l));
xlabel('In-phase'); ylabel('Quadrature');
% symbol error rates (minimum-distance detection) for information
ang = @(y) mod(round((angle(y) - pi/4)/(2*pi/M)), M);
ref = mod(round((angle(S(:,1)) - pi/4)/(2*pi/M)), M);
fprintf('SER noise only: %.3g, noise+turbulence: %.3g\n', mean(ang(Y_noise) ~= ref), mean(ang(Y_turb) ~= ref));
