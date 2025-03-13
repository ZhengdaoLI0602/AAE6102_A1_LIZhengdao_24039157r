function llh_coord = ecef2llh(xyz_coord)
    %% Written by Zhengdao LI (zhengda0.li@connect.polyu.hk)
    % Example: 
    % X, Y, Z = 1776694.9644800487, 5759463.252896432, 2079310.7706825584
    % ANS: [19.152548, 72.855909, 8.00]    
    
    % WGS84 ellipsoid parameters
    a = 6378137.0;  % Semi-major axis in meters
    f = 1 / 298.257223563;  % Flattening
    % b = a * (1 - f)  % Semi-minor axis in meters
    e_square = 2*f - f^2;  % Square of the first eccentricity

    % Extract coordinates
    x = xyz_coord(1);
    y = xyz_coord(2); 
    z = xyz_coord(3);

    %% >>> Longtitude
    lambda = atan(y/x);
    if lambda < 0
        lambda = pi + lambda;
    end

    %% >>> latitude
    p = sqrt(x^2 + y^2);
    lat = atan(z/p);  % Initial guess

    % Iterative calculation for latitude
    tol = 1e-12;
    iter = 0;
    max_iter = 100;
    while iter < max_iter
        N = a / sqrt(1 - e_square * sin(lat)^2);
        h = p / cos(lat) - N;
        lat_new = atan(z/(p * (1 - e_square * N / (N + h))));
        if abs(lat_new - lat) < tol
            break
        end
        lat = lat_new;
        iter = iter + 1;
    end

    %% >>> Height/Altitude
    N = a/sqrt(1-e_square*sin(lat)^2);

    if ~(lat==pi/2 || lat==-pi/2) 
        h = p/cos(lat) - N;
    else
        h = z/sin(lat) - N + e_square*N;
    end

    % Convert latitude and longitude to degrees
    % r2d = 180 / π

    llh_coord = [lat, lambda, h];
end