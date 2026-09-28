% FIXED version of Chapter8/CORRECT_plot_Fig8p10.m
% Program 8.1: LOS optical power distribution on the receiving plane of a
% 5 x 5 x 3 m room with four LED clusters (60 x 60 LEDs of 20 mW each).
%
% Fixes w.r.t. the original:
%  1. theta was assigned twice (70 then 12.5), so the 70-degree case of
%     Fig. 8.10 could never be produced; both semi-angles are now computed
%     and plotted side by side.
%  2. Units made explicit: powers in mW, so 10*log10(P) is in dBm.
%  3. Axis labels and titles added; the four LED contributions are computed
%     explicitly (no reliance on the fliplr/flipud symmetry trick, which is
%     only valid for a symmetric grid and symmetric LED positions).
clear; clc; close all;

theta_list = [70 12.5];       % LED semi-angles at half power (deg)
P_LED = 20;                   % optical power per LED (mW)
nLED = 60;                    % nLED x nLED LEDs per cluster
P_total = nLED*nLED*P_LED;    % power per cluster (mW)
Adet = 1e-4;                  % PD area (m^2)
Ts = 1; index = 1.5;
FOV = 70;                     % receiver FOV (deg)
G_Con = (index^2)/sind(FOV)^2;
lx = 5; ly = 5; lz = 3;
h = 2.15;                     % LED-to-receiver-plane distance (m)
[XT, YT] = meshgrid([-lx/4 lx/4], [-ly/4 ly/4]);   % four LED clusters
Nx = lx*20; Ny = ly*20;
x = linspace(-lx/2, lx/2, Nx);
y = linspace(-ly/2, ly/2, Ny);
[XR, YR] = meshgrid(x, y);
figure;
for n = 1:numel(theta_list)
    ml = -log(2)/log(cosd(theta_list(n)));
    P_rec_total = zeros(size(XR));
    for s = 1:numel(XT)
        D1 = sqrt((XR - XT(s)).^2 + (YR - YT(s)).^2 + h^2);
        cosphi = h./D1;
        H = (ml+1)*Adet.*cosphi.^(ml+1)./(2*pi*D1.^2);
        H(acosd(cosphi) > FOV) = 0;
        P_rec_total = P_rec_total + P_total.*H.*Ts.*G_Con;
    end
    P_rec_dBm = 10*log10(P_rec_total);
    subplot(1, numel(theta_list), n);
    surfc(x, y, P_rec_dBm); shading interp;
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Received power (dBm)');
    title(sprintf('\\Phi_{1/2} = %g^o: %.1f to %.1f dBm', theta_list(n), ...
        min(P_rec_dBm(:)), max(P_rec_dBm(:))));
    fprintf('theta = %4.1f deg: Pr = %.2f ... %.2f dBm\n', theta_list(n), min(P_rec_dBm(:)), max(P_rec_dBm(:)));
end
