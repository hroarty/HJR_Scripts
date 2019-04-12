%% This m script was written to generate trajectory data from the 25 MHz systems 
tic

close all
clear all

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

%% load the total data
radial_type='best';        
conf.Totals.DomainName='PLDP';
%conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/13MHz/' radial_type '/'];
conf.Totals.BaseDir=[root '/codaradm/data/totals/pldp/25MHz/0.5km/oi/nc/'];
conf.Totals.FilePrefix=strcat('OI_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.totals.nc';
conf.Totals.MonthFlag=0;
conf.Totals.Mask='/Users/hroarty/data/mask_files/BPU_2kmMask.txt';

dtime=datenum(2015,1,20,7,0,2):1/24:datenum(2015,1,20,20,0,0);
%dtime=datenum(2015,1,20,20,0,2):-1/24:datenum(2015,1,20,7,0,0);

%% create strings to use in the map filename
timestr_sd=datestr(dtime(1),'yyyymmdd');
timestr_ed=datestr(dtime(end),'yyyymmdd');


% F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
%     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);

[f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);

%% Concatenate the total data
[TUVcat,goodCount]=catTotalStructs_NC(f,'TUV');

%% Mask the data based on the land mask for NY harbor
%% mask any totals outside axes limits
%[TUVcat,I]=maskTotals(TUVcat,conf.Totals.Mask,true); % true keeps vectors in box

%% Grid the total data onto a rectangular grid
[TUVcat,dim]=gridTotals(TUVcat,0,0);

%% generate the drifter release points
addpath /Users/hroarty/Documents/MATLAB/HJR_Scripts/
[wp]=release_point_generation_matrix_PLDP;


X=TUVcat.LonLat(:,1);
Y=TUVcat.LonLat(:,2);
U=TUVcat.U;
V=TUVcat.V;
tt=TUVcat.TimeStamp;
tspan=TUVcat.TimeStamp;
drifter=[wp(:,2) wp(:,1)];


[X1,Y1]=meshgrid(unique(X),unique(Y));

[r,c]=size(X1);

U1=reshape(U,r,c,length(TUVcat.TimeStamp));
V1=reshape(V,r,c,length(TUVcat.TimeStamp));

%% Make the velocities negative for backward drift
% U1=-U1;
% V1=-V1;

%% generate the particle trajectories
[x,y,ts]=particle_track_ode_grid_LonLat(X1,Y1,U1,V1,tt,tspan,drifter);

[r1,c1]=size(x);

%% determine which position estimates are Nans to use in the coloring of the 
%% particles
color_flag=~isnan(x);



%% When the drifter leaves the domain the position turns into nans
%% replace the nans with the last known position
xx=x;
for ii=1:c1
    tf=find(isnan(x(:,ii)),1,'first');
    x(tf:end,ii)=x(tf-1,ii);
    y(tf:end,ii)=y(tf-1,ii);
end

%% plot the results
%% setup the basemap and plot the basemap [lonmin lonmax latmin latmax]
conf.HourPlot.axisLims=[-64.5 -63.833 -65.1 -64.75];
conf.Plot.coastFile='/Users/hroarty/data/coast_files/Antarctica4.mat';
conf.Plot.Projection='mercator';

conf.Plot.BaseDir='/Users/hroarty/COOL/01_CODAR/Antarctica/20150121_Drifters_Reverse/';



for ii=1:r1
hold on
%figure

%% ------------------------------------------------------------------------
%% Plot the base map

%% use the m_map base option
plotBasemap(conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),...
    conf.Plot.coastFile,conf.Plot.Projection,'patch',[240,230,140]./255);

%% use the shapefile
%  m_proj('mercator','longitudes',conf.HourPlot.axisLims(1:2), ...
%        'latitudes',conf.HourPlot.axisLims(3:4));
% 
%  tanLand = [240,230,140]./255;
%  S1 = m_shaperead('/Users/hroarty/data/shape_files/antarctica_shape/cst00_polygon_wgs84');
%  
%  for k=1:length(S1.ncst), 
%   h1=m_line(S1.ncst{k}(:,1),S1.ncst{k}(:,2));
%   m_patch(S1.ncst{k}(:,1),S1.ncst{k}(:,2),tanLand);
%   %set(h1,'Color','k')
% end; 
% 
% m_grid;

% if ii==1
%     m_plot(x(1,:),y(1,:),'.','Color','r');
% end

%% plot entire track in gray
if ii>=2 
    m_plot(x(1:ii,:),y(1:ii,:),'-','Color',[0.5 0.5 0.5]);
end 


%% plot last 6 hours in black 
if ii>6
    m_plot(x(ii-6:ii,:),y(ii-6:ii,:),'-','Color','k','LineWidth',2);
elseif ii>1
    m_plot(x(1:ii,:),y(1:ii,:),'-','Color','k','LineWidth',2);
end

%% plot last location of drifter in red
m_plot(x(ii,:),y(ii,:),'ro','MarkerFaceColor','r');

if ~isempty(find(isnan(xx(ii,:)), 1)) 
    m_plot(x(ii,isnan(xx(ii,:))),y(ii,isnan(xx(ii,:))),'bo','MarkerFaceColor','b');
end 


%% release point
%m_plot(drifter(1),drifter(2),'r*')

%% add zeros before the number string
N=append_zero(ii);

%% -------------------------------------------------
%% plot_bathymetry

bathy=load ('/Users/hroarty/data/bathymetry/antarctica/antarctic_bathy_3.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines1=0:-10:-100;
bathylines2=0:-200:-1400;
bathylines=[ bathylines2];

[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
clabel(cs,h1,'fontsize',8);
set(h1,'LineColor','k')

% [cs2, h2] = m_contour(bathy.loni,bathy.lati, bathy.depthi,[-6 -6]);
% set(h2,'LineColor','r')

%% -------------------------------------------------
%% Plot location of sites

%% read in the Antarctic sites
dir='/Users/hroarty/data/';
file='antarctic_codar_sites.txt';
[C]=read_in_maracoos_sites(dir,file);

sites=[5 6 7];

%% plot the location of the sites
for jj=5:7
    hdls.RadialSites=m_plot(C{3}(jj),C{4}(jj),'^r','markersize',8,'linewidth',2);
    m_text(C{3}(jj),C{4}(jj),C{2}(jj))
end




%%-------------------------------------------------
%% Add title string

conf.HourPlot.TitleString = [radial_type,' Particle Trajectories: ', ...
                            datestr(TUVcat.TimeStamp(ii),'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone(1:3)];

hdls.title = title( conf.HourPlot.TitleString, 'fontsize', 14,'color',[0 0 0] );

timestamp(1,'trajectories_from_PLDP.m')

print(1,'-dpng','-r100',[ conf.Plot.BaseDir conf.Totals.DomainName '_'  N '.png'])

close all
clear conf.HourPlot.TitleString
end

toc






