close all
clear all

%% Irene Time Period
% start_date=datenum(2011,8,23);
% end_date=datenum(2011,9,3);
% hurricane='Irene';

%% Sandy Time Period
start_date=datenum(2012,10,24);
end_date=datenum(2012,11,4);
hurricane='Sandy';


x_interval=1;
x_minor_interval=0.5;


codar_wave_data='/Users/hroarty/data/waves/SPRK';
fnformat='WVLM_SPRK_yyyy_mm_01_0000.wls';
[CODAR]=Codar_WVM7_readin_func(codar_wave_data,'wls');

%% read in the codar wave data
%[Wdata] = extract_waves_WVM7(start_date,end_date,codar_wave_data,fnformat);

ndbc_data='/Users/hroarty/data/NDBC/44009';
[Data44009]=NDBC_monthly_readin_func(ndbc_data,'txt');

ndbc_data='/Users/hroarty/data/NDBC/44025';
[Data44025]=NDBC_monthly_readin_func(ndbc_data,'txt');

ndbc_data='/Users/hroarty/data/NDBC/44065';
[Data44065]=NDBC_monthly_readin_func(ndbc_data,'txt');

ndbc_data='/Users/hroarty/data/NDBC/41001';
[Data41001]=NDBC_monthly_readin_func(ndbc_data,'txt');

%% determine which range cell to use for the codar data
%ind=find(RCLL==2);

%% plot the codar wave data
%h1=plot(time(ind),MWHT(ind),'b.-','Markersize',6);



%% plot the NDBC data
subplot(2,1,1)
hold on 
h2=plot(Data44009.time,Data44009.WVHT,'g-','LineWidth',2);
h3=plot(Data44025.time,Data44025.WVHT,'k-','LineWidth',2);
h4=plot(Data44065.time,Data44065.WVHT,'r-','LineWidth',2);
h44=plot(Data41001.time,Data41001.WVHT,'m-','LineWidth',2);

legend('44009','44025','44065','41001')
%legend('Wave Height','Average Wave Period')


ymin=0;
ymax=12;
y_interval=1;

date_format='mm/dd';

AX2=gca;
format_axis(AX2,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,ymax,y_interval)

xlabel('mm/dd')
ylabel('Wave Height (m)')
switch hurricane
    case 'Irene'
        title({'Data from NDBC buoy 44009 DELAWARE BAY 26 NM Southeast of Cape May, NJ';...
            'Hurricane Irene'})
    case 'Sandy'
          title({'Data from NDBC buoy 44009 DELAWARE BAY 26 NM Southeast of Cape May, NJ';...
            'Hurricane Sandy'})
end


subplot(2,1,2)

hold on
h5=plot(Data44009.time,Data44009.APD,'g-','LineWidth',2);
h6=plot(Data44025.time,Data44025.APD,'k-','LineWidth',2);
h7=plot(Data44065.time,Data44065.APD,'r-','LineWidth',2);
h8=plot(Data41001.time,Data41001.APD,'m-','LineWidth',2);

xlabel('mm/dd')
ylabel('Average Wave Period (s)')
AX3=gca;
format_axis(AX3,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,15,y_interval)


timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wave_comparison.m')

print(1,'-dpng','-r400',['Waves_multiple' hurricane '.png'])