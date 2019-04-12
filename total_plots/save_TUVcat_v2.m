clear all
close all

tic

% conf.Totals.DomainName='MARA';
% conf.Totals.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
% conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
% conf.Totals.FileSuffix='.mat';
% conf.Totals.MonthFlag='true';

conf.Totals.BaseDir='/Volumes/om/dods-data/thredds/cool/codar/totals/5MHz_6km_realtime/';
conf.Totals.FilePrefix='RU_5MHz_';
conf.Totals.FileSuffix='.totals.nc';
conf.Totals.MonthFlag=false;



conf.HourPlot.mask='/Users/hroarty/data/mask_files/MARACOOS_6km_Mask_Central.txt';
conf.Totals.grid_lims=[-75 -71 38+00/60 41+00/60];



year=2015;
% dtime=datenum(year,01,01,0,0,0):1/24:datenum(year,12,31,23,0,0);
dtime=datenum(year,01,01,0,0,0):1/24:datenum(year,1,31,23,0,0);

conf.Totals.SaveDir='/Users/hroarty/data/totals/';
conf.SaveFileStr= [conf.Totals.FilePrefix 'cat_' num2str(year) '_v3.mat'];

% F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
%     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);

% get the data from the mat files and concatenate
% [f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);
% [TUVcat,goodCount]=catTotalStructs(f,'TUV',false,false,true,conf);

% Get the data from the thredds server
% f='http://hfrnet.ucsd.edu/thredds/dodsC/HFR/PRVI/6km/hourly/RTV/HFRADAR,_Puerto_Rico_and_the_US_Virgin_Islands,_6km_Resolution,_Hourly_RTV_best.ncd';
% f='http://tds.marine.rutgers.edu:8080/thredds/dodsC/cool/codar/totals/5Mhz_6km_realtime_fmrc/Maracoos_5MHz_6km_Totals-FMRC_best.ncd';
%% concatenate the total data
% [TUVcat] = convert_MARA_NC_to_TUVstruct(f,dtime,conf);

% get the data from the nc files and insert it into a TUV struct
[file]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);


conf.Totals.VarList={'time','lon','lat','u','v','u_err','v_err','num_radials','site_code'};
conf.Totals.VarList2={'u','v','u_err','v_err','num_radials','site_code'};


for kk=1:length(conf.Totals.VarList)
        tot.(conf.Totals.VarList{kk})=[];
end
    
tot.u=zeros(155,185,length(dtime));

dim=[155*185,1];

TUV = TUVstruct( [dim(1) length(dtime)], 1 );


for jj=1:length(file)
%     tot.u(:,:,jj)=ncread(file{jj}, 'u');

    tot.time(:,jj)=ncread(file{jj},'time');
    
    for mm=1:length(conf.Totals.VarList2)
        tot.(conf.Totals.VarList2{mm})=ncread(file{jj}, conf.Totals.VarList2{mm}); 
    end
    
    TUV.U(:,jj)=reshape(tot.u,dim);
    TUV.V(:,jj)=reshape(tot.v,dim);
    TUV.ErrorEstimates.Uerr(:,jj)=reshape(tot.u_err,dim);
    TUV.ErrorEstimates.Verr(:,jj)=reshape(tot.v_err,dim);
%     TUV.OtherSpatialVars(:,jj)=reshape(tot.num_radials,dim);
%     TUV.OtherMatrixVars(:,jj)=reshape(tot.site_code,dim);
    disp(jj)
end

tot.lon=ncread(file{jj},'lon');
tot.lat=ncread(file{jj},'lat');
[tot.LON,tot.LAT] = meshgrid(tot.lon, tot.lat);
tot.LON=tot.LON';
tot.LAT=tot.LAT';

TUV.LonLat(:,1)=reshape(tot.LON,dim);
TUV.LonLat(:,2)=reshape(tot.LAT,dim);

TUV.TimeStamp=tot.time;
    
%     
% end

%% land mask the data
conf.Totals.Mask='/Users/hroarty/data/mask_files/MARACOOS_6kmMask_v2.txt';
[TUV,I]=maskTotals(TUV,conf.Totals.Mask,false); % false removes vectors on land
  

filename=[conf.Totals.SaveDir conf.SaveFileStr];
save(filename,'TUV')


toc








