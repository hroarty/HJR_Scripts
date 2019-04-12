%% read in the weatherflow data
%% path for the script  /Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data
read_weatherflow_data
buoy.name='37558';
yyyy0=2012;


wind_rose(buoy.wfdir,buoy.wspd,'dtype','meteo','n',12,'di',0:5:30,'ci',[5 10 15 20])
title('Wind Rose WeatherFlow Station 37588 20120101 to 20121231')
timestamp(1,'/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/plot_yearly_wind_rose.m')



print('-dpng','-r200',['Wind_Rose_' buoy.name '_2012.png'])

