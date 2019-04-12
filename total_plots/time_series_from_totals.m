% This m script was written to injest total vector data in ascii format,
% detide the data and plot the data

%% Use this section of code to read the ASCII total files into structured
%% array
% datapath='C:\Documents and Settings\hroarty\My Documents\COOL\01 CODAR\Tidal_Analysis\2009_10_MARCOOS_Totals\';
% total_data=Codar_OI_TOT_readin_func(datapath);


%% Load the structured array of total files
load 2009_October_Totals

%% Convert the 

time=[total_data.time]';


%index 4079 middle of NJ shelf
%index 6183 outside Block Island Sound
% index 7225 nearest to OOI Pioneer Mooring Array
index=7225;

for i=1:length(total_data)
U(i)=total_data(1,i).U(index);
end

indU=find(U==-999);
U(indU)=NaN;
U=U';

for i=1:length(total_data)
V(i)=total_data(1,i).V(index);
end

indV=find(V==-999);
V(indV)=NaN;
V=V';

[U_NAME,U_FREQ,U_TIDECON,U_OUT]=T_TIDE(U);

[V_NAME,V_FREQ,V_TIDECON,V_OUT]=T_TIDE(V);





date1=datenum(2009,9,30);
date2=datenum(2009,10,31);
start_date=date1;
end_date=date2;
X_hashes=[start_date-1:4:end_date];

ymax=60;
ymin=-60;
Y_hashes=(ymin:20:ymax);

subplot(2,1,1)
plot(time,U,'r')
hold on
box on
grid on
axis ([date1 date2 ymin ymax])
ylabel('u velocity (cm/s)')
set(gca,'XTick',X_hashes,'XTicklabel',datestr(X_hashes,'mm/dd'))
set(gca,'YTick',Y_hashes)
title('October 2009 Surface Velocity Time Series at OOI Pioneer Mooring Array')

subplot(2,1,2)
plot(time,V,'r')
hold on
% plot(time,V_OUT,'b')
% plot(time,V-V_OUT,'g')
box on
grid on
axis ([date1 date2 ymin ymax])
ylabel('v velocity (cm/s)')
set(gca,'XTick',X_hashes,'XTicklabel',datestr(X_hashes,'mm/dd'))
set(gca,'YTick',Y_hashes)

timestamp(1,'COOL/01 CODAR/Tidal_Analysis/time_series_from_totals.m')



