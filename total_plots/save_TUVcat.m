tic

conf.Totals.DomainName='MARA';
conf.Totals.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag='true';

% conf.Totals.BaseDir='/Volumes/om/dods-data/thredds/cool/codar/totals/5MHz_6km_realtime/';
% conf.Totals.FilePrefix='RU_5MHz_';
% conf.Totals.FileSuffix='.totals.nc';
% conf.Totals.MonthFlag=false;



conf.HourPlot.mask='/Users/hroarty/data/mask_files/MARACOOS_6km_Mask_Central.txt';
conf.Totals.grid_lims=[-75 -71 38+00/60 41+00/60];

% create array of the first of the month
% time.month=datenum(2009,1:96,1);
time.month=datenum(2016,2:3,1);
time.vec=datevec(time.month);

% dtime=datenum(year,01,01,0,0,0):1/24:datenum(year,12,31,23,0,0);

for jj=1:length(time.month)-1

    % create the hourly time array
    dtime=time.month(jj):1/24:time.month(jj+1)-1/24;

    date_string=sprintf('%d_%02d',time.vec(jj,1),time.vec(jj,2));

    conf.Totals.SaveDir='/Users/hroarty/data/totals/';
    conf.SaveFileStr= [conf.Totals.FilePrefix 'CAT_' date_string '_v7.3.mat'];

    % F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
    %     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);

    % get the data from the mat files and concatenate
    [f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);
    [TUVcat,goodCount]=catTotalStructs(f,'TUV',false,false,false,conf);

    % Get the data from the thredds server
    % f='http://hfrnet.ucsd.edu/thredds/dodsC/HFR/PRVI/6km/hourly/RTV/HFRADAR,_Puerto_Rico_and_the_US_Virgin_Islands,_6km_Resolution,_Hourly_RTV_best.ncd';
    % f='http://tds.marine.rutgers.edu:8080/thredds/dodsC/cool/codar/totals/5Mhz_6km_realtime_fmrc/Maracoos_5MHz_6km_Totals-FMRC_best.ncd';
    % concatenate the total data
    % [TUVcat] = convert_MARA_NC_to_TUVstruct(f,dtime,conf);




    filename=[conf.Totals.SaveDir conf.SaveFileStr];
    save(filename,'TUVcat','-v7.3')

end


toc








