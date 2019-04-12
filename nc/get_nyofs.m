% file='http://opendap.co-ops.nos.noaa.gov/thredds/dodsC/NOAA/NYOFS/MODELS/201712/nos.nyofs_fg.stations.nowcast.20171208.t20z.nc';
file='http://opendap.co-ops.nos.noaa.gov/thredds/dodsC/DBOFS/fmrc/Aggregated_7_day_DBOFS_Fields_Forecast_best.ncd';
file='/Users/hroarty/data/NYOFS/nos.nyofs_fg.stations.nowcast.20171211.t13z.nc';
% file='/Users/hroarty/data/NYOFS/nyofs_vdatums.nc';

ncdisp(file)

lon=ncread(file,'lon');
lat=ncread(file,'lat');

mask=ncread(file,'mask');

mask=logical(mask);

 plot(lon(mask),lat(mask),'b.')

 conf.Plot.filename='NYHOFS_Grid.png'; 
 conf.Plot.script='get_nyofs.m';
 conf.Plot.print_path ='/Users/hroarty/data/NYOFS/';
 
 
 timestamp(1,[conf.Plot.filename ' / ' conf.Plot.script])
 print(1,'-dpng','-r200',[conf.Plot.print_path  conf.Plot.filename])
 
