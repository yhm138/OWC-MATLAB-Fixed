% TEST_OWC_UTILS  Self-checks for the toolbox-free helpers in util/owc_*.m.
% Run from the repository root or from util/:  test_owc_utils
clear; clc;
addpath(fileparts(mfilename('fullpath')));

% Q-function: symmetric, vectorised, Q(0) = 1/2
assert(abs(owc_Q(0) - 0.5) < 1e-12);
assert(max(abs(owc_Q([-2 -1 1 2]) + owc_Q([2 1 -1 -2]) - 1)) < 1e-12);
% random integers cover 0..M-1
r = owc_randint(1, 1e5, 4);
assert(isequal(unique(r), 0:3));
% PPM: one pulse per frame, at the transmitted position
[P, s] = owc_generate_PPM(3, 1000);
[~, pos] = max(reshape(P, 8, []));
assert(numel(P) == 8000 && sum(P) == 1000 && all(pos - 1 == s));
% DPIM: symbol length 1 + k + NGS
[D, s] = owc_generate_DPIM(3, 1000, 2);
assert(numel(D) == sum(s) + 3000 && sum(D) == 1000 && D(1) == 1);
% Gray PAM round trip; adjacent levels differ in one bit
x = owc_pam_gray(0:7, 8);
assert(isequal(owc_pamdemod_gray(x, 8), 0:7));
[~, order] = sort(x); g = order - 1;
assert(all(sum(dec2bin(bitxor(g(1:end-1), g(2:end))) == '1', 2) == 1));
% bit errors on multi-bit symbols
assert(owc_biterr([0 3 2], [1 0 2], 2) == 3);
% measured-power AWGN
xx = randn(1, 2e5); yy = owc_awgn(xx, 10);
assert(abs(10*log10(mean(xx.^2)/mean((yy - xx).^2)) - 10) < 0.1);
% DWT low-band removal: DC is removed exactly, energy is preserved otherwise
assert(max(abs(owc_dwt_denoise_lowband(ones(1, 1024), 4))) < 1e-12);
% Gauss-Hermite: int exp(-x^2) dx = sqrt(pi), E[exp(l)] = 1 for log-normal
[xg, wg] = owc_gh20();
assert(abs(sum(wg) - sqrt(pi)) < 1e-9);
assert(abs(sum(wg.*exp(sqrt(2)*0.5*xg - 0.125))/sqrt(pi) - 1) < 1e-9);
% FLI model: zero mean over a mains period, output length
i_fl = owc_fl_model(2e-6, 1e-6, 0, 0.02 - 1e-6);
assert(numel(i_fl) == 20000 && abs(mean(i_fl)) < 1e-8);
disp('test_owc_utils: all tests passed');
