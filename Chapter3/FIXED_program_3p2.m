% FIXED version of Chapter3/NEEDFIX_program_3p2.m
% Program 3.2: optical power distribution in a diffuse (first-reflection) channel.
%
% Fixes w.r.t. the original:
%  1. The original only computed wall 1 and set the gains of the other three
%     walls to the dummy value h2 = h3 = h4 = 1. All four walls are computed.
%  2. The quadruple loop (~2e8 iterations, "calculation time too long") is
%     replaced by a loop over receiver points vectorised over the wall
%     elements (seconds instead of hours).
%  3. The concentrator gain / FOV test is applied to the reflected rays,
%     and wall elements are counted only once (the original also used an
%     unused transmitter-orientation, C, etc.).
%  4. Results are plotted (the original produced no output). The LOS
%     component is also computed so the total power distribution can be shown.
clear; clc; close all;

theta = 70;                           % LED semi-angle at half power (deg)
m = -log(2)/log(cosd(theta));         % Lambertian order of emission
P_total = 1;                          % total transmitted power (W, normalised)
Adet = 1e-4;                          % detector physical area (m^2)
rho = 0.8;                            % wall reflection coefficient
Ts = 1;                               % optical filter gain
index = 1.5;                          % refractive index of the concentrator
FOV = 60;                             % receiver FOV semi-angle (deg)
G_Con = (index^2)/sind(FOV)^2;        % concentrator gain

lx = 5; ly = 5; lz = 2.15;            % room size (m); lz = LED-to-receiver-plane height
ngrid = 20;                           % grid points per metre (original used 30)
Nx = lx*ngrid; Ny = ly*ngrid; Nz = round(lz*ngrid);
x = -lx/2 + lx/Nx*((1:Nx) - 0.5);   % receiver grid at cell centres (a receiver
y = -ly/2 + ly/Ny*((1:Ny) - 0.5);   % lying in a wall plane sees no reflection)
z = linspace(-lz/2, lz/2, Nz);
TP = [0 0 lz/2];                      % transmitter position (ceiling centre, facing down)

% ----- wall elements: position, unit normal (pointing into the room), area -----
[Yw, Zw] = meshgrid(y, z);  [Xw, Zw2] = meshgrid(x, z);
nYZ = numel(Yw); nXZ = numel(Xw);
W = [ -lx/2*ones(nYZ,1) Yw(:) Zw(:);            % wall 1: x = -lx/2
       lx/2*ones(nYZ,1) Yw(:) Zw(:);            % wall 2: x = +lx/2
       Xw(:) -ly/2*ones(nXZ,1) Zw2(:);          % wall 3: y = -ly/2
       Xw(:)  ly/2*ones(nXZ,1) Zw2(:) ];        % wall 4: y = +ly/2
Nw = [ repmat([ 1 0 0], nYZ, 1); repmat([-1 0 0], nYZ, 1);
       repmat([ 0 1 0], nXZ, 1); repmat([ 0 -1 0], nXZ, 1) ];
dA = [ repmat(ly*lz/(Ny*Nz), 2*nYZ, 1); repmat(lx*lz/(Nx*Nz), 2*nXZ, 1) ];

% ----- transmitter -> wall element (independent of receiver position) -----
V1 = W - TP;                                     % vectors LED -> wall element
D1 = sqrt(sum(V1.^2, 2));
cos_phi = -V1(:,3)./D1;                          % LED faces -z
cos_alpha = -sum(V1.*Nw, 2)./D1;                 % incidence angle at the wall
g1 = (m+1)/(2*pi)*cos_phi.^m.*cos_alpha./D1.^2 .* rho.*dA;   % power per unit Tx power
g1(cos_phi <= 0 | cos_alpha <= 0) = 0;

h_ref = zeros(Ny, Nx);  h_los = zeros(Ny, Nx);
for ii = 1:Nx
    for jj = 1:Ny
        RP = [x(ii) y(jj) -lz/2];                % receiver faces +z
        V2 = RP - W;                             % wall element -> receiver
        D2 = sqrt(sum(V2.^2, 2));
        cos_beta = sum(V2.*Nw, 2)./D2;           % irradiance angle from the wall
        cos_psi = -V2(:,3)./D2;                  % incidence angle at the PD
        ok = (cos_psi >= cosd(FOV)) & (cos_beta > 0);
        h_ref(jj,ii) = sum(g1(ok).*Adet.*cos_beta(ok).*cos_psi(ok)./(pi*D2(ok).^2));
        % LOS component
        d0 = norm(TP - RP); c0 = lz/d0;
        if c0 >= cosd(FOV)
            h_los(jj,ii) = (m+1)*Adet*c0^(m+1)/(2*pi*d0^2);
        end
    end
end
P_rec_ref = h_ref*P_total*Ts*G_Con;              % first-reflection power (W)
P_rec_tot = (h_ref + h_los)*P_total*Ts*G_Con;    % LOS + first reflection (W)

figure;
subplot(1,2,1); surf(x, y, 10*log10(P_rec_ref*1e3)); shading interp;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Received power (dBm)');
title('First-reflection (diffuse) power');
subplot(1,2,2); surf(x, y, 10*log10(P_rec_tot*1e3)); shading interp;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Received power (dBm)');
title('LOS + first-reflection power');
inner = P_rec_ref;
fprintf('Diffuse power: max %.2f dBm, min %.2f dBm (P_total = %g W)\n', ...
    10*log10(max(inner(:))*1e3), 10*log10(min(inner(:))*1e3), P_total);
