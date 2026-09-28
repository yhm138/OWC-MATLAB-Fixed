function y = owc_rectpulse(x, nsamp)
% OWC_RECTPULSE  Rectangular pulse shaping of a row vector (toolbox-free rectpulse).
%   Each element of x is repeated nsamp times.
y = reshape(repmat(x(:).', nsamp, 1), 1, []);
end
