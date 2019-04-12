function mean_vector_plot_fn_03(TUVcat,wind_mean,p)



%% Subsample the data
% Find the unique values for the lat and lon grid
unique_x=unique(TUVcat.LonLat(:,1));
unique_y=unique(TUVcat.LonLat(:,2));

% The indices for the rows and columns to keep
% x_ind=[1;10;19;27;36;44;53;61;70;78;87;96;105;113;122;130;138];
% y_ind=[1;10;20;29;38;47;57;66;76;85;94;103;113;121;130];
grid=3;

x_ind=1:grid:length(unique_x);
y_ind=1:grid:length(unique_y);

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




%% Plot the base map for the radial file
plotBasemap( p.HourPlot.axisLims(1:2),p.HourPlot.axisLims(3:4),p.HourPlot.CoastFile,'Mercator','patch',[.5 .9 .5],'edgecolor','k')

hold on

TUV = TUVsub;
  
%% Plot the percent coverage
hdls = [];
%[hdls.plotData,I] = plotData( TUV, 'm_vec', median(dtime), p.HourPlot.VectorScale);%, ...
                             % p.HourPlot.plotData_xargs{:} );
                             
[hdls.plotData,I] = plotData2( TUV, 'm_vec_same', TUV.TimeStamp, p.HourPlot.VectorScale);%, ...
%p.HourPlot.plotData_xargs{:} );


%%-------------------------------------------------
%% Plot location of sites
try
%% read in the MARACOOS sites
dir='/Users/hroarty/data/';
file='maracoos_codar_sites.txt';
[C]=read_in_maracoos_sites(dir,file);

%% plot the location of the 13 MHz sites
%% 41 to 42 for PR
%% 16 to 23 for BPU
for ii=16:22
    hdls.RadialSites=m_plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
end

catch
end

%%-------------------------------------------------
%% Plot the wind data on the map
try
% hdls.windbarb=m_quiver(-74.5,40,wind_mean.u,wind_mean.v,config.windscale);
% hdls.windmeas=m_text(-74.75,39.75,[wind_mean.mag_str ' m/s']);

%hdls.windbarb=m_quiver(-67-6/60,18+10/60,wind_mean.u,wind_mean.v,p.HourPlot.windscale);
hdls.windbarb=m_vec(p.wind.scale,p.wind.origin(1),p.wind.origin(2),wind_mean.u,wind_mean.v);

hdls.windmeas=m_text(p.wind.text(1),p.wind.text(2),[wind_mean.mag_str ' m/s']);

%% place a red dot at the origin of the wind vector
hdls.windbarb_origin=m_plot(p.wind.origin(1),p.wind.origin(2),'r.','MarkerSize',8);

%set(hdls.windbarb,'Color','k','LineWidth',4)

catch
end

%-------------------------------------------------
% Plot the colorbar
try
  p.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( TUV.U(:,I), TUV.V(:,I) ) );
  p.HourPlot.ColorTicks = 0:10:ss+10;
end

caxis( [ min(p.HourPlot.ColorTicks), max(p.HourPlot.ColorTicks) ] );
%colormap( feval( p.HourPlot.ColorMap, numel(p.HourPlot.ColorTicks)-1 ) );
jet(64);

cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 14 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 14 );

set(cax,'ytick',p.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

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

sd_str=datestr(TUVcat.TimeStamp,'mmm dd, yyyy ');
sd_str2=datestr(TUVcat.TimeStamp,'yyyy_mm_dd');



titleStr = [p.HourPlot.DomainName p.OI.radial_type ' Daily Mean for:  ' sd_str ];
            

hdls.title = title(titleStr);
set(hdls.title,'fontsize', 20);




%timestamp(1,'mean_daily_vector_plot_wrapper.m')
timestamp(1,'mean_vector_plot_daily_PR2.m')

print('-dpng','-r200',[p.HourPlot.print_path 'TUV_' p.HourPlot.DomainName '_' p.OI.radial_type '_Daily_mean' sd_str2 '.png'])

close all




