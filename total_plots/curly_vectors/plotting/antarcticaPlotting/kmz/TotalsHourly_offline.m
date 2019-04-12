function [kmlname filename] = TotalsHourly(file, prefix)

this_file = load(file);
lat = this_file(:,2);
lon = this_file(:,1);
u = this_file(:,3);
v = this_file(:,4);
u_err = this_file(:,5);
v_err = this_file(:,6);
idxu= find(u==-999); u(idxu)= NaN; u_err(idxu) = NaN; lon(idxu) = NaN; lat(idxu) = NaN;
idxv= find(v==-999); v(idxv)= NaN; v_err(idxv) = NaN; lon(idxv) = NaN; lat(idxv) = NaN;
idxeu= find(u_err>0.9); u(idxeu)= NaN; v(idxeu) = NaN; lon(idxeu) = NaN; lat(idxeu) = NaN;
idxev= find(v_err>0.9); v(idxev)= NaN; u(idxev) = NaN; lon(idxev) = NaN; lat(idxev) = NaN;

cd('/www/home/michaesm/public_html/gearth/codar/colorquiver/kmzs/') 
% cd('/Volumes/ironman-web/gearth/codar/colorquiver/kmzs/')

% remove NaNs from processing
nans = isnan(u+v);
u(nans) = [];
v(nans) = [];
lat(nans) = [];
lon(nans) = [];

clear nans

vel_mag = sqrt(u.^2+v.^2);
ranges = [0:2:60]; % 31 ranges
ranges2 = [ranges 200]; % add extra range

cmaps = [];
ccmap = jet(length(ranges2-1));
ccmap = ccmap.^1.5;

for ii=1:length(ranges2)-1
      ind_vel = find(vel_mag>ranges2(ii) & vel_mag<=ranges2(ii+1));
      if ~isempty(ind_vel)
          for k = 1:length(ind_vel)
              cmaps(ind_vel(k),:) = ccmap(ii,:);
          end
      end
end

ind = find(file == '_');
mm = file(ind(3)+1:ind(4)-1);
dd = file(ind(4)+1:ind(5)-1);
yy = file(ind(2)+1:ind(3)-1);
hh = file(ind(5)+1:end);

kmlname = [yy '-' mm '-' dd '-' hh ' GMT']; 

filename = [prefix '_Hourly_Currents.kmz'];

if strcmpi(prefix, 'BPU')
    KMLquiver(lat, lon, v, u,...
    'arrowStyle', 'line',...
    'arrowScale', 75,...
    'lineWidth', 1.5,...
    'fileName', filename,...
    'description', kmlname,...
    'lineColor', cmaps)
elseif strcmpi(prefix, 'MARASR')
    KMLquiver(lat, lon, v, u,...
    'arrowStyle', 'line',...
    'arrowScale', 25,...
    'lineWidth', 1.5,...
    'fileName', filename,...
    'description', kmlname,...
    'lineColor', cmaps)
elseif strcmpi(prefix, 'PLDP')
    KMLquiver(lat, lon, v, u,...
    'arrowStyle', 'line',...
    'arrowScale', 25,...
    'lineWidth', 1.5,...
    'fileName', filename,...
    'description', kmlname,...
    'lineColor', cmaps)
else
    KMLquiver(lat, lon, v, u,...
    'arrowStyle', 'line',...
    'arrowScale', 150,...
    'lineWidth', 1.5,...
    'fileName', filename,...
    'description', kmlname,...
    'lineColor', cmaps)
end
