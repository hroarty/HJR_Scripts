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

%% load the total data
        
conf.Totals.DomainName='MARASR';
conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/25MHz/'];
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag=1;
conf.Totals.Mask='/Users/hroarty/data/mask_files/25MHz_Mask.txt';

dtime=datenum(2016,5,30,0,0,2):1/24:datenum(2016,6,1,00,0,0);

%% create strings to use in the map filename
timestr_sd=datestr(dtime(1),'yyyymmdd');
timestr_ed=datestr(dtime(end),'yyyymmdd');


% F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
%     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);

[f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);

%% Concatenate the total data
[TUVcat,goodCount]=catTotalStructs(f,'TUV',0,0,0,0);

%% Mask the data based on the land mask for NY harbor
%% mask any totals outside axes limits
[TUVcat,I]=maskTotals(TUVcat,conf.Totals.Mask,true); % true keeps vectors in box

%% Grid the total data onto a rectangular grid
[TUVcat,dim]=gridTotals(TUVcat,0,0);

%% generate the drifter release points
% [wp]=release_point_generation_matrix_NYH;

wp(1,:)=[40+26/60 -74-3/60];

X=TUVcat.LonLat(:,1);
Y=TUVcat.LonLat(:,2);
U=TUVcat.U;
V=TUVcat.V;
tt=TUVcat.TimeStamp;
tspan=TUVcat.TimeStamp(1):1/24:TUVcat.TimeStamp(24);
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
conf.HourPlot.axisLims=[-74-20/60 -73-50/60 40+20/60 40+40/60];
conf.Plot.coastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.Plot.Projection='mercator';

conf.Plot.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20150506_NYH_Analysis/20160701_Ravit/';



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

conf.HourPlot.TitleString = [conf.Totals.DomainName,' Particle Trajectories: ', ...
                            datestr(tspan(ii),'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone(1:3)];

hdls.title = title( conf.HourPlot.TitleString, 'fontsize', 16,'color',[0 0 0] );

print(1,'-dpng','-r100',[ conf.Plot.BaseDir conf.Totals.DomainName '_'  N '.png'])


% if ii==1
%     f=getframe;
%     [im,map]=rgb2ind(f.cdata,256,'nodither');
% else
%     f=getframe;
%     im(:,:,1,ii)=rgb2ind(f.cdata,256,'nodither');
% end
% 
% close all
% clear conf.HourPlot.TitleString
 end
% 
% imwrite(im,map,'MARASR__24h_Animation.gif','DelayTime',.5,'LoopCount',inf)




% timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_25.m')
% 
% 


