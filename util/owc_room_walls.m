function [W, Nw, dA] = owc_room_walls(lx, ly, lz, ngrid)
% OWC_ROOM_WALLS  Discretise the four walls of a room for first-reflection
%   (diffuse) channel calculations. The room spans x in [-lx/2, lx/2],
%   y in [-ly/2, ly/2], z in [-lz/2, lz/2] (z = -lz/2 is the receiver plane,
%   z = +lz/2 the transmitter/ceiling plane).
%   W  : K-by-3 wall element centres
%   Nw : K-by-3 unit normals pointing into the room
%   dA : K-by-1 element areas
Nx = round(lx*ngrid); Ny = round(ly*ngrid); Nz = round(lz*ngrid);
x = linspace(-lx/2, lx/2, Nx);
y = linspace(-ly/2, ly/2, Ny);
z = linspace(-lz/2, lz/2, Nz);
[Yw, Zw] = meshgrid(y, z);  [Xw, Zw2] = meshgrid(x, z);
nYZ = numel(Yw); nXZ = numel(Xw);
W = [ -lx/2*ones(nYZ,1) Yw(:) Zw(:);
       lx/2*ones(nYZ,1) Yw(:) Zw(:);
       Xw(:) -ly/2*ones(nXZ,1) Zw2(:);
       Xw(:)  ly/2*ones(nXZ,1) Zw2(:) ];
Nw = [ repmat([ 1 0 0], nYZ, 1); repmat([-1 0 0], nYZ, 1);
       repmat([ 0 1 0], nXZ, 1); repmat([ 0 -1 0], nXZ, 1) ];
dA = [ repmat(ly*lz/(Ny*Nz), 2*nYZ, 1); repmat(lx*lz/(Nx*Nz), 2*nXZ, 1) ];
end
