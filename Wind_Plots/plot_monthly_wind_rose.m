%% read in the weatherflow data
%% path for the script  /Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data
read_weatherflow_data
buoy.name='37558';
yyyy0=2012;

V=datevec(buoy.t);

months=1:12;

for ii=1:length(months)
    ind=find(V(:,2)==ii & V(:,1)==yyyy0);


    wind_rose(buoy.wfdir(ind),buoy.wspd(ind),'dtype','meteo','n',12,'di',0:5:30,'ci',[5 10 15 20])
    title({'Wind Rose WeatherFlow Station 37588 ' ;datestr(buoy.t(ind(1)),'mmm yyyy')})
    timestamp(1,'/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/plot_monthly_wind_rose.m')
    
    month_str=append_zero(ii);
    
    print('-dpng','-r200',['Wind_Rose_' buoy.name '_Month_' month_str '.png'])
    
    close all
    clear ind month_str
    
end