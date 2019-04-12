conf.Totals.DomainName = 'MARA';
conf.OI.BaseDir = '/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
conf.OI.FilePrefix = strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.OI.FileSuffix = '.mat';
conf.OI.MonthFlag = true;
conf.ErrorPlot.Type='OI';
dtime=datenum(2018,4,17,17,0,0);
conf.ErrorPlot.axisLims=[-74 -73 35.5 36];
conf.Plot.coastFile = '/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.Plot.Projection='Mercator';

conf.ErrorPlot.ErrorComponent = 'Verr';

s = conf.ErrorPlot.Type;
t=conf.ErrorPlot.ErrorComponent;

[tdn,tfn] = datenum_to_directory_filename( conf.(s).BaseDir, dtime, conf.(s).FilePrefix, conf.(s).FileSuffix, conf.(s).MonthFlag );
tdn = tdn{1};

data = load(fullfile(tdn,tfn{1}));

 in = inpolygon(data.TUV.LonLat(:,1),data.TUV.LonLat(:,2),...
     conf.ErrorPlot.axisLims([1 2 2 1 1]),conf.ErrorPlot.axisLims([3 3 4 4 3]));
 
 plotBasemap( conf.ErrorPlot.axisLims(1:2), conf.ErrorPlot.axisLims(3:4), ...
             conf.Plot.coastFile, conf.Plot.Projection, 'patch',[1 .69412 0.39216],'edgecolor','k');


 
 T=num2str(data.TUV.ErrorEstimates.Verr(in),'%0.2f');
 
 m_text(data.TUV.LonLat(in,1),data.TUV.LonLat(in,2),T,'FontSize',5,'Color','k');
 

  conf.ErrorPlot.TitleString = [conf.ErrorPlot.ErrorComponent ' ', ...
      datestr(dtime,'yyyy/mm/dd HH:MM'),' ',data.TUV.TimeZone(1:3)];
 title( conf.ErrorPlot.TitleString, 'fontsize', 16,'color','k' );
 
 %% create the output directory and filename
conf.Plot.Filename = [conf.Totals.DomainName '_' conf.ErrorPlot.ErrorComponent '_' datestr(dtime,'yyyy_mm_dd_HHMM') '.png']; 
conf.Plot.script='scratch_error_plot_zoom.m';
conf.Plot.print_path = '/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161020_QC_Check/20180419_GS_QC/';


timestamp(1,[conf.Plot.Filename ' / ' conf.Plot.script])

print(1,'-dpng','-r200',[conf.Plot.print_path  conf.Plot.Filename])
 
 
 