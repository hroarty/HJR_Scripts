function [Data]=NDBC_monthly_readin_func(datapath,file_extension,dyr)
% This program was written by Hugh Roarty to read in NDBC data.  This
% program reads in monthly text data from the NDBC web site.  The function outputs a  
% structured array with the following fields.
%
% MWID  mean wind direction
% WSPD  wind speed
% WGST  wind gust
% WVHT  wave height
% DPD   dominant period
% APD   average period
% MWAD  mean wave direction
% PRES  atmospheric pressure
% ATMP  air temperature
% WTMP  water temperature
% time  matlab time
%
% All fill values are replaced with NaNs.
% Leave off the slash at the end of the datapath


%clear 

% Add path of data because not n same directory as script
addpath(datapath)

% create a variable filename to create a structured array containing all the
% STAT files
filename=dir([datapath '/*.' file_extension]);

% create a variable num_files the length of the structured array filename
num_files=length(filename);

% define variable start_date so i can write to it in the loop

NDBC_DATA=[];

% variables     
%               sdl     start date line
%               sd      start date
%               msd     matlab start date
% 

delimiterIn = ' ';
headerlinesIn = 1;

for ii=1:num_files
    
    yr=str2num(filename(ii).name(7:10));
    
    if yr<dyr
        temp=importdata(filename(ii).name, delimiterIn, headerlinesIn);
    else
        temp=importdata(filename(ii).name, delimiterIn, 2);
    end
    
    STAT=temp.data;
    STAT(:,19)=datenum(STAT(:,1),STAT(:,2),STAT(:,3),STAT(:,4),STAT(:,5),zeros(length(STAT),1));
    %% sort the data by time
   STAT=sortrows(STAT,19);
    
    NDBC_DATA=[NDBC_DATA;STAT];
    clear STAT temp
end

Data.MWID=NDBC_DATA(:,6);
Data.WSPD=NDBC_DATA(:,7);
Data.WGST=NDBC_DATA(:,8);
Data.WVHT=NDBC_DATA(:,9); 
Data.DPD=NDBC_DATA(:,10);
Data.APD=NDBC_DATA(:,11);
Data.MWAD=NDBC_DATA(:,12);
Data.PRES=NDBC_DATA(:,13);
Data.ATMP=NDBC_DATA(:,14);
Data.WTMP=NDBC_DATA(:,15);

Data.time=NDBC_DATA(:,19);

%% Identify the fill values and replace with NaNs
ind_MWID= Data.MWID==999; %% column 
Data.MWID(ind_MWID)=NaN;

ind_WSPD= Data.WSPD==99;
Data.WSPD(ind_WSPD)=NaN;

ind_WGST= Data.WGST==99;
Data.WGST(ind_WGST)=NaN;

ind_WVHT= Data.WVHT==99;
Data.WVHT(ind_WVHT)=NaN;

ind_DPD= Data.DPD==99;
Data.DPD(ind_DPD)=NaN;

ind_APD= Data.APD==99;
Data.APD(ind_APD)=NaN;

ind_MWAD= Data.MWAD==999;
Data.MWAD(ind_MWAD)=NaN;

ind_PRES= Data.PRES==9999;
Data.PRES(ind_PRES)=NaN;

ind_ATMP= Data.ATMP==999;
Data.ATMP(ind_ATMP)=NaN;

ind_WTMP= Data.WTMP==999;
Data.WTMP(ind_WTMP)=NaN;






















