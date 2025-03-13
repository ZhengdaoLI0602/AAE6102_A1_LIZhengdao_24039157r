function [Pos, Vel] = calcPosVelEKF(obs, sat, allSettings, Pos, Vel, currMeasNr)
%% Reference of Equations in: 
% "Open-source MATLAB code for GPS vector tracking on a softwaredefined
% receiver" by Bing Xu, Li-Ta Hsu
%% Competatible with FGI-GSRx Soft-defined Receiver: 
% https://github.com/nlsfi/FGI-GSRx
%% Written and modified by Zhengdao LI (zhengda0.li@connect.polyu.hk)



%% Set starting point
pos = Pos.xyz;
vel = Vel.xyz;

% Init clock elements in pos and vel vector
nrOfSignals = allSettings.sys.nrOfSignals;
pos(4:3+nrOfSignals) = zeros;
vel(4:3+nrOfSignals) = zeros;
if currMeasNr == 1
    error_vector = 1e-10 .* ones(6+2*nrOfSignals, 1);  % delta*[X,Y,Z, V_x,V_y,V_z, clk_bias, clk_drift]
else
    error_vector = Pos.error_vector;
end
% Constants
WGS84oe = allSettings.const.EARTH_WGS84_ROT;
SPEED_OF_LIGHT = allSettings.const.SPEED_OF_LIGHT;

%% Kalman Filter Parameter
ms = 1e-3;
pdi = 1;  % predetection integration time e.g. 1 ms
tor = pdi*ms;


% Transition matrix: Phi ( Equ.(3) )
transition_Phi  = eye(length(error_vector));
transition_Phi(1:3, 4:6) = tor.*eye(3);
transition_Phi(7:8, 7:8) = [1 tor; 0 1];


% State covariance: P
if currMeasNr == 1 % initialize at epoch 1
    diag_info = [1E2*ones(length(error_vector)-2*nrOfSignals, 1); ...
                 1E10*ones(2*nrOfSignals, 1)];
    state_cov_P = diag(diag_info);
else               % orient the previous state_cov_P
    state_cov_P = Pos.state_cov_P;
end

% Process noise matrix: Q ( Equ.(10) )
% % Method 1:
% h0 = 1e-21; % OCXO typical value
% h2 = 1e-24; % OCXO typical value
% Sv = 1e6;
% Sf = SPEED_OF_LIGHT^2*(h0/2);
% Sg = SPEED_OF_LIGHT^2*2*pi^2*h2;
% process_noise_Q_dyn = Sv.*[tor^3/3.*eye(3) tor^2/2.*eye(3); ...
%                            tor^2/2.*eye(3) tor.*eye(3)   ];  % Equ.(11)
% process_noise_Q_clk = [tor*Sf+tor^3/3*Sg  Sg*tor^2/2    ; ...
%                        Sg*tor^2/2         tor*Sg   ];        % Equ.(12)
% process_noise_Q = eye(length(error_vector));
% process_noise_Q(1:6, 1:6) = process_noise_Q_dyn;
% process_noise_Q(7:8, 7:8) = process_noise_Q_clk;
% Method 2: 
acc = 0.1;  
sigma2_pos_H = (acc*tor^2)^2;
sigma2_pos_V = 10*(acc*tor^2)^2;
sigma2_vel_H = (acc*tor)^2;
sigma2_vel_V = 10*(acc*tor)^2;
Sx = 2E-19;
Sf = 1E-20;
sigma2_clk_bias  = Sx * tor * SPEED_OF_LIGHT^2;
sigma2_clk_drift = Sf * tor * SPEED_OF_LIGHT^2;
process_noise_Q = diag([sigma2_pos_H.*ones(1,2), sigma2_pos_V, sigma2_vel_H.*ones(1,2), sigma2_vel_V, ...
      sigma2_clk_bias.*ones(1,nrOfSignals), sigma2_clk_drift.*ones(1,nrOfSignals)]);





%% Main loop starts 
ind = 0;    
% Loop over all signals
for signalNr = 1:nrOfSignals
    % Extract signal acronym
    signal = allSettings.sys.enabledSignals{signalNr};        
    % Loop over all channels
    for channelNr = 1:obs.(signal).nrObs
        if(obs.(signal).channel(channelNr).bObsOk)
            ind = ind + 1; % Index for valid obervations

            % These are the pseudorange and dopplers for all satellites
            pseudo_range(ind)      = obs.(signal).channel(channelNr).corrP;
            pseudo_range_rate(ind) = obs.(signal).channel(channelNr).doppler;
            
            % Calculate range to satellite    
            dx=sat.(signal).channel(channelNr).Pos(1)-pos(1);
            dy=sat.(signal).channel(channelNr).Pos(2)-pos(2);
            dz=sat.(signal).channel(channelNr).Pos(3)-pos(3);
            range(ind)=sqrt(dx^2+dy^2+dz^2); 

            % Direction cosines
            sv_matrix(ind,1) = dx/range(ind);
            sv_matrix(ind,2) = dy/range(ind);
            sv_matrix(ind,3) = dz/range(ind);
            sv_matrix(ind,3+signalNr) = 1;

            %  ----- POSITION PART ----- 
            % 1. Total clock correction term (m). */
            clock_correction = 0; %clock_correction = c*(sv_pos.dDeltaTime - eph(info.PRN).group_delay);
            % 2. First compute the SV's earth rotation correction
            rhox = sat.(signal).channel(channelNr).Pos(1) - pos(1);
            rhoy = sat.(signal).channel(channelNr).Pos(2) - pos(2);
            EarthRotCorr(ind) = WGS84oe / SPEED_OF_LIGHT * (sat.(signal).channel(channelNr).Pos(2)*rhox-sat.(signal).channel(channelNr).Pos(1)*rhoy);
            % 3. Total propagation delay. 
            propagation_delay(ind) = range(ind) + EarthRotCorr(ind) - clock_correction;
            % 4. Correct the pseudoranges also (because we corrected rcvr stamp)
            omp.dRange(ind)    = pseudo_range(ind) - propagation_delay(ind);       % (#delta pseudorange)
            Res_Range(ind)     = omp.dRange(ind) - pos(3 + signalNr)*SPEED_OF_LIGHT;
            %  ----- POSITION PART -----

            %  ----- VELOCITY PART -----
            % 1. Velocity observed
            relative_velocity(ind) = dx * sat.(signal).channel(channelNr).Vel(1) + dy * sat.(signal).channel(channelNr).Vel(2) + dz * sat.(signal).channel(channelNr).Vel(3);
            relative_velocity(ind) = relative_velocity(ind) / sqrt(dx*dx+dy*dy+dz*dz);
            % 2. Observed minus predicted (note that "-" changed to "+" due to "relative" velocity)
            omp.dRange_rate(ind) = pseudo_range_rate(ind) + relative_velocity(ind) + sat.(signal).channel(channelNr).Vel(4) * SPEED_OF_LIGHT;
            Res_RangeRate(ind)   = omp.dRange_rate(ind) - vel(3 + signalNr)*SPEED_OF_LIGHT; 
            %  ----- VELOCITY PART -----
        end
    end
    nrSatsUsed(signalNr) = ind;
end

% Measurement matrix: H ( Equ.(9) )
meas_pos_H = [sv_matrix(:,1:3)  zeros(size(sv_matrix,1),3) ...
               ones(size(sv_matrix,1),nrOfSignals)  zeros(size(sv_matrix,1),nrOfSignals)];
meas_vel_H = [zeros(size(sv_matrix,1),3)  sv_matrix(:,1:3)   ...
               zeros(size(sv_matrix,1),nrOfSignals)   ones(size(sv_matrix,1),nrOfSignals)  ];
meas_H = [meas_pos_H; meas_vel_H];

% Measurement vector: Z ( Equ.(7) )
meas_vector = [omp.dRange, omp.dRange_rate]';

% Measurement covariance matrix: R
meas_noise_R = eye(size(meas_H,1));
meas_noise_R(1:size(meas_pos_H,1), 1:size(meas_pos_H,1)) = 1e-3.* eye(size(meas_pos_H,1));
meas_noise_R(size(meas_pos_H,1)+1:end, size(meas_pos_H,1)+1:end) = 1e-4.* eye(size(meas_pos_H,1));


% ----- EXTENDED KALMAN FILTER EQUATIONS -----
% Extrapolation
error_vector = transition_Phi * error_vector;
state_cov_P  = transition_Phi * state_cov_P * transition_Phi' + process_noise_Q;
% Update
% SOL_mat = diag([ones(1, length(error_vector)-2), SPEED_OF_LIGHT, SPEED_OF_LIGHT]);

meas_residual   = meas_vector - meas_H * error_vector; % [m,m,m, m/s,m/s,m/s, ct->m, c->m/s]
KmG_denominator = meas_H * state_cov_P * meas_H' + meas_noise_R;
Kalman_gain     = state_cov_P * meas_H' * inv(KmG_denominator);
error_vector    = error_vector + Kalman_gain * meas_residual;
state_cov_P     = (eye(length(error_vector)) - Kalman_gain * meas_H) * state_cov_P;
% ----- EXTENDED KALMAN FILTER EQUATIONS -----

% Convert to clock bias and clock drift
% error_vector(7:end) = error_vector(7:end)/SPEED_OF_LIGHT;


%% Navigation Solutions
% Copying data to output data structure
Pos.trueRange    = range;
Pos.rangeResid   = Res_Range;
Pos.error_vector = error_vector;                                    % store the error vector
Pos.nrSats       = diff([0 nrSatsUsed]);
Pos.signals      = allSettings.sys.enabledSignals;
Pos.state_cov_P  = state_cov_P;                                     % update state covariance matrix
Pos.xyz          = Pos.xyz + error_vector(1:3)';                    % update position
Pos.dt           = Pos.dt  + error_vector(7:6+nrOfSignals)';        % update clock bias
% Get dop values
Pos.dop = getDOPValues(allSettings.const, sv_matrix, Pos.xyz);


% Copying data to output data structure
Vel.nrSats       = nrSatsUsed;
Vel.dopplerResid = Res_RangeRate;
Vel.xyz          = error_vector(4:6)';                    % update velocity
Vel.df           = error_vector(6+nrOfSignals+1: end)';   % update clock drift


end