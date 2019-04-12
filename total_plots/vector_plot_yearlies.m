tic

clear all; close all; 

%% This m script was written to read in the yearly netcdf files that Mike 
%% Smith created at
%% /home/michaesm/codar/codar_means/yearly_means

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%% specific period
% start_time = datenum(2012,1,1,00,0,2);
% end_time=datenum(2012,1,1,23,0,2);
% dtime = start_time:1/24:end_time;
% time_str=datestr(dtime,'yyyy_mm_dd_HHMM');

%% now minus 24 hours
% end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add some slop to handle rounding
% start_time = end_time - 24/24;
% dtime = [start_time:1/24:end_time]; 

%regions={'region01';'region02';'region03';'region04';'region05'};
regions={'regionALL'};

conf.HourPlot.VectorScale = .02;
conf.HourPlot.grid=3;
coastFileName = '/Users/hroarty/data/coast_files/MARA_coast.mat';

%% load the political boundaries file
boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');


%years.num=2007:2013;
years.num=2007;

for ii=1:length(years.num)
    
%% -----------------------------------------------------------
%% the location of the total data
% input_file = ['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_'...
%     num2str(years.num(ii)) 'yearcomposite_' num2str(years.num(ii)) '_01_01_0000.nc']; 

input_file = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_7yearcomposite_2007_01_01_0000.nc'; 

%% get the time from the file
 dtime = ncread(input_file,'time');


%% extract the lat and lon from the nc file
lat = ncread(input_file,'lat');
lon = ncread(input_file,'lon');

%% read the coverage at each grid point
coverage = ncread(input_file,'perCov');

%% replace the fill values of -999 with NaN
logInd=coverage==-999;
coverage(logInd)=NaN;
coverage=coverage';

% %% read the divergence at each grid point
% div=ncread(input_file,'div');
% 
% %% replace the fill values of -999 with NaN
% logInd2=div==-999;
% div(logInd2)=NaN;
% div=div';

[lon,lat,u,v,div,vor]=divergence('netcdf','ncfile',input_file,'adddivergence',false,'addvorticity',false,'maxerror',nan); 
div=div';

%% create a new variable with lon lat and coverage
[LON LAT]=meshgrid(lon,lat);


%% load the current data
[TUV]=convert_NC_to_TUVstruct(input_file,false );

%% land mask the data
conf.Totals.Mask='/Users/hroarty/data/mask_files/MARACOOS_6kmMask.txt';
[TUV,I]=maskTotals(TUV,conf.Totals.Mask,false); % false removes vectors on land

%[TUV,I]=maskTotals(TUV,mask2,true); % true keeps vectors in box

for jj=1:length(regions)
    
    region=regions{jj};

switch region
    case 'regionALL'
    lims=[-77 -68 34 43];%ALL MAB
    case 'region01'
    lims=[-71 -68 40 43];% North
    case 'region02'
    lims=[-72 -69 39 41.5];% RI
    case 'region03'
    lims=[-75 -72 39 41];% NJ
    case 'region04'
    lims=[-76 -72 37 39];% MD
    case 'region05'
    lims=[-76 -73 35 37];% VA NC
end
    


mask2=[lims([1 2 2 1 1]);lims([3 3 4 4 3])];
mask2=mask2';



%figure



%% plot the location of the sites within the bounding box
%hdls.RadialSites=m_plot(sites{1}(in),sites{2}(in),'^r','markersize',8,'linewidth',2);

%% Subsample the data
% Find the unique values for the lat and lon grid
unique_x=unique(TUV.LonLat(:,1));
unique_y=unique(TUV.LonLat(:,2));

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
    ind=find(NX(i)==TUV.LonLat(:,1) &NY(i)==TUV.LonLat(:,2));
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
TUV=subsrefTUV(TUV,marcoos_grid_ind);




%% plot_bathymetry
%bathy=load ('/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat');
bathy=load ('/Users/hroarty/data/bathymetry/eastcoast_4min.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines=[ -50 -100 -1000 -5000];

hold on
m_proj('mercator','long',lims(1:2),'lat',lims(3:4));

dtime2=dtime+datenum(2001,01,01);

%colormap_blue_red_hjr
%M=load('/Users/hroarty/Documents/MATLAB/color_maps/redblue.mat');
%M=flipud(M);
%colormap(M.redblue);
%caxis([0 20])

%% Add a colorbar
colorticks=0:3:15;
caxis([0 15])
colormap(feval(@jet,numel(colorticks)-1))


cax = colorbar;
set(cax,'ylim',[0 colorticks(end)],'ytick',colorticks,'fontsize',14,'fontweight','bold')

%% Plot the basemap
%plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch',[240,230,140]./255);

%% call plotData2 after plotbasemap because the vectors will be messed up if called before
%[hdls.plotData,I] = plotData2( TUV, 'm_quiver', dtime2, conf.HourPlot.VectorScale);
%[hdls.plotData,I] = plotData2( TUV, 'm_vec_same', dtime2, conf.HourPlot.VectorScale);
%[hdls.plotData,I] = plotData( TUV, 'grid');

% %% plot the political boundaries
% hdls.boundaries=m_plot(boundaries(:,1),boundaries(:,2),'-k','linewidth',1);
% %% Plot the bathymetry
% [cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
% clabel(cs,h1,'fontsize',8);
% set(h1,'LineColor','k')
% 
%  title({'MARACOOS HF Radar Vector Map from';datestr(dtime+datenum(2001,01,01),'yyyy') },'FontWeight','bold','FontSize',14)
% %% create the output directory and filename
% output_directory = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150505_HJR_Figures_Yearly/';
% output_filename = ['MARACOOS_Vectors_' region '_' datestr(dtime+datenum(2001,01,01),'yyyy') '.png'];
% 
% %% print the image
% print(1, '-dpng', '-r200', [output_directory output_filename]);


 curly_vector_plot_fn(TUV,conf);



timestamp(1,'/HJR_Scripts/total_plots/vector_plot_yearlies.m')



close all;
% clear input_file

end

end


%clear all;

toc
