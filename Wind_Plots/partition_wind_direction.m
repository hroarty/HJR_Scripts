close all
clear all


%% read in the weatherflow data
%% path for the script  /Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data
read_weatherflow_data
buoy.name='37558';
yyyy0=2012;

%% read in the hourly data
hourly=load('tuckertonwind.mat');

%% Define some configuration parameters
config.start_date=datenum(2012,01,01);
config.end_date=datenum(2012,12,31);
config.x_interval=30;
config.date_format='mm/dd';
config.ymin=-40;
config.ymax=40;
config.y_interval=10;


[u,v]=compass2uv(buoy.wfdir,buoy.wspd);
[uhr,vhr]=compass2uv(hourly.hourlywinddir,hourly.hourlywindspd);


month=1:12;
end_day=eomday(2012,month);

wind_dir2=[];

for jj =month
    ind=find(hourly.hourlytime >= datenum(2012,jj,1,0,0,0) & hourly.hourlytime <= datenum(2012,jj,end_day(jj),23,0,0));
    ind=ind';
    disp(size(ind))
    
    %monthstr=append_zero(jj);
    monthstr=datestr(datenum(2012,jj,1,0,0,0),'mmm');
    
%     wind_dir.NE=find(hourly.hourlywinddir(ind) > 0 & hourly.hourlywinddir(ind) < 90)';
%     wind_dir.SE=find(hourly.hourlywinddir(ind) > 90 & hourly.hourlywinddir(ind) < 180)';
%     wind_dir.SW=find(hourly.hourlywinddir(ind) > 180 & hourly.hourlywinddir(ind) < 270)';
%     wind_dir.NW=find(hourly.hourlywinddir(ind) > 270 & hourly.hourlywinddir(ind) < 360)';
    
    wind_dir.(monthstr).NE=find(hourly.hourlywinddir(ind) > 0 & hourly.hourlywinddir(ind) < 90)';
    wind_dir.(monthstr).SE=find(hourly.hourlywinddir(ind) > 90 & hourly.hourlywinddir(ind) < 180)';
    wind_dir.(monthstr).SW=find(hourly.hourlywinddir(ind) > 180 & hourly.hourlywinddir(ind) < 270)';
    wind_dir.(monthstr).NW=find(hourly.hourlywinddir(ind) > 270 & hourly.hourlywinddir(ind) < 360)';
    
    wind_dir2(jj,1)= length(wind_dir.(monthstr).NE);
    wind_dir2(jj,2)= length(wind_dir.(monthstr).SE);
    wind_dir2(jj,3)= length(wind_dir.(monthstr).SW);
    wind_dir2(jj,4)= length(wind_dir.(monthstr).NW);
    
    
end













