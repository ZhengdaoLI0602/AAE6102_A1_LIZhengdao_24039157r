function R = R_ecef_enu(ref_llh_coord)
    %% Written by Zhengdao LI (zhengda0.li@connect.polyu.hk)
    phi    = ref_llh_coord(1);
    lambda = ref_llh_coord(2);

    R = [-sin(lambda)          cos(lambda)                  0;
         -sin(phi)*cos(lambda) -sin(phi)*sin(lambda) cos(phi);
         cos(phi)*cos(lambda)  cos(phi)*sin(lambda)  sin(phi)];
end