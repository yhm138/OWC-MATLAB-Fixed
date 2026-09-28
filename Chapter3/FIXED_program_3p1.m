% FIXED version of Chapter3/program_3p1.m
% Program 3.1: LOS channel gain / received optical power on the receiving plane
% (single Lambertian LED in the centre of the ceiling).
%
% Fixes w.r.t. the original:
%  1. Optical concentrator gain is n^2/sin^2(FOV), not n^2/sin(FOV).
%  2. The concentrator only accepts light within its FOV: H = 0 for psi > FOV.
%  3. Units made explicit: power in mW, so 10*log10(P) is in dBm.
clear; clc; close all;

theta = 70;                           % LED semi-angle at half power (deg)
m = -log(2)/log(cosd(theta));         % Lambertian order of emission
P_total = 20;                         % transmitted optical power of the LED (mW)
Adet = 1e-4;                          % detector physical area of the PD (m^2)
%% Optics parameters
Ts = 1;                               % gain of optical filter (1 if not used)
index = 1.5;                          % refractive index of the concentrator
FOV = 60;                             % receiver field of view, semi-angle (deg)
G_Con = (index^2)/sind(FOV)^2;        % gain of the optical concentrator (FIX 1)
%% Room dimension
lx = 5; ly = 5; lz = 3;               % room dimension (m)
h = 2.15;                             % distance between source and receiver plane (m)
Nx = lx*20; Ny = ly*20;               % number of grid points in the receiver plane
XT = 0; YT = 0;                       % position of the LED
x = linspace(-lx/2, lx/2, Nx+1);
y = linspace(-ly/2, ly/2, Ny+1);
[XR, YR] = meshgrid(x, y);            % receiver plane grid
D1 = sqrt((XR-XT).^2 + (YR-YT).^2 + h^2);   % LED-to-receiver distance
cosphi = h./D1;                       % cos(irradiance angle) = cos(incidence angle)
psi = acosd(cosphi);                  % incidence angle at the receiver (deg)
%% LOS DC channel gain
H_LOS = (m+1)*Adet.*cosphi.^(m+1)./(2*pi.*D1.^2);  % = (m+1)A/(2 pi d^2) cos^m(phi) cos(psi)
H_LOS(psi > FOV) = 0;                 % FIX 2: outside the FOV nothing is received
P_rec = P_total.*H_LOS.*Ts.*G_Con;    % received power (mW)
P_rec_dBm = 10*log10(P_rec);          % (dBm)

figure;
meshc(x, y, P_rec_dBm);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Received power (dBm)');
title(sprintf('LOS received power, \\Phi_{1/2}=%g^o, FOV=%g^o', theta, FOV));
axis([-lx/2 lx/2 -ly/2 ly/2 min(P_rec_dBm(:)) max(P_rec_dBm(:))]);
fprintf('Received power: max %.2f dBm, min %.2f dBm\n', max(P_rec_dBm(:)), min(P_rec_dBm(:)));
