close all
clear all


%% read in the weatherflow data
%% path for the script  /Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data
read_weatherflow_data
buoy.name='37558';
yyyy0=2012;

%% read in the hourly data
hourly=load('tuckertonwind.mat');


t1=datenum(2012,01,01);
t2=datenum(2012,1,31);
x_interval=5;
date_format='mm/dd';
ymin=0;
ymax=360;
y_interval=60;

datestr1=datestr(t1,'yyyymmdd');
datestr2=datestr(t2,'yyyymmdd');


[u,v]=compass2uv(buoy.wfdir,buoy.wspd);
[uhr,vhr]=compass2uv(hourly.hourlywinddir,hourly.hourlywindspd);

%% READ IN THE CODAR DATA

addpath /Users/hroarty/Documents/MATLAB/HJR_Scripts/codar_wave_scripts


datapath='/Users/hroarty/data/waves/SEAB';
[SEAB]=Codar_WVM7_readin_func(datapath,'wls');
ind2=find(SEAB.RCLL==2);
ind3=find(SEAB.RCLL==3);

datapath='/Users/hroarty/data/waves/SPRK';
[SPRK]=Codar_WVM7_readin_func(datapath,'wls');
ind4=find(SPRK.RCLL==2);
ind5=find(SPRK.RCLL==3);

datapath='/Users/hroarty/data/waves/BRNT';
[BRNT]=Codar_WVM7_readin_func(datapath,'wls');
ind6=find(BRNT.RCLL==2);
ind7=find(BRNT.RCLL==3);

datapath='/Users/hroarty/data/waves/BRMR';
[BRMR]=Codar_WVM7_readin_func(datapath,'wls');
ind8=find(BRMR.RCLL==2);
ind9=find(BRMR.RCLL==3);

datapath='/Users/hroarty/data/waves/RATH';
[RATH]=Codar_WVM7_readin_func(datapath,'wls');
ind10=find(RATH.RCLL==2);
ind11=find(RATH.RCLL==3);

datapath='/Users/hroarty/data/waves/WOOD';
[WOOD]=Codar_WVM7_readin_func(datapath,'wls');
ind12=find(WOOD.RCLL==2);
ind13=find(WOOD.RCLL==3);



s=[1 .5 0;... % orange WOOD
                1 0 0;...   % red    RATH
                0 .5 0;...  % green  BRMR
                0 0 1];     % blue   BRNT

% h=plot(SEAB.time(ind2),SEAB.WNDB(ind2),'Color',s(1,:),'LineWidth',2);
% plot(SPRK.time(ind4),SPRK.WNDB(ind4),'Color',s(2,:),'LineWidth',2)

conf.Radials.Sites={'WOOD','RATH','BRMR','BRNT'};



%% FIGURE 1
figure(1)
h1=plot(hourly.hourlytime,hourly.hourlywinddir,'r.');

hold on

%for ii=1:numel(conf.Radials.Sites)
for ii=3

site=conf.Radials.Sites{ii};

switch site
    case 'BRNT'
        plot(BRNT.time(ind6),BRNT.WNDB(ind6),'o','Markersize',6,'Color',s(4,:))
        title('Wind Direction for Site BRNT')
    case 'BRMR'
        plot(BRMR.time(ind8),BRMR.WNDB(ind8),'o','Markersize',6,'Color',s(3,:))
        title('Wind Direction for Site BRMR')
    case 'RATH'
        plot(RATH.time(ind10),RATH.WNDB(ind10),'o','Markersize',6,'Color',s(2,:))
        title('Wind Direction for Site RATH')
    case 'WOOD'
        plot(WOOD.time(ind12),WOOD.WNDB(ind12),'o','Markersize',6,'Color',s(1,:))
        title('Wind Direction for Site WOOD')
end
end




format_axis(gca,t1,t2,x_interval,date_format,ymin,ymax,y_interval)

ylabel('Wind Direction (deg CWN)')
xlabel('Date mm/dd')
title(['Comparison Between WeatherFlow Station 37558 and CODAR Station' site])

timestamp(1,'/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/plot_codar_weatherflow_wind_dir_time_series.m')
print('-dpng','-r200',['Wind_dir_ts_' buoy.name '_' site '_' datestr1 '_' datestr2 '.png'])




