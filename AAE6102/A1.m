%% Written by Zhengdao LI (zhengda0.li@connect.polyu.hk)
close all


test_ekf
%% Save and load data

load("Outputs/Opensky2/nav_OLS.mat")
solu_ols = navData;
load("Outputs/Opensky2/nav_WLS.mat")
solu_wls = navData;
load("Outputs/Opensky2/nav_EKF.mat")
solu_ekf = navData;

NrEpoch    = size(navData, 2);
GT_llh     = [settings.nav.trueLat, settings.nav.trueLong, settings.nav.trueHeight];
GT_ecef    = llh2ecef(GT_llh.*[pi/180, pi/180, 1]);
R_mat      = R_ecef_enu(GT_llh.*[pi/180, pi/180, 1]); % transform from LLH to ENU coordinate

pos_llh = (1:3);
vel_enu = (4:6);
pos_enu = (7:9);

for i = 1: NrEpoch % loop through each epoch
    % OLS: (pos_llh, vel_enu)
    SOLU.ols(i, pos_llh) = solu_ols{1,i}.Pos.LLA;
    SOLU.ols(i, vel_enu) = (R_mat * solu_ols{1,i}.Vel.xyz')'; % ((3,3) * (1,3)')' = (1,3)
    SOLU.ols(i, pos_enu) = (R_mat * (solu_ols{1,i}.Pos.xyz - GT_ecef)' )';

    % WLS: (pos_llh, vel_enu)
    SOLU.wls(i, pos_llh) = solu_wls{1,i}.Pos.LLA;
    SOLU.wls(i, vel_enu) = (R_mat * solu_wls{1,i}.Vel.xyz')';
    SOLU.wls(i, pos_enu) = (R_mat * (solu_wls{1,i}.Pos.xyz - GT_ecef)' )';

    % EKF: (pos_llh, vel_enu)
    SOLU.ekf(i, pos_llh) = solu_ekf{1,i}.Pos.LLA;
    SOLU.ekf(i, vel_enu) = (R_mat * solu_ekf{1,i}.Vel.xyz')';
    SOLU.ekf(i, pos_enu) = (R_mat * (solu_ekf{1,i}.Pos.xyz - GT_ecef)' )';
end


%% LLH Location

% figure; hold on; grid on
% scatter(SOLU.ols(:, pos_llh(2)), SOLU.ols(:, pos_llh(1)), 30, 'filled', 'r', 'DisplayName', 'OLS')
% scatter(SOLU.wls(:, pos_llh(2)), SOLU.wls(:, pos_llh(1)), 30, 'filled', 'b', 'DisplayName', 'WLS')
% scatter(SOLU.ekf(:, pos_llh(2)), SOLU.ekf(:, pos_llh(1)), 30, 'filled', 'cyan', 'DisplayName', 'EKF')
% scatter(GT_llh(2), GT_llh(1), 300, 'filled', 'g', "pentagram",'MarkerEdgeColor', 'k', 'DisplayName', 'Grount Truth')
% legend('show');
% ylabel("Latitude (deg)");
% xlabel("Longtitude (deg)");

figure; 
geobasemap('satellite');
geoscatter(SOLU.ols(:, pos_llh(1)), SOLU.ols(:, pos_llh(2)), 30, 'filled', 'r', 'DisplayName', 'OLS'); hold on
geoscatter(SOLU.wls(:, pos_llh(1)), SOLU.wls(:, pos_llh(2)), 30, 'filled', 'b', 'DisplayName', 'WLS'); hold on
geoscatter(SOLU.ekf(:, pos_llh(1)), SOLU.ekf(:, pos_llh(2)), 30, 'filled', 'cyan', 'DisplayName', 'EKF'); hold on
geoscatter(GT_llh(1), GT_llh(2), 300, 'filled', 'g', "pentagram",'MarkerEdgeColor', 'k', 'DisplayName', 'Grount Truth'); hold on
legend('show');


%% Position Error
figure; 
subplot(3,1,1)
hold on; grid on 
plot(1:NrEpoch, SOLU.ols(:,pos_enu(1)), 'r-*', 'DisplayName', 'OLS', LineWidth=1);
plot(1:NrEpoch, SOLU.wls(:,pos_enu(1)), 'blue-*', 'DisplayName', 'WLS', LineWidth=1);
plot(1:NrEpoch, SOLU.ekf(:,pos_enu(1)), 'cyan-*', 'DisplayName', 'EKF', LineWidth=1);
legend('show'); ylabel("Error (m)"); title("East (E)")

subplot(3,1,2)
hold on; grid on
plot(1:NrEpoch, SOLU.ols(:,pos_enu(2)), 'r-*', 'DisplayName', 'OLS', LineWidth=1);
plot(1:NrEpoch, SOLU.wls(:,pos_enu(2)), 'blue-*', 'DisplayName', 'WLS', LineWidth=1);
plot(1:NrEpoch, SOLU.ekf(:,pos_enu(2)), 'cyan-*', 'DisplayName', 'EKF', LineWidth=1);
legend('show'); ylabel("Error (m)"); title("North (N)")

subplot(3,1,3)
hold on; grid on
plot(1:NrEpoch, SOLU.ols(:,pos_enu(3)), 'r-*', 'DisplayName', 'OLS', LineWidth=1);
plot(1:NrEpoch, SOLU.wls(:,pos_enu(3)), 'blue-*', 'DisplayName', 'WLS', LineWidth=1);
plot(1:NrEpoch, SOLU.ekf(:,pos_enu(3)), 'cyan-*', 'DisplayName', 'EKF', LineWidth=1);
legend('show'); ylabel("Error (m)"); title("Up (U)")
xlabel("Time (Epoch)")


%% Velocity
figure; 
subplot(3,1,1)
hold on; grid on 
plot(1:NrEpoch, SOLU.ols(:,vel_enu(1)), 'r-*', 'DisplayName', 'OLS', LineWidth=1);
plot(1:NrEpoch, SOLU.wls(:,vel_enu(1)), 'blue-*', 'DisplayName', 'WLS', LineWidth=1);
plot(1:NrEpoch, SOLU.ekf(:,vel_enu(1)), 'cyan-*', 'DisplayName', 'EKF', LineWidth=1);
legend('show'); ylabel("Velocity (m/s)"); title("East (E)")

subplot(3,1,2)
hold on; grid on 
plot(1:NrEpoch, SOLU.ols(:,vel_enu(2)), 'r-*', 'DisplayName', 'OLS', LineWidth=1);
plot(1:NrEpoch, SOLU.wls(:,vel_enu(2)), 'blue-*', 'DisplayName', 'WLS', LineWidth=1);
plot(1:NrEpoch, SOLU.ekf(:,vel_enu(2)), 'cyan-*', 'DisplayName', 'EKF', LineWidth=1);
legend('show'); ylabel("Velocity (m/s)"); title("North (N)")

subplot(3,1,3)
hold on; grid on 
plot(1:NrEpoch, SOLU.ols(:,vel_enu(3)), 'r-*', 'DisplayName', 'OLS', LineWidth=1);
plot(1:NrEpoch, SOLU.wls(:,vel_enu(3)), 'blue-*', 'DisplayName', 'WLS', LineWidth=1);
plot(1:NrEpoch, SOLU.ekf(:,vel_enu(3)), 'cyan-*', 'DisplayName', 'EKF', LineWidth=1);
legend('show'); ylabel("Velocity (m/s)"); title("Up (U)")

xlabel("Time (Epoch)")


%% Evaluation
[rmse, stdv] = get_rmse_std(SOLU.ols, pos_enu)
[rmse, stdv] = get_rmse_std(SOLU.wls, pos_enu)
[rmse, stdv] = get_rmse_std(SOLU.ekf, pos_enu)
