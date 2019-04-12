lims=[-74-20/60 -73-50/60 40+20/60 40+40/60]; % zoom out all of NJ
coastFileName = '/Users/roarty/Documents/GitHub/HJR_Scripts/data/coast_files/MARA_coast.mat';

hold on
%figure
% plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch',[240,230,140]./255);



f='/Users/roarty/data/bathymetry/raritan_bay_m060r_30m.nc';

x=ncread(f,'x');
y=ncread(f,'y');



[X,Y]=meshgrid(x,y);

LON=X;
LAT=Y;

[r,c]=size(X);

utmzone=repmat(18,r,c);
% 
% % [LAT,LON] = utm2deg(X,Y,utmzone);
[LAT,LON]=utm2ll(X,Y,utmzone);
% 
% % lon=lon';
% % lat=lat';
% 
% % [LON,LAT]=meshgrid(lon,lat);
% % 
LON=LON';
LAT=LAT';

z=ncread(f,'Band1');

axesm utm
% axesm('utm','MapLatLimit',lims(3:4),'MapLonLimit',lims(1:2))
setm(gca,'zone','18t')
setm(gca,'MapLatLimit',lims(3:4),'MapLonLimit',lims(1:2))
setm(gca,'Frame','on','Grid','on')
gridm('mlinelocation',0.1,'plinelocation',0.1,'mlabellocation',0.1,'plabellocation',0.1)
setm(gca,'grid','on','meridianlabel','on','parallellabel','on')

pcolor(LON,LAT,z)

colormap(jet(16))
caxis([-30 0])
cax=colorbar;


shading flat

box on
grid on

%% Add title and timestamp to the figure
title({'NOAA 30 m Bathymetry'},'FontWeight','bold','FontSize',14)

conf.Plot.Filenname='Raritan_Bay_NOAA_DEM.png';
conf.Plot.script='plot_NOAA_Raritan_Bay.m';
conf.Plot.print_path='/Users/roarty/COOL/TWL/';


timestamp(1,[conf.Plot.Filenname ' / ' conf.Plot.script])

% set(gca, 'LooseInset', get(gca, 'TightInset'))

%% print the figure
print(1,'-dpng','-r400',[conf.Plot.print_path conf.Plot.Filenname])