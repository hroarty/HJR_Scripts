%% This m script was written to extract time series data from the grid points 
%% that are closest to the virtual meterological towers for the BPU project

%% load the BPU sampling stations
dir='/Users/hroarty/COOL/01_CODAR/BPU/20120328_Sampling_Locations/';
file='BPU_sampling_grid.csv';
[C]=read_in_BPU_sites(dir,file);

%% load the total data 
conf.Totals.DomainName='BPU';
conf.Totals.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20120208_Zelenke_Request/totals/oi/';
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag=0;

dtime=datenum(2012,02,03,12,0,0):1/24:datenum(2012,02,09,16,0,0);  

% F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
%     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);

[f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);

%% Concatenate the total data
[TUVcat,goodCount]=catTotalStructs(f,'TUV');

%% define the start index (indS) end index (indE) and index length (indL) to 
%% extract the time series data over
indS=11;
indE=15;
indL=indE-indS+1;

%% preallocate the arrays so I can write to them.  The rows will be each
%% timestep and the columns will be each grid point
BPU.U=nan(length(f),indL);
BPU.V=nan(length(f),indL);
BPU.LonLat=nan(indL,2);

for ii=indS:indE
    BPU.U(:,ii-10)=TUVcat.U(C{4}(ii),:)';
    BPU.V(:,ii-10)=TUVcat.V(C{4}(ii),:)';
    BPU.LonLat=TUVcat.LonLat(C{4}(ii));
end

BPU.TimeStamp=TUVcat.TimeStamp';
BPU.GridPoint=C{3}(indS:indE)';


save BPU.mat BPU

