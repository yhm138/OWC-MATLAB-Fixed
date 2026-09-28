function y = owc_awgn(x, snr_dB)
% OWC_AWGN  Add white Gaussian noise at SNR (dB) relative to the MEASURED
%   signal power, i.e. the toolbox-free equivalent of awgn(x, snr_dB, 'measured').
%   Signal power is averaged over all elements of x; complex x gets circular noise.
p_sig = sum(abs(x(:)).^2)/numel(x);
p_noise = p_sig/10^(snr_dB/10);
if isreal(x)
    y = x + sqrt(p_noise)*randn(size(x));
else
    y = x + sqrt(p_noise/2)*(randn(size(x)) + 1i*randn(size(x)));
end
end
