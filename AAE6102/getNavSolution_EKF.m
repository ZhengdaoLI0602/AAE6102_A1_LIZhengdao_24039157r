function [obs, sat, navSolution, allSettings] = getNavSolution_EKF(obs, sat, navSolution, allSettings, currMeasNr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function calculates navigation solutions for the receiver. 
%
% Inputs:
%   obs             - Observations for one epoch
%   sat             - satellite positions and velocities for one epoch
%   navSolution     - Current navigation solution 
%   allSettings     - receiver settings.
%   ephData         -  ephemeris data for all systems
%
% Outputs:
%   obsSingle       - Observations for one epoch
%   satSingle       - satellite positions and velocities for one epoch
%   navSolutions    - Output from navigation (position, velocity, time,
%
% %% Modified by Zhengdao LI (zhengda0.li@connect.polyu.hk)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Init temporary variables
[Pos, Vel, Time, allSettings] = initPosVel_EKF(obs, sat, navSolution, allSettings, currMeasNr);

% Check if we have enough observations for a nav solution
trynav = checkIfNavIsPossible(obs, allSettings);

if (trynav)

    % Calculate receiver position and velocity solution with EKF (% written by Zhengdao LI)
    [Pos, Vel] = calcPosVelEKF(obs, sat, allSettings, Pos, Vel, currMeasNr);   
    
    % Update observation structure
    obs = updateObservations(obs, Pos, Vel, allSettings);

    % Coordinate conversion 
    [Pos.LLA(1), Pos.LLA(2), Pos.LLA(3)] = wgsxyz2lla(allSettings.const, Pos.xyz); 

    % TBA enu calculations
    %[reflat,reflon,refalt] = wgsxyz2lla([settings.truePosition.X settings.truePosition.Y settings.truePosition.Z]);
    %navSolution.LSE.enu = wgsxyz2enu(navSolution.LSE.Pos.XYZ(1:3), reflat, reflon, refalt);    

    % Update time estimates from fix
    Time = updateReceiverTime(Pos, obs, allSettings);

else 
    % There are not enough satellites to find 3D position 
    disp(': Not enough information for position solution.');

    % Copy whatever data we have and set rest to NaN
    nrOfSignals = allSettings.sys.nrOfSignals;
    lengthdop=4+nrOfSignals;
    navSolution.LSE.Pos.XYZ  = [0 0 0];
    navSolution.LSE.Pos.dt  = NaN;
    navSolution.LSE.Pos.fom  = NaN;
    navSolution.LSE.DOP  = zeros(1,lengthdop);
    navSolution.LSE.Vel.XYZ  = [0 0 0];
    navSolution.LSE.Vel.df  = NaN;
    navSolution.LSE.Vel.fom  = NaN;
    navSolution.LSE.Systems  = NaN;        
    navSolution.LSE.FixStatus  = 'LKG';    
    navSolution.Klm.FixStatus  = 'LKG';        
    navSolution.nrSatUsed = 0;  
    navSolution.totalSatUsed = 0;
    navSolution.Time.receiverTow = NaN;
    
    navSolution.LSE.LLA  = [0 0 0];
    navSolution.LSE.enu  = [0 0 0];
    navSolution.Klm.LLA  = [0 0 0];

end

navSolution.Pos = Pos;
navSolution.Vel = Vel;
navSolution.Time = Time;
