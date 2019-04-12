tic

clear all
close all

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

%% Puerto Rico Configuration
% conf.HourPlot.Type='UWLS';
% 
% conf.HourPlot.VectorScale=0.004;
% conf.HourPlot.ColorMap='jet';
% conf.HourPlot.ColorTicks=0:10:50;
% conf.HourPlot.axisLims=[-69 -65 16+00/60 18+40/60];
% conf.Totals.grid_lims=[-69 -65 16+00/60 18+40/60];
% radial_type='measured';
% 
% conf.HourPlot.DomainName='Puerto Rico';
% conf.HourPlot.Print=false;
% conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/PR_coast3.mat';
% conf.HourPlot.bathy='/Users/hroarty/data/bathymetry/puerto_rico/puerto_rico_6second_grid.mat';
% 
% conf.UWLS.BaseDir=[root '/codaradm/data/totals/caracoos/oi/mat/13MHz/measured/'];
% conf.UWLS.FilePrefix='tuv_CARA_';
% conf.UWLS.FileSuffix='.mat';
% conf.UWLS.MonthFlag=true;
% 
% conf.OI.BaseDir=[root '/codaradm/data/totals/caracoos/oi/mat/13MHz/' radial_type '/'];
% conf.OI.FilePrefix='tuv_OI_CARA_';
% conf.OI.FileSuffix='.mat';
% conf.OI.MonthFlag=true;
% 
% conf.NC.BaseDir='http://hfrnet.ucsd.edu/thredds/dodsC/HFR/PRVI/6km/hourly/RTV/HFRADAR,_Puerto_Rico_and_the_US_Virgin_Islands,_6km_Resolution,_Hourly_RTV_best.ncd';
% % conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151202_YR5.0_Progress/PR_Plots/';
% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20160614_Progress_Report/PR_Plots_South/';

%% Mid Atlantic 5 MHz Configuration
% conf.NC.BaseDir='http://hfrnet.ucsd.edu/thredds/dodsC/HFR/USEGC/6km/hourly/RTV/HFRADAR,_US_East_and_Gulf_Coast,_6km_Resolution,_Hourly_RTV_best.ncd';
conf.NC.BaseDir='http://tds.marine.rutgers.edu:8080/thredds/dodsC/cool/codar/totals/5Mhz_6km_realtime_fmrc/Maracoos_5MHz_6km_Totals-FMRC_best.ncd';

conf.HourPlot.Type='OI';

conf.Save.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20160929_Monthly_Means/';
conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20160929_Monthly_Means/';
conf.HourPlot.DomainName='MARACOOS';
conf.HourPlot.axisLims=[-77 -67 33+00/60 44+00/60];
conf.Totals.grid_lims=[-77 -67 33+00/60 44+00/60];
conf.HourPlot.bathy='/Users/hroarty/data/bathymetry/eastcoast.mat';

conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.ColorTicks=0:10:50;
radial_type='measured';

conf.HourPlot.grid=3;

conf.HourPlot.Print=false;
conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';



%% configuration for plotting and saving if statements
conf.Flag.Plot=1;
conf.Flag.Mean=1;

%% configuration data for the metadata in the file
conf.Plot.script_path='/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/';
conf.Plot.script_name='mean_total_file_generation.m';
conf.Data.Institution='Rutgers University';
conf.Data.Contact='Hugh Roarty hroarty@marine.rutgers.edu';
conf.Data.Info='This data file is monthly mean of HF radar surface currents';

%dtime = datenum(2014,5,1,0,0,2):1/24:datenum(2014,05,2,0,0,0);

%months=[datenum(2015,1,1) datenum(2016 ,1:6 ,1)];
% months=[datenum(2015,1:12,1) datenum(2016 ,1 ,1)];
 months=datenum(2015,1:3,1);

for ii=1:numel(months)-1

%% Declare the time that you want to load
dtime = months(ii):1/24:months(ii+1);



%% load the total data depending on the config
 s=conf.HourPlot.Type;
% [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);
f=conf.NC.BaseDir;

%% concatenate the total data

[TUVcat] = convert_MARACOOS_NC_to_TUVstruct(f,dtime,conf);
X=sprintf('Finished loading data for %s',datestr(months(ii),'mmm dd, yyyy'));
disp(X)

%% calculate the percent coverage at each grid point
coverage = 100 * sum( isfinite(TUVcat.U+TUVcat.V), 2 ) / size(TUVcat.U,2);

%% find the grid points less that 50% coverage
ind=find(coverage<50);

%% set the velocity in the grid points below 50% coverage to Nans
TUVcat.U(ind,:)=NaN;
TUVcat.V(ind,:)=NaN;

%% average the vectors
TUVavg = nanmeanTotals(TUVcat);


%% if statement to decide if you want to plot the mean

if conf.Flag.Plot

%% Plot the base map for the radial file
plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.CoastFile,'Mercator','patch',[240,230,140]./255,'edgecolor','k')

hold on

%% Subsample the data
% Find the unique values for the lat and lon grid
unique_x=unique(TUVavg.LonLat(:,1));
unique_y=unique(TUVavg.LonLat(:,2));

x_ind=1:conf.HourPlot.grid:length(unique_x);
y_ind=1:conf.HourPlot.grid:length(unique_y);

[NX,NY]=meshgrid(unique_x(x_ind),unique_y(y_ind));

% Vectorize the array
NX=NX(:);
NY=NY(:);

% define the varaible before you write to it
marcoos_grid_ind=[];

% find the indices of the grid points you want to keep
for i=1:length(NX)
    ind=find(NX(i)==TUVcat.LonLat(:,1) &NY(i)==TUVcat.LonLat(:,2));
    if ~isempty(ind)
        marcoos_grid_ind(i)=ind;
    end
end

% remove the zeros from the indices array
marcoos_grid_ind(marcoos_grid_ind==0)=[];

% % create a row vector of the Index of spatial grid points to be kept
% SpatialI=1:1:length(data.TUV.U);
% SpatialI=30:1:50;
% 
% % transpose the row vector into a column vector
% SpatialI=SpatialI';

%% Use the subsrefTUV function to only plot certain grid points
TUVsub=subsrefTUV(TUVcat,marcoos_grid_ind);

[hdls.plotData,I] = plotData2( TUVsub, 'm_vec_same', TUVsub.TimeStamp, conf.HourPlot.VectorScale);

%% plot_bathymetry
bathy=load(conf.HourPlot.bathy);
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines=[ -50 -80 -200];

[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
clabel(cs,h1,'fontsize',8);
set(h1,'LineColor','k')


% %%-------------------------------------------------
% %% Plot location of sites
% try
% %% read in the MARACOOS sites
% dir='/Users/hroarty/data/';
% file='maracoos_codar_sites.txt';
% [C]=read_in_maracoos_sites(dir,file);
% 
% %% plot the location of the radar sites
% 
% for ii=48:49
%     hdls.RadialSites=m_plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
% end
% 
% catch
% end

%-------------------------------------------------
% Plot the colorbar
try
  conf.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
  conf.HourPlot.ColorTicks = 0:10:ss+10;
end
caxis( [ min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks) ] );
%colormap( feval( p.HourPlot.ColorMap, numel(p.HourPlot.ColorTicks)-1 ) );

%colormap(winter(10));

% load ('/home/hroarty/Matlab/cm_jet_32.mat')


cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 8 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 12 );

set(cax,'ytick',conf.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

%-------------------------------------------------
% % Add title string
% try, p.HourPlot.TitleString;
% catch
%   p.HourPlot.TitleString = [p.HourPlot.DomainName,' ',p.HourPlot.Type,': ', ...
%                             datestr(dtime,'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone(1:3)];
% end
% hdls.title = title( p.HourPlot.TitleString, 'fontsize', 16,'color',[.2 .3 .9] );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add title string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
titleStr = {sprintf('%s %s Average, %d possible hourly maps', ...
                    conf.HourPlot.DomainName,conf.HourPlot.Type,length(TUVcat.TimeStamp)),
            sprintf('From %s to %s',datestr(dtime(1),'dd-mmm-yyyy HH:MM'),datestr(dtime(end),'dd-mmm-yyyy HH:MM'))};
hdls.title = title(titleStr, 'fontsize', 20 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add path of script to image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_vector_plot_PR_NN.m')

sd_str=datestr(min(dtime),'yyyymmdd');
ed_str=datestr(max(dtime),'yyyymmdd');

print(1,'-dpng','-r400',[conf.Plot.PrintPath 'Total_Average_' conf.HourPlot.Type '_' ...
    conf.HourPlot.DomainName '_' sd_str '_' ed_str '.png'])

close all

end


if conf.Flag.Mean
    
        TUVavg.MetaData.Script=conf.Plot.script_name;
        TUVavg.MetaData.Institution=conf.Data.Institution;
        TUVavg.MetaData.Contact=conf.Data.Contact;
        TUVavg.MetaData.Information=conf.Data.Info;
        TUVavg.MetaData.DataSource=conf.NC.BaseDir;
        
        %% save the mean data in a mat file
        save([conf.Save.directory conf.HourPlot.DomainName '_HFR_Monthly_Mean_' datestr(dtime(1),'yyyymmdd') '.mat'], '-struct', 'TUVavg');

end

end

toc




