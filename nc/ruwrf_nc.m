tic

clear all
close all

compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

javaaddpath('/Users/hroarty/Documents/MATLAB/netcdfAll-4.2.jar')
setpref ( 'SNCTOOLS', 'USE_JAVA', true );

DATA=[];

data_path=[root '/coolgroup/bpu/wrf/RUWRF/20130208/3km/'];

%addpath ( data_path)
addpath /Volumes/coolgroup/bpu/wrf/RUWRF/20130208/3km/

dtime.MT=datenum(2013,02,08,15,0,0):1/24:datenum(2013,02,08,20,0,0);
dtime.DV=datevec(dtime.MT);

print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20130208_Sandy_One_Pagers/pressure/';

for ii=1:length(dtime.MT)
    
    str.yr=num2str(dtime.DV(ii,1));
    str.mo=append_zero(dtime.DV(ii,2));
    str.da=append_zero(dtime.DV(ii,3));
    str.hr=append_zero(dtime.DV(ii,4));
    
    
    
    file=['wrfout_d01_' str.yr '-' str.mo '-' str.da '_' str.hr ':00:00'];

    full_path=[data_path file];
    disp(file);
    %nc_dump(full_path)

    wrf.SurfacePressure = nc_varget(file,'PSFC');
    wrf.lat= nc_varget(file,'XLAT');
    wrf.lon = nc_varget(file,'XLONG');
    
    hold on
    
    [cs,h2]=contour(wrf.lon,wrf.lat,wrf.SurfacePressure,85000:1000:105000);
    clabel(cs,h2,'fontsize',6);

    [cs3,h3]=contour(wrf.lon,wrf.lat,wrf.SurfacePressure,[90000 90000]);
    set(h3,'Color','k','LineWidth',2)
    
    axis([-77 -68 34 43])

    title(['Surface Pressure ' datestr(dtime.MT(ii),'mmm dd,yyyy HH:MM')])
    
    set(gca,'DataAspectRatio',[0.60 0.462 1])
    
    print('-dpng','-r200',[print_path 'RUWRF_PSFC_' datestr(dtime.MT(ii),'yyyy_mm_dd_HHMM') '.png'])
    clear str file
    close all
    %pause

end

toc

