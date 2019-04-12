clear all;close all;
file='http://tds.marine.rutgers.edu:8080/thredds/dodsC/roms/espresso/2013_da/his_Best/ESPRESSO_Real-Time_v2_History_Best_Available_best.ncd';
ncdisp(file);


time=ncread(file,'ocean_time'); % seconds since 2006-01-01 00:00:00
datetime=(time./(60*60*24))+datenum(datevec('2006-01-01 00:00:00'));

%ncread(filename,parameter,start indices, count indices);
temp=ncread(file,'temp',[1 1 1 1000],[Inf Inf Inf 1]); % Type help ncread
lat=ncread(file,'lat_rho');
lon=ncread(file,'lon_rho');
test=squeeze(double(temp(:,:,:,1)));
pcolor(lon,lat,test(:,:,1));