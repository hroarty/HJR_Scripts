% Project Converge Figure 0 - Basemap
% Written by Sage 8/12/14
%------------------------------------------------
close all; clear all;
addpath /Users/sage/Documents/MATLAB/m_map/
addpath /Users/sage/Documents/MATLAB/Bedmap2_Toolbox_v2-2/Bedmap2_Toolbox_v2.30/

% Older Range [-64.42 -63.64][-64.94 -64.61]

% Setup basemap
m_proj('Transverse Mercator','longitudes',[-64.42 -63.64], 'latitudes',[-65 -64.6]);
xticks = -64.4:.05:-63.65;
yticks = -65:.05:-64.6;
for k=1:length(xticks)
  if rem(k-3,4)==0
    xticklabels(k,:) = sprintf(' %2.1f %cW',abs(xticks(k)),char(176));
  end
end
for k=1:length(yticks)
  if rem(k-1,2)==0
    yticklabels(k,:) = sprintf(' %2.1f %cS',abs(yticks(k)),char(176));
  end
end
%m_grid('box','fancy','tickstyle','dd','fontsize',11,'YaxisLocation','right')
m_grid('box','on','fontsize',11,'YaxisLocation','left','tickstyle','dd','tickdir','out',...
  'xtick',xticks,'ytick',yticks,'xticklabels',xticklabels,'yticklabels',yticklabels,'linestyle','none');
hold on;

% Bedmap Bathymetry
% [loni,lati]=meshgrid(-64.42:.001:-63.64,-65:.001:-64.6);
% vari = bedmap2_interp(lati,loni,'bedw');
% vari(vari>0)=NaN;
% hold on;
% [C,h] = m_contour(loni,lati,vari,-2000:100:-100,'edgecolor',[1 1 1]*.58);
% set(h,'ShowText','on')
% uistack(h,'top')

% GeoMapApp Bathymetry
bathy = load('palmerdeep_geomapapp.xyz');
lon = -( 360-unique(bathy(:,1)) );
lat = unique(bathy(:,2));
vari = reshape(bathy(:,3),length(lon),length(lat));
vari = flipud(vari');
vari(vari>0)=NaN;

% Remove bathymetry points within the coastline
% coast = load('coast_gshhs.mat');
% [LON,LAT]=meshgrid(lon,lat);
% IN = inpolygon(LON,LAT,coast.ncst(:,1),coast.ncst(:,2));
% vari(IN)=NaN;

% IN=vari*NaN;
% [nr,nc]=size(vari);
% for ir = 1:nr
%   for ic = 1:nc
%     IN(ir,ic) = inpolygon(lon(ir),lat(ic),coast.ncst(:,1),coast.ncst(:,2));
%     disp([num2str(ir) '-' num2str(ic)]);
%   end
% end

%Plot the bathymetry
hold on;
[C,h] = m_contour(lon,lat,vari,[-2000:200:-100],'edgecolor',[1 1 1]*.58);
%set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2)
th = clabel(C,h);
set(th,'color',[1 1 1]*.58,'fontsize',8);

%Coastline
%m_gshhs_h('patch',[1 1 1]*.78,'edgecolor',[1 1 1]*.48);
m_usercoast('coast_bas.mat','patch',[1 1 1]*.78,'edgecolor',[1 1 1]*.48);

% North Arrow
nah = narrow(-63.7,-64.625,.15);
nah = m_text(-63.7,-64.629,'North','HorizontalAlignment','center');

% Palmer Station
m_plot(-64.053056,-64.774167,'.','markersize',28,'color',[1 102 94]/255);
m_text(-64.053056,-64.766,'Palmer Station');

% Save Figure
title( 'Palmer Station Antarctica','fontsize',14,'interpreter','none');
set(gcf,'PaperPosition',[0.25 0.5 8 8],'renderer','zbuffer')
print(gcf,'-dpng','-r300', 'images/fig0_basemap_geomap.png');



%------------------------------------------------
% Script to convert high-res coastline shapefile to gshhs format
% British Antarctic Survey coastline data from http://add.scar.org
if (0)  
  a=shaperead('coastline/cst00_polygon'); 
  mstruct = defaultm('stereo');
  mstruct.origin = [-90 0 0];
  mstruct.mapparallels = -71; %Not sure if this does anything
  mstruct.nparallels = 1; %Ibid
  mstruct.geoid = [6378137.0 .11]; %.11 is a fudge factor for the eccintricity 
  mstruct = defaultm(mstruct);
  ncst=[NaN NaN]; %Must start with a NaN for m_usercoast to work
  for jj=1:length(a)
    [a(jj).Lat,a(jj).Lon] = minvtran(mstruct,a(jj).X,a(jj).Y);
    %m_patch(a(jj).Lon(1:end-1),a(jj).Lat(1:end-1),'r')%,[1/.78 1 1]*.78)%,'edgecolor',[1/.48 1 1]*.48);
    %hold on;
    ncst = [ncst; a(jj).Lon',a(jj).Lat'+1];
  end
  
  k=[find(isnan(ncst(:,1)))];
  Area=zeros(length(k)-1,1);
  for i=1:length(k)-1,
    x=ncst([k(i)+1:(k(i+1)-1) k(i)+1],1);
    y=ncst([k(i)+1:(k(i+1)-1) k(i)+1],2);
    nl=length(x);
    Area(i)=sum( diff(x).*(y(1:nl-1)+y(2:nl))/2 );
  end;

  save coast_bas ncst k Area
  
  m_proj('Transverse Mercator','longitudes',[-64-45/60 -63.5], 'latitudes',[-65-1/6 -64-4/6]); % Full penninsula [-65 -55][-66 -62]
  m_usercoast('coast_bas.mat','patch',[1/.78 1 1]*.78,'edgecolor',[1 1 1]*.48);
  
  % Create equivalent coast from GSHHS
  m_gshhs('h','save','coast_gshhs') %Save gshhs data for the same region
  m_usercoast('coast_gshhs.mat','line','color',[1 1 1]*.48,'linewidth',2);

end %if
