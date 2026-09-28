% FIXED version of Chapter8/NEEDFIX_plot_Fig8p14.m
% Received optical power distribution due to the first reflections from the
% four walls, four LED clusters (Fig. 8.14), plus the LOS + reflection total.
%
% Fixes w.r.t. the original:
%  1. Only wall 1 was computed and the other walls were copied (h2 = h3 = h4 = h1),
%     which is wrong (the walls are at different positions relative to each
%     receiver point). All four walls are computed.
%  2. Only one transmitter at the ceiling centre (TP1 = [0 0 lz/2]) was used
%     although four LED clusters were defined (XT, YT). All four are used.
%  3. The quadruple loop is vectorised over wall elements.
%  4. The plot grid orientation: h1(ii,jj) was indexed (x,y) but surf(x,y,Z)
%     expects Z(y,x); now consistent.
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

theta = 70;
m = -log(2)/log(cosd(theta));
P_LED = 20; nLED = 60;
P_total = nLED*nLED*P_LED;          % mW per LED cluster
Adet = 1e-4; rho = 0.8; Ts = 1; index = 1.5;
FOV = 70; G_Con = (index^2)/sind(FOV)^2;
lx = 5; ly = 5; lz = 2.15;          % lz = distance ceiling -> receiver plane
ngrid = 10;                         % grid points per metre
Nx = lx*ngrid; Ny = ly*ngrid;
x = -lx/2 + lx/Nx*((1:Nx) - 0.5);   % receiver grid at cell centres (a receiver
y = -ly/2 + ly/Ny*((1:Ny) - 0.5);   % lying in a wall plane sees no reflection)
TP = [-lx/4 -ly/4 lz/2; lx/4 -ly/4 lz/2; -lx/4 ly/4 lz/2; lx/4 ly/4 lz/2];
[W, Nw, dA] = owc_room_walls(lx, ly, lz, ngrid);
% transmitter -> wall element gains (summed over the four clusters)
g1 = zeros(size(dA));
for s = 1:size(TP, 1)
    V1 = W - TP(s,:);
    D1 = sqrt(sum(V1.^2, 2));
    cos_phi = -V1(:,3)./D1;
    cos_alpha = -sum(V1.*Nw, 2)./D1;
    g = (m+1)/(2*pi)*cos_phi.^m.*cos_alpha./D1.^2;
    g(cos_phi <= 0 | cos_alpha <= 0) = 0;
    g1 = g1 + g;
end
g1 = g1.*rho.*dA;
h_ref = zeros(Ny, Nx); h_los = zeros(Ny, Nx);
for ii = 1:Nx
    for jj = 1:Ny
        RP = [x(ii) y(jj) -lz/2];
        V2 = RP - W;
        D2 = sqrt(sum(V2.^2, 2));
        cos_beta = sum(V2.*Nw, 2)./D2;
        cos_psi = -V2(:,3)./D2;
        ok = cos_psi >= cosd(FOV) & cos_beta > 0;
        h_ref(jj,ii) = sum(g1(ok).*Adet.*cos_beta(ok).*cos_psi(ok)./(pi*D2(ok).^2));
        for s = 1:size(TP, 1)
            d0 = norm(TP(s,:) - RP); c0 = lz/d0;
            if c0 >= cosd(FOV)
                h_los(jj,ii) = h_los(jj,ii) + (m+1)*Adet*c0^(m+1)/(2*pi*d0^2);
            end
        end
    end
end
P_rec_1ref_dBm = 10*log10(h_ref*P_total*Ts*G_Con);
P_rec_tot_dBm = 10*log10((h_ref + h_los)*P_total*Ts*G_Con);
figure;
subplot(1,2,1); surf(x, y, P_rec_1ref_dBm); shading interp;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Received power (dBm)'); title('First reflections');
subplot(1,2,2); surf(x, y, P_rec_tot_dBm); shading interp;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Received power (dBm)'); title('LOS + first reflections');
in = P_rec_1ref_dBm;
fprintf('First-reflection power: %.2f ... %.2f dBm\n', min(in(:)), max(in(:)));
