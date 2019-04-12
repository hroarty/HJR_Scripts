tic

% clear all; close all; 

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add 2 seconds to handle rounding

start_time = datenum(2012,8,1,00,0,2);
end_time=datenum(2012,10,1,00,0,2);
dtime = start_time:1/24:end_time;

conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/';
                 %/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz
conf.OI.FilePrefix='tuv_oi_BPU_';
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;

%% config info for the plot
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.Type=conf.HourPlot.Type;
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
%conf.HourPlot.axisLims=[-75 -73-40/60 38+40/60 39+40/60];
conf.HourPlot.axisLims=[-74-20/60 -73-20/60 39+40/60 40+40/60];
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

p.HourPlot.Type='OI';
s = p.HourPlot.Type;

%% load the total data depending on the config
s=conf.HourPlot.Type;
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


[TUVcat,goodCount] = catTotalStructs(f,'TUV');



[tidestruct,Ttide,Tnotide]=t_tide_totals(TUVcat,0.5);

sd_str=datestr(dtime(1),'yyyymmdd');
ed_str=datestr(dtime(end),'yyyymmdd');

savefile = ['BPU_Total_CAT_' sd_str '_' ed_str '.mat'];
%save(savefile, 'TUVcat','tidestruct','Ttide','Tnotide')
save(savefile, 'TUVcat')


% v = 'TUV';
% 
% 
% numFiles = length(f);
% goodCount = 0;
% 
% for i = 1:numFiles
%     try
%         % Load total hour:  assume it has the struct TUV as the final total current
%         % data product.  totals or oma should have TUV if using
%         % HFRPdriver_Totals_OMA.m
%         % Assuming if I can load it it's good.  What if the file exists but
%         % is empty?  I think it will get counted as a good file.
%         data=load(f{i},v);
%         fprintf('Loading file %u of %u\n ',i,numFiles);
%     catch
%         fprintf('Can''t load %s ... skipping\n',f{i});
%         continue;  % Skip rest of for loop
%     end
% 
%         
% 
% 
% %% Plot the base map for the radial file
% plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.coatlinefile,'Mercator','patch',[.5 .9 .5],'edgecolor','k')
% 
% hold on
% 
% 
%                            
% [hdls.plotData,I] = plotData2( data.TUV, 'm_vec_same', data.TUV.TimeStamp, conf.HourPlot.VectorScale);
%                              % p.HourPlot.plotData_xargs{:} );
% 
% 
% %-------------------------------------------------
% % Plot the colorbar
% try
%   conf.HourPlot.ColorTicks;
% catch
%   ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
%   conf.HourPlot.ColorTicks = 0:10:ss+10;
% end
% caxis( [ min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks) ] );
% colormap( feval( conf.HourPlot.ColorMap, numel(conf.HourPlot.ColorTicks)-1 ) )
% %colormap( feval( conf.HourPlot.ColorMap, conf.HourPlot.ColorMapBins))
% %colormap(jet(10))
% 
% cax = colorbar;
% hdls.colorbar = cax;
% hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
%                     'saturated.'], 'fontsize', 8 );
% hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 12 );
% 
% set(cax,'ytick',conf.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')
% 
% h1=title(datestr(data.TUV.TimeStamp,21));
% 
% %%-------------------------------------------------
% %% Plot location of sites
% try
% sl = vertcat( data.RTUV.SiteOrigin );
% 
% % Only plot the ones that are inside the plot limits.
% plotRect = [ p.HourPlot.axisLims([1,3]);
%          p.HourPlot.axisLims([2,3]);
%          p.HourPlot.axisLims([2,4]);
%          p.HourPlot.axisLims([1,4]);
%          p.HourPlot.axisLims([1,3]) ];
% ins = inpolygon(sl(:,1),sl(:,2),plotRect(:,1),plotRect(:,2));
% hdls.RadialSites = m_plot( sl(ins,1), sl(ins,2), ...
%                          '^k','markersize',8,'linewidth',2);
% catch
% end
% 
% 
% 
% 
% 
% 
% 
% %% create the output directory and filename
% %output_directory = '/Users/hroarty/COOL/01_CODAR/BPU/20120813_SeaBreeze/Detided/';
% output_directory = '/Users/hroarty/COOL/01_CODAR/BPU/20120912_SeaBreeze/RawZoom/';
% %output_directory = '/Users/hroarty/COOL/01_CODAR/BPU/20120813_SeaBreeze_Event/Detided/';
% output_filename = ['Tot_BPU_RawN_' datestr(data.TUV.TimeStamp,'yyyymmddTHHMM') '.png'];
% 
% %% print the image
% print(1, '-dpng', [output_directory output_filename]);
% 
%  clear data
%  close all
% end
% 
% 
% 
% 
% 
% 
% % title({'MARACOOS HF Radar Data Coverage from';[datestr(data.t(1)+datenum(2001,01,01),'yyyy/mm/dd HH:MM') ' to ' datestr(data.t(end)+datenum(2001,01,01),'yyyy/mm/dd HH:MM')]},'FontWeight','bold','FontSize',14)
% % xlabel({''; 'Temporal Coverage (%)'},'FontSize',12)
% % ylabel({'Spatial Coverage (%)'; ''},'FontSize',12)
% % legend('Optimal Interpolation')
% 
% %timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/grid_coverage_plot.m')
% 
% 
% 
% %close all;clear all;
% 
toc
