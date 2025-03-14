%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright 2015-2021 Finnish Geospatial Research Institute FGI, National
%% Land Survey of Finland. This file is part of FGI-GSRx software-defined
%% receiver. FGI-GSRx is a free software: you can redistribute it and/or
%% modify it under the terms of the GNU General Public License as published
%% by the Free Software Foundation, either version 3 of the License, or any
%% later version. FGI-GSRx software receiver is distributed in the hope
%% that it will be useful, but WITHOUT ANY WARRANTY, without even the
%% implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
%% See the GNU General Public License for more details. You should have
%% received a copy of the GNU General Public License along with FGI-GSRx
%% software-defined receiver. If not, please visit the following website 
%% for further information: https://www.gnu.org/licenses/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Pos, Vel, Time, allSettings] = initPosVel_EKF(obs, sat, navSolution, allSettings, currMeasNr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function initialises the Pos, Vel and Time structs from navSolution.
%
% Inputs:
%   navSolution - Navigation solution data
%
% Outputs:
%   Pos - Structure with current position
%   Vel - Structure with current velocity
%   Time - Structure with current time
%
% %% Modified by Zhengdao LI (zhengda0.li@connect.polyu.hk)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Pos = navSolution.Pos;
    Vel = navSolution.Vel;
    Time = navSolution.Time;
    % Document the initial position given by OLS
    if currMeasNr == 1
        initial_guess_ols           = calcPosLSE(obs, sat, allSettings, Pos); 
        Pos.xyz                     = llh2ecef([allSettings.nav.trueLat, allSettings.nav.trueLong, allSettings.nav.trueHeight].*[pi/180, pi/180, 1]); 
        allSettings.nav.ekf_ini_pos = Pos.xyz; 
        Vel.xyz = [0 0 0];
        Pos.dt = 0;
        Vel.df = 0;
    else
        Pos.xyz = allSettings.nav.ekf_ini_pos;
    end
    
end