
coastFileName = '/Users/roarty/Documents/GitHub/HJR_Scripts/data/coast_files/World_coast.mat';

% lims=[-180 180 -70 70]; % zoom out all of NJ
% plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch',[240,230,140]./255);

m_proj('miller','lat',[-77 77]);   
m_coast('patch',[240,230,140]./255,'edgecolor','none'); 
m_grid('box','fancy','linestyle','-','gridcolor','w','backcolor',[.2 .65 1]);

set(gcf,'color','w');   % Need to do this otherwise 'print' turns the lakes black

%% Plot the offshore wind lease area
% shape_dir       = '/Users/roarty/Downloads/gadm36_levels_shp/';
% S1 = m_shaperead([shape_dir 'gadm36_5']);

shape_dir       = '/Users/roarty/Downloads/TM_WORLD_BORDERS_SIMPL-0/';
S1 = m_shaperead([shape_dir 'TM_WORLD_BORDERS_SIMPL-0.3']);

for kk=1:length(S1.ncst)
    h1=m_line(S1.ncst{kk}(:,1),S1.ncst{kk}(:,2),'color','k');
end