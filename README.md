## PDF version
Apart from the following markdown format, a clear PDF version of A1 is available here: [`A1_LIZhengdao_24039157r`](https://github.com/ZhengdaoLI0602/AAE6102_A1_LIZhengdao_24039157r/blob/main/AAE6102_Assignments.pdf)

## How to produce the outcomes
The results in this report are processed based on the FGI-GSRx software-defined receiver (SDR) open-sourced by the Finnish Geospatial Research Institute[^1]. 

The folder `AAE6102/Plots` contains all the Figure that is included in the assignment. Within the folder `main\grsx`, set the 


## Task 1

The initial acquisition results display 9 satellites (PRN 3,4,8,16,22,26,27,31,32) for the open-sky dataset and 7 satellites (PRN 1,3,7,11,18,22,28) for the urban dataset, respectively, as detailed in Figure 1.

### Initial Acquisition Results

| Dataset | Satellites |
| :-- | :-- |
| Open-Sky | PRN 3,4,8,16,22,26,27,31,32 |
| Urban | PRN 1,3,7,11,18,22,28 |

![F1](https://github.com/user-attachments/assets/4dd4d888-792d-493c-9a97-3f143a9176af)



## Task 2

In this report, the multipath effect is assumed to occur only in the urban dataset, but not in the open-sky dataset. We will adopt this assumption for the remainder of the discussion.

Traditional GNSS receivers use a correlator spacing of-0.5 chip, 0, and 0.5 chips for early, prompt, and late correlators, respectively. This setup is used in the Early-Minus-Late (EML) code tracking loop to estimate the code phase error. Multi-correlator features smaller correlator spacing (e.g.,-0.5chips: 0.1chips: 0.5chips) to provide more detailed autocorrelation profile.

For the open-sky dataset, the autocorrelation curve should be in an ‘isosceles triangular’ shape. In contrast, the autocorrelation plot of urban datasets could hold two scenarios: constructive and destructive multipath effects. For both multipath scenarios, the autocorrelation curves will show more distortion and randomness than those from the open-sky dataset, and the correlation peaks of the two scenarios tend to have a time delay (shifted rightwards). As for the constructive multipath case, the magnitude of the peaks appears to be higher than those from the open-sky dataset, while the magnitude of peaks given by the destructive multipath will be lower.

For conventional tracking loop, the early phase will alway be made equal to the late phase, the location of the peak will be used to be the prompt phase. In this case, since the multipath effect impacts the peaks of the correlation curves to be shifted rightward, there will be time delay after receiver conducts the tracking and pseudorange measurement error will be enlarged.


## Task 3
We particularly analyze the satellite PRN16 in the open-sky dataset. The SDR has the functionality of decoding for navigation message and the output results (including general information, timing and reference parameters, polynomial correction terms, and orbital parameters) have been summarized in Table 1.

### Table 1: GPS L1 Ephemeris Parameters for PRN16

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

The design of the weighting matrix for Weighted Least Squares (WLS) positioning is based on the satellite Carrier-to-Noise density ($CN_0$) and elevation angle ($EL$), as proposed in [^2]. Specifically, the weighting matrix **W** is given by:
![Eq1](https://github.com/user-attachments/assets/fd3d2427-845e-4a12-a702-eb0ab1f2fc29)


where the parameters are tuned as $T=50,\ F=20,\ A=50,\ a=30$, to be fit in with the urban environment of Hong Kong. Therefore, in the Earth-centered, Earth-fixed (ECEF) coordinate, the position fix vector $$\Delta X=[\Delta x, \Delta y,\Delta z,  c \Delta b_{clk}]^\top$$ ($c$ denotes the speed of light) in each iteration in the algorithm becomes:

$$
    \Delta X = (G^\top WG)^{-1}G^\top W\Delta \rho,
$$

where $G$ is the measurement matrix, $\Delta \rho$ is the delta pseudorange measurements. Similarly, the velocity vector $$V=[ V_x, V_y,V_z, c\dot{b}_{clk}]^\top$$ in each iteration becomes:

$$
    V = (G^\top WG)^{-1}G^\top W \Delta \dot{\rho},
$$

where $\Delta \dot{\rho}$ denotes the vector of delta pseudorange rate measurement. Notably, the positioning results without the weighting matrix is denoted as Ordinary Least-Squares (OLS) positioning and will be taken as a comparison.

Extended Kalman Filter (EKF) can integrate the information from the pseudorange and Doppler measurements and estimate the user position and velocity simultaneously. In this report, the designed state vector

$$
**S**=[\Delta x, \Delta y,\Delta z,V_x, V_y,V_z,c\Delta b_{clk}, c\dot{b}_{clk}]^\top,
$$

and the measurement vector

$$
**Z**=[\Delta \rho_1,..., \Delta \rho_m, \Delta \dot{\rho}_1, ..., \Delta \dot{\rho}_m]^\top.
$$

In the measurement noise covariance matrix, we set the variance for delta pseudorange measurement to be 10m, and that for delta pseudorange rate to be 0.1m/s. For the setting of the process noise covariance matrix Q, the prediction and update procedures of EKF, one can refer to [^3]. Besides, the initial position of EKF is set based on positioning results given by OLS.

We set a period of 90ms for a navigation solution, and finally get the total resultant number of epochs during 90s to be 926. For the open-sky and urban datasets, we benchmark the positioning results of OLS, WLS and EKF with the ground truth locations in the latitude-longitude-height (LLH) coordinate. The 2D results are presented in Figure 2a for open-sky dataset, and in Figure 2b for the urban dataset Besides, the position error (Figure 3a and 3b) and velocity (Figure 4a and 4b) in Earth-North-Up (ENU) coordinate are plotted for both datasets.


![F2](https://github.com/user-attachments/assets/5fe51d83-5ba6-4b3e-971d-001637e2a892)


![F3](https://github.com/user-attachments/assets/2309fa29-df4e-4fa2-a7aa-c248622f9059)


![F4](https://github.com/user-attachments/assets/8eb20419-4bc0-40cf-99f6-3a681a9cdc14)


 
### Evaluations

Overall, in Figure 2, it can be seen that the 2D positioning accuracy order is: EKF>WLS>OLS, since the closeness between distributed points and ground truth has the order: EKF>WLS>OLS. This can also be reflected in Table 2 and 3, where 2D RMSE of EKF is better than WLS better than WLS.

For both datasets, though the EKF positionings may not cover the grouth truth (GT) location, its results tend to hold a significantly higher precision than OLS and WLS. Besides, EKF characterizes smooth change between adjacent epoch, while the other two generate frequent and sudden changes. This can also be reflected in Table 2 and 3, where the 2D standard deviation (STD) of the EKF is always the smallest.

Notably, the multipath effect impacts on both user position and velocities estimation, and the urban datasets with **multipath effect** generates overall worse positioning results than those from the open-sky dataset. Figure 3 shows that the positioning errors increase from around 15m (open-sky) to around 100m (urban) in E, N, U directions with multipath effect. Figure 4 shows that the velocities in the three directions become larger for the urban dataset. The 2D positioning results in LLH frame for the three algorithms also overall locate more separated from the grouth truth, and positionings become more dispersed in the urban dataset with multipath, which indicates bad quality in both accuracy and precision.


#### Table 2: Positioning Results Summary for Open-Sky Dataset
| Algorithm | 2D RMSE (m) | 3D RMSE (m) | 2D STD (m) | 3D STD (m) |
| :-- | :-- | :-- | :-- | :-- |
| OLS | 1.38 | 9.17 | 0.63 | 2.45 |
| WLS | 1.35 | 6.28 | 0.67 | 2.54 |
| EKF | 1.06 | 20.99 | 0.18 | 0.99 |

#### Table 3: Positioning Results Summary for Urban Dataset
| Algorithm | 2D RMSE (m) | 3D RMSE (m) | 2D STD (m) | 3D STD (m) |
| :-- | :-- | :-- | :-- | :-- |
| OLS | 61.07 | 92.32 | 22.89 | 35.72 |
| WLS | 25.60 | 59.67 | 13.28 | 30.87 |
| EKF | 39.88 | 55.68 | 13.71 | 16.33 |

---



### Acknowledgement:
This work is partially aided by Perplexity.AI, including markdown format generation and some discussion on the emphemeris parameters.


### References

[^1]: “FGI-GSRx software receiver,” Finnish Geospatial Research Institute, 2024. [Online]. Available: https://github.com/nlsfi/FGI-GSRx
[^2]: H.-F. Ng, G. Zhang, K.-Y. Yang, S.-X. Yang, and L.-T. Hsu, “Improved weighting scheme using consumer-level GNSS L5/E5a/B2a pseudorange measurements in the urban area,” Advances in Space Research, 2020.
[^3]: B. Xu and L.-T. Hsu, “Open-source MATLAB code for GPS vector tracking on a software-defined receiver,” GPS Solutions, vol. 23, no. 2, p. 46, Apr. 2019.

