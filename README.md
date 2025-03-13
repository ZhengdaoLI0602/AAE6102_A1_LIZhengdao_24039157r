## PDF version
Apart from the following markdown format, a clear PDF version of A1 is available here: [`A1_LIZhengdao_24039157r`](https://github.com/ZhengdaoLI0602/AAE6102_A1_LIZhengdao_24039157r/blob/main/AAE6102_Assignments.pdf)

## Task 1

The results in this report are processed based on the FGI-GSRx software-defined receiver (SDR) open-sourced by the Finnish Geospatial Research Institute[^1]. The initial acquisition results display 9 satellites (PRN 3,4,8,16,22,26,27,31,32) for the open-sky dataset and 7 satellites (PRN 1,3,7,11,18,22,28) for the urban dataset, respectively, as detailed in Figure 1.

### Initial Acquisition Results

| Dataset | Satellites |
| :-- | :-- |
| Open-Sky | PRN 3,4,8,16,22,26,27,31,32 |
| Urban | PRN 1,3,7,11,18,22,28 |

![F1](https://github.com/user-attachments/assets/4dd4d888-792d-493c-9a97-3f143a9176af)



## Task 2

In this report, the multipath effect is assumed to occur only in the urban dataset, but not in the open-sky dataset.

Traditional GNSS receivers use a correlator spacing of -0.5 chip, 0, and 0.5 chips for early, prompt, and late correlators, respectively. This setup is used in the Early-Minus-Late (EML) code tracking loop to estimate the code phase error. Multi-correlator features smaller correlator spacing (e.g., -0.5chips: 0.1chips: 0.5chips) to provide more detailed autocorrelation profile.

For the open-sky dataset, the autocorrelation curve should be in an "isosceles triangular" shape. In contrast, the autocorrelation plot of urban datasets could hold two scenarios: constructive and destructive multipath effects. For both multipath scenarios, the autocorrelation curves will show more distortion and randomness than those from the open-sky dataset, and the correlation peaks of the two scenarios tend to have a time delay (shifted rightwards).

## Task 3

We particularly analyze the satellite PRN16 in the open-sky dataset. The SDR has the functionality of decoding for navigation message and the output results (including general information, timing and reference parameters, polynomial correction terms, and orbital parameters) have been summarized in Table 1.

### GPS L1 Ephemeris Parameters for PRN16

| Variable | Explanation | Value |
| :-- | :-- | :-- |
| `WeekNumber` | -- | 1155 |
| `PRN` | Pseudorandom Noise code | 16 |
| `refTime` | Transmission time of the signal | 390108.0138 |
| `Pos` | Satellite position in ECEF frame (m) | [-1.1009e+06, 2.3775e+07, 1.1045e+07] |
| `Clock` | Satellite Clock Correction | -4.0688e-04 |
| `health` | Satellite health status (0 = healthy) | 0 |
| `T\_GD` | Total Group Delay (hardware signal delay in seconds) | 1.8626e-09 |
| `IODC` | Issue of Data Clock (clock parameters identifier) | 56 |
| `t\_oc` | Reference Time of Clock (seconds of GPS week) | 396000 |
| `a\_f2` | Satellite clock drift rate coefficient (s/s²) | 0 |
| `a\_f1` | Satellite clock drift coefficient (s/s) | -1.3756e-11 |
| `a\_f0` | Satellite clock bias (s) | -3.2456e-04 |
| `IODE\_sf2` | Issue of Data Ephemeris in subframe 2 | 56 |
| `C\_rs` | Amplitude of sine correction to orbit radius (m) | -110.1563 |
| `deltan` | Mean motion difference from computed value (rad/s) | 4.4020e-09 |
| `M\_0` | Mean anomaly at reference time (rad) | 2.7467 |
| `C\_uc` | Amplitude of cosine correction to argument of latitude (rad) | -5.7314e-06 |
| `e` | Eccentricity (dimensionless) | 0.0039 |
| `C\_us` | Amplitude of sine correction to argument of latitude (rad) | 6.0219e-06 |
| `sqrtA` | Square root of semi-major axis (m$^{1/2}$) | 5.1538e+03 |
| `t\_oe` | Reference Time of Ephemeris (seconds of GPS week) | 396000 |
| `C\_ic` | Amplitude of cosine correction to inclination (rad) | -2.6077e-08 |
| `omega\_0` | Longitude of ascending node at weekly epoch (rad) | 1.3772 |
| `C\_is` | Amplitude of sine correction to inclination (rad) | -6.3330e-08 |
| `i\_0` | Inclination angle at reference time (rad) | 0.9707 |
| `C\_rc` | Amplitude of cosine correction to orbit radius (m) | 266.0313 |
| `omega` | Argument of perigee (rad) | 0.9996 |
| `omegaDot` | Rate of right ascension change (rad/s) | -8.0410e-09 |
| `iDot` | Rate of inclination angle change (rad/s) | -1.3001e-10 |
| `IODE\_sf3` | Issue of Data Ephemeris in subframe 3 | 56 |

## Task 4 \& 5

### Positioning Settings and Results

The design of the weighting matrix for Weighted Least Squares (WLS) positioning is based on the satellite Carrier-to-Noise density ($CN_0$) and elevation angle ($EL$), as proposed in. Specifically, the weighting matrix $\bm{W}$ is given by:

$$
\bm{W}= \left\{
\begin{array}{lr} 
\frac{1}{\sin^2(EL)}\left( 10^{-\frac{CN_0-T}{a}}\left( \left(\frac{A}{10^{-\frac{F-T}{a}}}-1\right)\frac{CN_0-T}{F-T}  +1 \right) \right),        &  CN_0 < T \\
1,       &   CN_0 \geq T
\end{array},
\right.
$$

where the parameters are tuned as $T=50,\ F=20,\ A=50,\ a=30$, to be fit in with the urban environment of Hong Kong.

Extended Kalman Filter (EKF) can integrate the information from the pseudorange and Doppler measurements and estimate the user position and velocity simultaneously. In this report, the designed state vector

$$
\bm{S}=[\Delta x, \Delta y,\Delta z,V_x, V_y,V_z,c\Delta b_{clk}, c\dot{b}_{clk}]^\top,
$$

and the measurement vector

$$
\bm{Z}=[\Delta \rho_1,\ldots, \Delta \rho_m, \Delta \dot{\rho}_1, \ldots, \Delta \dot{\rho}_m]^\top.
$$

### Evaluations

Overall, the 2D positioning accuracy order is: EKF>WLS>OLS. This can also be reflected in Tables 1 and 2, where the 2D RMSE of EKF is better than WLS better than WLS.

For both datasets, though the EKF positionings may not cover the ground truth (GT) location, its results tend to hold a significantly higher precision than OLS and WLS.

### Positioning Results Summary

#### Open-Sky Dataset

| Algorithm | 2D RMSE | 3D RMSE | 2D STD | 3D STD |
| :-- | :-- | :-- | :-- | :-- |
| OLS | 1.38 | 9.17 | 0.63 | 2.45 |
| WLS | 1.35 | 6.28 | 0.67 | 2.54 |
| EKF | 1.06 | 20.99 | 0.18 | 0.99 |

#### Urban Dataset

| Algorithm | 2D RMSE | 3D RMSE | 2D STD | 3D STD |
| :-- | :-- | :-- | :-- | :-- |
| OLS | 61.07 | 92.32 | 22.89 | 35.72 |
| WLS | 25.60 | 59.67 | 13.28 | 30.87 |
| EKF | 39.88 | 55.68 | 13.71 | 16.33 |

---

### References

You will need to replace the numeric references with actual links or citations in your GitHub Markdown document.

---

### Figures

Please insert figures as needed using Markdown syntax, e.g., `Figure Caption`.

---

### Notes:

1. **Citations**: Replace `[^1]`, ``, etc., with actual references or links.
2. **Figures**: Insert figures using Markdown syntax, e.g., `Figure Caption`.
3. **Tables**: Adjust table formatting as needed for readability.

This Markdown version maintains the structure and content of your original LaTeX document but uses Markdown syntax for formatting and links.


[^1]: https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/52988654/bc71b884-b5a7-4343-8b8c-7b3c2a287b1b/paste.txt

