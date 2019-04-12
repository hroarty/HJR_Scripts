url='http://colossus.dl.stevens-tech.edu:8080/thredds/dodsC/fmrc/NYBight/NYHOPS_Forecast_Collection_for_the_New_York_Bight_best.ncd';
%      http://colossus.dl.stevens-tech.edu:8080/thredds/dodsC/fmrc/NYBight/NYHOPS_Forecast_Collection_for_the_New_York_Bight_best.ncd

 %"hours since 2010-01-01T00:00:00Z"
reftime=datenum(2010,1,1);
t=ncread(url,'time');
t=(t/24)+reftime;
lat=ncread(url,'lat');
lon=ncread(url,'lon');
uvang=ncread(url,'ang');


[yy mm dd hh mi ss]=datevec(t);


tyy=2012;
tmm=10;

I=yy==tyy & mm==tmm;

tsub=ncread(url,'time',min(I),length(I));
tsub=(tsub/24)+reftime;




usub=ncread(url,'u',[1 1 1 min(I)],[Inf Inf 1 length(I)]);
vsub=ncread(url,'v',[1 1 1 min(I)],[Inf Inf 1 length(I)]);

musub=nanmean(squeeze(usub),3);
mvsub=nanmean(squeeze(vsub),3);

uveitheta = (musub+sqrt(-1)*mvsub).*exp(sqrt(-1)*uvang);
musub = real(uveitheta);
mvsub = imag(uveitheta);

figure(1)
EC_map(0)
hold on
quiver(lon,lat,musub,mvsub,'r')
hold off


