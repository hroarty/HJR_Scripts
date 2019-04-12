close all
clear all

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

% Configuration data
% conf.RadialPlot.axisLims=[-72-00/60 -67-00/60 39+00/60 43+00/60];
% conf.RadialPlot.axisLims=[-75-00/60 -73-00/60 35+30/60 37+00/60];
conf.RadialPlot.axisLims=[-74.5 -71 39 41.25];
conf.RadialPlot.Mask=[conf.RadialPlot.axisLims([1 2 2 1 1])',conf.RadialPlot.axisLims([3 3 4 4 3])'];


conf.Totals.DomainName='MARA';
conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/5MHz/'];


% conf.RadialPlot.axisLims=[-75-00/60 -73-00/60 38+30/60 41+00/60];
% conf.Totals.DomainName='BPU';
% conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/13MHz/'];
%conf.Plot.Filename = 'MAB_13MHz_Radial_Map.png';


conf.Radials.MaskFlag=1;
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag=1;
conf.Totals.Mask='/Users/roarty/Documents/GitHub/HJR_Scripts/data/mask_files/MARACOOS_6kmMask.txt';
conf.Radials.coast='/Users/roarty/Documents/GitHub/HJR_Scripts/data/coast_files/MARA_coast.mat';

conf.Radials.Sites={'BLCK','AMAG','MRCH','HEMP','HOOK','LOVE','BRIG'};
conf.Radials.Range={139,99,64,75,99,122,157};
% conf.Radials.Sites={'LISL','DUCK','HATY','CORE'};

dtime=datenum(2018,4,17,8,0,0):1/24:datenum(2018,4,17,18,0,0);

M=colormap7;

for jj=1:length(dtime)
    
    [f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime(jj),conf.Totals.FilePrefix,...
        conf.Totals.FileSuffix,conf.Totals.MonthFlag);

    data=load(f{1});


    data.RTUV = maskRadials( data.RTUV, conf.Totals.Mask, 0);



    plotBasemap( conf.RadialPlot.axisLims(1:2),conf.RadialPlot.axisLims(3:4),conf.Radials.coast,'Mercator','patch',[1 .69412 0.39216],'edgecolor','k');

    hold on

    % plot the bathy
        bathy=load ('/Users/roarty/Documents/GitHub/HJR_Scripts/data/bathymetry/eastcoast_4min.mat');
        ind2= bathy.depthi==99999;
        bathy.depthi(ind2)=NaN;
        bathylines=-10:-20:-100;
        [c, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi, bathylines, 'k');
        clabel(c,h1,'fontsize',6);

 

    for ii=1:length(data.RTUV)
        Rorig=data.RTUV(ii);

        I = strmatch(Rorig.SiteName, conf.Radials.Sites);

        if  I
            % mask the vectors outside the plot limit
            Rorig=maskRadials(Rorig,conf.RadialPlot.Mask,1);
            % plot the radial vectors
%             m_vec(1,Rorig.LonLat(:,1),Rorig.LonLat(:,2),Rorig.U*.004,Rorig.V*.004,M(I,:));% plot each radial site a different color
            m_vec(1,Rorig.LonLat(:,1),Rorig.LonLat(:,2),Rorig.U*.004,Rorig.V*.004,'g');% plot all radials same color
            % plot the site origin
            m_plot(Rorig.SiteOrigin(1), Rorig.SiteOrigin(2), '^',...
                'markersize', 12,...
                'markerfacecolor', M(I,:),...
                'markeredgecolor', 'k');
            
            % find the range cell that matches where the turbine farm is
            ind=floor(Rorig.RangeBearHead(:,1))==conf.Radials.Range{I};
            m_vec(1,Rorig.LonLat(ind,1),Rorig.LonLat(ind,2),Rorig.U(ind)*.004,Rorig.V(ind)*.004,'k');% plot all radials same color
        end

    end

    % Add title string

    conf.HourPlot.TitleString = ['Radial Map: ', ...
                                datestr(dtime(jj),'yyyy/mm/dd HH:MM')];

    hdls.title = title( conf.HourPlot.TitleString, 'fontsize', 14,'color',[0 0 0] );

     %% create the output directory and filename
    conf.Plot.Filename = ['MAB_05MHz_Radial_Map_' datestr(dtime(jj),'yyyymmdd_HHMM') '.png']; 
    conf.Plot.script='plot_radials_one_map.m';
    % conf.Plot.print_path = '/Users/hroarty/COOL/01_CODAR/South_Africa/20171201_South_Africa_Talk/';
    conf.Plot.print_path = '/Users/roarty/COOL/01_CODAR/BPU/20180607_NY_Bight_Impact/';


    timestamp(1,[conf.Plot.Filename ' / ' conf.Plot.script])
    print(1,'-dpng','-r200',[conf.Plot.print_path  conf.Plot.Filename])
    close all
end
