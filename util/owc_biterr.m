function [nerr, ratio] = owc_biterr(a, b, k)
% OWC_BITERR  Number and ratio of bit errors (toolbox-free biterr).
%   [nerr, ratio] = owc_biterr(a, b)     a, b binary vectors
%   [nerr, ratio] = owc_biterr(a, b, k)  a, b integer symbols of k bits each;
%                                        ratio is errors / (numel(a)*k)
a = a(:); b = b(:);
if nargin < 3
    k = 1;
end
if k == 1
    nerr = sum(a ~= b);
else
    d = bitxor(uint32(a), uint32(b));
    nerr = 0;
    for ii = 1:k
        nerr = nerr + sum(bitget(d, ii));
    end
    nerr = double(nerr);
end
ratio = nerr/(numel(a)*k);
end
