function [DATA]=ndbc_nc(buoy)


tic

javaaddpath('/Users/hroarty/Documents/MATLAB/netcdfAll-4.2.jar')
setpref ( 'SNCTOOLS', 'USE_JAVA', true );



DATA=[];

for ii=1:length(buoy.year)
    
    %% if statement to deal with no data for 2012 on station 44014
%     if buoy.year(ii)==2012
%         continue
%     end

    %file=['http://dods.ndbc.noaa.gov//thredds/dodsC/data/stdmet/44009/44009h' num2str(year(ii)) '.nc'];
    file=['https://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/' buoy.name '/' buoy.name 'h' num2str(buoy.year(ii)) '.nc'];
         
    disp(file);
    nc_dump(file)

    data(:,1) = nc_varget(file,'time');
    data(:,1) = epoch2datenum( data(:,1));
    data(:,2) = nc_varget(file,'wind_dir');
    data(:,3) = nc_varget(file,'wind_spd');
    data(:,4) = nc_varget(file,'gust');
    data(:,5) = nc_varget(file,'wave_height');
    data(:,6) = nc_varget(file,'dominant_wpd');
    data(:,7) = nc_varget(file,'average_wpd');
    data(:,8) = nc_varget(file,'mean_wave_dir');
    data(:,9) = nc_varget(file,'air_pressure');
    data(:,10) = nc_varget(file,'air_temperature');
    data(:,11) = nc_varget(file,'sea_surface_temperature');
    data(:,12) = nc_varget(file,'dewpt_temperature');
%     data(:,13) = nc_varget(file,'visibility');
%     data(:,13) = nc_varget(file,'visibility_in_air');
%     data(:,14) = nc_varget(file,'water_level');
    
    DATA=[DATA; data];
    
    clear data
    
    

end

%% Identify the fill values and replace with NaNs
ind_MWID= DATA(:,2)==999; %% column 
DATA(ind_MWID,2)=NaN;

ind_WSPD= DATA(:,3)==99;
DATA(ind_WSPD,3)=NaN;

ind_WGST= DATA(:,4)==99;
DATA(ind_WGST,4)=NaN;

ind_WVHT= DATA(:,5)==99;
DATA(ind_WVHT,5)=NaN;

ind_DPD= DATA(:,6)==99;
DATA(ind_DPD,6)=NaN;

ind_APD= DATA(:,7)==99;
DATA(ind_APD,7)=NaN;

ind_MWAD= DATA(:,8)==999;
DATA(ind_MWAD,8)=NaN;

ind_PRES= DATA(:,9)==9999;
DATA(ind_PRES,9)=NaN;

ind_ATMP= DATA(:,10)==999;
DATA(ind_ATMP,10)=NaN;

ind_WTMP= DATA(:,11)==999;
DATA(ind_WTMP,11)=NaN;

toc

