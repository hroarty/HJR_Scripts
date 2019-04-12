function [TUV]=convert_Nazzaro_NC_to_TUVgrid(file,var)



%% read in the nc variables
% tot.t=ncread(file,'time');
tot.lat = ncread(file,'lat');
tot.lon = ncread(file,'lon');
tot.u=ncread(file,var.u);
tot.v=ncread(file,var.v);

%% replace fill values -999 with NaNs
ind.u=tot.u==-999;
tot.u(ind.u)=NaN;
ind.v=tot.v==-999;
tot.v(ind.v)=NaN;

[LON,LAT]=meshgrid(tot.lon,tot.lat);

%% get the time units from the nc variable
% time.units=nc_attget(file,'time','units');
% time.str=time.units(end-18:end);
% time.matlab=datenum(time.str);

%% create the empty TUV stuctured array  added 20160216 HJR
TUV = TUVstruct( [length(LON(:)) 1], 1 );

%% Populate the TUV struct with the data from the .nc file

TUV.TimeStamp=var.t;
TUV.TimeZone='UTC';
TUV.LON=LON;
TUV.LAT=LAT;
TUV.U=tot.u';
TUV.V=tot.v';
TUV.LonLat(:,1)=LON(:);
TUV.LonLat(:,2)=LAT(:);

% TUV.U=TUV.U(:);
% TUV.V=TUV.V(:);


% if errorflag
%     TUV.ErrorEstimates.Type='OIuncert';
%     TUV.ErrorEstimates.Uerr=tot.u_err;
%     TUV.ErrorEstimates.Verr=tot.v_err;
%     TUV.ErrorEstimates.UerrUnits='cm2/s2';
%     TUV.ErrorEstimates.VerrUnits='cm2/s2';
% end

end
