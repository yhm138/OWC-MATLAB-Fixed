% FIXED version of Chapter4/CORRECT_program_4p7.m
% Program 4.7: analytical PSD of L-PPM for L = 4, 8, 16.
%
% Fixes w.r.t. the original:
%  1. The bit resolution was fixed at M = 4 while L was varied. For L-PPM,
%     M = log2(L); with M = 4 the slot duration Ts = M/(L*Rb) was wrong for
%     L = 4 and 8 (e.g. L = 4 gave Ts = Tb instead of Tb/2).
%  2. sinc() replaced by util/owc_sinc (Signal Processing Toolbox not needed).
%  3. Axis labels corrected.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

Rb = 1; Tb = 1/Rb;        % normalised bit rate
p_avg = 1; R = 1;
L_values = [4 8 16];
figure; hold on;
for L = L_values
    M = log2(L);                              % FIX 1
    a = R*L*p_avg;                            % pulse amplitude (peak = L*Pavg)
    Ts = M/(L*Rb);                            % slot duration
    f = linspace(0, 8*Rb, 4001);
    P_sq = (a*Ts)^2*owc_sinc(f*Ts).^2;        % |P(f)|^2 of rectangular slot pulse
    temp1 = 0;
    for k = 1:L-1
        temp1 = temp1 + (k/L - 1).*cos(2*pi*k*f*Ts);
    end
    S_c = (1/(L*Ts))*((L-1)/L + (2/L)*temp1); % continuous spectrum
    S = P_sq.*S_c/((p_avg*R)^2*Tb);           % normalised PSD
    plot(f/Rb, S, 'DisplayName', sprintf('L = %d', L));
end
xlabel('Normalised frequency f/R_b');
ylabel('S(f)/((RP_{avg})^2T_b)');
title('Analytical PSD of PPM (continuous part)');
grid on; legend('show'); hold off;
