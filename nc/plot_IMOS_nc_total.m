%% the location of the radial data
conf.Radial.Sites={'CRVT','SBRD'};

jj=2;

input_dir = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20140107_Australia_Data/CODAR_2011/Vector/'; 

conf.Plot.lon_min=112.5;
conf.Plot.lon_max=116.5;
conf.Plot.lat_min=-32.5; 
conf.Plot.lat_max=-29.5;
conf.Plot.Coast='/Users/hroarty/data/coast_files/Australia.mat';




conf.HourPlot.VectorScale=0.004;



time.start=datenum(2011,07,02);
time.end=datenum(2011,07,03);

dtime.num = time.start:1/24:time.end;
dtime.str=datestr(dtime.num,'yyyymmddTHHMMSS');



for ii = 1:length (dtime.num)
 files{ii,1} =[input_dir, 'IMOS_ACORN_V_' dtime.str(ii,:) 'Z_TURQ_FV00_sea-state.nc']; 
end

for ii = 1:length(files)
 %t = nc_varget(files{ii},'time');
tot.lat = nc_varget(files{ii},'LATITUDE');
tot.lon = nc_varget(files{ii},'LONGITUDE');
tot.u=100*nc_varget(files{ii},'ssr_Surface_Eastward_Sea_Water_Velocity');
tot.v=100*nc_varget(files{ii},'ssr_Surface_Northward_Sea_Water_Velocity');

tot.vel=100*sqrt(tot.u.^2 + tot.v.^2);


 

%% Plot the radial file
plotBasemap( [conf.Plot.lon_min conf.Plot.lon_max],[conf.Plot.lat_min conf.Plot.lat_max],...
    conf.Plot.Coast,'Mercator','patch',[.5 .9 .5],'edgecolor','k')

%whitebg([0.6 0.6 0.6])

hold on

% m_vec(1,tot.lon,tot.lat,tot.u*conf.Radials.VectorScale,...
%     tot.v*conf.Radials.VectorScale,tot.vel);

TUV = TUVstruct( [length(tot.lat) 1], 1 );

TUV.LonLat(:,1)=tot.lon;
TUV.LonLat(:,2)=tot.lat;
TUV.U=tot.u;
TUV.V=tot.v;

[hdls.plotData,I] = plotData2( TUV, 'm_vec_same', dtime.num(ii), conf.HourPlot.VectorScale);%, ...
                               %p.HourPlot.plotData_xargs{:} );

%title(strrep(radial_file.FileName{1}(end-28:end),'_',' '));

caxis([0 100])
jet(16);
% colorbar


%% Add a colorbar
cax = colorbar;
set(cax,'ytick',0:10:100,'fontsize',14,'fontweight','bold')

title(['TUV TURQ ' dtime.str(ii,:)])

printpath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20140107_Australia_Data/CODAR_2011/Figures/';

print(1,'-dpng','-r200',[printpath 'TUV_TURQ_' dtime.str(ii,:) '.png'])

close all


end