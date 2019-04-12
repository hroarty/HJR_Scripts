%%

load arthur_track

storm='arthur';
timestart=datenum(2014,7,4);
timeend=datenum(2014,7,6);
timeint=1/24;
buoynames={'44008';'44065';'44025';'44009';'44014'};
dates=timestart:timeint:timeend;
lonbuoy=nan(length(buoynames),1);
latbuoy=nan(length(buoynames),1);
winddir=nan(length(buoynames),length(dates));
windspd=winddir;
waveheight=winddir;

for n=1:length(buoynames)
    file=['http://dods.ndbc.noaa.gov//thredds/dodsC/data/stdmet/' buoynames{n} '/' buoynames{n} 'h' datestr(dates(1),'yyyy') '.nc'];

    try
        lonbuoy(n)=ncread(file,'longitude');
        latbuoy(n)=ncread(file,'latitude');
        time=double(ncread(file,'time'))/60/60/24+datenum(1970,1,1);
        indt=find(time>=min(dates)-timeint/2&time<=max(dates)+timeint/2);
        if(~isempty(indt))
            time=double(ncread(file,'time',min(indt),length(indt)))/60/60/24+datenum(1970,1,1);
            dir=nan(size(time));
            spd=nan(size(time));
            wvh=nan(size(time));
            try
                dir=double(squeeze(ncread(file,'wind_dir',[1 1 min(indt)],[1 1 length(indt)])));
            catch
                disp(['no direction in ' file])
            end
            try
                spd=double(squeeze(ncread(file,'wind_spd',[1 1 min(indt)],[1 1 length(indt)])));
            catch
                disp(['no speed in ' file])
            end
            try
                wvh=double(squeeze(ncread(file,'wave_height',[1 1 min(indt)],[1 1 length(indt)])));
            catch
                disp(['no wave height in ' file])
            end

            for c=1:length(dates)
                indt=find(time>=dates(c)-timeint/2&time<dates(c)+timeint/2);
                winddir(n,c)=nanmean(dir(indt));
                windspd(n,c)=nanmean(spd(indt));
                waveheight(n,c)=nanmean(wvh(indt));
            end
        end
    catch
        disp([file ' DNE'])
    end
end
    

winddir=winddir+180;
test=abs([winddir windspd waveheight]);
test=nansum(test,2);
lonbuoy(test==0)=nan;
latbuoy(test==0)=nan;

disp('dataing done')


%%

xl=[-77 -67.5];
yl=[34 42.8];

load('/Users/hroarty/Documents/MATLAB/HJR_Scripts/Wind_Plots/parula-mod.mat')

bathy=load ('/Users/hroarty/data/bathymetry/eastcoast_4min.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines=[-40 -80 -200];

coast = load('/Users/hroarty/Documents/MATLAB/HJR_Scripts/Wind_Plots/MARACOOS_Complete_Coast.mat');
coast = coast.ncst;

load('/Users/hroarty/Documents/MATLAB/HJR_Scripts/Wind_Plots/neStateLines.mat');

lon(lon<min(xl)|lon>max(xl))=nan;
lat(lat<min(yl)|lat>max(yl))=nan;

hurricane=imread('/Users/hroarty/Documents/MATLAB/HJR_Scripts/Wind_Plots/hurricane.png');
ahurr=sum(hurricane,3);
ahurr(ahurr>0)=1;
ahurr(ahurr==0)=2;
ahurr=ahurr-1;

tropstorm=imread('/Users/hroarty/Documents/MATLAB/HJR_Scripts/Wind_Plots/tropicalstorm.png');
atropstorm=sum(tropstorm,3);
atropstorm(atropstorm>0)=1;
atropstorm(atropstorm==0)=2;
atropstorm=atropstorm-1;

tropdep=imread('/Users/hroarty/Documents/MATLAB/HJR_Scripts/Wind_Plots/tropicaldepression.png');
atropdep=sum(tropdep,3);
atropdep(atropdep>0)=1;
atropdep(atropdep==0)=2;
atropdep=atropdep-1;

ind=find(diff(tracktime)==0)+1;
tracktime(ind)=[];
tracklon(ind)=[];
tracklat(ind)=[];
tracktime_1h=min(tracktime):1/24:max(tracktime);
tracklon_1h=interp1(tracktime,tracklon,tracktime_1h);
tracklat_1h=interp1(tracktime,tracklat,tracktime_1h);



for n=1:length(dates)

[cs, h1] = contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
clabel(cs,h1,'fontsize',8);
set(h1,'Color', [96,96,96]./255, 'linewidth', .25)
hold on
cmap = colormap(cmap);
c = colorbar;
caxis([0 8])

wh=[];
ind=find(isnan(waveheight(:,n)));
wh=[wh,scatter(lonbuoy(ind),latbuoy(ind),150,'k','filled')];
ind=find(~isnan(waveheight(:,n)));
wh=[wh,scatter(lonbuoy(ind),latbuoy(ind),150,waveheight(ind,n),'filled','markeredgecolor','k')];


tanLand = [240,230,140]./255; %rgb value for tan

mapshow(coast(:,1), coast(:,2), 'DisplayType', 'polygon', 'facecolor', tanLand)
hold on

u=windspd(:,n).*sind(winddir(:,n));
v=windspd(:,n).*cosd(winddir(:,n));
w=quiver([lonbuoy;-70],[latbuoy;35],[u;10]/8,[v;0]/8,0,'k','linewidth',2);
text(-70,35,'10 m/s','verticalalignment','bottom');

indall=find(tracktime_1h<=dates(n));
indsmall=find(tracktime<dates(n));
indbig=find(tracktime==dates(n));

hourlytrack=plot(tracklon_1h(indall),tracklat_1h(indall),'k');
besttrack=[];
for k=1:length(indsmall)
    if(trackcat(indsmall(k))>0)
        besttrack=[besttrack,image([tracklon(indsmall(k))-.25 tracklon(indsmall(k))+.25],[tracklat(indsmall(k))-.25 tracklat(indsmall(k))+.25],hurricane,'alphadata',ahurr)];
        besttrack=[besttrack,text(tracklon(indsmall(k))+.02,tracklat(indsmall(k))+.01,int2str(trackcat(indsmall(k))),'color','w','fontweight','bold','horizontalalignment','center','verticalalignment','middle','fontname','futura','fontsize',8)];
    elseif(trackcat(indsmall(k))==-1)
        besttrack=[besttrack,image([tracklon(indsmall(k))-.25 tracklon(indsmall(k))+.25],[tracklat(indsmall(k))-.25 tracklat(indsmall(k))+.25],tropdep,'alphadata',atropdep)];
    elseif(trackcat(indsmall(k))==0)
        besttrack=[besttrack,image([tracklon(indsmall(k))-.25 tracklon(indsmall(k))+.25],[tracklat(indsmall(k))-.25 tracklat(indsmall(k))+.25],tropstorm,'alphadata',atropstorm)];
    end
end

if(~isempty(indbig))
    if(trackcat(indbig)>0)
        besttrack=[besttrack,image([tracklon(indbig)-.5 tracklon(indbig)+.5],[tracklat(indbig)-.5 tracklat(indbig)+.5],hurricane,'alphadata',ahurr)];
        besttrack=[besttrack,text(tracklon(indbig)+.02,tracklat(indbig)+.01,int2str(trackcat(indbig)),'color','w','fontweight','bold','horizontalalignment','center','verticalalignment','middle','fontname','futura','fontsize',14)];
    elseif(trackcat(indbig)==0)
        besttrack=[besttrack,image([tracklon(indbig)-.5 tracklon(indbig)+.5],[tracklat(indbig)-.5 tracklat(indbig)+.5],tropstorm,'alphadata',atropstorm)];
    elseif(trackcat(indbig)==-1)
        besttrack=[besttrack,image([tracklon(indbig)-.5 tracklon(indbig)+.5],[tracklat(indbig)-.5 tracklat(indbig)+.5],tropdep,'alphadata',atropdep)];
    end
end


xlim(xl);
ylim(yl);
box on

sl = plot(lon, lat, 'k.', 'markersize', 1);

grid on
xlabel('Longitude', 'fontsize', 12)
ylabel('Latitude', 'fontsize', 12)
project_mercator;
ylabel(c, 'Wave Height (m)', 'fontsize', 12);
title(['Measured Wind and Wave Height ' datestr(dates(n),'mmm dd yyyy HH:MM')])

set(gcf, 'paperposition', [0 0 11 8.5]);
set(gcf, 'paperorientation', 'landscape');

print(figure(1),['/Users/hroarty/COOL/01_CODAR/MARACOOS/20150206_Storm_Animations/' storm '_wind' datestr(dates(n),'yyyymmddTHHMM')],'-dpng','-r200')

close
end

disp('plotting done')
