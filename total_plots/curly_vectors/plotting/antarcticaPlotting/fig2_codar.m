% Project Converge Figure 2 - Codar Plots
% Written by Sage 8/5/14
%
% Codar Area [-64-45/60 -63.5][-65-1/6 -64-4/6]
%------------------------------------------------
close all; clear all;
addpath /Users/sage/Documents/MATLAB/m_map/

type = 1; % 1=vectors, 2=vec w/speed, 3=vec w/divergence, 4=streamlines

% Load colormaps
colorbrewer;

titles{4} = 'January 12, 2013 2:00 AM';
titles{7} = 'January 12, 2013 6:00 AM';
titles{8} = 'January 12, 2013 10:00 AM';
titles{9} = 'January 12, 2013 2:00 PM';
titles{10} = 'January 12, 2013 6:00 PM';
titles{11} = 'January 12, 2013 10:00 PM';

%------------------------------------------------
% Setup basemap
m_proj('Transverse Mercator','longitudes',[-64.42 -63.64], 'latitudes',[-65 -64.6]);
xticks = -64.4:.05:-63.65;
yticks = -65:.05:-64.6;
for k=1:length(xticks)
  if rem(k-3,4)==0
    xticklabels(k,:) = sprintf(' %2.2f %cW',abs(xticks(k)),char(176));
  end
end
for k=1:length(yticks)
  if rem(k-1,2)==0
    yticklabels(k,:) = sprintf(' %2.2f %cS',abs(yticks(k)),char(176));
  end
end
%m_grid('box','fancy','tickstyle','dd','fontsize',11,'YaxisLocation','right')
m_grid('box','on','fontsize',11,'YaxisLocation','left','tickstyle','dd','tickdir','out',...
  'xtick',xticks,'ytick',yticks,'xticklabels',xticklabels,'yticklabels',yticklabels,'linestyle','none');
hold on;

%Coastline
m_usercoast('coast_bas.mat','patch',[1 1 1]*.78,'edgecolor',[1 1 1]*.48);

% North Arrow
nah = narrow(-63.7,-64.625,.15);
nah = m_text(-63.7,-64.629,'North','HorizontalAlignment','center');

% Palmer Station
m_plot(-64.053056,-64.774167,'.','markersize',28,'color',[1 102 94]/255);
m_text(-64.053056,-64.766,'Palmer Station');

%------------------------------------------------
% Load Codar Datafiles
files = dir('data_codar/TUV*.mat');
for jj=[4,7,8,9,10,11] %1:length(files)
  filename = files(jj).name;
  data = load(['data_codar/' filename]);
  
  % Iterate over each timestamp
  %for k=1:length(data.TUVorig.TimeStamp)
  k=1;
    d.Lon = data.TUVorig.LonLat(:,1);
    d.Lat = data.TUVorig.LonLat(:,2);
    d.U = data.TUVorig.U(:,k);
    d.V = data.TUVorig.V(:,k);
    d.Mag = sqrt( d.U.^2 + d.V.^2 );
    j = strmatch( 'GDOP', { data.TUVorig.ErrorEstimates.Type }, 'exact' );
    d.Gdop = data.TUVorig.ErrorEstimates(j).TotalErrors(:,k);
    
    % Find good data
    ind_mm = find(d.Mag<50);
    %ind_gdopu = find(data.TUVorig.ErrorEstimates(j).Uerr(:,k)<=.8);
    %ind_gdopv = find(data.TUVorig.ErrorEstimates(j).Verr(:,k)<=.8);
    %ind_gdop = intersect(ind_gdopu,ind_gdopv);
    ind_gdop = find(d.Gdop<=.8);
    ind=intersect(ind_mm,ind_gdop);
    
    % Remove bad data for file 4
    if (jj==4)
      ind4 = find(d.Lat<-64.7);
      ind=intersect(ind,ind4);
    end
    
    if (length(ind)>0)  
      dd.Lon = d.Lon(ind);
      dd.Lat = d.Lat(ind);
      dd.U = d.U(ind);
      dd.V = d.V(ind);
      dd.Mag = d.Mag(ind);
      dd.Gdop = d.Gdop(ind);

      if (type>=2)
        % Grid Velocity Data
        [dg.Lon,dg.Lat]=meshgrid(min(dd.Lon):.01:max(dd.Lon),min(dd.Lat):.005:max(dd.Lat));
        dg.U = griddata(dd.Lon,dd.Lat,dd.U,dg.Lon,dg.Lat);
        dg.V = griddata(dd.Lon,dd.Lat,dd.V,dg.Lon,dg.Lat);
        dg.Mag = sqrt(dg.U.^2+dg.V.^2);
        dg.Dist = dg.Lon*NaN;

        % Remove poorly interpolated data
        [nr,nc]=size(dg.Lon);
        for inr=1:nr
          for inc=1:nc
            dcheck=sort(deg2km(distance(dg.Lat(inr,inc),dg.Lon(inr,inc),dd.Lat,dd.Lon)));
            dg.Dist(inr,inc)=dcheck(1);
            if (dcheck(1)>1.5)
              dg.U(inr,inc)=NaN;
              dg.V(inr,inc)=NaN;
              dg.Mag(inr,inc)=NaN;
            end
          end
        end
      end

      if (type>=3)
        % Calculate Divergence
        dm=deg2km(distance(dg.Lat(1,1),dg.Lon(1,1),dg.Lat,dg.Lon));
        dg.Div = -divergence(dm,dm,dg.U,dg.V);
      end
      
      if (type==1)
        mvh1(1) = m_vec(100,dd.Lon,dd.Lat,dd.U,dd.V,'k','edgeclip','on'); %Replace 'k' with dd.Mag to plot colored arrows
        % Scale Vector
          mvh1(2) = m_vec(100,-63.72,-64.67,25,0,'k','edgeclip','on'); 
          mvh1(3) = m_text(-63.7,-64.677,'25 cm/s','HorizontalAlignment','center');
        caxis([0 50]);
        colormap(RdYlBu10);
        % GDOP Plots
        %[x,y]=m_ll2xy(lon,lat);
        %mvh2 = scatter3(x,y,x*0,88,gdop,'marker','.'); view([ 0 90]);
        %caxis([0 1.5]);
        %cbh = colorbar('EastOutside');
        %ylabel(cbh,'Current Velocity (cm/s)','fontsize',10);
        title( sprintf('Surface Currents: %s',titles{jj}) ,'fontsize',14,'interpreter','none');
      elseif (type==2)
        [CS,mvh2] = m_contourf(dg.Lon,dg.Lat,dg.Mag,0:5:50,'edgecolor','none'); 
        mvh1 = m_vec(100,dd.Lon,dd.Lat,dd.U,dd.V,'w','edgeclip','on');
        colormap(RdYlBu10);
        caxis([0 50]);
        cbh = colorbar('SouthOutside');
        xlabel(cbh,'Current Velocity (cm/s)','fontsize',10)
      elseif (type==3)
        [CS,mvh2] = m_contourf(dg.Lon,dg.Lat,dg.Div,'linecolor','none'); 
        mvh1 = m_vec(100,dd.Lon,dd.Lat,dd.U,dd.V,'k','edgeclip','on');
        % Scale Vector
          mvh1(2) = m_vec(100,-63.72,-64.67,25,0,'k','edgeclip','on'); 
          mvh1(3) = m_text(-63.7,-64.677,'25 cm/s','HorizontalAlignment','center');
        colormap(flipud(PuOr7));
        caxis([-17 17]);
        cbh = colorbar('EastOutside');
        ylabel(cbh,[{'Divergence (purple) to Convergence (orange)'},{'cm/s per km'}],'fontsize',10)
        title( sprintf('Surface Currents & Convergence Zones: %s',titles{jj}) ,'fontsize',14,'interpreter','none');
      elseif (type==4)
        [CS,mvh2] = m_contourf(dg.Lon,dg.Lat,dg.Mag,0:5:50,'edgecolor','none'); 
        colormap(RdYlBu10);
        caxis([0 50]);
        cbh = colorbar('SouthOutside');
        xlabel(cbh,'Current Velocity (cm/s)','fontsize',10)
        
        (nr+nc)*2
        rx = random('Uniform',min(dd.Lon),max(dd.Lon),(nr+nc)*2,1);
        ry = random('Uniform',min(dd.Lat),max(dd.Lat),(nr+nc)*2,1);
        %         for kk=1:length(rx)
        %           dcheck=sort(deg2km(distance(ry(kk),rx(kk),dd.Lat,dd.Lon)));
        %           if (dcheck(1)>.5)
        %             rx(kk)=NaN;
        %             ry(kk)=NaN;
        %           end
        %         end
        xy = stream2(dg.Lon,dg.Lat,dg.U,dg.V,rx,ry,[.1 75]);
        %rx = round(random('Uniform',1,nr,nr,1));
        %ry = round(random('uniform',1,nc,nc,1));
        %xy = stream2(dg.Lon,dg.Lat,dg.U,dg.V,dg.Lon(rx,ry),dg.Lat(rx,ry),[.1 75]);
        for kk=1:length(xy)
          if ( length(xy{kk})>1 && sum(~isnan(xy{kk}(:,1)))>30 )
            mvh1(kk) = m_line(xy{kk}(:,1),xy{kk}(:,2),'color','k','linewidth',1);
          end
        end
        
        dv = datevec(data.TUVorig.TimeStamp(k));
        title( sprintf('%s %d/%d/%d %2d:00',filename,dv(1),dv(2),dv(3),dv(4)) ,'fontsize',14,'interpreter','none');
        set(gcf,'PaperPosition',[0.25 0.5 8 8],'renderer','opengl','color','w')
        print(gcf,'-dpng','-r300', sprintf('images/fig2_codar_%d_%d_sp.png',jj,type) );

        delete(mvh2);
        [CS,mvh2] = m_contourf(dg.Lon,dg.Lat,dg.Div,'linecolor','none'); 
        colormap(RdBu);
        caxis([-.03 .03]);
        cbh = colorbar('SouthOutside');
        xlabel(cbh,'Divergence (cm/s/m)','fontsize',10)
        
      end
      
      % Finish and Print
      dv = datevec(data.TUVorig.TimeStamp(k));
      %title( sprintf('%s %d/%d/%d %2d:00',filename,dv(1),dv(2),dv(3),dv(4)) ,'fontsize',14,'interpreter','none');      
      set(gcf,'PaperPosition',[0.25 0.5 8 8],'renderer','opengl','color','w')
      print(gcf,'-dpng','-r300', sprintf('images/fig2_codar_%d_%d.png',jj,type) );
      
      % Remove Data for next go round
      if (type==2 || type==3)
        delete(mvh1);
      end
      if (type==1 || type==4)
        for mvi=1:length(mvh1)
          try
            delete(mvh1(mvi))
          catch err
          end
        end
      end
      if (type==2 || type==3 || type==4)
        delete(mvh2)
      end

      
    end %if
  %end %k
end %jj
