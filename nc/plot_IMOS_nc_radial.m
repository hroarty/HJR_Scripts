%% the location of the radial data
conf.Radial.Sites={'CRVT','SBRD'};

jj=2;

input_dir = ['/Users/hroarty/COOL/01_CODAR/MARACOOS/20140107_Australia_Data/CODAR_2011/' conf.Radial.Sites{jj} '/']; 

conf.Plot.lon_min=112.5;
conf.Plot.lon_max=116.5;
conf.Plot.lat_min=-34; 
conf.Plot.lat_max=-28;
conf.Plot.Coast='/Users/hroarty/data/coast_files/Australia.mat';




conf.Radials.VectorScale=0.004;



time.start=datenum(2011,07,02);
time.end=datenum(2011,07,03);

dtime.num = time.start:1/24:time.end;
dtime.str=datestr(dtime.num,'yyyymmddTHHMMSS');



for ii = 1:length (dtime.num)
 files{ii,1} =[input_dir, 'IMOS_ACORN_RV_' dtime.str(ii,:) 'Z_' conf.Radial.Sites{jj} '_FV00_radial.nc']; 
end

for ii = 1:length(files)
 %t = nc_varget(files{ii},'time');
rad.lat = nc_varget(files{ii},'LATITUDE');
rad.lon = nc_varget(files{ii},'LONGITUDE');
rad.vel=100*nc_varget(files{ii},'ssr_Surface_Radial_Sea_Water_Speed');
rad.bear=nc_varget(files{ii},'ssr_Surface_Radial_Direction_Of_Sea_Water_Velocity');

[rad.u,rad.v]=compass2uv(rad.bear,rad.vel);

 

%% Plot the radial file
plotBasemap( [conf.Plot.lon_min conf.Plot.lon_max],[conf.Plot.lat_min conf.Plot.lat_max],...
    conf.Plot.Coast,'Mercator','patch',[.5 .9 .5],'edgecolor','k')

%whitebg([0.6 0.6 0.6])

hold on

m_vec(1,rad.lon,rad.lat,rad.u*conf.Radials.VectorScale,...
    rad.v*conf.Radials.VectorScale,rad.vel);
% m_quiver(rad.lon,rad.lat,rad.u*conf.Radials.VectorScale,...
%     rad.v*conf.Radials.VectorScale);

%title(strrep(radial_file.FileName{1}(end-28:end),'_',' '));

caxis([-50 50])
% colormap(flipud(jet(64)));
% colorbar


colormap_blue_red_hjr
M=flipud(M);
colormap(M);

%% Add a colorbar
cax = colorbar;
set(cax,'ytick',[-50:10:50],'fontsize',14,'fontweight','bold')

title(['RDLm ' conf.Radial.Sites{jj} ' ' dtime.str(ii,:)])

printpath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20140107_Australia_Data/CODAR_2011/Figures/';

print(1,'-dpng','-r200',[printpath 'RDLm_' conf.Radial.Sites{jj} '_' dtime.str(ii,:) '.png'])

figure(2)
hist(rad.vel)
print(2,'-dpng','-r200',[printpath 'HIST_RDLm_' conf.Radial.Sites{jj} '_' dtime.str(ii,:) '.png'])


close all


end