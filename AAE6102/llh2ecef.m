function ecef_coord = llh2ecef(llh_coord)
    %% Reference: "Understanding GPS: principles and applications"
    %% Written by Zhengdao LI (zhengda0.li@connect.polyu.hk)
    phi    = llh_coord(1); 
    lambda = llh_coord(2);
    h      = llh_coord(3);  %latitude; longitude; height

    a = 6378137.0000;
    b = 6356752.3142;
    e_square = 1 - (b/a)^2;

    x = a*cos(lambda)/sqrt(1+(1-e_square)*tan(phi)^2)    + h*cos(lambda)*cos(phi);
    y = a*sin(lambda)/sqrt(1+(1-e_square)*tan(phi)^2)    + h*sin(lambda)*cos(phi);
    z = a*(1-e_square)*sin(phi)/sqrt(1-e_square*sin(phi)^2) + h*sin(phi);

    ecef_coord = [x, y, z];
end