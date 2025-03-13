
fingerindexes = [-0.5:0.1:0.5];
corr_mat = [];
num_time = 20;

num_time =10;
figure; hold on
for sv_id = 1: size(trackResults.gpsl1.channel,2)
    for idd=1:num_time
        % idd = 1;
        corr_E = sqrt(trackResults.gpsl1.channel(sv_id).I_E(:,idd).^2 + trackResults.gpsl1.channel(sv_id).Q_E(:,idd).^2);
        corr_L = sqrt(trackResults.gpsl1.channel(sv_id).I_L(:,idd).^2 + trackResults.gpsl1.channel(sv_id).Q_L(:,idd).^2);
        corr_P = sqrt(trackResults.gpsl1.channel(sv_id).I_P(:,idd).^2 + trackResults.gpsl1.channel(sv_id).Q_P(:,idd).^2);
    
        corr_mat(:,idd) = [corr_E; corr_P; corr_L];
        plot(fingerindexes', corr_mat(:,idd));
    end
end
xlabel("Time delay (chips)")
ylabel("Correlation value")
title("ACF")









