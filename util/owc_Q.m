function y = owc_Q(x)
% OWC_Q  Gaussian Q-function, Q(x) = 0.5*erfc(x/sqrt(2)).
%   Fixed replacement for util/Q.m, which evaluated erfc(sqrt(x^2)/sqrt(2))/2,
%   i.e. Q(|x|): wrong for negative arguments and not vectorised (x^2).
%   Also replaces qfunc() (Communications Toolbox).
y = 0.5*erfc(x./sqrt(2));
end
