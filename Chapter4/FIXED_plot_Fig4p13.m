% FIXED version of Chapter4/CORRECT_plot_Fig4p13.m
% Program 4.10: analytical PSD of DPIM with no guard slot, L = 4, 8, 16, 32.
%
% Fixes w.r.t. the original:
%  1. The PSD was plotted un-normalised but labelled "dB/Hz"; it is now
%     normalised as in the book, S(f)/((R*Pavg)^2*Tb), on a linear axis vs f/Rb.
%  2. The asymptotic-ACF loop overwrote r(5L+1) (= R(5L)) with 1/Lavg^2;
%     index offset fixed (r(k+1) = R(k) consistently). r is reset for every L.
%  3. sinc() replaced by util/owc_sinc; unused variables removed.
%
% Slot autocorrelation R(k) (renewal process, symbol length uniform in 1..L):
%   R(0) = 1/Lavg, R(k) = 2(L+1)^(k-2)/L^k for 1<=k<=L,
%   R(k) = (1/L) sum_{i=1..L} R(k-i) for k > L,  R(inf) = 1/Lavg^2.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

Rb = 1; Tb = 1/Rb;
p_avg = 1; R = 1;
Kmax = 1000;
figure; hold on;
for M = 2:5
    L = 2^M;
    Lavg = 0.5*(L + 1);
    a = R*Lavg*p_avg;                  % pulse amplitude
    Ts = M/(Lavg*Rb);                  % slot duration
    f = linspace(0, 8*Rb, 4001);
    r = zeros(1, Kmax+1);              % r(k+1) = R(k)
    r(1) = 1/Lavg;
    for k = 1:L
        r(k+1) = (2/(L^k))*((L+1)^(k-2));
    end
    for k = L+1:5*L
        r(k+1) = sum(r(k-(1:L)+1))/L;
    end
    r(5*L+2:end) = 1/Lavg^2;           % FIX 2: R(k) for k > 5L
    P_sq = (a*Ts)^2*owc_sinc(f*Ts).^2;
    term2 = 0;
    for k = 1:Kmax
        term2 = term2 + (r(k+1) - 1/Lavg^2)*cos(2*pi*k*f*Ts);
    end
    p = (1/Ts)*P_sq.*((r(1) - 1/Lavg^2) + 2*term2);
    p = p/((p_avg*R)^2*Tb);           % FIX 1
    plot(f/Rb, p, 'DisplayName', sprintf('L = %d', L));
end
title('PSD of DPIM (0 guard slots), continuous part');
xlabel('Normalised frequency f/R_b'); ylabel('S(f)/((RP_{avg})^2T_b)');
legend('show'); grid on; hold off;
