%% Thia m script plots the individual total grid point time series.
%% I run the code on ironman to generate the time series then transfer the 
%% saved mat file to my computer to plot the data


close all
clear all

conf.Plot.PrintPath='/Users/hroarty/COOL/STUDENT_ITEMS/Robert_Forney_2013/Paper/20150115_Time_Series_Plots/RDLmELTm/';

%% This data file contains the fields 
%% TUVcat
%% Tnotide
%% Ttide
load '/Users/hroarty/COOL/STUDENT_ITEMS/Robert_Forney_2013/Paper/20150115_Time_Series_Plots/BPU_RDLmELTm_1674_20120830_20120920.mat'

point=[-74.2,39.1];
I=1674;

%% create strings to use in the map filename
dtime2=BPU.Time;

timestr_sd=datestr(BPU.Time(1),'yyyymmdd');
timestr_ed=datestr(BPU.Time(end),'yyyymmdd');

U=BPU.U;
V=BPU.V;

region='region4';
[wp,wp2,rot]=fn_region_geometry(region);

%% rotate the u and v into a cross shelf and along shelf current
[ur, vr] = dg_rotate_refframe(U,V,rot);

%% Detide the data

[TIDESTRUC,XOUT]=t_tide(ur+1i*vr);

ur_tidal=real(XOUT);
vr_tidal=imag(XOUT);

%% calculate the nontidal current
ur_no_tide=ur-ur_tidal;
vr_no_tide=vr-vr_tidal;

%% Get the lowpass filtered data
per=32;
om=2*pi/per;

ns=64;

%% calculate the low pass of the data    
[tlow,ur_low,ur_hi]=lowpassbob(dtime2,ur,om,ns);
[tlow,vr_low,vr_hi]=lowpassbob(dtime2,vr,om,ns);

%% ************************************************************************
%% FIGURE 1
%% raw signal
figure (1)
subplot 211
plot(dtime2,ur,'r')
box on 
grid on
datetick('x','mm/dd')
ylabel('Cross Shore (cm/s)')
title (['Raw Time Series Plot at Lon:' sprintf('%3.2f',point(1)) ' Lat:' sprintf('%3.2f',point(2)) ' Index:' sprintf('%4.0f',I)])

subplot 212
plot(dtime2,vr,'b')
box on 
grid on
datetick('x','mm/dd')
ylabel('Along Shore (cm/s)')
timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_13_troubleshoot.m')
print(1,'-dpng','-r400',[ conf.Plot.PrintPath  'BPU_Totals_' timestr_sd '_' timestr_ed '_ts_index_' num2str(I) '_raw.png'])


%% ************************************************************************
%% FIGURE 2
figure (2)
subplot 211
plot(dtime2,ur_tidal,'r')
box on 
grid on
datetick('x','mm/dd')
ylabel('Cross Shore (cm/s)')
title (['Tidal Time Series Plot at Lon:' sprintf('%3.2f',point(1)) ' Lat:' sprintf('%3.2f',point(2)) ' Index:' sprintf('%4.0f',I)])

subplot 212
plot(dtime2,vr_tidal,'b')
box on 
grid on
datetick('x','mm/dd')
ylabel('Along Shore (cm/s)')

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_13_troubleshoot.m')
print(2,'-dpng','-r400',[ conf.Plot.PrintPath  'BPU_Totals_' timestr_sd '_' timestr_ed '_ts_index_' num2str(I) '_tidal.png'])

%% ************************************************************************
%% Figure 3
figure (3)
subplot 211
plot(dtime2,ur_no_tide,'r')
box on 
grid on
datetick('x','mm/dd')
ylabel('Cross Shore (cm/s)')
title (['Detided Time Series Plot at Lon:' sprintf('%3.2f',point(1)) ' Lat:' sprintf('%3.2f',point(2)) ' Index:' sprintf('%4.0f',I)])

subplot 212
plot(dtime2,vr_no_tide,'b')
box on 
grid on
datetick('x','mm/dd')
ylabel('Along Shore (cm/s)')

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_13_troubleshoot.m')
print(3,'-dpng','-r400',[ conf.Plot.PrintPath  'BPU_Totals_' timestr_sd '_' timestr_ed '_ts_index_' num2str(I) '_detided.png'])


%% ************************************************************************
%% Figure 4
figure (4)
subplot 211
plot(tlow,ur_low,'r')
box on 
grid on
datetick('x','mm/dd')
ylabel('Cross Shore (cm/s)')
title (['Low Pass ' sprintf('%3.0f',per) ' Hours, Time Series Plot at Lon:' sprintf('%3.2f',point(1)) ' Lat:' sprintf('%3.2f',point(2)) 'Index:' sprintf('%4.0f',I)])

subplot 212
plot(tlow,vr_low,'b')
box on 
grid on
datetick('x','mm/dd')
ylabel('Along Shore (cm/s)')

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_13_troubleshoot.m')
print(4,'-dpng','-r400',[ conf.Plot.PrintPath  'BPU_Totals_' timestr_sd '_' timestr_ed '_ts_index_' num2str(I) '_lowpass.png'])

