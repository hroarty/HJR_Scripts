%% Scratch script to generate radial coverage plots
%% Written by Hugh Roarty on March 26, 2010

tic

close all; clear all;
% addpath /home/codaradm/HFR_Progs-2_1_3beta/matlab/general
% addpath /home/codaradm/operational_scripts/totals
% add_subdirectories_to_path('/home/codaradm/HFR_Progs-2_1_3beta/matlab/',{'CVS','private','@'});
% addpath /home/hroarty/Matlab
% addpath /home/codaradm/cocmp_scripts/helpers

conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.Type=conf.HourPlot.Type;
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.ColorTicks=0:10:100;
conf.HourPlot.axisLims=[-75-20/60 -74-40/60 38+30/60 39+5/60];
conf.HourPlot.DomainName='MARASR';
%conf.HourPlot.DomainName='MARAShort';
conf.HourPlot.Print=false;
conf.HourPlot.mask=[-74.5 38.3; -74.5 39.5; -75.5 39.5; -75.5 38.3;-74.5 38.3];

conf.Plot.coastFile='/Volumes/codaradm/data/coast_files/MARA_coast.mat';
conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151202_YR5.0_Progress/Del_Bay/';
%conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20140219_Aviso_HFR_Comparison/';

%conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20130917_Drifters_Manning/20131008_Total_Analysis/';


conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/25MHz/';
%conf.OI.BaseDir='/Volumes/codaradm/data/totals/shorts/maracoos/oi/mat/5MHz';
conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;


%% Declare the time that you want to load
% end_time=floor(now*24+1)/24 +2/(24*60*60);
% start_time=end_time-1;
% dtime=start_time:1/24:end_time;

months=datenum(2015 ,6:12 ,1);

for ii=1:numel(months)-1

    dtime = months(ii):1/24:months(ii+1);


    %% load the total data depending on the config
    s=conf.HourPlot.Type;
    [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


    %% concatenate the total data
    [TUVcat,goodCount] = catTotalStructs(f,'TUV',false,false,true,conf);
    ii = false(size(TUVcat));

    %% calculate the number of valid measurements for each map
    good.number=sum(~isnan(TUVcat.U),1);
    good.max=max(good.number);
    good.percent=good.number./good.max;

    %% Plot the base map for the radial file
    plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.Plot.coastFile,'Mercator','patch',[240,230,140]./255,'edgecolor','k')

    hold on
    
    %% establish the colormap
    try
      conf.HourPlot.ColorTicks;
    catch
      ss = max( cart2magn( TUVcat.U(:,I), TUVcat.V(:,I) ) );
      conf.HourPlot.ColorTicks = 0:10:ss+10;
    end
    caxis( [ min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks) ] );
    colormap( feval( conf.HourPlot.ColorMap, numel(conf.HourPlot.ColorTicks)-1 ) );
    

    %% Plot the percent coverage
    percentLimits = [min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks)];
   
    [h,ts]=plotData(TUVcat,'perc','m_line',percentLimits);
    set(h,'markersize',15);


    %% -------------------------------------------------
    %% Plot location of sites
    try
    %% read in the MARACOOS sites
    dir='/home/hroarty/Matlab/';
    file='maracoos_codar_sites.txt';
    [C]=read_in_maracoos_sites(dir,file);

    %% plot the location of the 13 MHz sites
    for ii=36:38
        hdls.RadialSites=m_plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
    end

    catch
    end
    
    %% -------------------------------------------------
    %% Plot the political boundaries
    
    %% load the political boundaries file
    boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');

    %% plot the location of the sites within the bounding box
    %hdls.RadialSites=m_plot(sites{1}(in),sites{2}(in),'^r','markersize',8,'linewidth',2);

    %% plot the political boundaries
    hdls.boundaries=m_plot(boundaries(:,1),boundaries(:,2),'-k','linewidth',1);



    %-------------------------------------------------
    % Plot the colorbar
    cax = colorbar;
    hdls.colorbar = cax;
    hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                        'saturated.'], 'fontsize', 8 );
    hdls.xlabel = xlabel( cax, '%', 'fontsize', 12 );

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
    titleStr = {sprintf('%s %s Coverage, %d possible hourly maps', ...
                        conf.HourPlot.DomainName,conf.HourPlot.Type,length(TUVcat.TimeStamp)),...
                sprintf('From %s to %s',datestr(dtime(1),'yyyy-mm-dd HH:MM'),datestr(dtime(end),'yyyy-mm-dd HH:MM'))};
    hdls.title = title(titleStr, 'fontsize', 20 );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add path of script to image
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    timestamp(1,'/total_plots/mean_coverage_plot_25_Delaware.m')

    %-------------------------------------------------
    % Print if desired
    %-------------------------------------------------

    sd_str=datestr(dtime(1),'yyyymmdd');
    ed_str=datestr(dtime(end),'yyyymmdd');
    print(1,'-dpng','-r200',[conf.Plot.PrintPath conf.HourPlot.DomainName '_total_coverage_' sd_str '_' ed_str '.png'])


    %% plot the time series of data coverage
    figure(2)
    plot(TUVcat.TimeStamp,good.percent)
    %[AX,H1,H2] = plotyy(TUVcat.TimeStamp,good.percent,TUVcat.TimeStamp,good.number,'plot');
    format_axis(gca,TUVcat.TimeStamp(1),TUVcat.TimeStamp(end),10,1,...
        'mm/dd/yy',0,1,0.1)
    xlabel('Date')
    ylabel('Percent of Valid Measurements (Relative to Max for Time Period)')

    titleStr2 = sprintf('MARACOOS Delaware Bay Coverage Max: %d Grid Points', round(good.max));
    hdls.title = title(titleStr2, 'fontsize', 20 );


    % ylim([0 1])
    % set(get(H2),'Ylim',[0 6000])
    % box on
    % grid on
    % datetick('x','mm/dd/yy')
    timestamp(2,'/total_plots/mean_coverage_plot_25_Delaware.m')
    print(2,'-dpng','-r200',[conf.Plot.PrintPath conf.HourPlot.DomainName '_total_coverage_ts2_' sd_str '_' ed_str '.png'])

    close all
    clear dtime TUVcat good

end
toc
