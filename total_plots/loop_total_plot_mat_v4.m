tic

 clear all; close all; 

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add 2 seconds to handle rounding


start_time = datenum(2017,05,26,22,0,0);
end_time=datenum(2017,05,26,22,0,0);
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
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
% conf.OI.BaseDir='/Volumes/codaradm/data_reprocessed/totals/maracoos/oi/mat/5MHz/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/ideal/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/measured/';
conf.OI.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/20180301_May_Reprocessing/totals/maracoos/oi/mat/5MHz/';
conf.HourPlot.DomainName='MARA';
conf.HourPlot.axisLims=[-75 -71-00/60 38+00/60 41+00/60];% NJ and Delaware
% conf.HourPlot.axisLims=[-77 -68-00/60 34+00/60 42+00/60];%% MAB
% conf.HourPlot.axisLims2=[-80 -74 33 38];% VA NC
% conf.HourPlot.axisLims=[-76.5 -73 33.5 37];% VA NC

% %% 13 MHz configs
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
conf.Totals.MaxTotSpeed=300;
conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',0.6},{'OIuncert','Verr',0.6},{'OIuncert','UVCovariance',0.6}};

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

% conf.datatype='TUV';
conf.datatype='TUVoi';

% regions={'region01';'region02';'region03';'region04';'region05'};
regions={'region05'};

LandMask=load('/Users/hroarty/data/mask_files/MARACOOS_6kmMask.txt');

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
            lims=[-77 -73 34 37];% VA NC
        end
        
        conf.HourPlot.axisLims=lims;

        conf.HourPlot.Mask=[lims([1 2 2 1 1])' lims([3 3 4 4 3])'];
        
        % mask the totals outside the plot limits
        TUVcat2=maskTotals( TUVcat,conf.HourPlot.Mask);
%         TUVcat2=TUVcat;
       
        %% Plot the base map for the radial file
%         plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.coastlinefile,'Mercator','patch',[240,230,140]./255,'edgecolor','k')
        
        % m_proj('mercator','lat',conf.HourPlot.axisLims(3:4),'long',conf.HourPlot.axisLims(1:2));
        % m_gshhs_h('patch',[240,230,140]./255);
        % % m_coast('patch',[240,230,140]./255);
        % % m_grid('linestyle','none','linewidth',2,'tickdir','out','xaxisloc','top','yaxisloc','right');
        % m_grid('box','fancy','tickdir','in');
        hold on
        
        % pcolor the magnitude of the surface current field
        pcolor(TT.LON,TT.LAT,TT.MAG);
        shading interp
                 
        axis(conf.HourPlot.axisLims)
       
        
        project_mercator;
        
        % Plot the SST data
        % without cloud mask
%         f='http://tds.maracoos.org/thredds/dodsC/AVHRR/2017/Unmasked/Files/20170402.092.2306.n18.EC1.nc';
%         f='http://tds.maracoos.org/thredds/dodsC/AVHRR/2017/Unmasked/Files/20170323.082.2322.n18.EC1.nc';
%         f='http://tds.maracoos.org/thredds/dodsC/AVHRR/2017/Unmasked/Files/20170527.147.0741.n19.EC1.nc';
        f='http://tds.maracoos.org/thredds/dodsC/AVHRR/2017/Unmasked/Files/20170526.146.2243.n18.EC1.nc';

        SAT.lon=ncread(f,'lon');
        SAT.lat=ncread(f,'lat');
        SAT.lat=flipud(SAT.lat);
        SAT.time=ncread(f,'time');
        SAT.mcsst=ncread(f,'mcsst');

        [SAT.LON,SAT.LAT]=meshgrid(SAT.lon,SAT.lat);

        SAT.mcsst=rot90(SAT.mcsst);

        pcolor(SAT.LON,SAT.LAT,SAT.mcsst)

        colormap(jet)
        caxis([10 28])
        colorbar
        shading flat
        
%         mapshow(coast2(:,1), coast2(:,2), 'DisplayType', 'polygon')


        

%         %% Plot Bathymetry
        %bathy=load ('/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat');
        bathy=load ('/Users/hroarty/data/bathymetry/eastcoast.mat');
        ind2= bathy.depthi==99999;
        bathy.depthi(ind2)=NaN;
%         bathylines=[ -10 -30 -50 -80 -200];
        bathylines=[ -200 -200];

%         [cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
        [cs, h1] = contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
        clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
        set(h1,'LineColor',[0.8 0.8 0.8])


        % colored arrows
%         [hdls.plotData,I] = plotData2( TUVcat2, 'm_vec_same', TUVcat.TimeStamp, conf.HourPlot.VectorScale);
                                     % p.HourPlot.plotData_xargs{:} );
          
         % pcolor magnitude w black arrows
              
%        [hdls.plotData,I] = plotData2( TUVcat, 'm_vec_same_color', TUVcat.TimeStamp, conf.HourPlot.VectorScale);

        % plot the vectors
        h=streakarrow(TT.LON(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
            TT.LAT(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
            TT.U(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
            TT.V(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end), 1, 1, 1);
        
        % shade in the land
        coast = load(conf.HourPlot.coastlinefile);
        coast2 = coast.ncst;
        e = plot(coast2(:,1), coast2(:,2), 'k', 'linewidth', 1);
        tanLand = [240,230,140]./255;
        mapshow(coast2(:,1), coast2(:,2), 'DisplayType', 'polygon', 'facecolor', tanLand)

         box on
         grid on

%         %-------------------------------------------------
%         % Plot the colorbar
%         try
%           conf.HourPlot.ColorTicks;
%         catch
%           ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
%           conf.HourPlot.ColorTicks = 0:10:ss+10;
%         end
%         caxis( [ min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks) ] );
% %         colormap( feval( conf.HourPlot.ColorMap, numel(conf.HourPlot.ColorTicks)-1 ) )
%         colormap(conf.HourPlot.ColorMap)
%         %colormap( feval( conf.HourPlot.ColorMap, conf.HourPlot.ColorMapBins))
%         %colormap(jet(10))
% 
%         cax = colorbar;
%         hdls.colorbar = cax;
%         hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
%                             'saturated.'], 'fontsize', 8 );
%         hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 12 );
% 
%         set(cax,'ytick',conf.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

         conf.HourPlot.TitleString={[conf.datatype '  ' datestr(TUVcat.TimeStamp,'mmm dd,yyyy HH:MM')];
             [ conf.OI.cleanTotalsVarargin{1}{2} ' < ' num2str(conf.OI.cleanTotalsVarargin{1}{3}) ' ' ...
              conf.OI.cleanTotalsVarargin{2}{2} ' < ' num2str(conf.OI.cleanTotalsVarargin{2}{3}) ' ' ...
              conf.OI.cleanTotalsVarargin{3}{2} ' < ' num2str(conf.OI.cleanTotalsVarargin{3}{3})]};
        h1=title(conf.HourPlot.TitleString);

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
                hdls.RadialSites = plot( s3(jj,1), s3(jj,2), ...
                                 '^k','markersize',12,'linewidth',2,'MarkerFaceColor','g');
            elseif  strmatch(s4{jj},'RDLMeasured')
                hdls.RadialSites = plot( s3(jj,1), s3(jj,2), ...
                                 'sk','markersize',12,'linewidth',2,'MarkerFaceColor','r');
            end
        end

        catch
        end
        
        clear s1 s2 s3 s4


        timestamp(1,'loop_total_plot_mat_v4.m')




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
        % output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161007_Matthew_Prep/20171012_UNC_totals_filtered/';
        % output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161007_Matthew_Prep/20171024_Reprocessing/';
        % output_directory ='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180104_Winter_Storm_Grayson/';
        output_directory =['/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/20180223_Total_Plots/' region '/'];

        output_filename = ['Tot_' conf.HourPlot.DomainName '_' conf.datatype '_' datestr(TUVcat2.TimeStamp,'yyyymmddTHHMM') '.png'];

        if ~exist( output_directory, 'dir' )
              mkdir(output_directory);
        end

        %% print the image
        print(1, '-dpng','-r100', [output_directory output_filename]);


         close all
    end
end


toc
