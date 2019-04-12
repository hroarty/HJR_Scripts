function [kmlname filename] = TotalsAverage(dtime, input_dir, prefix)

for i = 1:length(dtime);
    files{i} = [input_dir 'OI_' prefix '_' datestr(dtime(i), 'yyyy_mm_dd_HH00')];
end

medianTime = datestr(median(dtime));

clear i

tmp = load(files{1});
[r,c] = size(tmp);
uv = nan(r,c,length(files));

for x = 1:length(files)
    uv(:,:,x) = load(files{x});
end

uv = uv(:, [1:6], :);
uvavg = nanmean(uv,3);
uv(uv == -999) = nan;
umask = sum(isnan(uv(:,3,:)),3);
vmask = sum(isnan(uv(:,4,:)),3);
uvavg(umask < 12,3) = nan;
uvavg(vmask < 12,4) = nan;
uvavg = nanmean(uv,3);


iU = find(uvavg(:,5)>0.9);
iV = find(uvavg(:,6)>0.9);

uvavg(iU,[3:6])=nan;
uvavg(iV,[3:6])=nan;

cd('/www/home/michaesm/public_html/gearth/codar/colorquiver/kmzs/') 
% cd('/Volumes/ironman-web/gearth/codar/colorquiver/kmzs/')

% remove NaNs from processing
% nans = isnan(mean_u+mean_v);
% mean_u(nans) = [];
% mean_v(nans) = [];
% lat(nans) = [];
% lon(nans) = [];

nans = isnan(uvavg(:,3)+uvavg(:,4));
uvavg(nans,:) = [];

clear nans
vel_mag = sqrt(uvavg(:,3).^2+uvavg(:,4).^2);

% vel_mag(
% vel_mag = sqrt(mean_u.^2+mean_v.^2);

ranges = [0:2:60];
ranges2 = [ranges 200];

[m n] = size(uvavg);

cmaps = nan(m,3);
ccmap = jet(length(ranges2-1));
ccmap = ccmap.^1.5;

for ii=1:length(ranges2)-1
      ind_vel = find(vel_mag>ranges2(ii) & vel_mag<=ranges2(ii+1));
%       if ~isempty(ind_vel)
     if length(ind_vel)>0
          for k = 1:length(ind_vel)
              cmaps(ind_vel(k),:) = ccmap(ii,:);
          end
      end
end

kmlname = [medianTime ' GMT (+/- 12 hours)'];

filename = [prefix '_25Hr_Currents.kmz'];

if strcmpi(prefix, 'BPU')
    KMLquiver(uvavg(:,2), uvavg(:,1), uvavg(:,4), uvavg(:,3),...
    'arrowStyle', 'line',...
    'arrowScale', 100,...
    'lineWidth', 1.5,...
    'fileName', filename,...
    'description', kmlname,...
    'lineColor', cmaps)
elseif strcmpi(prefix, 'MARASR')
    KMLquiver(uvavg(:,2), uvavg(:,1), uvavg(:,4), uvavg(:,3),...
    'arrowStyle', 'line',...
    'arrowScale', 75,...
    'lineWidth', 1.5,...
    'fileName', filename,...
    'description', kmlname,...
    'lineColor', cmaps)
elseif strcmpi(prefix, 'PLDP')
    KMLquiver(uvavg(:,2), uvavg(:,1), uvavg(:,4), uvavg(:,3),...
    'arrowStyle', 'line',...
    'arrowScale', 75,...
    'lineWidth', 1.5',...
    'fileName', filename,...
    'description', kmlname,...
    'lineColor',cmaps)
else
    KMLquiver(uvavg(:,2), uvavg(:,1), uvavg(:,4), uvavg(:,3),...
    'arrowStyle', 'line',...
    'arrowScale', 150,...
    'lineWidth', 1.5,...
    'fileName', filename,...
    'description', kmlname,...
    'lineColor', cmaps)
end
