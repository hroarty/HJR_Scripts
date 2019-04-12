 url='http://tds.marine.rutgers.edu:8080/thredds/dodsC/roms/espresso/2013_da/avg_Best/ESPRESSO_Real-Time_v2_Averages_Best_Available_best.ncd';
 
%'hours since 2013-05-18T00:00:00Z'
reftime=datenum(2013,5,18);
t=ncread(url,'time');
t=(t/24)+reftime;

lat=ncread(url,'lat_u');
lon=ncread(url,'lon_u');

figure(1)
%lims=[-77 -68 33 44];
lims=[ -74-20/60 -73-40/60 40+20/60 40+40/60];
coastFileName = '/Users/hroarty/data/coast_files/MARA_coast.mat';
 plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch',[240,230,140]./255);


hold on
m_plot(lon,lat,'r.')

 print(1,'-r200','-dpng','ESPRESSO_Domain_Zoom.png')
