close all; clear all;


tic
%% Add HFR_Progs to the path
% addpath /home/codaradm/HFR_Progs-2_1_3beta/matlab/general
% add_subdirectories_to_path('/home/codaradm/HFR_Progs-2_1_3beta/matlab/',{'CVS','private','@'});
% addpath /home/hroarty/Matlab/

% addpath /Volumes/codaradm/HFR_Progs-2_1_3beta/matlab/general
% add_subdirectories_to_path('/Volumes/codaradm/HFR_Progs-2_1_3beta/matlab/',{'CVS','private','@'});
% addpath /Volumes/hroarty/Matlab/


%% define the config parameters 
%conf.Radials.BaseDir='/home/codaradm/data/radials/';
conf.Radials.BaseDir='/Volumes/codaradm/data/radials/';
% conf.Radials.BaseDir='/Volumes/hroarty/lemus/Archive_Codar/';
%conf.Radials.BaseDir='/Users/hroarty/data/radials/';
% conf.Radials.Sites= {'BLCK','MRCH','HOOK','LOVE','BRIG','ASSA'};
% conf.Radials.Types= {'RDLi','RDLi','RDLi','RDLi','RDLi','RDLi'};
%conf.Radials.Types= {'RDLx','RDLx','RDLx','RDLx','RDLx','RDLx'};
% conf.Radials.Sites= {'NAUS','NAUS','ERRA','ERRA','MRCH','MRCH','HOOK','HOOK',...
%                      'LOVE','LOVE','GRHD','GRHD','WILD','WILD','ASSA','ASSA','CEDR','CEDR',...
%                        'DUCK','DUCK','HATY','HATY'};
% conf.Radials.Types= {'RDLi','RDLm','RDLi','RDLm','RDLi','RDLm','RDLi','RDLm'...
%                      'RDLi','RDLm','RDLi','RDLm','RDLi','RDLm'};
% conf.Radials.Sites= {'LOVE','LOVE'};
% conf.Radials.Types= {'RDLi','RDLm'};
conf.Radials.Sites= {'NANT','NANT','ASSA','ASSA','LISL','LISL',};
conf.Radials.Types= {'RDLi','RDLm','RDLi','RDLm','RDLi','RDLm'};
conf.Radials.Range={18,18};                        
conf.Radials.Bear={125,125};

conf.Radials.MonthFlag=true;
conf.Radials.TypeFlag=false;
conf.Radials.HourFlag=false;
conf.Radials.Raw=false;
%conf.Radials.MaskFile='/home/codaradm/data/mask_files/BPU_2km_extendedMask.txt';
%conf.Radials.MaskFile='/Volumes/codaradm/data/mask_files/BPU_2km_extendedMask.txt';
conf.Radials.MaskFile='/Users/roarty/Documents/GitHub/HJR_Scripts/data/mask_files/MARACOOS_6kmMask.txt';
conf.Radials.MaxRadSpeed=300;

%% declare the analysis time
year=2016;
dtime=datenum(year,1,1,0,0,2):1/24:datenum(year+1,1,1,00,0,2);

%% define the colormap for the data
%range_color=jet(numel(conf.Radials.Sites));

%% addpath for function colormap17.m that is a colormap that i made.  The colormap
%% is contained in the variable M
% addpath /Volumes/hroarty/Matlab/
% colormap7_light_dark
% range_color=M;

cleanflag=0;
maskflag=0;

conf.HourPlot.script='wrapper_rad_vel_ts_no_concatenation.m';
conf.HourPlot.print_path='/Users/roarty/COOL/01_CODAR/MARACOOS_II/20190410_Radial_Velocity_Distribution/';
conf.Save.directory=conf.HourPlot.print_path;


% range=8;        % range in km
% bearing=180;    % bearing in degrees CCWE

for ii = 1:numel(conf.Radials.Sites)
    
    try
    [Rorig]=driver_rad_vel_no_concat(dtime,conf,ii,cleanflag,maskflag);
    
    hold on
    
   vel_time=NaN(length(Rorig),1);
   vel_mean=NaN(length(Rorig),1);
   vel_sd=NaN(length(Rorig),1);
    
    for jj=1:length(Rorig)
        test_time=ones(length(Rorig(jj).RadComp),1);
        test_time=test_time*Rorig(jj).TimeStamp;
        plot(test_time,Rorig(jj).RadComp,'b.')
        vel_time(jj)=Rorig(jj).TimeStamp;
        vel_mean(jj)=mean(Rorig(jj).RadComp);
        vel_sd(jj)=std(Rorig(jj).RadComp);
        vel_N(jj)=length(Rorig(jj).RadComp);
        
        clear test_time
    end
    
    catch
    end
    
    plot(vel_time,vel_mean,'g')
    
    plot(vel_time,vel_mean+3*vel_sd,'r')
    plot(vel_time,vel_mean-3*vel_sd,'r')


%% FIGURE 1 FORMATTING
figure(1)

X_hashes=datenum(2016,1:12,1);
format_axis2(gca,vel_time(1),vel_time(end),X_hashes,'mm/dd',-300,300,50)


% %% loop to create labels for legend
% for jj=1:numel(conf.Radials.Sites)
%     legend_label{jj}=[conf.Radials.Sites{jj} ' ' conf.Radials.Types{jj}];
% end
% 
% h_legend=legend(legend_label,'Location','NorthEast');
% %h_legend=legend(conf.Radials.Sites,'Location','North','Orientation','horizontal');
% %legend(conf.Radials.Types,'Location','North','Orientation','horizontal');
% set(h_legend,'FontSize',7)

ylabel('Radial Velocity (cm/s)')
title([num2str(year) ' Radial Velocity Distribution for ' conf.Radials.Sites{ii} ' ' conf.Radials.Types{ii}])
%title('Baseline Time Series Plot')
sd_str=datestr(min(dtime),'yyyymmdd');
ed_str=datestr(max(dtime),'yyyymmdd');


conf.Plot.Filename=['Rad_Vel_distribution_ts_' conf.Radials.Sites{ii} '_' conf.Radials.Types{ii} '_' sd_str '_' ed_str '.png'];


timestamp(1,[conf.Plot.Filename ' / ' conf.HourPlot.script])
print(1,'-dpng','-r200',[conf.HourPlot.print_path  conf.Plot.Filename])

close all

% Data.Rorig=Rorig;
Data.vel_time=vel_time;
Data.vel_mean=vel_mean;
Data.vel_sd=vel_sd;
Data.vel_N=vel_N;

save([conf.Save.directory 'Radials_' conf.Radials.Sites{ii} '_' conf.Radials.Types{ii} '_' datestr(Rorig(1).TimeStamp,'yyyy_mm_dd') '.mat'], '-struct', 'Data');

end

toc
