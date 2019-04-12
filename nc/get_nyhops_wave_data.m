close all
clear all

f='http://colossus.dl.stevens-tech.edu:8080/thredds/dodsC/fmrc/NYBight/NYHOPS_Forecast_Collection_for_the_New_York_Bight_best.ncd';
%  http://colossus.dl.stevens-tech.edu:8080/thredds/dodsC/fmrc/NYBight/NYHOPS_Forecast_Collection_for_the_New_York_Bight_best.ncd

%  %"hours since 2010-01-01T00:00:00Z"
% reftime=datenum(2010,1,1);
% t=ncread(url,'time');
% t=(t/24)+reftime;
% lat=ncread(url,'lat');
% lon=ncread(url,'lon');
% uvang=ncread(url,'ang');

conf.station.coords=[-74.0726 39.9325];
conf.station.name={'SPRK'};

% determine the start time of the model
timeAtt = ncreadatt(f, 'time', 'units');
timeStr = timeAtt(end-19:end-1);
% datestr(datenum(timeStr, 'yyyy-mm-ddTHH:MM:SS'))
timeNYH = datenum(timeStr, 'yyyy-mm-ddTHH:MM:SS');
datestr(timeNYH)

%% load in the time variable of the model
dtime = ncread(f, 'time');

%% convert the model time to matlab time
% hours since 2017-04-29
dtime1=dtime/(24)+timeNYH;

lat=ncread(f,'lat');
lon=ncread(f,'lon');

%% find the closest grid point to the HFR station
% column 21 or end is closest to shore
% column 1 
column=16;
d = dist( conf.station.coords(1,1), conf.station.coords(1,2), lon(:,column), lat(:,column) );
[Y1,I1] = min(d);%% find index of closest longitude point

WH=ncread(f,'wh',[I1 21 1],[1 1 Inf]);
WP=ncread(f,'wp',[I1 I2 1],[1 1 Inf]);
WD=ncread(f,'wd',[I1 I2 1],[1 1 Inf]);

WH=squeeze(WH);
WP=squeeze(WP);
WD=squeeze(WD);









% figure(1)
% EC_map(0)
% hold on
% quiver(lon,lat,musub,mvsub,'r')
% hold off


