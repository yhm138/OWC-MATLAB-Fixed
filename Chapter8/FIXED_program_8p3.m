% FIXED version of Chapter8/NEEDFIX_program_8p3.m
% Program 8.3: RMS delay spread D_rms over the receiving plane (LOS + first
% reflections), four LED clusters.
%
% Fixes w.r.t. the original:
%  1. Only transmitter TP1 and wall 1 were included ("calculate the h_vector
%     from all the walls and all the transmitters" was left as a comment).
%     All four transmitters and all four walls are now included.
%  2. The impulse-response window was 30 ns, but first-reflection paths in a
%     5 x 5 m room are up to ~50 ns long (D1+D2 up to ~15 m); late arrivals
%     were silently dropped (find() returned empty). The window is now set
%     from the longest path.
%  3. The variable "index" (lens refractive index) was overwritten by the
%     time-bin index; delay binning is done with accumarray-like indexing.
%  4. Vectorised over wall elements (the original quadruple loop was very slow).
%  5. Time resolution 0.5 ns -> 0.1 ns and receiver grid 0.1 m -> 0.05 m
%     (wall elements 0.05 m): with 0.5-ns bins the LOS arrivals of the four
%     LEDs were rounded to a few bins, which made the surface spiky.
%  D_rms = sqrt( sum((t-tau0)^2 h^2) / sum(h^2) ), tau0 = sum(t h^2)/sum(h^2).
clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'));

C = 3e8*1e-9;                        % speed of light in m/ns
theta = 70; m = -log(2)/log(cosd(theta));
Adet = 1e-4; rho = 0.8; FOV = 60;
lx = 5; ly = 5; lz = 3 - 0.85;       % receiver plane 0.85 m above the floor
ngrid_rx = 20;                       % receiver grid points per metre
ngrid_wall = 20;                     % wall elements per metre
Nx = lx*ngrid_rx; Ny = ly*ngrid_rx;
x = -lx/2 + lx/Nx*((1:Nx) - 0.5);   % receiver grid at cell centres (a receiver
y = -ly/2 + ly/Ny*((1:Ny) - 0.5);   % lying in a wall plane sees no reflection)
TP = [-lx/4 -ly/4 lz/2; lx/4 ly/4 lz/2; lx/4 -ly/4 lz/2; -lx/4 ly/4 lz/2];
[W, Nw, dA] = owc_room_walls(lx, ly, lz, ngrid_wall);
delta_t = 0.1;                       % time resolution (ns)
Tmax = 2*sqrt(lx^2 + ly^2 + lz^2)/C; % upper bound on first-reflection delay (FIX 2)
t_vector = 0:delta_t:ceil(Tmax);
nt = numel(t_vector);
% transmitter -> wall element parts, per transmitter
nTx = size(TP, 1);
g1 = zeros(numel(dA), nTx); d1 = g1;
for s = 1:nTx
    V1 = W - TP(s,:);
    D1 = sqrt(sum(V1.^2, 2));
    cos_phi = -V1(:,3)./D1;
    cos_alpha = -sum(V1.*Nw, 2)./D1;
    g = (m+1)/(2*pi)*cos_phi.^m.*cos_alpha./D1.^2.*rho.*dA;
    g(cos_phi <= 0 | cos_alpha <= 0) = 0;
    g1(:,s) = g; d1(:,s) = D1;
end
Drms = zeros(Ny, Nx); mean_delay = Drms;
for ii = 1:Nx
    for jj = 1:Ny
        RP = [x(ii) y(jj) -lz/2];
        h_vector = zeros(1, nt);
        V2 = RP - W;
        D2 = sqrt(sum(V2.^2, 2));
        cos_beta = sum(V2.*Nw, 2)./D2;
        cos_psi = -V2(:,3)./D2;
        ok = cos_psi >= cosd(FOV) & cos_beta > 0;
        g2 = Adet.*cos_beta.*cos_psi./(pi*D2.^2);
        for s = 1:nTx
            % LOS
            d0 = norm(TP(s,:) - RP); c0 = lz/d0;
            if acosd(c0) <= FOV
                k0 = round(d0/C/delta_t) + 1;
                h_vector(k0) = h_vector(k0) + (m+1)*Adet*c0^(m+1)/(2*pi*d0^2);
            end
            % first reflections
            k = round((d1(ok,s) + D2(ok))/C/delta_t) + 1;
            h_vector = h_vector + accumarray(k, g1(ok,s).*g2(ok), [nt 1]).';
        end
        p2 = h_vector.^2;
        mean_delay(jj,ii) = sum(p2.*t_vector)/sum(p2);
        Drms(jj,ii) = sqrt(sum((t_vector - mean_delay(jj,ii)).^2.*p2)/sum(p2));
    end
end
figure;
surf(x, y, Drms, 'EdgeColor', 'none'); colorbar;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('D_{rms} (ns)');
title('RMS delay spread (LOS + first reflections, 4 LEDs)');
axis([-lx/2 lx/2 -ly/2 ly/2 min(Drms(:)) max(Drms(:))]);
fprintf('D_rms: %.2f ... %.2f ns\n', min(Drms(:)), max(Drms(:)));
