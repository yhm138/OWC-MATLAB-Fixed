# Bug fixes (`FIXED_*.m`)

Every fix is a **new file** next to the original (`ChapterX/FIXED_<name>.m`);
the original scripts are kept unchanged for reference. All `FIXED_*` scripts

* run in **base MATLAB (no toolboxes)** and in **GNU Octave ≥ 6** (tested with Octave 8.4),
* add `util/` to the path themselves (`addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'util'))`),
* compare simulations with the analytical result wherever the book gives one.

Run them all (and regenerate `docs/figures/`) with

```matlab
run_all_fixed                      % MATLAB or Octave, from the repository root
run_all_fixed('', 'docs/figures')  % also save every figure as PNG
```

```bash
# headless Octave (Linux)
xvfb-run -a octave --no-gui --eval "graphics_toolkit('qt'); run_all_fixed('', 'docs/figures')"
```

`util/test_owc_utils.m` contains self-checks for the helper functions.

---

## New helper functions (`util/owc_*.m`)

| File | Replaces | Why |
| --- | --- | --- |
| `owc_Q.m` | `util/Q.m`, `qfunc` | `Q.m` computed `erfc(sqrt(x^2)/sqrt(2))/2` = Q(\|x\|): **wrong for x < 0** and not vectorised (`x^2`). |
| `owc_randint.m` | `util/my_randint.m`, `randsrc`, `randint` | 3-argument form used `randi(M-1,…)` → values **1…M-1** (symbol 0 never sent); 2-argument form needed the Communications Toolbox. |
| `owc_generate_PPM.m` | `util/generate_PPM.m` | missing `;` printed every symbol; `bi2de` (toolbox); O(n²) array growth. Also returns the symbols. |
| `owc_generate_DPIM.m` | `util/generate_DPIM.m` | `bi2de` (toolbox); O(n²) array growth. Also returns the symbols. |
| `owc_fl_model.m` | `util/fl_model.m` | vectorised over time, no `global` variables; same Moreira FLI model. |
| `owc_rectpulse.m`, `owc_upsample.m`, `owc_biterr.m`, `owc_awgn.m`, `owc_sinc.m` | `rectpulse`, `upsample`, `biterr`, `awgn(…,'measured')`, `sinc` | toolbox-free equivalents (`owc_biterr` also counts bit errors of multi-bit symbols). |
| `owc_pam_gray.m`, `owc_pamdemod_gray.m`, `owc_psk_gray.m`, `owc_qpsk_gray.m` | `modem.pammod` (removed from MATLAB), `comm.PAMModulator`, `comm.PSKModulator`, `qammod` | Gray-coded mappers identical to MATLAB's mapping. |
| `owc_psd.m` | `periodogram` + `dspdata.psd` (removed from MATLAB) | averaged periodogram. |
| `owc_dwt_denoise_lowband.m` | `wavedec/appcoef/waverec` (Wavelet Toolbox), `mapminmax` | periodised Daubechies-4 DWT; the approximation band is zeroed. |
| `owc_gh20.m` | copy-pasted tables | 20-point Gauss–Hermite nodes/weights (one of the copies had a wrong weight, see Fig. 6.7). |
| `owc_room_walls.m` | – | wall discretisation for first-reflection channel models. |

---

## Chapter 3 – channel modelling

| Original | Fixed | Errors found and fixed |
| --- | --- | --- |
| `program_3p1.m` | `FIXED_program_3p1.m` | Concentrator gain was `n^2/sin(FOV)`; correct is **`n^2/sin^2(FOV)`** (received power 0.62 dB too low at FOV = 60°). No FOV test on the LOS gain. Units (mW → dBm) documented. |
| `NEEDFIX_program_3p2.m` | `FIXED_program_3p2.m` | Walls 2–4 were **dummy values `h2=h3=h4=1`** (added 3 to a gain of ~1e-6!). ~2·10⁸-iteration loop ("calculation time too long") → vectorised, seconds. All four walls, FOV and concentrator applied; LOS + diffuse plotted (original had no output). Receiver grid at cell centres. |
| `CORRECT_plot_Fig3p28.m` | `FIXED_plot_Fig3p28.m` | `I = 0` gave `NaN`; legend should be the log-irradiance variance σ_l². |
| `CORRECT_plot_Fig3p31.m`, `program_3p5.m` | – | Checked, correct (gamma-gamma pdf, Kim visibility model). |

## Chapter 4 – modulation

| Original | Fixed | Errors found and fixed |
| --- | --- | --- |
| `CORRECT_program_4p4.m` | `FIXED_program_4p4.m` | A comment broken over two lines left the statement `sqrt(2)*sqrt(nsamp/(2*SNR(i)));` executing every iteration. Adaptive Monte-Carlo length; simulation matches Q(√(Eb/N0)). |
| `CORRECT_program_4p5.m` | `FIXED_program_4p5.m` | No theory curve; 1e5 calls to `gngauss` per point → vectorised. |
| `NEEDFIX_plot_Fig4p5.m` | `FIXED_plot_Fig4p5.m` | OOK-NRZ PSD **4× too large**: for unipolar OOK with peak `a = 2RP` the continuous PSD is `a²Tb/4·sinc²(fTb)`. `dspdata.psd` no longer exists. Nothing was plotted. Now analytical (NRZ and RZ, incl. discrete lines) **and** simulated PSD with the same normalisation. |
| `CORRECT_program_4p7.m` | `FIXED_program_4p7.m` | **`M = 4` fixed while `L = 4, 8, 16`**: for L-PPM `M = log2 L`, otherwise the slot duration `Ts = M/(L·Rb)` is wrong. |
| `program_4p8.m` | `FIXED_program_4p8.m` | Simulated SER **never plotted**; theory curves drawn without `hold on` (HDD curve overwritten). SDD symbol error compared with the exact expression and the union bound. 500 symbols → 2e5. |
| `program_4p11.m` | `FIXED_program_4p11.m` | Quantity is the **slot** error rate (matches Q(√(M·Lavg·SNR/2))); wrong comment "energy per slot"; no labels. |
| `program_4p12.m` | `FIXED_program_4p12.m` | **Legend swapped** "PPM (soft)" / "PPM (hard)". |
| `NEEDFIX_program_4p13.m` | `FIXED_program_4p13.m` | **Undefined variable `MF_output`** (should be `Rx_output`); comment line broken into code → syntax error. Now matches Q(√(2Eb/N0)). |
| `program_4p14.m` | `FIXED_program_4p14.m` | `my_randint(N,1,4)` gave symbols 1–3 only; **symbol error rate compared with a bit-error-rate formula**; the random multipath channel was overwritten by `h = 1`. Now Gray-QPSK BER, correct SNR bookkeeping (half the sub-carriers are null), optional multipath + ZF equaliser with Rayleigh theory. |
| `CORRECT_plot_Fig4p13.m` | `FIXED_plot_Fig4p13.m` | Plot labelled "dB/Hz" but linear and un-normalised; `r(5L+1)` overwritten by the asymptotic value (index off by one). |

## Chapter 5 – artificial-light interference and diffuse channels

| Original | Fixed | Errors found and fixed |
| --- | --- | --- |
| `program_5p1.m` | `FIXED_program_5p1.m` | FLI sampled at `Tb` (not `Tsamp`) over `Tb·nsamp·sig_length` → **index-out-of-bounds error**; background current `Ib` overwritten by the FLI current. |
| `NEEDFIX_program_5p5.m` | `FIXED_program_5p5.m` | Undefined `rt`, `Lev`, `wname`; meaningless parameters (`Tb = Tsamp = 10`); Wavelet/NN toolboxes. Now a complete BER study (no FLI / FLI / FLI + DWT) at 100 Mbps; level 6 removes the FLI band (< ~780 kHz). |
| `program_5p6.m` | `FIXED_program_5p6.m` | Missing `;` printed `pt`; `eyediagram` (toolbox); several delay spreads shown. |
| `CORRECT_demo_Fig5p38.m` | `FIXED_demo_Fig5p38.m` | `Tsamp = 16` with `Tb = 3, nsamp = 16` and threshold `Ep/2 = 0.25` unrelated to the real MF output (≈ 2.6·10⁴ for a "1") → the decisions are meaningless, and the BER was never computed. BER vs Eb/N0 for several D_T now simulated. |
| `CORRECT_plot_Fig5p7.m` | `FIXED_plot_Fig5p7.m` | HPF impulse response truncated at 10 Tb where it is still 4 % of its peak (DC gain ≠ 0); no labels. |
| `CORRECT_plot_Fig5p8.m` | `FIXED_plot_Fig5p8.m` | Three `bar` calls in the same axes → **only the last histogram visible**; `expect_one` could be a vector; HPF response truncated at 1.3 time constants. |
| `WRONG_plot_Fig5p6.m` | `FIXED_plot_Fig5p6.m` | NOPR and power-penalty curves overlaid on one axis with no legend/labels; now two panels, data points shown with the fits. |

## Chapter 6 – FSO under turbulence

| Original | Fixed | Errors found and fixed |
| --- | --- | --- |
| `WRONG_plot_Fig6p7.m` | `FIXED_plot_Fig6p7.m` | Gauss–Hermite weight **`7.8025564785e6` instead of `e-6`**; quadrature loop started at **`j = i`** instead of 1; Q-argument **missing square root** (`Ks²/σ²` instead of `Ks/σ`); `Temp` (temperature) reused as accumulator. |
| `WRONG_plot_Fig6p14.m` | `FIXED_plot_Fig6p14.m` | Sky background solid angle **`4/π·FOV²` → `π/4·FOV²`**; `Q.m` bug; labels, y-limits and turbulence-free references added. |
| `WRONG_plot_Fig6p24.m` | `FIXED_plot_Fig6p24.m` | Only one turbulence strength and no reference; now σ_l² = 0.1…0.5 + AWGN reference, vectorised quadrature. |
| `CORRECT_plot_Fig6p19.m` | `FIXED_plot_Fig6p19.m` | Margin is a ratio: `10*log10(m*1e3)` "dBm" added a spurious +30 dB; Chernoff bound evaluated at Pout = 1 (complex result). Exact outage added. |
| `CORRECT_plot_Fig6p10_Fig6p11_Fig6p12.m` | `FIXED_plot_Fig6p10_Fig6p11_Fig6p12.m` | Local functions in a script (not Octave-portable); broken comment line; stray `filter` call; only 2 of 3 figures; `t = 0:1/Fs:T` has one extra sample per symbol. Coherent correlation receiver, three constellations (input / noise / noise + turbulence). |

## Chapter 8 – indoor VLC

| Original | Fixed | Errors found and fixed |
| --- | --- | --- |
| `CORRECT_plot_Fig8p10.m` | `FIXED_plot_Fig8p10.m` | `theta` assigned twice (70 then 12.5): the 70° case was unreachable. Both cases plotted. |
| `NEEDFIX_plot_Fig8p14.m` | `FIXED_plot_Fig8p14.m` | Walls 2–4 **copied from wall 1** (`h2=h3=h4=h1`); only one transmitter at the centre although four LED clusters were defined; x/y transposed for `surf`. |
| `NEEDFIX_program_8p3.m` | `FIXED_program_8p3.m` | Only TX1 and wall 1; **30 ns window < longest path (~50 ns)** → late reflections dropped silently; `index` (lens) overwritten. All TX/walls, vectorised. |
| `NEO_program_8p4.m`, `OLD_program_8p4.m` | `FIXED_program_8p4.m` | **Bits counted as `nsym*M` instead of `TxN*nsym*M` → BER 4× too high**; OLD uses the removed `modem.*` API and broken lines; NEO needs the Communications Toolbox. Ideal-channel reference added. |

---

### Figures

All figures produced by the fixed scripts are in [`docs/figures`](docs/figures).
