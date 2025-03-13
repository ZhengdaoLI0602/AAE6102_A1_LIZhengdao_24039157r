clearvars
load('Outputs/Opensky2/matlab.mat')
settings.sys.ls_type = 2;  % 2: ekf; 0: ols; 1:wls
[obsData, satData, navData] = doNavigation(obsData, settings, ephData);


% %%  Drawing Figures
% for i = 1: size(navData, 2)
%     pos_llh_ekf(i,:) = navData{1,i}.Pos.LLA;
%     vel_xyz_ekf(i,:) = navData{1,i}.Vel.xyz;
%     % err_vec(i,:)     = navData{1,i}.Pos.error_vector';
%     % mea_residual(i,:)  = navData{1,i}.Pos.ekf.meas_residual';
%     % kmg(i,:)           = navData{1,i}.Pos.ekf.Kalman_gain';
%     % vlit(i,: ) = [navData{1,i}.Pos.bValid, navData{1,i}.Vel.bValid];
% end
% 
% 
% load("pos_llh_os.mat")
% figure;hold on; grid on;
% scatter(pos_llh(:,2),     pos_llh(:,1), 30, 'filled', 'b', 'DisplayName', 'OLS')
% scatter(pos_llh_ekf(:,2), pos_llh_ekf(:,1), 30, 'filled', 'r', 'DisplayName', 'EKF')
% scatter(settings.nav.trueLong, settings.nav.trueLat,30, 'filled', 'green', 'DisplayName', 'GT')