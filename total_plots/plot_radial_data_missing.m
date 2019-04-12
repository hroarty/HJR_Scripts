
clc
clear all
close all
 
tic

%% declare the analysis time
yr=2018;
% dtime=datenum(year,1,1,0,0,0):1/24:datenum(year,11,29,00,0,0);
dtime=datenum(yr,3,4,0,0,0):1/24:datenum(yr,3,9,00,0,0);
% conf.NDBC.t0=datenum(yr(1),1,1);
% conf.NDBC.tN=dtime(end);
conf.NDBC.t0=dtime(1);
conf.NDBC.tN=dtime(end);

x_tick_label=[];
% x_tick=datenum(yr,1:12,1);
x_tick=dtime(1):2:dtime(end);

frequency=5;

switch frequency
    case 5
        conf.Radials.Sites={'NAUS','NANT','MVCO','BLCK',...
                    'AMAG','MRCH','HEMP','HOOK','LOVE','BRIG','WILD',...
                    'ASSA','CEDR','LISL','DUCK','HATY','CORE'};
        conf.Radials.Types= {'RDLi','RDLi','RDLi','RDLi',...
                    'RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi',...
                    'RDLi','RDLi','RDLi','RDLi','RDLi','RDLi'};
        conf.OI.DomainName='MARA';
        conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
        conf.OI.FilePrefix=['tuv_oi_' conf.OI.DomainName '_'];
        conf.OI.FileSuffix='.mat';
        conf.OI.MonthFlag=1;
        conf.OI.HourFlag=0;
    case 13
        conf.Radials.Sites={'SEAB','BRAD','SPRK','BRNT',...
                    'BRMR','RATH','WOOD'};
        conf.Radials.Types= {'RDLi','RDLi','RDLi','RDLi',...
                    'RDLi','RDLi','RDLi'};
                conf.OI.DomainName='BPU';
        conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/';
        conf.OI.FilePrefix=['tuv_oi_' conf.OI.DomainName '_'];
        conf.OI.FileSuffix='.mat';
        conf.OI.MonthFlag=1;
        conf.OI.HourFlag=0;
end


                
%  conf.Radials.Sites={'NAUS'};
%  conf.Radials.Types= {'RDLi'};
%  conf.Radials.Types2= {'RDLm'};
                


conf.HourPlot.Type='OI';
s = conf.HourPlot.Type;
% conf.datatype='RTUV';
conf.datatype='missingRadials';

% create the cell array with the list of the total filenames
% [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag,conf.(s).HourFlag);
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);

% data_type_ideal=NaN(length(conf.Radials.Sites),length(dtime));
% data_type_meas=NaN(length(conf.Radials.Sites),length(dtime));

data_type_ideal=zeros(length(conf.Radials.Sites),length(dtime));
data_type_meas=zeros(length(conf.Radials.Sites),length(dtime));


for ii = 1:length(dtime) 
   
    try 
       data=load(f{ii},conf.datatype);
       str=sprintf('Loading File %u of %u',ii,length(dtime));
       disp(str)
    catch err
        disp(err)
        % since no data for that time period make all sites NaN
        data_type_ideal(:,ii)=0;
        data_type_meas(:,ii)=0;
        fprintf('Can''t load %s ... skipping\n',f{ii});
        continue;  % Skip rest of for loop
    end
   
   for jj=1:length(conf.Radials.Sites)
       
       % determine where the radial site is in the list
       tf=strcmp(conf.Radials.Sites{jj},data.missingRadials.Sites);
        
       temp=data.missingRadials.Types;
       
       % if the radial file is present then sum(tf)=1 then execute lines
       % else make spots NaNs
       
       if sum(tf)
           data_type_ideal(jj,ii)=strcmp('RDLi',temp(tf));
           data_type_meas(jj,ii)=strcmp('RDLm',temp(tf));
       else
           data_type_ideal(jj,ii)=0;
           data_type_meas(jj,ii)=0;
       end
        
       
   end
   
   clear data
   
end

for jj=1:length(conf.Radials.Sites)
%% plot the data presence for each site in its own subplot
        plot_handle(jj)=subplot(length(conf.Radials.Sites),1,jj);

        grid on
        hold on
        ylim([0.5 1.5])
        xlim([conf.NDBC.t0 conf.NDBC.tN])
        ylabel(conf.Radials.Sites(jj),'fontsize',10,'rot',00,'HorizontalAlignment','right')

        set(gca,'xtick',x_tick)
        set(gca,'xticklabel',x_tick_label)

        set(gca,'ytick',[ ])

        %% data_presence will be 1s or 0s
%         h(jj) = plot(dtime, data_type_ideal, '.', 'color', 'g','MarkerSize',20);
%         h(jj) = plot(dtime, data_type_meas, '.', 'color', 'k','MarkerSize',20);
        
        plot(dtime, data_type_ideal(jj,:), '.', 'color', 'g','MarkerSize',20);
        plot(dtime, data_type_meas(jj,:), '.', 'color', 'k','MarkerSize',20);
end

ideal=logical(data_type_ideal);
meas=logical(data_type_meas);
    
subplot(length(conf.Radials.Sites),1,jj)
% set(gca,'xticklabel',datestr(x_tick,'mmm'),'fontsize',10)
set(gca,'xticklabel',datestr(x_tick,'mm/dd/yy'),'fontsize',8,'XTickLabelRotation',45)

subplot(length(conf.Radials.Sites),1,1)
h= title(['MAB Missing Radial Data from ' num2str(yr) ' Meas (black) Ideal (green)'],'FontWeight','bold','FontSize',14);

%maximizeSubPlots(plot_handle)


 %% create the output directory and filename
conf.Plot.script='plot_radial_data_missing.m';
% conf.Plot.print_path = '/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20171201_YR1.5_Progress_Report/';
conf.Plot.print_path ='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20180209_Radial_Inspection/';
conf.Plot.Filename = ['MAB_Missing_Radial_Data_'  num2str(yr) '_' num2str(yr) '.png'];
    
timestamp(1,[conf.Plot.Filename ' / ' conf.Plot.script])
print(1,'-dpng','-r200',[conf.Plot.print_path  conf.Plot.Filename])

% write a text file that lists the missing times for each station
fileID = fopen(['Missing_Radials_' yr '.txt'],'w');
fprintf(fileID,'************************************* \n');

for jj=1:length(conf.Radials.Sites)
    fprintf(fileID,'%s Ideal \n',conf.Radials.Sites{jj});
    test=datestr(dtime(ideal(jj,:)),'mmm.dd,yyyy HH:MM');
    fprintf(fileID,'%u Missing Files \n',size(test,1));
    for kk=1:size(test,1)
        fprintf(fileID,'%s\n',test(kk,:));
    end
    fprintf(fileID,'************************************* \n');
    fprintf(fileID,'%s Measured \n',conf.Radials.Sites{jj});
    test2=datestr(dtime(meas(jj,:)),'mmm.dd,yyyy HH:MM');
    fprintf(fileID,'%u Missing Files \n',size(test2,1));
    for kk=1:size(test2,1)
        fprintf(fileID,'%s\n',test2(kk,:));
    end
    fprintf(fileID,'************************************* \n');
    clear test test2
end

fclose(fileID);

% write a text file that lists total missing files for each station
fileID = fopen('Missing_Radials_Summary_2017.txt','w');
fprintf(fileID,'************************************* \n');
fprintf(fileID,'MAB 5 MHz Missing Files  \n');
fprintf(fileID,'From %s to %s  \n',datestr(dtime(1),'mmm.dd,yyyy'),datestr(dtime(end),'mmm.dd,yyyy'));
fprintf(fileID,'************************************* \n');
for jj=1:length(conf.Radials.Sites)
    
    test=datestr(dtime(ideal(jj,:)),'mmm.dd,yyyy HH:MM');
    test2=datestr(dtime(meas(jj,:)),'mmm.dd,yyyy HH:MM');
    fprintf(fileID,'%s %u Ideal %u Meas\n',conf.Radials.Sites{jj},size(test,1),size(test2,1));
 
    clear test test2
end

fclose(fileID);


toc
