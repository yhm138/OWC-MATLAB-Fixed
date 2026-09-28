
[toc]

## Overview

This repository contains the source code related to *Optical Wireless Communications System and Channel Modelling with MATLAB*. 

**Some of the original code had issues and required modifications. I have made the necessary adjustments to enhance practicality and functionality.**



## Fixed, verified versions (`FIXED_*.m`)

Many of the original scripts contain bugs (wrong formulas, undefined variables,
dummy values, index errors, wrong legends, APIs removed from MATLAB, ...).
Every script with a problem now has a **new** corrected companion file
`ChapterX/FIXED_<name>.m`; the originals are left untouched for comparison.

* The complete list of bugs and fixes is in **[FIXES.md](FIXES.md)**.
* The fixed scripts need **no MATLAB toolbox** and also run in **GNU Octave**
  (tested with Octave 8.4). Toolbox functions were replaced by small helpers in
  `util/owc_*.m`.
* Wherever the book gives an analytical result, the fixed scripts plot the
  simulation **and** the theory, so the model can be checked at a glance.
* All figures produced by the fixed scripts are in [`docs/figures`](docs/figures).

### Examples

| | |
| --- | --- |
| ![OOK-NRZ BER](docs/figures/FIXED_program_4p4_1.png) | ![PPM HDD/SDD](docs/figures/FIXED_program_4p8_1.png) |
| ![DWT FLI mitigation](docs/figures/FIXED_program_5p5_1.png) | ![BPPM APD turbulence](docs/figures/FIXED_plot_Fig6p7_1.png) |

## MATLAB / Octave Version

* Original scripts: MATLAB R2024a (several need the Communications, Signal
  Processing or Wavelet Toolbox).
* `FIXED_*` scripts: any recent MATLAB without toolboxes, or GNU Octave >= 6.

## Directory Structure

- `Chapter3/` ... `Chapter8/` - scripts per book chapter (original + `FIXED_*`).
- `util/` - utility functions. `owc_*.m` are the corrected, toolbox-free helpers;
  `test_owc_utils.m` checks them.
- `run_all_fixed.m` - runs every `FIXED_*` script (optionally saving figures).
- `FIXES.md` - bug list; `docs/figures/` - output of the fixed scripts.

## Some Code Descriptions

Below is a list of the MATLAB scripts included in this repository (not all):

| Name                     | Description                                                                                                                     |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| `CORRECT_plot_Fig3p31.m` | The gamma-gamma probability density function (PDF)                                                                              |
| `FIXED_plot_Fig3p28.m`   | PDF of log-normal distribution                                                                                                  |
| `FIXED_program_3p2.m`    | Program 3.2: optical power distribution of LOS + first-reflection (diffuse) channel                                            |
| `FIXED_program_4p4.m`    | Program 4.4: MATLAB code to simulate Bit Error Rate (BER) of On-Off Keying Non-Return-to-Zero (OOK-NRZ)                         |
| `FIXED_program_4p5.m`    | Program 4.5: MATLAB code to simulate BER of OOK-NRZ using a matched filter-based receiver                                       |
| `FIXED_plot_Fig4p13.m`   | Program 4.10: MATLAB code to calculate Power Spectral Density (PSD) of Discrete Pulse Interval Modulation (DPIM) (0 Guard Slot) |
| `FIXED_program_5p5.m`    | Program 5.5: DWT-based mitigation of fluorescent-light interference                                                             |
| `FIXED_plot_Fig6p7.m`    | BER of BPPM FSO with APD receiver under log-normal turbulence                                                                   |
| `FIXED_program_8p3.m`    | Program 8.3: RMS delay spread over the receiving plane of a room                                                                |
| `FIXED_program_8p4.m`    | Program 8.4: 4x4 optical MIMO with PAM and zero-forcing detection                                                               |

See each chapter's `README.md` for the full list.

## Usage

The `FIXED_*` scripts add `util/` to the path automatically; just run them, e.g.

```matlab
run('Chapter4/FIXED_program_4p4.m')
run_all_fixed                        % run every fixed script
run_all_fixed('', 'docs/figures')    % ... and save all figures as PNG
```

GNU Octave (headless Linux):

```bash
sudo apt-get install octave xvfb
xvfb-run -a octave --no-gui --eval "graphics_toolkit('qt'); run_all_fixed('', 'docs/figures')"
```

For the original scripts, ensure that `util/` is included in your MATLAB path:

```matlab
addpath('path/to/util');
```

Units convention (as in the book): optical powers of LEDs are given in **mW**,
so `10*log10(P)` is directly in **dBm**.

## Contribution

Feel free to contribute to this repository by forking it and submitting pull requests. Any enhancements, bug fixes, or additional features are welcome.

## Acknowledgements

This project is based on *Optical Wireless Communications System and Channel Modelling with MATLAB*. Special thanks to the authors and contributors of the original code.

---

### Star History

[![Star History Chart](https://api.star-history.com/svg?repos=AcraeaTerpsicore/Optical-Wireless-Communications-System-and-Channel-Modelling-with-MATLAB&type=Date)](https://www.star-history.com/#AcraeaTerpsicore/Optical-Wireless-Communications-System-and-Channel-Modelling-with-MATLAB&Date)

### &#8627; Stargazers
[![Stargazers repo roster for @AcraeaTerpsicore/Optical-Wireless-Communications-System-and-Channel-Modelling-with-MATLAB](http://reporoster.com/stars/AcraeaTerpsicore/Optical-Wireless-Communications-System-and-Channel-Modelling-with-MATLAB)](https://github.com/AcraeaTerpsicore/Optical-Wireless-Communications-System-and-Channel-Modelling-with-MATLAB/stargazers)

### &#8627; Forkers
[![Forkers repo roster for @AcraeaTerpsicore/Optical-Wireless-Communications-System-and-Channel-Modelling-with-MATLAB](http://reporoster.com/forks/AcraeaTerpsicore/Optical-Wireless-Communications-System-and-Channel-Modelling-with-MATLAB)](https://github.com/AcraeaTerpsicore/Optical-Wireless-Communications-System-and-Channel-Modelling-with-MATLAB/network/members)




