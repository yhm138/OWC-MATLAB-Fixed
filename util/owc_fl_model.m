function [i_elect, i_low, i_high] = owc_fl_model(Ib, samp_int, start_time, end_time)
% OWC_FL_MODEL  Moreira's model of the interference photocurrent produced by
%   a fluorescent lamp driven by an electronic ballast (book Program 3.4).
%   Ib         : average photocurrent due to the lamp (A)
%   samp_int   : sampling interval (s)
%   start_time : start time (s),  end_time : end time (s)
%   The returned current is zero-mean (the DC part Ib is removed by the
%   receiver's AC coupling). Same model as util/fl_model.m, but vectorised
%   and without global variables.
t = (start_time:samp_int:end_time).';
% ***** low-frequency component (mains harmonics, up to 2 kHz) *****
i = 1:20;
p1 = [4.65 2.86 5.43 3.90 2.00 5.98 2.38 4.35 5.87 0.70 ...
      1.26 1.29 1.28 0.63 6.06 5.49 4.45 3.24 2.07 0.87];
p2 = [0.00 0.08 6.00 5.31 2.27 5.70 2.07 3.44 5.01 6.0 ...
      6.00 6.17 5.69 5.37 4.00 3.69 1.86 1.38 5.91 4.88];
b = 10.^((-13.1*log(100*i-50)+27.1)/20);
c = 10.^((-20.8*log(100*i)+92.4)/20);
A1 = 5.9;
i_low = zeros(numel(t), 1);
for n = 1:numel(i)          % loop over harmonics, vectorised over time
    i_low = i_low + b(n)*cos(2*pi*(100*i(n)-50)*t + p1(n)) ...
                  + c(n)*cos(2*pi*100*i(n)*t + p2(n));
end
i_low = (Ib/A1)*i_low;
% ***** high-frequency component (ballast switching, fh = 37.5 kHz) *****
j = [1 2 4 6 8 10 12 14 16 18 20 22];
d_db = [-22.2 0.00 -11.5 -30.0 -33.9 -35.3 -39.3 -42.7 -46.4 -48.1 -53.1 -54.9];
d = 10.^(d_db/10);
thetaj = [5.09 0.00 2.37 5.86 2.04 2.75 3.55 4.15 1.64 4.51 3.55 1.78];
f_high = 37500;
A2 = 2.1;
i_high = zeros(numel(t), 1);
for n = 1:numel(j)
    i_high = i_high + d(n)*cos(2*pi*f_high*j(n)*t + thetaj(n));
end
i_high = (Ib/A2)*i_high;
i_elect = (i_low + i_high).';
i_low = i_low.'; i_high = i_high.';
end
