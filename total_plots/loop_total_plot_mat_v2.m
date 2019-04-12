tic

 clear all; close all; 

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add 2 seconds to handle rounding

start_time = datenum(2018,1,4,0,0,0);
end_time=datenum(2018,1,5,0,0,0);
dtime = start_time:1/24:end_time;


%% config info for the plot
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.Type=conf.HourPlot.Type;
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.Print=false;
conf.HourPlot.coastlinefile='/Users/hroarty/data/coast_files/MARA_coast.mat';

%% 5 MHz configs
%conf.OI.BaseDir='/Users/hroarty/data/realtime/totals/maracoos/oi/mat/5MHz/';
conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/ideal/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/measured/';
conf.HourPlot.DomainName='MARA';
% conf.HourPlot.axisLims=[-76 -72-00/60 37+00/60 41+00/60];% NJ and Delaware
% conf.HourPlot.axisLims=[-77 -68-00/60 34+00/60 44+00/60];%% MAB
conf.HourPlot.axisLims=[-77 -73 33.5 37];% VA NC

%% 13 MHz configs
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/';
% %conf.OI.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20150210_QAQC/20150811_RealTime_QC/Totals_With_QC/';
% conf.HourPlot.DomainName='BPU';
% conf.HourPlot.axisLims=[-74-20/60 -73-15/60 39+40/60 40+20/60];
% % conf.HourPlot.axisLims=[-74-10/60 -72-30/60 39+45/60 40+50/60];

%% 13 MHz special configs
% conf.OI.BaseDir='/Volumes/hroarty/codar/Seroka_Greg/totals/totals/maracoos/oi/mat/13MHz/';
% %conf.OI.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20150210_QAQC/20150811_RealTime_QC/Totals_With_QC/';
% conf.HourPlot.DomainName='BPU';
% %conf.HourPlot.axisLims=[-75-00/60 -73-00/60 39+10/60 40+40/60];
% conf.HourPlot.axisLims=[-75-00/60 -73-00/60 38+30/60 40+00/60];

conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=1;
conf.OI.HourFlag=0;

conf.HourPlot.DistanceBarLength = 50;
conf.HourPlot.DistanceBarLocation = [conf.HourPlot.axisLims(2)-15/60 conf.HourPlot.axisLims(4)-15/60];
conf.HourPlot.ColorTicks = [0:10:40];
conf.HourPlot.ColorMapBins=64;
conf.HourPlot.ColorMap='parula';
conf.HourPlot.Print=1;
conf.MonthFlag=0;

conf.HourPlot.grid_spacing=1;


p.HourPlot.Type='OI';
s = p.HourPlot.Type;

%% load the total data depending on the config
s=conf.HourPlot.Type;
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag,conf.(s).HourFlag);

conf.datatype='TUV';


[TUVcat,goodCount] = catTotalStructs(f,conf.datatype,0,0,0);



%[tidestruct,Ttide,Tnotide]=t_tide_totals(TUVcat,0.5);

sd_str=datestr(dtime(1),'yyyymmdd');
ed_str=datestr(dtime(end),'yyyymmdd');

%savefile = ['BPU_Total_CAT_' sd_str '_' ed_str '.mat'];
%save(savefile, 'TUVcat','tidestruct','Ttide','Tnotide')
%save(savefile, 'TUVcat')

%% load the data
%load BPU_Total_CAT_20120801_20121001

%% Subsample the data
% Find the unique values for the lat and lon grid
unique_x=unique(TUVcat.LonLat(:,1));
unique_y=unique(TUVcat.LonLat(:,2));

x_ind=1:conf.HourPlot.grid_spacing:length(unique_x);
y_ind=1:conf.HourPlot.grid_spacing:length(unique_y);

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
TUVcat=subsrefTUV(TUVcat,marcoos_grid_ind);


%% remove the vectors outside the plot region
in=inpolygon(TUVcat.LonLat(:,1),TUVcat.LonLat(:,2),conf.HourPlot.axisLims([1 2 2 1 1]),conf.HourPlot.axisLims([3 3 4 4 3]));
TUVcat.U(~in,:)=NaN;
TUVcat.V(~in,:)=NaN;


%% find the indices of the no tide data that match the selected time period
ind=find(TUVcat.TimeStamp==dtime(1));
ind2=find(TUVcat.TimeStamp==dtime(end));

%% read in the hurricane track
dir2='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20160906_Hermine_Prep/';
file2='HERMINE_2016_Atlantic_Basin.csv';

[D]=read_in_hurricane_track_hermine(dir2,file2);

%% interpolate hurricane position data onto the time axis
hermine.lat = interp1(D{7},D{2},dtime);


%% loop to plot the data

% for ii = ind:1:ind2
for ii = 1:length(dtime)   

%% Plot the base map for the radial file
plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.coastlinefile,'Mercator','patch',[240,230,140]./255,'edgecolor','k')

hold on

%% Plot Bathymetry
%bathy=load ('/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat');
bathy=load ('/Users/hroarty/data/bathymetry/eastcoast.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines=[ -10 -30 -50 -80 -200];

[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
clabel(cs,h1,'fontsize',8);
set(h1,'LineColor','k')


                           
[hdls.plotData,I] = plotData2( TUVcat, 'm_vec_same', TUVcat.TimeStamp(ii), conf.HourPlot.VectorScale);
                             % p.HourPlot.plotData_xargs{:} );


%-------------------------------------------------
% Plot the colorbar
try
  conf.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
  conf.HourPlot.ColorTicks = 0:10:ss+10;
end
caxis( [ min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks) ] );
colormap( feval( conf.HourPlot.ColorMap, numel(conf.HourPlot.ColorTicks)-1 ) )
%colormap( feval( conf.HourPlot.ColorMap, conf.HourPlot.ColorMapBins))
%colormap(jet(10))

cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 8 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 12 );

set(cax,'ytick',conf.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

h1=title([conf.datatype '  ' datestr(TUVcat.TimeStamp(ii),21)]);

%%-------------------------------------------------
%% Plot location of sites
try
sl = vertcat( data.RTUV.SiteOrigin );

% Only plot the ones that are inside the plot limits.
plotRect = [ p.HourPlot.axisLims([1,3]);
         p.HourPlot.axisLims([2,3]);
         p.HourPlot.axisLims([2,4]);
         p.HourPlot.axisLims([1,4]);
         p.HourPlot.axisLims([1,3]) ];
ins = inpolygon(sl(:,1),sl(:,2),plotRect(:,1),plotRect(:,2));
hdls.RadialSites = m_plot( sl(ins,1), sl(ins,2), ...
                         '^k','markersize',8,'linewidth',2);
catch
end


timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/loop_total_plot_mat_v2.m')




%% create the output directory and filename
%output_directory = '/Users/hroarty/COOL/STUDENT_ITEMS/Robert_Forney_2013/Paper/20150116_Maps_Raw/';
%output_directory = '/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20150610_Smooth_Fields/OSN/';
%output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS/20150210_QAQC/20150811_RealTime_QC/Total_Maps_With_QC/';
%output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131217_Sandy_Award/29150909_SEAB_Inspection/Hourlies/';
%output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160108_Shelf_Break_Front/hourlies/';
% output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160309_Greg_LCS/';
% output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20160906_Hermine_Prep/20160912_MAB_Maps/Best/';
% output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161020_QC_Check/NC/';
% output_directory ='/Users/hroarty/COOL/01_CODAR/ASBPA/13_Totals/';
output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180104_Winter_Storm_Grayson';
output_filename = ['Tot_' conf.HourPlot.DomainName '_' conf.datatype '_' datestr(TUVcat.TimeStamp(ii),'yyyymmddTHHMM') '.png'];

%% print the image
print(1, '-dpng', [output_directory output_filename]);

 %clear data
 close all
end


toc
