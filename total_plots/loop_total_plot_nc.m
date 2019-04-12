tic

clear all; close all; 

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add 2 seconds to handle rounding
end_time=datenum(2012,9,13,00,0,0);
start_time = datenum(2012,9,12,00,0,0);
dtime = start_time:1/24:end_time;

time_str=datestr(dtime,'yyyymmddTHHMMSS');

%% -----------------------------------------------------------
%% the location of the total data
input_dir = '/Volumes/arctic_home/palamara/BPU/CODAR13/'; 

%% loop to get all the file names

files=cell(length(dtime),1);

for ii = 1:length (dtime)
files{ii,1} =[input_dir, 'BPU_CODAR_' time_str(ii,:) '.nc']; 
end

%% config info for the plot
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.Type=conf.HourPlot.Type;
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';

conf.HourPlot.axisLims=[-75 -73-40/60 38+40/60 39+40/60];
conf.HourPlot.DomainName='BPU';
conf.HourPlot.Print=false;
conf.HourPlot.coatlinefile='/Users/hroarty/data/coast_files/BPU_coast.mat';


conf.HourPlot.DistanceBarLength = 50;
conf.HourPlot.DistanceBarLocation = [-73 41.5];
conf.HourPlot.ColorTicks = [0:5:50];
conf.HourPlot.ColorMapBins=64;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.Print=1;
conf.MonthFlag=0;

conf.HourPlot.grid_spacing=1;
space=1;

%% loop to grab info on the total files
for ii = 1:length(files) ; % length(files):-1:length(files)-24 %length(files)-24:length(files)
    try 
        fprintf('Loading Total file: %s\n',files{ii})
        t = nc_varget(files{ii},'time')+datenum(2001,1,1);
        lat = nc_varget(files{ii},'lat');
        lon = nc_varget(files{ii},'lon');%lon=double(lon);
        
        [lon_g,lat_g]=meshgrid(lon,lat);

        u = nc_varget(files{ii},'u_detided');%u = double(u);
        v = nc_varget(files{ii},'v_detided');%v = double(v);
        
        ind_u=find(u==-999);
        u(ind_u)=NaN;
        
        ind_v=find(v==-999);
        v(ind_v)=NaN;
        
        %% subsample the data by taking only every second data point
        [r,c]=size(u);
        u_new=u(1:space:r,1:space:c);
        v_new=v(1:space:r,1:space:c);
        
        lon_n=lon_g(1:space:r,1:space:c);
        lat_n=lat_g(1:space:r,1:space:c);
        
        [r2,c2]=size(u_new);
        
        T=TUVstruct([r2*c2,1],1);
        
        T.U=u_new(:);
        T.V=v_new(:);
        T.TimeStamp=t;
        T.LonLat(:,1)=lon_n(:);
        T.LonLat(:,2)=lat_n(:);
        
        
        
%         u=u(:);
%         v=v(:);
        rad = nc_varget(files{ii},'num_radials');
        
        % u_err = nc_varget(files(i).name,'u_err');u_err = double(u_err);
        % v_err = nc_varget(files(i).name,'v_err');v_err = double(v_err);
        % id(i).id = files(i).name;
 
        
   
        
    catch
        fprintf('Total file not present %s\n',files{ii})
       
    end



%MARC_driver_plot_totals_HJR(datenum(2012,9,2,23,0,0),conf);


%% Plot the base map for the radial file
plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.coatlinefile,'Mercator','patch',[.5 .9 .5],'edgecolor','k')

hold on

% scale=0.001;
% 
% mm=cart2magn(u,v);
% m_vec(1,lon_n,lat_n,u_new*scale,v_new*scale,'k');


%-------------------------------------------------
% % Plot the data
% hdls = [];
% 
% % Find the unique values for the lat and lon grid
% unique_x=unique(T.LonLat(:,1));
% unique_y=unique(T.LonLat(:,2));
% 
% % The indices for the rows and columns to keep
% % x_ind=[1;10;19;27;36;44;53;61;70;78;87;96;105;113;122;130;138];
% % y_ind=[1;10;20;29;38;47;57;66;76;85;94;103;113;121;130];
% 
% grid_spacing=3;
% x_ind=[1:grid_spacing:length(unique_x)];
% y_ind=[1:grid_spacing:length(unique_y)];
% 
% [NX,NY]=meshgrid(unique_x(x_ind),unique_y(y_ind));
% 
% % Vectorize the array
% NX=NX(:);
% NY=NY(:);
% 
% % define the varaible before you write to it
% marcoos_grid_ind=[];
% 
% % find the indices of the grid points you want to keep
% for i=1:length(NX)
%     ind=find(NX(i)==T.LonLat(:,1) &NY(i)==T.LonLat(:,2));
%     if ~isempty(ind)
%         marcoos_grid_ind(i)=ind;
%     end
% end
% 
% % remove the zeros from the indices array
% marcoos_grid_ind(marcoos_grid_ind==0)=[];
% 
% % % create a row vector of the Index of spatial grid points to be kept
% % SpatialI=1:1:length(data.TUV.U);
% % SpatialI=30:1:50;
% % 
% % % transpose the row vector into a column vector
% % SpatialI=SpatialI';
% 
% %% Use the subsrefTUV function to only plot certain grid points
% Tnew=subsrefTUV(T,marcoos_grid_ind);
% 
% % [hdls.plotData] = plotData( data.TUV, 'm_vec',dtime, p.HourPlot.VectorScale, ...
% %                               p.HourPlot.plotData_xargs{:});

                              
%[hdls.plotData,I] = plotData(T, 'm_vec', T.TimeStamp, conf.HourPlot.VectorScale);
                           
[hdls.plotData,I] = plotData2( T, 'm_vec_same', T.TimeStamp, conf.HourPlot.VectorScale);
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

h1=title(datestr(t,21));

%% create the output directory and filename
%output_directory = '/Users/hroarty/COOL/01_CODAR/BPU/20120813_SeaBreeze/Detided/';
output_directory = '/Users/hroarty/COOL/01_CODAR/BPU/20120912_SeaBreeze/DetidedZoom/';
%output_directory = '/Users/hroarty/COOL/01_CODAR/BPU/20120813_SeaBreeze_Event/Detided/';
output_filename = ['Tot_BPU_DeTide_' datestr(t,'yyyymmddTHHMM') '.png'];

%% print the image
print(1, '-dpng', [output_directory output_filename]);

 clear T
 close all
end






% title({'MARACOOS HF Radar Data Coverage from';[datestr(data.t(1)+datenum(2001,01,01),'yyyy/mm/dd HH:MM') ' to ' datestr(data.t(end)+datenum(2001,01,01),'yyyy/mm/dd HH:MM')]},'FontWeight','bold','FontSize',14)
% xlabel({''; 'Temporal Coverage (%)'},'FontSize',12)
% ylabel({'Spatial Coverage (%)'; ''},'FontSize',12)
% legend('Optimal Interpolation')

%timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/grid_coverage_plot.m')



%close all;clear all;

toc
