close all
clear all

% f='http://colossus.dl.stevens-tech.edu:8080/thredds/dodsC/fmrc/NYBight/NYHOPS_Forecast_Collection_for_the_New_York_Bight_best.ncd';
f='http://colossus.dl.stevens-tech.edu/thredds/dodsC/latest/Complete_gcmplt_version4.nc';

% conf.HourPlot.axisLims= [-74-20/60 -73-48/60 40+24/60 40+51/60];% All of NYH
% conf.HourPlot.region='NYH';
% conf.HourPlot.axisLims= [-74-12/60 -74-6/60 40+38/60 40+40/60];% Newark Bay
% conf.HourPlot.region='Newark_Bay';
conf.HourPlot.axisLims= [-74-10/60 -73-50/60 40+00/60 40+20/60];% Newark Bay
conf.HourPlot.region='Shark_River';

conf.station.coords=[-74.0726 39.9325];
conf.station.name={'SPRK'};

lat=ncread(f,'lat');
lon=ncread(f,'lon');



lims=[-75.5 -72.5 38 41]; % zoom out all of NJ

m_proj('Mercator','lat',conf.HourPlot.axisLims(3:4),'long', conf.HourPlot.axisLims(1:2));
m_gshhs_f('patch',[1 .69412 0.39216]);
m_grid('box','fancy','tickdir','out');

hold on

m_plot(lon,lat,'k.')

m_plot(-74.009598,40.187470,'rs')

conf.HourPlot.script='plot_nyhops_grid.m';
conf.HourPlot.print_path='/Users/hroarty/Documents/MATLAB/HJR_Scripts/nc/';
conf.Plot.Filename=['NYHOPS_Grid_' conf.HourPlot.region '.png'];

timestamp(1,[conf.Plot.Filename ' / ' conf.HourPlot.script])
print(1,'-dpng','-r200',[conf.HourPlot.print_path  conf.Plot.Filename])