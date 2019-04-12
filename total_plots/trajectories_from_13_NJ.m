%% This m script was written to generate trajectory data from the 25 MHz systems 

close all
clear all

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

%% EDIT THIS PART %%

time_average=24;%% hours of half the time averaging interval
time_average_matlab=time_average/24;
time_average_str=num2str(2*time_average);

%% load the total data
radial_type='best';        
conf.Totals.DomainName='BPU';
% conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/13MHz/' radial_type '/'];
conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/13MHz/'];
% conf.Totals.BaseDir= ['/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20160630_Eddy_Animation/' time_average_str '_hr_mean/'];

conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
% conf.Totals.FilePrefix=strcat('tuv_oi_',time_average_str,'hr_mean_');

conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag=1;
conf.Totals.Mask='/Users/hroarty/data/mask_files/BPU_2kmMask.txt';

% dtime=datenum(2016,4,23,0,0,2):1/24:datenum(2016,4,24,0,0,0);
% dtime=datenum(2016,12,3,8,0,2):1/24:datenum(2016,12,5,8,0,0);
dtime=datenum(2017,8,5,18,0,2):1/24:datenum(2017,8,9,12,0,0);

%% the axisLims is not used because the limits are set by the drifter points
%conf.HourPlot.axisLims=[-74-30/60 -73-30/60 39+30/60 40+30/60];
conf.Plot.coastFile='/Users/hroarty/data/coast_files/BPU_coast.mat';
conf.Plot.Projection='mercator';
% conf.Plot.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20141014_13_Drifters/';
% conf.Plot.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160425_13_Eddy/';
% conf.Plot.BaseDir=['/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20160630_Eddy_Animation/trajectory' time_average_str '/'];
% conf.Plot.BaseDir=['/Users/hroarty/Consulting/Monmouth_County_Prosecutors/Drift/'];
conf.Plot.BaseDir=['//Users/hroarty/COOL/01_CODAR/MARACOOS_II/20170809_KiteSurfer/'];

%% END OF EDIT %%

%% create strings to use in the map filename
timestr_sd=datestr(dtime(1),'yyyymmdd');
timestr_ed=datestr(dtime(end),'yyyymmdd');


% F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
%     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);

[f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,...
    conf.Totals.FileSuffix,conf.Totals.MonthFlag,0);

%% Concatenate the total data
[TUVcat,goodCount]=catTotalStructs(f,'TUV',0,0,0,conf);

%% Mask the data based on the land mask for NY harbor
%% mask any totals outside axes limits
%[TUVcat,I]=maskTotals(TUVcat,conf.Totals.Mask,true); % true keeps vectors in box

%% Grid the total data onto a rectangular grid
[TUVcat,dim]=gridTotals(TUVcat,0,0);

%% generate the drifter release points
addpath /Users/hroarty/Documents/MATLAB/HJR_Scripts/

% wpi(1,:)=[39+45/60 -73-50/60];
% [wp]=release_point_generation_NJ13(wpi);

%% generate the drifter release points
%% wp1 latitude longitude 
%% wp1 is the south east point in the matrix
%wp1=[40.5 -70];
%wp1=[39.5 -73];
wp1=[40+20/60+0/3600 -73-55/60-00/3600];
%wp1=[35.25 -75];
resolution=2;
range=10;

[wp]=release_point_generation_matrix(wp1,resolution,range);
% wp=wp1;

%% define the axis limits based on the drifter points
offset=60/60; % add 15 minutes to the edge of the drifter points
conf.HourPlot.axisLims=[min(wp(:,2))-offset max(wp(:,2))+offset ...
    min(wp(:,1))-offset max(wp(:,1))+offset];

X=TUVcat.LonLat(:,1);
Y=TUVcat.LonLat(:,2);
U=TUVcat.U;
V=TUVcat.V;
tt=TUVcat.TimeStamp;
tspan=TUVcat.TimeStamp(1):1/24:TUVcat.TimeStamp(end);
drifter=[wp(:,2) wp(:,1)];


[X1,Y1]=meshgrid(unique(X),unique(Y));

[r,c]=size(X1);

U1=reshape(U,r,c,length(TUVcat.TimeStamp));
V1=reshape(V,r,c,length(TUVcat.TimeStamp));

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
%% setup the basemap and plot the basemap




for ii=1:r1
hold on
%figure
plotBasemap(conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),...
    conf.Plot.coastFile,conf.Plot.Projection,'patch',[240,230,140]./255);

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
    m_plot(x(ii,find(isnan(xx(ii,:)))),y(ii,find(isnan(xx(ii,:)))),'bo','MarkerFaceColor','b');
end 


%% release point
%m_plot(drifter(1),drifter(2),'r*')

%% add zeros before the number string
N=append_zero(ii);


%%-------------------------------------------------
%% Add title string

conf.HourPlot.TitleString = [radial_type,' Particle Trajectories: ', ...
                            datestr(tspan(ii),'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone(1:3)];

hdls.title = title( conf.HourPlot.TitleString, 'fontsize', 14,'color',[0 0 0] );

timestamp(1,'trajectories_from_13_PR.m')

print(1,'-dpng','-r100',[ conf.Plot.BaseDir conf.Totals.DomainName '_'  N '.png'])

close all
clear conf.HourPlot.TitleString
end









