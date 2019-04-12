tic

 clear all; close all; 

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add 2 seconds to handle rounding


start_time = datenum(2016,5,23,15,0,0);
end_time=datenum(2016,5,23,18,0,0);
dtime = start_time:1/24:end_time;


%% config info for the plot
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.Type=conf.HourPlot.Type;
conf.HourPlot.VectorScale=0.004;
% conf.HourPlot.ColorMap='jet';
conf.HourPlot.Print=false;
conf.HourPlot.coastlinefile='/Users/hroarty/data/coast_files/MARA_coast.mat';
% conf.HourPlot.coastlinefile='/Users/hroarty/data/coast_files/NC_coast.mat';


% 5 MHz configs
%conf.OI.BaseDir='/Users/hroarty/data/realtime/totals/maracoos/oi/mat/5MHz/';
% conf.OI.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161007_Matthew_Prep/20171024_Reprocessing/totals/maracoos/oi/mat/5MHz/';
% conf.OI.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/20180301_May_Reprocessing/totals/maracoos/oi/mat/5MHz';
conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/ideal/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/measured/';
conf.HourPlot.DomainName='BPU';
% conf.HourPlot.axisLims=[-75 -71-00/60 38+00/60 41+00/60];% NJ and Delaware
conf.HourPlot.axisLims= [-74-15/60 -73-15/60 39+30/60 40+15/60];
% conf.HourPlot.axisLims=[-77 -68-00/60 34+00/60 42+00/60];%% MAB
% conf.HourPlot.axisLims2=[-80 -74 33 38];% VA NC
% conf.HourPlot.axisLims=[-76.5 -73 33.5 37];% VA NC


conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=1;
conf.OI.HourFlag=0;
conf.Totals.MaxTotSpeed=300;
conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',1},{'OIuncert','Verr',1},{'OIuncert','UVCovariance',1}};

conf.HourPlot.DistanceBarLength = 50;
conf.HourPlot.DistanceBarLocation = [conf.HourPlot.axisLims(2)-15/60 conf.HourPlot.axisLims(4)-15/60];
conf.HourPlot.ColorTicks = 0:10:60;
conf.HourPlot.ColorMapBins=64;
% [conf.HourPlot.ColorMap]=colormap6;
conf.HourPlot.ColorMap=jet(64);
% conf.HourPlot.ColorMap=cmocean('speed',length(conf.HourPlot.ColorTicks)-1);
conf.HourPlot.Print=1;
conf.HourPlot.Mask=[conf.HourPlot.axisLims([1 2 2 1 1])',conf.HourPlot.axisLims([3 3 4 4 3])'];
conf.HourPlot.grid_spacing=1;
conf.HourPlot.grid=1;



conf.HourPlot.Type='OI';
s = conf.HourPlot.Type;

%% load the total data depending on the config
s=conf.HourPlot.Type;
% [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag,conf.(s).HourFlag);
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);
conf.datatype='TUV';
% conf.datatype='TUVoi';

% regions={'region01';'region02';'region03';'region04';'region05'};
regions={'special'};

LandMask=load('/Users/hroarty/data/mask_files/MARACOOS_6kmMask.txt');

%% Plot Bathymetry
%bathy=load ('/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat');
bathy=load ('/Users/hroarty/data/bathymetry/eastcoast.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines=[ -10 -30 -50 -80 -200];

for ii = 1:length(dtime) 
    
   data=load(f{ii});

% clean the total vectors 
    TUVcat=cleanTotals(data.(conf.datatype),conf.Totals.MaxTotSpeed,conf.OI.cleanTotalsVarargin{:});
    
    
    
    mag = sqrt(TUVcat.U.^2 + TUVcat.V.^2); % 
    [TT.LON,TT.LAT]=meshgrid(unique(TUVcat.LonLat(:,1)),unique(TUVcat.LonLat(:,2)));
    TT.MAG=griddata(TUVcat.LonLat(:,1),TUVcat.LonLat(:,2),mag,TT.LON,TT.LAT);
    TT.U=griddata(TUVcat.LonLat(:,1),TUVcat.LonLat(:,2),TUVcat.U,TT.LON,TT.LAT);
    TT.V=griddata(TUVcat.LonLat(:,1),TUVcat.LonLat(:,2),TUVcat.V,TT.LON,TT.LAT);

    IN = inpolygon(TT.LON,TT.LAT,LandMask(:,1),LandMask(:,2));
    TT.MAG(IN)=NaN;
    TT.U(IN)=NaN;
    TT.V(IN)=NaN;
    
    for jj=1:length(regions)
        
        region=regions{jj};
    
        switch region
            case 'regionALL'
            lims=[-77 -68 34 43];%ALL MAB
            case 'region01'
            lims=[-70 -68 40 43];% North
            case 'region02'
            lims=[-72 -70 39 41.5];% RI
            case 'region03'
            lims=[-75 -72 39 41];% NJ
            case 'region04'
            lims=[-76 -72 37 39];% MD
            case 'region05'
%             lims=[-77 -73 34 37];% VA NC
            lims=[-74 -73 35.5 36];% zoom
            case 'special'
            lims= [-74-15/60 -73-15/60 39+30/60 40+15/60];
        end
        
        conf.HourPlot.axisLims=lims;

        conf.HourPlot.Mask=[lims([1 2 2 1 1])' lims([3 3 4 4 3])'];
        
        % mask the totals outside the plot limits
        TUVcat2=maskTotals( TUVcat,conf.HourPlot.Mask);
%         TUVcat2=TUVcat;
       
        %% Plot the base map for the radial file
        plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.coastlinefile,'Mercator','patch',[240,230,140]./255,'edgecolor','k')
        
        % m_proj('mercator','lat',conf.HourPlot.axisLims(3:4),'long',conf.HourPlot.axisLims(1:2));
        % m_gshhs_h('patch',[240,230,140]./255);
        % % m_coast('patch',[240,230,140]./255);
        % % m_grid('linestyle','none','linewidth',2,'tickdir','out','xaxisloc','top','yaxisloc','right');
        % m_grid('box','fancy','tickdir','in');
        hold on
        
        
  
        % colored arrows
        [hdls.plotData,I] = plotData2( TUVcat2, 'm_vec_same', TUVcat.TimeStamp, conf.HourPlot.VectorScale);

          
         % pcolor magnitude w black arrows
         
%          m_pcolor(TT.LON,TT.LAT,TT.MAG);
%         shading interp
%         %         
%         axis(conf.HourPlot.axisLims)
%         box on
%         grid on
        
%        addpath /Users/hroarty/GitHub/hfrprogs/matlab/plot/
%         [hdls.plotData,I] = plotData2( TUVcat2, 'm_vec_same_color', TUVcat.TimeStamp, conf.HourPlot.VectorScale);

        % plot the vectors
%         h=streakarrow(TT.LON(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
%             TT.LAT(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
%             TT.U(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
%             TT.V(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end), 1, 1, 1);


        %-------------------------------------------------
        % Plot the colorbar
        try
          conf.HourPlot.ColorTicks;
        catch
          ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
          conf.HourPlot.ColorTicks = 0:10:ss+10;
        end
        caxis( [ min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks) ] );
%         colormap( feval( conf.HourPlot.ColorMap, numel(conf.HourPlot.ColorTicks)-1 ) )
        colormap(conf.HourPlot.ColorMap)
        %colormap( feval( conf.HourPlot.ColorMap, conf.HourPlot.ColorMapBins))
        %colormap(jet(10))

        cax = colorbar;
        hdls.colorbar = cax;
        hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                            'saturated.'], 'fontsize', 8 );
        hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 12 );

        set(cax,'ytick',conf.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

         conf.HourPlot.TitleString={[conf.datatype '  ' datestr(TUVcat.TimeStamp,'mmm dd,yyyy HH:MM')];
             [ conf.OI.cleanTotalsVarargin{1}{2} ' < ' num2str(conf.OI.cleanTotalsVarargin{1}{3}) ' ' ...
              conf.OI.cleanTotalsVarargin{2}{2} ' < ' num2str(conf.OI.cleanTotalsVarargin{2}{3}) ' ' ...
              conf.OI.cleanTotalsVarargin{3}{2} ' < ' num2str(conf.OI.cleanTotalsVarargin{3}{3})]};
        
          
          h1=title(conf.HourPlot.TitleString);
        
        % Plot the bathymetry lines
         [cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
        clabel(cs,h1,'fontsize',8,'Color',[0.2 0.2 0.2]);
        set(h1,'LineColor',[0.2 0.2 0.2])

        %%-------------------------------------------------
        %% Plot location of sites
        try
        s1 = vertcat( data.RTUV.SiteOrigin );
        s2={data.RTUV.Type};

        % Only plot the ones that are inside the plot limits.
        plotRect = [ conf.HourPlot.axisLims([1,3]);
                 conf.HourPlot.axisLims([2,3]);
                 conf.HourPlot.axisLims([2,4]);
                 conf.HourPlot.axisLims([1,4]);
                 conf.HourPlot.axisLims([1,3]) ];
        ins = inpolygon(s1(:,1),s1(:,2),plotRect(:,1),plotRect(:,2));

        s3=s1(ins,:);
        s4=s2(ins);

        for jj=1:length(s3)
            if strmatch(s4{jj},'RDLIdeal')
                hdls.RadialSites = m_plot( s3(jj,1), s3(jj,2), ...
                                 '^k','markersize',12,'linewidth',2,'MarkerFaceColor','g');
            elseif  strmatch(s4{jj},'RDLMeasured')
                hdls.RadialSites = m_plot( s3(jj,1), s3(jj,2), ...
                                 'sk','markersize',12,'linewidth',2,'MarkerFaceColor','r');
            end
        end

        catch
        end
        
        clear s1 s2 s3 s4

        timestamp(1,'loop_total_plot_mat_color_arrows.m')

        %% create the output directory and filename

%         output_directory =['/www/home/hroarty/public_html/maracoos/animations_vectors/05MHz/';/' region '/'];
%         output_directory =['/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/20180301_May_Reprocessing/images_totals/' region '/'];
%          output_directory =['/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161020_QC_Check/20180323_LOVE_missing_test/' region '/'];
%          output_directory =['/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161020_QC_Check/20180419_GS_QC/' region '/'];
         output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20180530_Maps_No_Clean/';
%         output_filename = ['Tot_' conf.HourPlot.DomainName '_' conf.datatype '_' num2str(ii) '.png'];
        output_filename = ['Tot_' conf.HourPlot.DomainName '_' conf.datatype '_' datestr(TUVcat2.TimeStamp,'yyyy_mm_dd_HHMM') '.png'];
        
        if ~exist( output_directory, 'dir' )
              mkdir(output_directory);
        end
        
        timestamp(1,'/HJR_Scripts/total_plots/loop_total_plot_mat_color_arrows.m')

        %% print the image
        print(1, '-dpng','-r200', [output_directory output_filename]);


         close all
    end
end


toc
