function [rmse, stdv] = get_rmse_std(solu_pos_enu, pos_enu)
    two_DE = sqrt(solu_pos_enu(:,pos_enu(1)).^2 + solu_pos_enu(:,pos_enu(2)).^2);     % E,N
    three_DE = sqrt(solu_pos_enu(:,pos_enu(1)).^2 + solu_pos_enu(:,pos_enu(2)).^2 + solu_pos_enu(:,pos_enu(3)).^2);     % E,N,U
    rmse = [rms(two_DE), rms(three_DE)];
    stdv = [std(two_DE), std(three_DE)];
end