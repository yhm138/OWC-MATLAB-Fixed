function r = owc_randint(nrows, ncols, M)
% OWC_RANDINT  Uniform random integers in {0,...,M-1} (default M = 2, i.e. bits).
%   Fixed replacement for util/my_randint.m: the 3-argument form used
%   randi(M-1,...) which returns {1,...,M-1} (symbol 0 never generated), and
%   the 2-argument form needed randsrc() from the Communications Toolbox.
if nargin < 3
    M = 2;
end
r = floor(M*rand(nrows, ncols));
end
