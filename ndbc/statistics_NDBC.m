close all
clear all

%% m script written on January 17, 2014 to make scatter plots of the wave height
%% comparisons between NDBC buoys

%% Buoy Info Cell Arrays
buoy.name={'44008','44097','44025','44065','44009','44014','44066',};

%% find all combinations of buoys
c = combnk(1:length(buoy.name),2);

%% determine the time that you want to analyze
dtime.span=datenum(2012,2,1):1/24:datenum(2012,6,1);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

digits=2;

conf.print_path='/Users/hroarty/COOL/01_CODAR/Waves/20140411_Wave_Correlation/';

for ii=1:length(c)

buoy01=load(['/Users/hroarty/data/NDBC/' buoy.name{c(ii,1)} '/ndbc_' buoy.name{c(ii,1)} '_2012.mat']);
buoy02=load(['/Users/hroarty/data/NDBC/' buoy.name{c(ii,2)} '/ndbc_' buoy.name{c(ii,2)} '_2012.mat']);



%% find the data that matches the time period you are interesred in
ind=find(buoy01.DATA(:,1)>=dtime.start & buoy01.DATA(:,1)<=dtime.end);
ind2=find(buoy02.DATA(:,1)>=dtime.start & buoy02.DATA(:,1)<=dtime.end);

sum(isnan(buoy01.DATA(ind,:)),1);
sum(isnan(buoy02.DATA(ind2,:)),1);

%% interpolate the data onto a common time axis
buoy01i=interp1(buoy01.DATA(:,1),buoy01.DATA,dtime.span);
buoy02i=interp1(buoy02.DATA(:,1),buoy02.DATA,dtime.span);

%% FIGURE 1 Time series plot of the two comparisons
% plot(buoy01.DATA(ind,1),buoy01.DATA(ind,5),'g','LineWidth',2);
% hold on
% plot(buoy02.DATA(ind2,1),buoy02.DATA(ind2,5),'k','LineWidth',2);
% 
% legend(buoy.name{c(ii,1)},buoy.name{c(ii,2)})
% datetick('x')
% box on
% grid on
% timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/statistics_NDBC.m')
% 
% print('-dpng','-r200',[conf.print_path 'WaveHeightTS_' buoy.name{c(ii,1)} '_' buoy.name{c(ii,2)}...
%     '_' dtime.startSTR '_'  dtime.endSTR '.png'])




%% FIGURE 2 Scatter plot of the two comparisons
figure(2)


%% find where the data is good
Good = isnan(buoy01i(:,5)) + isnan(buoy02i(:,5));
DataPts=length(Good)-sum(Good);

plot(buoy01i(Good==0,5),buoy02i(Good==0,5),'b*')

P=polyfit(buoy01i(Good==0,5),buoy02i(Good==0,5),1);

RHO = corr(buoy01i(Good==0,5),buoy02i(Good==0,5));

RMSD=sqrt(mean((buoy01i(Good==0,5)-buoy02i(Good==0,5)).^2));

X=0:1:6;
Y=polyval(P,X);

hold on

plot(X,Y,'k-')

xlabel(['NDBC Buoy ' buoy.name{c(ii,1)}])
ylabel(['NDBC Buoy ' buoy.name{c(ii,2)}])
title ('Significant Wave Height (m) Scatter Plot')
box on
grid on
axis equal

textbp( ['Correlation: ' num2str(RHO,digits)])
textbp( ['y = ' num2str(P(1),digits) ' x + ' num2str(P(2),digits) ])
%textbp( ['Data Points: ' num2str(DataPts,0) ])
textbp( ['Data Points: ' sprintf('%5.0f ', DataPts)])
textbp( ['RMSD: ' sprintf('%5.2f ', RMSD)])

timestamp(2,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/statistics_NDBC.m')

print('-dpng','-r200',[conf.print_path 'WaveHeightCorr_' buoy.name{c(ii,1)} '_' buoy.name{c(ii,2)}...
    '_' dtime.startSTR '_'  dtime.endSTR '.png'])

close all
clear Good P RHO X Y

end


