function enu_coord = ecef2enu(xyz_coord, ref_xyz_coord)
    %% Written by Zhengdao LI (zhengda0.li@connect.polyu.hk)
    xyz_coord     = reshape(xyz_coord, [1,3]);
    ref_xyz_coord = reshape(ref_xyz_coord, [1,3]);

    % Both llh_coord and ref_xyz_coord are in ECEF format
    ref_llh_coord = ecef2llh(ref_xyz_coord);
    % using the reference llh coordinate, to generate transformation matrix from xyz to enu
    R = R_ecef_enu(ref_llh_coord);
    % size 3*3, to be multiplied with 3*1 vector
    dt_xyz = xyz_coord - ref_xyz_coord;

    enu_coord = R*dt_xyz';
end
