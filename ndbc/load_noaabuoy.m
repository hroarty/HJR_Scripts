function [tme,varargout]=load_noaabuoy(fle,varargin)
%
% Function to load "Standard Met Data" from a file of NDBC buoy data.
% 
% [TME,SWH,WSPD,WDIR]=LOAD_NOAABUOY(FLE) will return time (in matlab 
% datenum format), significant wave height (SWH) in meters, wind speed 
% (WSPD) (m/s) and wind direction (WDIR) (from) (WDIR) from the file of 
% NDBC buoy data (FLE).
%
% [TME,ALLDAT]=LOAD_NOAABUOY(FLE) will return a structure (ALLDAT)
% containing all avaiable data in the file as well as the time, (TME).
%
% [TME,ALLDAT]=LOAD_NOAABUOY(FLE,[STME ETME]) will extract the data
% only within the time interval specified by the starting and ending times
% [STME ETME]. These times must be provided in matlab datenum format.
%
% Data (swh and dwp) flagged as bad with values of 99.0 or 999.0 are set
% to NaN's.
% 
% INPUT:
%  The "Standard Met Data" NDBC buoy data file is an ascii flat file in
%  which the columns of each record contains the following data:
%   Year, Month, Day, Hour, Wind Direction, Wind Speed, Gust Speed, Wave
%   Height, Dominant Wave Period, Average Wave Period, Mean Wave Direction,
%   Barometric Pressure, Air Temperature, Water Temperature, Dew Point,
%   Visibility, and Tide.
%
%  OUTPUT:
%  The structure ALLDAT contains the following fields:
%  swh - significant wave height (m)
%  dwp - dominant wave period (sec)
%  wdr - wind direction (deg. from)
%  wsp - wind speed (m/s)
%  gst - gust speed (m/s)
%  awp - average wave period (sec)
%  mwd - mean wave direction (deg from)
%  bar - barometric pressure (mbar)
%  air - air temperature (deg C)
%  wat - water temperature (deg C) 
%
%   Version: 1.1 - 1/2006,                Paul Jessen, NPS
%
%

%
% Program: load_noaa_buoy
%
% Written by: Paul Jessen
%             Department of Oceanography
%             Naval Postgraduate School
%             Monterey, CA 93943
%
% First Version: 1.0 - 1/2006
%
% Latest Version: 1.1 - 1.2006
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modifications:
%
%  Version: 1.1 - Function now returns all variables except time in the
%                 structure 'alldat'.
%               - Function now returns individual variables: 'swh', 'wspd,'
%                 and wdir rather than 'dwp' if 'alldat' not used.
%                 1/26/2006 - pfj)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

%
% check for right number of input and output arguments
%
if nargin < 1,
  errordlg('Must supply file name!');
  return
end
switch nargout
  case 1  
    errordlg('Must have at least two output arguments!');
    return
  case 2
    out_opt=1
  case 4
    out_opt=0;
  otherwise
    errordlg('Wrong number of output arguments!');
    return
end
%
% check time range
%
in_opt=0;
if nargin > 1
  extme=varargin{1};
  stme=extme(1);
  etme=extme(2);
  in_opt=1;
%  keyboard
end
%
% load data
%
data=load(fle);
%
% decode time
%
yr=data(:,1);
mon=data(:,2);
day=data(:,3);
hr=data(:,4);
mn=data(:,5);
tme=datenum(yr,mon,day,hr,mn,0);
%
% determine whether to extract all or just some of the data
% based on whether or not a time span was provided.
%
if in_opt == 1,
  ia=find(tme>=stme & tme <= etme);
  if isempty(ia) == 1,
    warndlg('No data found within specified time interval!');
    tme=[];
    swh=[];
    wspd=[];
    wdir=[];
    alldat=[];
    return
  end
  ndat=data(ia,:);
  tme=tme(ia);
else
  ndat=data;
end
%
% extract standard wave variables from data. Do some qc
%
swh=ndat(:,8);
ia=find(swh>90);
swh(ia)=NaN;
wspd=ndat(:,6);
ia=find(wspd>98);
wspd(ia)=NaN;
wdir=ndat(:,5);
ia=find(wdir>360);
wdir(ia)=NaN;
%
% if an additional variable was supplied create a structure
% with the rest of the data
%
if out_opt == 1,
  alldat=struct('swh',ndat(:,8),'dwp',ndat(:,9),'wsp',ndat(:,6),...
    'wdr',ndat(:,5),'gst',ndat(:,7),'awp',ndat(:,10),'mwd',ndat(:,11),...
    'bar',ndat(:,12),'air',ndat(:,13),'wat',ndat(:,14));
  %
  % do some qc on swh, dwp, and wind speed
  %
  ia=find(alldat.swh>90);
  alldat.swh(ia)=NaN;
  ia=find(alldat.dwp>90);
  alldat.dwp(ia)=NaN;
  ia=find(alldat.wsp>90);
  alldat.wsp(ia)=NaN;
  ia=find(alldat.wdr>360);
  alldat.wdr(ia)=NaN;
  varargout{1}=alldat;
else
  varargout{1}=swh;
  varargout{2}=wspd;
  varargout{3}=wdir;
end