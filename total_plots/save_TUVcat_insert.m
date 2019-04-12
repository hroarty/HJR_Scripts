tic

compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes/';
else
     root = '/home/';
end

addpath(genpath('/home/hroarty/codar/MARACOOS/Radials2Totals/totals_toolbox/'))%

conf.Totals.DomainName='MARA';
conf.Totals.BaseDir=[root 'codaradm/data/totals/maracoos/oi/mat/5MHz/'];
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag='true';

conf.HourPlot.mask=[root '/hroarty/data/mask_files/MARACOOS_6km_Mask_Central.txt'];
conf.Totals.grid_lims=[-75 -71 38+00/60 41+00/60];

conf.Totals.MaxTotSpeed=300;
conf.OI.cleanTotals={{'OIuncert','Uerr',0.7},{'OIuncert','Verr',0.7}};

% create array of the first of the month
% time.month=datenum(2009,1:96,1);
time.month=datenum(2016,1:12,1);
time.vec=datevec(time.month);

% dtime=datenum(year,01,01,0,0,0):1/24:datenum(year,12,31,23,0,0);

for jj=1:length(time.month)-1

    % create the hourly time array
    dtime=time.month(jj):1/24:time.month(jj+1)-1/24;

    date_string=sprintf('%d_%02d',time.vec(jj,1),time.vec(jj,2));

    conf.Totals.SaveDir='/Users/hroarty/data/totals/';
    conf.SaveFileStr= [conf.Totals.FilePrefix 'CAT_' date_string '_Vinsert.mat'];

    % get the data from the mat files and concatenate
    [f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);
%     [TUVcat,goodCount]=catTotalStructs(f,'TUV',false,false,false,conf);
    
    
    DIM=[11732,length(dtime)];%[ NGridPts, NTimeStamps ]
    N=1;
    
    TUV = TUVstruct( DIM, N );
    
    numFiles = length(f);
    
    for kk=1:numFiles

    data=load(f{kk},'TUV');
    
    [TUVclean,I] = cleanTotals(data.TUV,conf.Totals.MaxTotSpeed,conf.OI.cleanTotals);
    
    clean_string=sprintf('Number of Grid Points Cleaned: %d',I);
    disp(clean_string)
    
    if kk==1
        TUV.DomainName=TUVclean.DomainName;
        TUV.CreationInfo='Created by Hugh Roarty';
        TUV.LonLat=TUVclean.LonLat;
    end
    
    TUV.TimeStamp(1,kk)=TUVclean.TimeStamp;
    TUV.U(:,kk)=TUVclean.U;
    TUV.V(:,kk)=TUVclean.V;
%     TUV.ErrorEstimates.Uerr(:,kk)=data.TUV.ErrorEstimates.Uerr;
%     TUV.ErrorEstimates.Verr(:,kk)=data.TUV.ErrorEstimates.Verr;
%     TUV.ErrorEstimates.UVCovariance(:,kk)=data.TUV.ErrorEstimates.UVCovariance;
%     TUV.ErrorEstimates.TotalErrors(:,kk)=data.TUV.ErrorEstimates.TotalErrors;
    
%     disp(kk)
    
    clear data
    
    end




    filename=[conf.Totals.SaveDir conf.SaveFileStr];
    save(filename,'TUV','-v7.3')

end


toc








