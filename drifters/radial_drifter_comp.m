
clear all
close all

drifterid='43340';

sites={'BRNT','LOVE','SPRK'};
types={'RDLm','RDLi'};
subdir=true;
processopt=false;
imageopt=true;
cut_dist=true;
addlab='/qartod';

rdlDir='/Volumes/boardwalk/codaradm/data/radials/';
rext='.ruv';
if(strcmp(addlab,'/qartod'))
    rdlDir='/Volumes/boardwalk/hroarty/data/realtime/radials/';
    rext='.qcv';
end
if(strcmp(addlab,'/teresa'))
    rdlDir='/Users/palamara/Documents/codar_teststuff/spatial_filter/Archive/';
    subdir=false;
end

addpath(genpath('/Volumes/boardwalk/codaradm/HFR_Progs-2_1_3beta/matlab/'))

adjustdist={'VELU','VELV','ESPC','ETMP',...
    'RNGE','BEAR','VELO','HEAD','SPRC',...
    'GRNG','LRNG','SPKE','TRND','STCK','GRAD',...
    'U','V','VeloDrift'};

savetypes={'LOND','LATD','VELU','VELV','VFLG','ESPC','ETMP',...
    'RNGE','BEAR','VELO','HEAD','SPRC',...
    'GRNG','LRNG','SPKE','TRND','STCK','GRAD'};

LR_sites={'AMAG','ASSA','BLCK','BRIG','CEDR','CORE','CStM','DUCK','FARO',...
    'GMNB','GrnI','HATY','HEMP','HOOK','LISL','LOVE','MABO','MRCH','MVCO',...
    'NANT','NAUS','PYFC','WILD'};

MR_sites={'BRAD','BRMR','BRNT','CDDO','FURA','RATH','SEAB','SPRK','WOOD'};

SR_sites={'BISL','CMPT','CPHN','GCAP','HLPN','MISQ','MNTK','OLDB','PORT',...
    'SILD','STLI','SUNS','VIEW'};

for site_n=1:length(sites)
    for type_n=1:length(types)
        site=sites{site_n};
        type=types{type_n};
        
        if(~exist(['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid],'dir'))
            mkdir(['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid]);
        end
        if(~exist(['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site],'dir'))
            mkdir(['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site]);
        end
        
        if(processopt)
            %rdl=loadRDLFile('/Users/palamara/Documents/codar_teststuff/RDLm_WOOD_2016_04_26_0600.ruv',true);
            load(['/Users/palamara/Documents/codar_teststuff/drifters/drifters/USCG_' drifterid '_2016_05_10.mat'])
            
            if(strcmp(drifterid,'43372'))
                time(time>datenum(2016,5,31))=nan;
            end
            
            for n=1:length(savetypes)
                eval([savetypes{n} '=nan(size(time));']);
            end
            
            DIST=nan(size(time));
            VeloDrift=nan(size(time));
            
            
            for n=1:length(time)
                t=time(n);
                if(isnan(t))
                    continue;
                end
                if(subdir)
                    rdl=loadRDLFile([rdlDir,site,'/',datestr(t,'yyyy_mm/'),...
                        type '_' site '_' datestr(t,'yyyy_mm_dd_HH00') rext],true);
                else
                    rdl=loadRDLFile([rdlDir,site,'/',...
                        type '_' site '_' datestr(t,'yyyy_mm_dd_HH00') rext],true);
                end
                
                if(~isempty(rdl.LonLat))
                    site_loc=rdl.SiteOrigin;
                    % find index of table-start row in header
                    tablestart_ind=find(strncmp('%TableStart',rdl.OtherMetadata.Header,length('%TableStart')));
                    tablestart_ind=tablestart_ind(1);
                    
                    % divide into pre-data and post-data subsets of header
                    subset1=rdl.OtherMetadata.Header(1:tablestart_ind+2);
                    subset3=rdl.OtherMetadata.Header(tablestart_ind+3:end);
                    
                    % get number of columns (in header description)
                    colnum_ind=find(strncmp('%TableColumns',subset1,length('%TableColumns')));
                    colnum=str2num(subset1{colnum_ind}(length('%TableColumns:  '):end));
                    
                    % get 4-char variable IDs
                    coltype_ind=strncmp('%TableColumnTypes',subset1,length('%TableColumnTypes'));
                    coltype=subset1{coltype_ind};
                    ind=find(coltype==':');
                    coltype=coltype(ind+1:end);
                    coltype(coltype==' ')='';
                    if(length(coltype)~=colnum*4)
                        warning('column type labels do not match up with column count')
                    end
                    
                    % get long-name header to each variable
                    header=cell(1,colnum);
                    for k=1:colnum
                        header{k}=coltype(k*4-3:k*4);
                    end
                    
                    % remove any data flagged in VFLG (mostly/all AngSeg
                    % flags)
                    indvflg=find(strcmp(header,'VFLG'));
                    indvflg_good=find(rdl.OtherMetadata.RawData(:,indvflg)==0);
                    rdl.OtherMetadata.RawData=rdl.OtherMetadata.RawData(indvflg_good,:);
                    
                    % find closest lon/lat radial measurement to current
                    % drifter location
                    indlon=find(strcmp(header,'LOND'));
                    indlat=find(strcmp(header,'LATD'));
                    d=dist_ref(Lon(n),Lat(n),rdl.OtherMetadata.RawData(:,indlon),rdl.OtherMetadata.RawData(:,indlat));
                    indd=find(d==min(d));
                    DIST(n)=d(indd);
                    
                    % loop through all varis in 'savetypes' and assign
                    % radial data closest to drifter location
                    for k=1:length(savetypes)
                        ind=find(strcmp(header,savetypes{k}));
                        if(~isempty(ind))
                            eval([savetypes{k} '(n)=rdl.OtherMetadata.RawData(indd,ind);']);
                        end
                    end
                    
                    % rotate drifter velocity according to bearing at
                    % closest radial measurement
                    [~,VeloDrift(n)]=rot(U(n),V(n),BEAR(n));
                    
                    clear rdl header col* ind* subset* table* d k t
                end
            end
            
            % reverse rotated drifter velocity to match direction to/from
            % CODAR site
            VeloDrift=-VeloDrift;
            
            clear n
            
            save(['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/drifter_comp_' name_str '_' site '_' type '.mat']);
        end
        
        if(imageopt)
            
            % %%
            %
            % clear all
            % close all
            %
            % site='BRNT';
            % type='RDLi';
            % drifterid='43340';
            
            if(~processopt)
                newvars=load(['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/drifter_comp_' drifterid '_' site '_' type '.mat']);
                
                newvarnames=fields(newvars);
                for n=1:length(newvarnames);
                    if(~exist(newvarnames{n},'var'))
                        eval([newvarnames{n} '=newvars.' newvarnames{n} ';']);
                    end
                end
            end
            
            if(sum(~isnan(VELO))>length(time)/2)
                
                espclim=20;
                
                if(cut_dist)
                    if(ismember(site,LR_sites))
                        maxdist=6;
                    elseif(ismember(site,MR_sites))
                        maxdist=2.5;
                    elseif(ismember(site,SR_sites))
                        maxdist=2.5;
                    end
                    cut_dist_lab=['_maxseparation' num2str(maxdist) 'km'];
                else
                    cut_dist_lab='';
                    maxdist=999;
                end
                
                ind_dist=find(DIST>maxdist);
                for nd=1:length(adjustdist)
                    eval([adjustdist{nd} '(ind_dist)=nan;']);
                end
                
                if(site_loc(2)>38&site_loc(2)<40.7)
                    load njbathymetry_3sec
                    mapoffset=.2;
                else
                    load bathymetry_USeastcoast
                    mapoffset=.5;
                end
                
                subplot(2,2,1)
                contour(loni,lati,depthi,[0 0],'k');
                hold on
                contour(loni,lati,depthi,[-20 -50],'color',[.5 .5 .5]);
                xlim([min([site_loc(1) Lon])-mapoffset max([site_loc(1) Lon])+mapoffset])
                ylim([min([site_loc(2) Lat])-mapoffset max([site_loc(2) Lat])+mapoffset])
                project_mercator(gca)
                scatter(site_loc(1),site_loc(2),100,'m','filled','marker','^');
                plot(Lon,Lat,'color','k')
                ind_dist=find(DIST<=maxdist);
                scatter(Lon(ind_dist),Lat(ind_dist),3,time(ind_dist),'filled')
                cb=colorbar;
                caxis([min(time) max(time)])
                dint=ceil(range(time)/8);
                set(cb,'ytick',ceil(min(time)):dint:ceil(min(time))+dint*8,...
                    'yticklabel',datestr(ceil(min(time)):dint:ceil(min(time))+dint*8,'mm/dd'));
                title({['Site: ' site];['Drifter: ' drifterid]})
                
                subplot(2,2,3)
                hist(ESPC(ESPC<999))
                xlabel('ESPC')
                ylabel('Frequency')
                title({'Spatial Quality Distribution';['No SD Count = ' int2str(sum(ESPC==999))]});
                
                subplot(2,2,[2 4])
                ind=find(~isnan(VELO));
                scatter(VELO(ind),VeloDrift(ind),'b.')
                set(gca,'xtick',-90:15:90,'ytick',-90:15:90)
                axlim=max(abs([VELO(ind) VeloDrift(ind)]))*1.1;
                xlim(axlim*[-1 1])
                ylim(axlim*[-1 1])
                axis square
                hold on
                mb=polyfit(VELO(ind),VeloDrift(ind),1);
                [r,p]=corrcoef(VELO(ind),VeloDrift(ind));
                r=sprintf('%.2f',r(2));
                r(1)='r';
                p=sprintf('%.2f',p(2));
                p(1)='p';
                rmse=sqrt(sum((VELO(ind)-VeloDrift(ind)).^2)/length(ind));
                rmse=sprintf('%.2f',rmse);
                ind=find(ESPC==999);
                scatter(VELO(ind),VeloDrift(ind),'r.')
                if(isempty(ind))
                    scatter(axlim+2,axlim+2,'r.');
                end
                ind=find(ESPC~=999&~isnan(VELO));
                mb999=polyfit(VELO(ind),VeloDrift(ind),1);
                [r999,p999]=corrcoef(VELO(ind),VeloDrift(ind));
                r999=sprintf('%.2f',r999(2));
                r999(1)='r';
                p999=sprintf('%.2f',p999(2));
                p999(1)='p';
                rmse999=sqrt(sum((VELO(ind)-VeloDrift(ind)).^2)/length(ind));
                rmse999=sprintf('%.2f',rmse999);
                ind=find(ESPC~=999&ESPC>=espclim);
                scatter(VELO(ind),VeloDrift(ind),'c.')
                if(isempty(ind))
                    scatter(axlim+2,axlim+2,'c.');
                end
                ind=find(ESPC<espclim);
                mbespc=polyfit(VELO(ind),VeloDrift(ind),1);
                [respc,pespc]=corrcoef(VELO(ind),VeloDrift(ind));
                respc=sprintf('%.2f',respc(2));
                respc(1)='r';
                pespc=sprintf('%.2f',pespc(2));
                pespc(1)='p';
                rmseespc=sqrt(sum((VELO(ind)-VeloDrift(ind)).^2)/length(ind));
                rmseespc=sprintf('%.2f',rmseespc);
                y=mb(1)*axlim*[-1 1]+mb(2);
                plot(axlim*[-1 1],y,'color',[.5 0 .5]);
                y=mb999(1)*axlim*[-1 1]+mb999(2);
                plot(axlim*[-1 1],y,'color',[.5 0 .5],'linestyle','--');
                y=mbespc(1)*axlim*[-1 1]+mbespc(2);
                plot(axlim*[-1 1],y,'color',[.5 0 .5],'linestyle',':','linewidth',1.5);
                plot(axlim*[-1 1],axlim*[-1 1],'k','linewidth',1.25);
                xlabel('CODAR Velocity')
                ylabel('Drifter Velocity')
                legend(['ESPC<' num2str(espclim) ', N=' int2str(sum(ESPC<espclim))],...
                    ['ESPC=999 (DNE), N=' int2str(sum(ESPC==999))],...
                    ['ESPC>' num2str(espclim) ', N=' int2str(sum(ESPC>=espclim&ESPC~=999))],...
                    ['BF All: ' r ',' p ',rmse' rmse],...
                    ['BF ESPC~=999: ' r999 ',' p999 ',rmse' rmse999],...
                    ['BF ESPC<' num2str(espclim) ': ' respc ',' pespc ',rmse' rmseespc],...
                    '1:1',...
                    'location','northoutside');
                
                print(figure(1),['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site '/drifter_comp_' name_str '_' site '_' type cut_dist_lab '.png'],'-dpng','-r300');
                
                
                figure
                ETMP(ETMP==999)=nan;
                ESPC(ESPC==999)=nan;
                xtickint=ceil(range(time)/8);
                %[ax,h1,h2]=plotyy([time',time'],[VELO',VeloDrift'],[time',time',time'],[ETMP',ESPC',DIST']);
                
                subplot(2,1,1)
                ind=find(~isnan(DIST));
                patch([time(ind) time(ind(end:-1:1)) time(ind(1))],[DIST(ind) -DIST(ind(end:-1:1)) DIST(ind(1))],'r','facealpha',.25)
                hold on
                plot(time,VELO,'color','b','linewidth',1.5,'marker','.')
                plot(time,VeloDrift,'color','g','linewidth',1.5,'marker','.')
                axlim=max([axlim DIST]);
                s1=[];
                for t=floor(min(time)):ceil(max(time))
                    s1=[s1,plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle',':')];
                end
                set(gca,'xtick',ceil(min(time)):xtickint:ceil(max(time)),...
                    'xticklabel',datestr(ceil(min(time)):xtickint:ceil(max(time)),'mm/dd'))
                %xlim([min(time) min(time)+range(time)/2])
                xlim([min(time) max(time)])
                ylim(axlim*[-1 1])
                xlabel('Time')
                ylabel({'Radial Vector Component (cm/s)';'Distance (km)'})
                legend('Distance to Closest Radial Measurement',[site ' Velocity'],['Drifter ' drifterid ' Velocity'],...
                    'location','northoutside','orientation','horizontal');
                
                subplot(2,1,2)
                plot(time,ESPC,'color','b','marker','.')
                hold on
                ind=find(isnan(ESPC));
                scatter(time(ind),-ones(size(ind)),10,'c','filled')
                plot(time,ETMP,'color','r','marker','.')
                ind=find(isnan(ETMP));
                scatter(time(ind),-1.5*ones(size(ind)),10,'m','filled')
                s2=[];
                for t=floor(min(time)):ceil(max(time))
                    s2=[s2,plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle',':')];
                end
                set(gca,'xtick',ceil(min(time)):xtickint:ceil(max(time)),...
                    'xticklabel',datestr(ceil(min(time)):xtickint:ceil(max(time)),'mm/dd'))
                %xlim([min(time) min(time)+range(time)/2])
                xlim([min(time) max(time)])
                ylim([-2 max([ESPC ETMP])+2])
                xlabel('Time')
                ylabel({'Radial Quality'; '(Standard Devation, cm/s)'})
                legend('Spatial Quality (ESPC)','No Valid ESPC','Temporal Quality (ETMP)','No Valid ETMP',...
                    'location','northoutside','orientation','horizontal');
                
                % subplot(4,1,3)
                % ind=find(~isnan(DIST));
                % patch([time(ind) time(ind(end:-1:1)) time(ind(1))],[DIST(ind) -DIST(ind(end:-1:1)) DIST(ind(1))],'r','facealpha',.25)
                % hold on
                % plot(time,VELO,'color','b','linewidth',1.5)
                % plot(time,VeloDrift,'color','g','linewidth',1.5)
                % axlim=max([axlim DIST]);
                % for t=ceil(min(time)):floor(max(time))
                %     plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle',':');
                % end
                % set(gca,'xtick',ceil(min(time)):xtickint:ceil(max(time)),...
                %     'xticklabel',datestr(ceil(min(time)):xtickint:ceil(max(time)),'mm/dd'))
                % xlim([min(time)+range(time)/2 max(time)])
                % ylim(axlim*[-1 1])
                % xlabel('Time')
                % ylabel({'Radial Vector Component (cm/s)';'Distance (km)'})
                % legend('Distance to Closest Radial Measurement',[site ' Velocity'],['Drifter ' drifterid ' Velocity'],...
                %     'location','northoutside','orientation','horizontal');
                %
                % subplot(4,1,4)
                % plot(time,ESPC,'color','b','marker','.')
                % hold on
                % ind=find(isnan(ESPC));
                % scatter(time(ind),-ones(size(ind)),'c.')
                % plot(time,ETMP,'color','r','marker','.')
                % ind=find(isnan(ETMP));
                % scatter(time(ind),-ones(size(ind)),'m.')
                % for t=ceil(min(time)):floor(max(time))
                %     plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle',':');
                % end
                % set(gca,'xtick',ceil(min(time)):xtickint:ceil(max(time)),...
                %     'xticklabel',datestr(ceil(min(time)):xtickint:ceil(max(time)),'mm/dd'))
                % xlim([min(time)+range(time)/2 max(time)])
                % ylim([-2 max([ESPC ETMP])+2])
                % xlabel('Time')
                % ylabel({'Radial Quality'; '(Standard Devation, cm/s)'})
                % legend('Spatial Quality (ESPC)','No Valid ESPC','Temporal Quality (ETMP)','No Valid ETMP',...
                %     'location','northoutside','orientation','horizontal');
                %
                print(figure(2),['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site '/drifter_comp_' name_str '_' site '_' type cut_dist_lab '_time.png'],'-dpng','-r300');
                
                tm=floor(min(time)):1/4:ceil(max(time));
                tl=cellstr(datestr(tm,'mm/dd'));
                tl(mod(tm,1)>0)={''};
                
                delete(s1,s2)
                for s=1:2
                    subplot(2,1,s)
                    % for t=floor(min(time)):1/8:ceil(max(time))
                    %     if(~mod(t,1))
                    %         plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle','-');
                    %     else
                    %         plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle',':');
                    %     end
                    % end
                    set(gca,'xtick',tm,...
                        'xticklabel',tl,...
                        'xgrid','on');
                end
                
                t1=floor(min(time));
                while(t1<max(time))
                    t2=t1+7;
                    if(t1<min(time))
                        t1=min(time);
                    end
                    if(t2+3>max(time))
                        t2=max(time);
                    end
                    for s=1:2
                        subplot(2,1,s)
                        xlim([t1 t2])
                    end
                    print(figure(2),['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site '/drifter_comp_' name_str '_' site '_' type cut_dist_lab '_time_wk' datestr(t1,'yyyymmdd') '.png'],'-dpng','-r300');
                    t1=t2;
                end
                
                figure(3)
                hsvmap=colormap('hsv');
                hsvmap(end+1,:)=hsvmap(1,:);
                ESPC(isnan(ESPC))=-1;
                ETMP(isnan(ETMP))=-1;
                veldiff=abs(VELO-VeloDrift);
                xd=(Lon-site_loc(1))*111.12*cosd(site_loc(2));
                yd=(Lat-site_loc(2))*111.12;
                bear=atan2(yd,xd);
                bear=bear*180/pi;
                bear=-(bear-90);
                bear(bear<0)=bear(bear<0)+360;
                beardiff=abs(BEAR-bear);
                beardiff(beardiff>180)=beardiff(beardiff>180)-360;
                beardiff=abs(beardiff);
                beardiffcats=[0 10 .8
                    10 20 .7
                    20 30 .6
                    30 50 .5
                    50 75 .4
                    75 100 .3
                    100 125 .2
                    125 150 .1
                    150 181 0];
                bearlegend=[];
                for c=1:size(beardiffcats,1)
                    bearlegend=[bearlegend,{sprintf('%d-%d',beardiffcats(c,1),beardiffcats(c,2))}];
                end
                
                subplot(2,2,1)
                scatter(ESPC,veldiff,'b.')
                ind=find(ESPC>-1);
                mb=polyfit(ESPC(ind),veldiff(ind),1);
                hold on
                x=[0 max(ESPC)*1.1];
                y=mb(1)*x+mb(2);
                plot(x,y,'k');
                xlabel('Spatial Quality')
                ylabel('Velocity Difference')
                [r,p]=corrcoef(ESPC(ind),veldiff(ind));
                title({[site ' ' type ' vs. ' drifterid];['r=' num2str(r(2),'%0.2f') ', p=' num2str(p(2),'%0.2f')]})
                xint=ceil(max(ESPC)*1.1/7);
                set(gca,'xlim',[-2 max(ESPC)*1.1],...
                    'ylim',[0 max(veldiff)*1.1],...
                    'xtick',[-1 xint:xint:xint*6],...
                    'xticklabel',[{'NA'},cellstr(int2str([xint:xint:xint*6]'))']);
                box on
                grid on
                
                subplot(2,2,2)
                scatter(ETMP,veldiff,'b.')
                ind=find(ETMP>-1);
                mb=polyfit(ETMP(ind),veldiff(ind),1);
                hold on
                x=[0 max(ETMP)*1.1];
                y=mb(1)*x+mb(2);
                plot(x,y,'k');
                xlabel('Temporal Quality')
                ylabel('Velocity Difference')
                [r,p]=corrcoef(ETMP(ind),veldiff(ind));
                title({[site ' ' type ' vs. ' drifterid];['r=' num2str(r(2),'%0.2f') ', p=' num2str(p(2),'%0.2f')]})
                xint=ceil(max(ETMP)*1.1/7);
                set(gca,'xlim',[-2 max(ETMP)*1.1],...
                    'ylim',[0 max(veldiff)*1.1],...
                    'xtick',[-1 xint:xint:xint*6],...
                    'xticklabel',[{'NA'},cellstr(int2str([xint:xint:xint*6]'))']);
                box on
                grid on
                
                subplot(2,2,3)
                for c=1:size(beardiffcats,1)
                    ind=find(beardiff>=beardiffcats(c,1)&beardiff<beardiffcats(c,2));
                    scatter(DIST(ind),veldiff(ind),'markeredgecolor',beardiffcats(c,3)*[1 1 1],'markerfacecolor',beardiffcats(c,3)*[1 1 1],'marker','.')
                    if(isempty(ind))
                        scatter(-5,-5,'markeredgecolor',beardiffcats(c,3)*[1 1 1],'markerfacecolor',beardiffcats(c,3)*[1 1 1],'marker','.')
                    end
                    hold on
                end
                ind=find(~isnan(veldiff));
                mb=polyfit(DIST(ind),veldiff(ind),1);
                hold on
                xmax=min([max(DIST)*1.1 maxdist]);
                x=[0 xmax];
                y=mb(1)*x+mb(2);
                plot(x,y,'k');
                xlabel({'Distance to Radial Measurement';'Color: Bearing Difference'})
                ylabel('Velocity Difference')
                [r,p]=corrcoef(DIST(ind),veldiff(ind));
                title({[site ' ' type ' vs. ' drifterid];['r=' num2str(r(2),'%0.2f') ', p=' num2str(p(2),'%0.2f')]})
                xint=ceil(xmax/8);
                if(xmax<8)
                    xint=ceil(xmax*10/8)/10;
                end
                set(gca,'xlim',[0 xmax],...
                    'ylim',[0 max(veldiff)*1.3],...
                    'xtick',[0:xint:xint*7]);
                ind=find(beardiffcats(:,1)<=max(beardiff));
                legend(bearlegend(ind),'location','north','orientation','horizontal')
                % colorbar
                % colormap(hsvmap)
                % ylabel(colorbar,'Bearing Difference')
                % caxis([0 200])
                box on
                grid on
                
                subplot(2,2,4)
                DIST_site=dist_ref(site_loc(1),site_loc(2),Lon,Lat);
                scatter(DIST_site,veldiff,10,BEAR,'filled')
                ind=find(~isnan(veldiff));
                mb=polyfit(DIST_site(ind),veldiff(ind),1);
                hold on
                x=[0 max(DIST_site)*1.1];
                y=mb(1)*x+mb(2);
                plot(x,y,'k');
                xlabel('Distance to Site')
                ylabel('Velocity Difference')
                [r,p]=corrcoef(DIST_site(ind),veldiff(ind));
                title({[site ' ' type ' vs. ' drifterid];['r=' num2str(r(2),'%0.2f') ', p=' num2str(p(2),'%0.2f')]})
                xint=ceil(max(DIST_site)*1.1/8);
                set(gca,'xlim',[0 max(DIST_site)*1.1],...
                    'ylim',[0 max(veldiff)*1.1],...
                    'xtick',[0:xint:xint*7]);
                colorbar
                colormap(hsvmap)
                ylabel(colorbar,'Bearing')
                caxis([0 360])
                box on
                grid on
                
                print(figure(3),['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site '/drifter_comp_' name_str '_' site '_' type cut_dist_lab '_diffscatter.png'],'-dpng','-r300');
                
                if(strcmp(addlab,'/qartod'))
                    
                    close all
                    
                    ESPC(ESPC==-1)=999;ETMP(ETMP==-1)=999;
                    
                    qrtd=[GRNG; LRNG; SPKE; GRAD; TRND; STCK];
                    qrtd_testnum=ones(size(qrtd));
                    for k=2:size(qrtd,1)
                        qrtd_testnum(k,:)=k;
                    end
                    ind=find(isnan(VELO));
                    qrtd(:,ind)=nan;
                    time_exp=repmat(time,[6 1]);
                    qrtd(end+1,:)=sum(qrtd==3|qrtd==4,1);
                    
                    
                    subplot(2,2,1)
                    contour(loni,lati,depthi,[0 0],'k');
                    hold on
                    contour(loni,lati,depthi,[-20 -50],'color',[.5 .5 .5]);
                    xlim([min([site_loc(1) Lon])-mapoffset max([site_loc(1) Lon])+mapoffset])
                    ylim([min([site_loc(2) Lat])-mapoffset max([site_loc(2) Lat])+mapoffset])
                    project_mercator(gca)
                    scatter(site_loc(1),site_loc(2),100,'m','filled','marker','^');
                    plot(Lon,Lat,'color','k')
                    ind_dist=find(DIST<=maxdist);
                    scatter(Lon(ind_dist),Lat(ind_dist),3,time(ind_dist),'filled')
                    cb=colorbar;
                    caxis([min(time) max(time)])
                    dint=ceil(range(time)/8);
                    set(cb,'ytick',ceil(min(time)):dint:ceil(min(time))+dint*8,...
                        'yticklabel',datestr(ceil(min(time)):dint:ceil(min(time))+dint*8,'mm/dd'));
                    title({['Site: ' site];['Drifter: ' drifterid]})
                    
                    subplot(2,2,3)
                    qrtd_tests={'GRNG','LRNG','SPKE','GRAD','TRND','STCK'};
                    testcombos={1;2;3;4;5;6;[1 2 3];[1 2 4];[1 2 6];[3 4];[1 2 3 4]};
                    
                    out_table={'Mandatory Passing Tests','r','p','rmse','N'};
                    
                    for k=1:length(testcombos)
                        test_check=testcombos{k};
                        out_table{k+1,1}=qrtd_tests{test_check(1)};
                        for kk=2:length(test_check)
                            out_table{k+1,1}=[out_table{k+1,1} '+' qrtd_tests{test_check(kk)}];
                        end
                        qrtd_check=qrtd(test_check,:);
                        qrtd_check=sum(qrtd_check==3|qrtd_check==4,1);
                        ind=find(qrtd_check==0&~isnan(VELO));
                        [r,p]=corrcoef(VELO(ind),VeloDrift(ind));
                        rmse=sqrt(sum((VELO(ind)-VeloDrift(ind)).^2)/length(ind));
                        out_table{k+1,2}=sprintf('%.2f',r(2));
                        out_table{k+1,3}=sprintf('%.2f',p(2));
                        out_table{k+1,4}=sprintf('%.2f',rmse);
                        out_table{k+1,5}=int2str(length(ind));
                    end
                    text(1,1,out_table(:,1),'horizontalalignment','right','verticalalignment','top')
                    xlim([0 2.5])
                    set(gca,'visible','off')
                    hold on
                    text(1.4,1,out_table(:,2),'horizontalalignment','right','verticalalignment','top')
                    text(1.8,1,out_table(:,3),'horizontalalignment','right','verticalalignment','top')
                    text(2.2,1,out_table(:,4),'horizontalalignment','right','verticalalignment','top')
                    text(2.5,1,out_table(:,5),'horizontalalignment','right','verticalalignment','top')
                    
                    subplot(2,2,[2 4])
                    ind=find(~isnan(VELO));
                    scatter(VELO(ind),VeloDrift(ind),'b.')
                    set(gca,'xtick',-90:15:90,'ytick',-90:15:90)
                    axlim=max(abs([VELO(ind) VeloDrift(ind)]))*1.1;
                    xlim(axlim*[-1 1])
                    ylim(axlim*[-1 1])
                    axis square
                    hold on
                    mb=polyfit(VELO(ind),VeloDrift(ind),1);
                    [r,p]=corrcoef(VELO(ind),VeloDrift(ind));
                    r=sprintf('%.2f',r(2));
                    r(1)='r';
                    p=sprintf('%.2f',p(2));
                    p(1)='p';
                    rmse=sqrt(sum((VELO(ind)-VeloDrift(ind)).^2)/length(ind));
                    rmse=sprintf('%.2f',rmse);
                    ind=find(qrtd(end,:)>1&~isnan(VELO));
                    scatter(VELO(ind),VeloDrift(ind),'r.')
                    if(isempty(ind))
                        scatter(axlim+2,axlim+2,'r.');
                    end
                    ind=find(qrtd(end,:)<=1&~isnan(VELO));
                    mb999=polyfit(VELO(ind),VeloDrift(ind),1);
                    [r999,p999]=corrcoef(VELO(ind),VeloDrift(ind));
                    r999=sprintf('%.2f',r999(2));
                    r999(1)='r';
                    p999=sprintf('%.2f',p999(2));
                    p999(1)='p';
                    rmse999=sqrt(sum((VELO(ind)-VeloDrift(ind)).^2)/length(ind));
                    rmse999=sprintf('%.2f',rmse999);
                    ind=find(qrtd(end,:)==1&~isnan(VELO));
                    scatter(VELO(ind),VeloDrift(ind),'c.')
                    if(isempty(ind))
                        scatter(axlim+2,axlim+2,'c.');
                    end
                    ind=find(qrtd(end,:)==0&~isnan(VELO));
                    mbespc=polyfit(VELO(ind),VeloDrift(ind),1);
                    [respc,pespc]=corrcoef(VELO(ind),VeloDrift(ind));
                    respc=sprintf('%.2f',respc(2));
                    respc(1)='r';
                    pespc=sprintf('%.2f',pespc(2));
                    pespc(1)='p';
                    rmseespc=sqrt(sum((VELO(ind)-VeloDrift(ind)).^2)/length(ind));
                    rmseespc=sprintf('%.2f',rmseespc);
                    y=mb(1)*axlim*[-1 1]+mb(2);
                    plot(axlim*[-1 1],y,'color',[.5 0 .5]);
                    y=mb999(1)*axlim*[-1 1]+mb999(2);
                    plot(axlim*[-1 1],y,'color',[.5 0 .5],'linestyle','--');
                    y=mbespc(1)*axlim*[-1 1]+mbespc(2);
                    plot(axlim*[-1 1],y,'color',[.5 0 .5],'linestyle',':','linewidth',1.5);
                    plot(axlim*[-1 1],axlim*[-1 1],'k','linewidth',1.25);
                    xlabel('CODAR Velocity')
                    ylabel('Drifter Velocity')
                    legend(['All Passing, N=' int2str(sum(qrtd(end,:)==0&~isnan(VELO)))],...
                        ['>1 Failed Test, N=' int2str(sum(qrtd(end,:)>1&~isnan(VELO)))],...
                        ['1 Fail, N=' int2str(sum(qrtd(end,:)==1&~isnan(VELO)))],...
                        ['BF All: ' r ',' p ',rmse' rmse],...
                        ['BF 0-1 Failed Test: ' r999 ',' p999 ',rmse' rmse999],...
                        ['BF No Failed Tests: ' respc ',' pespc ',rmse' rmseespc],...
                        '1:1',...
                        'location','northoutside');
                    
                    print(figure(1),['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site '/drifter_comp_' name_str '_' site '_' type cut_dist_lab '_qrtd.png'],'-dpng','-r300');
                    
                    
                    figure
                    ETMP(ETMP==999)=nan;
                    ESPC(ESPC==999)=nan;
                    xtickint=ceil(range(time)/8);
                    %[ax,h1,h2]=plotyy([time',time'],[VELO',VeloDrift'],[time',time',time'],[ETMP',ESPC',DIST']);
                    
                    qrtd_use=qrtd([1:4,6],:);
                    qrtd_use=sum(qrtd_use==3|qrtd_use==4);
                    qrtd_f=find(qrtd_use>0);
                    
                    subplot(3,1,1)
                    ind=find(~isnan(DIST));
                    patch([time(ind) time(ind(end:-1:1)) time(ind(1))],[DIST(ind) -DIST(ind(end:-1:1)) DIST(ind(1))],'r','facealpha',.25)
                    hold on
                    plot(time,VELO,'color','b','linewidth',1.5,'marker','.')
                    plot(time,VeloDrift,'color','g','linewidth',1.5,'marker','.')
                    scatter(time(qrtd_f),VELO(qrtd_f),'markeredgecolor','b','linewidth',2,'marker','x');
                    axlim=max([axlim DIST]);
                    s1=[];
                    for t=floor(min(time)):ceil(max(time))
                        s1=[s1,plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle',':')];
                    end
                    set(gca,'xtick',ceil(min(time)):xtickint:ceil(max(time)),...
                        'xticklabel',datestr(ceil(min(time)):xtickint:ceil(max(time)),'mm/dd'))
                    %xlim([min(time) min(time)+range(time)/2])
                    xlim([min(time) max(time)])
                    ylim(axlim*[-1 1])
                    xlabel('Time')
                    ylabel({'Radial Vector Component (cm/s)';'Distance (km)'})
                    legend('Distance to Closest Radial Measurement',[site ' Velocity'],['Drifter ' drifterid ' Velocity'],...
                        'location','northoutside','orientation','horizontal');
                    
                    subplot(3,1,2)
                    ind=find(qrtd(1:end-1,:)==2);
                    scatter([time_exp(ind); time(1)],[qrtd_testnum(ind); -1],10,'k','filled');
                    hold on
                    ind=find(qrtd(1:end-1,:)==3|qrtd(1:end-1,:)==4);
                    scatter([time_exp(ind); time(1)],[qrtd_testnum(ind); -1],10,'r','filled');
                    set(gca,'xtick',ceil(min(time)):xtickint:ceil(max(time)),...
                        'xticklabel',datestr(ceil(min(time)):xtickint:ceil(max(time)),'mm/dd'))
                    xlim([min(time) max(time)])
                    xlabel('Time')
                    ylim([0 7])
                    set(gca,'ytick',1:6,'yticklabel',{'GRNG','LRNG','SPKE','GRAD','TRND','STCK'},'ygrid','on')
                    ylabel('Test')
                    legend('Not Evaluated','Suspect or Failing','location','northoutside','orientation','horizontal')
                    
                    subplot(3,1,3)
                    plot(time,ESPC,'color','b','marker','.')
                    hold on
                    ind=find(isnan(ESPC));
                    scatter(time(ind),-ones(size(ind)),10,'c','filled')
                    plot(time,ETMP,'color','r','marker','.')
                    ind=find(isnan(ETMP));
                    scatter(time(ind),-1.5*ones(size(ind)),10,'m','filled')
                    scatter(time(qrtd_f),ESPC(qrtd_f),'markeredgecolor','b','linewidth',2,'marker','x');
                    ind=find(isnan(ESPC));
                    ind=intersect(ind,qrtd_f);
                    scatter(time(ind),-ones(size(ind)),'markeredgecolor','c','linewidth',2,'marker','x');
                    scatter(time(qrtd_f),ETMP(qrtd_f),'markeredgecolor','r','linewidth',2,'marker','x');
                    ind=find(isnan(ETMP));
                    ind=intersect(ind,qrtd_f);
                    scatter(time(ind),-ones(size(ind)),'markeredgecolor','m','linewidth',2,'marker','x');
                    s2=[];
                    for t=floor(min(time)):ceil(max(time))
                        s2=[s2,plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle',':')];
                    end
                    set(gca,'xtick',ceil(min(time)):xtickint:ceil(max(time)),...
                        'xticklabel',datestr(ceil(min(time)):xtickint:ceil(max(time)),'mm/dd'))
                    %xlim([min(time) min(time)+range(time)/2])
                    xlim([min(time) max(time)])
                    ylim([-2 max([ESPC ETMP])+2])
                    xlabel('Time')
                    ylabel({'Radial Quality'; '(Standard Devation, cm/s)'})
                    legend('Spatial Quality','No Valid ESPC','Temporal Quality','No Valid ETMP',...
                        'location','northoutside','orientation','horizontal');
                    
                    % subplot(4,1,3)
                    % ind=find(~isnan(DIST));
                    % patch([time(ind) time(ind(end:-1:1)) time(ind(1))],[DIST(ind) -DIST(ind(end:-1:1)) DIST(ind(1))],'r','facealpha',.25)
                    % hold on
                    % plot(time,VELO,'color','b','linewidth',1.5)
                    % plot(time,VeloDrift,'color','g','linewidth',1.5)
                    % axlim=max([axlim DIST]);
                    % for t=ceil(min(time)):floor(max(time))
                    %     plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle',':');
                    % end
                    % set(gca,'xtick',ceil(min(time)):xtickint:ceil(max(time)),...
                    %     'xticklabel',datestr(ceil(min(time)):xtickint:ceil(max(time)),'mm/dd'))
                    % xlim([min(time)+range(time)/2 max(time)])
                    % ylim(axlim*[-1 1])
                    % xlabel('Time')
                    % ylabel({'Radial Vector Component (cm/s)';'Distance (km)'})
                    % legend('Distance to Closest Radial Measurement',[site ' Velocity'],['Drifter ' drifterid ' Velocity'],...
                    %     'location','northoutside','orientation','horizontal');
                    %
                    % subplot(4,1,4)
                    % plot(time,ESPC,'color','b','marker','.')
                    % hold on
                    % ind=find(isnan(ESPC));
                    % scatter(time(ind),-ones(size(ind)),'c.')
                    % plot(time,ETMP,'color','r','marker','.')
                    % ind=find(isnan(ETMP));
                    % scatter(time(ind),-ones(size(ind)),'m.')
                    % for t=ceil(min(time)):floor(max(time))
                    %     plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle',':');
                    % end
                    % set(gca,'xtick',ceil(min(time)):xtickint:ceil(max(time)),...
                    %     'xticklabel',datestr(ceil(min(time)):xtickint:ceil(max(time)),'mm/dd'))
                    % xlim([min(time)+range(time)/2 max(time)])
                    % ylim([-2 max([ESPC ETMP])+2])
                    % xlabel('Time')
                    % ylabel({'Radial Quality'; '(Standard Devation, cm/s)'})
                    % legend('Spatial Quality (ESPC)','No Valid ESPC','Temporal Quality (ETMP)','No Valid ETMP',...
                    %     'location','northoutside','orientation','horizontal');
                    %
                    print(figure(2),['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site '/drifter_comp_' name_str '_' site '_' type cut_dist_lab '_qrtd_time.png'],'-dpng','-r300');
                    
                    tm=floor(min(time)):1/4:ceil(max(time));
                    tl=cellstr(datestr(tm,'mm/dd'));
                    tl(mod(tm,1)>0)={''};
                    
                    delete(s1,s2)
                    for s=1:3
                        subplot(3,1,s)
                        % for t=floor(min(time)):1/8:ceil(max(time))
                        %     if(~mod(t,1))
                        %         plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle','-');
                        %     else
                        %         plot([t t],axlim*[-1 1],'color',[.5 .5 .5],'linestyle',':');
                        %     end
                        % end
                        set(gca,'xtick',tm,...
                            'xticklabel',tl,...
                            'xgrid','on');
                    end
                    
                    t1=floor(min(time));
                    while(t1<max(time))
                        t2=t1+7;
                        if(t1<min(time))
                            t1=min(time);
                        end
                        if(t2+3>max(time))
                            t2=max(time);
                        end
                        for s=1:3
                            subplot(3,1,s)
                            xlim([t1 t2])
                        end
                        print(figure(2),['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site '/drifter_comp_' name_str '_' site '_' type cut_dist_lab '_qrtd_time_wk' datestr(t1,'yyyymmdd') '.png'],'-dpng','-r300');
                        t1=t2;
                    end
                    
                    figure(3)
                    hsvmap=colormap('hsv');
                    hsvmap(end+1,:)=hsvmap(1,:);
                    ESPC(isnan(ESPC))=-1;
                    ETMP(isnan(ETMP))=-1;
                    veldiff=abs(VELO-VeloDrift);
                    xd=(Lon-site_loc(1))*111.12*cosd(site_loc(2));
                    yd=(Lat-site_loc(2))*111.12;
                    bear=atan2(yd,xd);
                    bear=bear*180/pi;
                    bear=-(bear-90);
                    bear(bear<0)=bear(bear<0)+360;
                    beardiff=abs(BEAR-bear);
                    beardiff(beardiff>180)=beardiff(beardiff>180)-360;
                    beardiff=abs(beardiff);
                    beardiffcats=[0 10 .8
                        10 20 .7
                        20 30 .6
                        30 50 .5
                        50 75 .4
                        75 100 .3
                        100 125 .2
                        125 150 .1
                        150 181 0];
                    bearlegend=[];
                    for c=1:size(beardiffcats,1)
                        bearlegend=[bearlegend,{sprintf('%d-%d',beardiffcats(c,1),beardiffcats(c,2))}];
                    end
                    
                    ind1=find(qrtd(end,:)==1);
                    indmany=find(qrtd(end,:)>1);
                    
                    subplot(2,2,1)
                    scatter(ESPC,veldiff,'b.')
                    ind=find(ESPC>-1);
                    mb=polyfit(ESPC(ind),veldiff(ind),1);
                    hold on
                    scatter(ESPC(ind1),veldiff(ind1),'c.');
                    scatter(ESPC(indmany),veldiff(indmany),'r.');
                    x=[0 max(ESPC)*1.1];
                    y=mb(1)*x+mb(2);
                    plot(x,y,'k');
                    xlabel('Spatial Quality')
                    ylabel('Velocity Difference')
                    [r,p]=corrcoef(ESPC(ind),veldiff(ind));
                    title({[site ' ' type ' vs. ' drifterid];['r=' num2str(r(2),'%0.2f') ', p=' num2str(p(2),'%0.2f')]})
                    xint=ceil(max(ESPC)*1.1/7);
                    set(gca,'xlim',[-2 max(ESPC)*1.1],...
                        'ylim',[0 max(veldiff)*1.1],...
                        'xtick',[-1 xint:xint:xint*6],...
                        'xticklabel',[{'NA'},cellstr(int2str([xint:xint:xint*6]'))']);
                    box on
                    grid on
                    
                    subplot(2,2,2)
                    scatter(ETMP,veldiff,'b.')
                    ind=find(ETMP>-1);
                    mb=polyfit(ETMP(ind),veldiff(ind),1);
                    hold on
                    scatter(ETMP(ind1),veldiff(ind1),'c.');
                    scatter(ETMP(indmany),veldiff(indmany),'r.');
                    x=[0 max(ETMP)*1.1];
                    y=mb(1)*x+mb(2);
                    plot(x,y,'k');
                    xlabel('Temporal Quality')
                    ylabel('Velocity Difference')
                    [r,p]=corrcoef(ETMP(ind),veldiff(ind));
                    title({[site ' ' type ' vs. ' drifterid];['r=' num2str(r(2),'%0.2f') ', p=' num2str(p(2),'%0.2f')]})
                    xint=ceil(max(ETMP)*1.1/7);
                    set(gca,'xlim',[-2 max(ETMP)*1.1],...
                        'ylim',[0 max(veldiff)*1.1],...
                        'xtick',[-1 xint:xint:xint*6],...
                        'xticklabel',[{'NA'},cellstr(int2str([xint:xint:xint*6]'))']);
                    box on
                    grid on
                    
                    subplot(2,2,3)
                    for c=1:size(beardiffcats,1)
                        ind=find(beardiff>=beardiffcats(c,1)&beardiff<beardiffcats(c,2));
                        scatter(DIST(ind),veldiff(ind),'markeredgecolor',beardiffcats(c,3)*[1 1 1],'markerfacecolor',beardiffcats(c,3)*[1 1 1],'marker','.')
                        if(isempty(ind))
                            scatter(-5,-5,'markeredgecolor',beardiffcats(c,3)*[1 1 1],'markerfacecolor',beardiffcats(c,3)*[1 1 1],'marker','.')
                        end
                        hold on
                    end
                    ind=find(~isnan(veldiff));
                    mb=polyfit(DIST(ind),veldiff(ind),1);
                    hold on
                    xmax=min([max(DIST)*1.1 maxdist]);
                    x=[0 xmax];
                    y=mb(1)*x+mb(2);
                    plot(x,y,'k');
                    xlabel({'Distance to Radial Measurement';'Color: Bearing Difference'})
                    ylabel('Velocity Difference')
                    [r,p]=corrcoef(DIST(ind),veldiff(ind));
                    title({[site ' ' type ' vs. ' drifterid];['r=' num2str(r(2),'%0.2f') ', p=' num2str(p(2),'%0.2f')]})
                    xint=ceil(xmax/8);
                    if(xmax<8)
                        xint=ceil(xmax*10/8)/10;
                    end
                    set(gca,'xlim',[0 xmax],...
                        'ylim',[0 max(veldiff)*1.3],...
                        'xtick',[0:xint:xint*7]);
                    ind=find(beardiffcats(:,1)<=max(beardiff));
                    legend(bearlegend(ind),'location','north','orientation','horizontal')
                    % colorbar
                    % colormap(hsvmap)
                    % ylabel(colorbar,'Bearing Difference')
                    % caxis([0 200])
                    box on
                    grid on
                    
                    subplot(2,2,4)
                    DIST_site=dist_ref(site_loc(1),site_loc(2),Lon,Lat);
                    scatter(DIST_site,veldiff,10,BEAR,'filled')
                    ind=find(~isnan(veldiff));
                    mb=polyfit(DIST_site(ind),veldiff(ind),1);
                    hold on
                    x=[0 max(DIST_site)*1.1];
                    y=mb(1)*x+mb(2);
                    plot(x,y,'k');
                    xlabel('Distance to Site')
                    ylabel('Velocity Difference')
                    [r,p]=corrcoef(DIST_site(ind),veldiff(ind));
                    title({[site ' ' type ' vs. ' drifterid];['r=' num2str(r(2),'%0.2f') ', p=' num2str(p(2),'%0.2f')]})
                    xint=ceil(max(DIST_site)*1.1/8);
                    set(gca,'xlim',[0 max(DIST_site)*1.1],...
                        'ylim',[0 max(veldiff)*1.1],...
                        'xtick',[0:xint:xint*7]);
                    colorbar
                    colormap(hsvmap)
                    ylabel(colorbar,'Bearing')
                    caxis([0 360])
                    box on
                    grid on
                    
                    print(figure(3),['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site '/drifter_comp_' name_str '_' site '_' type cut_dist_lab '_qrtd_diffscatter.png'],'-dpng','-r300');
                    
                    
                    figure
                    subplot(2,3,1)
                    hist(qrtd(1,:))
                    xlim([0 5])
                    title([site ' Data on Drifter ' drifterid ' Track'])
                    ylabel('Frequency')
                    xlabel('GRNG Flags')
                    subplot(2,3,2)
                    hist(qrtd(2,:))
                    xlim([0 5])
                    title([site ' Data on Drifter ' drifterid ' Track'])
                    ylabel('Frequency')
                    xlabel('LRNG Flags')
                    subplot(2,3,3)
                    hist(qrtd(3,:))
                    xlim([0 5])
                    title([site ' Data on Drifter ' drifterid ' Track'])
                    ylabel('Frequency')
                    xlabel('SPKE Flags')
                    subplot(2,3,4)
                    hist(qrtd(4,:))
                    xlim([0 5])
                    title([site ' Data on Drifter ' drifterid ' Track'])
                    ylabel('Frequency')
                    xlabel('GRAD Flags')
                    subplot(2,3,5)
                    hist(qrtd(5,:))
                    xlim([0 5])
                    title([site ' Data on Drifter ' drifterid ' Track'])
                    ylabel('Frequency')
                    xlabel('TRND Flags')
                    subplot(2,3,6)
                    hist(qrtd(6,:))
                    xlim([0 5])
                    title([site ' Data on Drifter ' drifterid ' Track'])
                    ylabel('Frequency')
                    xlabel('STCK Flags')
                    
                    print(figure(4),['/Users/palamara/Documents/codar_teststuff/drifters' addlab '/images/' drifterid '/' site '/drifter_comp_' name_str '_' site '_' type cut_dist_lab '_qrtd_hist.png'],'-dpng','-r300');
                    
                end
                
            end
        end
        close all
        clearvars -except addlab rext drifterid sites cut_dist adjustdist LR_sites MR_sites SR_sites types subdir savetypes rdlDir site_n type_n processopt imageopt
    end
end
