function y = owc_upsample(x, n)
% OWC_UPSAMPLE  Insert n-1 zeros between samples of a row vector (toolbox-free upsample).
y = zeros(1, numel(x)*n);
y(1:n:end) = x;
end
