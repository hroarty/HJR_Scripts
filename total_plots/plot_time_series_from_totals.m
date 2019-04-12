% This m script plots a time series from total files of a U or V component
% of the vector

date1=datenum(2009,9,30);
date2=datenum(2009,10,31);
start_date=date1;
end_date=date2;
X_hashes=[start_date-1:4:end_date];

ymax=60;
ymin=-60;
Y_hashes=(ymin:20:ymax);

subplot(3,1,1)
plot(time,V,'r')
hold on
grid on
axis ([date1 date2 ymin ymax])
set(gca,'XTick',X_hashes,'XTicklabel',datestr(X_hashes,'mm/dd'))
set(gca,'YTick',Y_hashes)
title(' V component (cm/s)')

subplot(3,1,2)
plot(time,V_OUT,'b')
grid on
axis ([date1 date2 ymin ymax])
set(gca,'XTick',X_hashes,'XTicklabel',datestr(X_hashes,'mm/dd'))
set(gca,'YTick',Y_hashes)
title(' Tidal V component (cm/s)')

subplot(3,1,3)
plot(time,V-V_OUT,'g')
grid on
axis ([date1 date2 ymin ymax])
set(gca,'XTick',X_hashes,'XTicklabel',datestr(X_hashes,'mm/dd'))
set(gca,'YTick',Y_hashes)
title(' V - Tidal V component (cm/s)')

timestamp(1,'COOL/01 CODAR/Tidal_Analysis/plot_time_series_from_totals.m')