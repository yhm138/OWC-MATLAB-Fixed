function [x, map] = owc_pam_gray(sym, L)
% OWC_PAM_GRAY  Gray-coded L-PAM mapping of integers 0..L-1 to levels
%   -(L-1), ..., -1, 1, ..., (L-1)  (toolbox-free pammod(...,'gray')).
%   map(k+1) is the level index (0..L-1) carrying symbol k.
g = bitxor(0:L-1, floor((0:L-1)/2));   % Gray code of level index
map = zeros(1, L);
map(g + 1) = 0:L-1;                    % symbol -> level index
x = 2*map(sym + 1) - (L-1);
x = reshape(x, size(sym));
end
