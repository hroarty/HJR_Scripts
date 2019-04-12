tic

 clear all; close all; 

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add 2 seconds to handle rounding

start_time = datenum(2015,6,1,00,0,0);
end_time=datenum(2015,6,2,00,0,0);
dtime = start_time:1/24:end_time;


%% config info for the plot
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.Type=conf.HourPlot.Type;

conf.HourPlot.DomainName='MARA';


%conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/';
conf.OI.BaseDir='/Users/hroarty/data/realtime/totals/maracoos/oi/mat/5MHz/';
conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;

p.HourPlot.Type='OI';
s = p.HourPlot.Type;

conf.datatype='TUVosn';

output_directory = '/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20150610_Smooth_Fields/scatter/';

%% load the total data depending on the config
s=conf.HourPlot.Type;
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);

numFiles = length(f);

v=conf.datatype;

for ii = 1:numFiles
    try
        % Load total hour:  assume it has the struct TUV as the final total current
        % data product.  totals or oma should have TUV if using
        % HFRPdriver_Totals_OMA.m
        % Assuming if I can load it it's good.  What if the file exists but
        % is empty?  I think it will get counted as a good file.
        data=load(f{ii});
        fprintf('Loading file %u of %u\n ',ii,numFiles);
%         data.(v)=maskTotals(data.TUV,mask,true);
%         fprintf('Masking file %u of %u\n ',i,numFiles);
    catch err
        disp(err)
        fprintf('Can''t load %s ... skipping\n',f{ii});
        continue;  % Skip rest of for loop
    end
    
    %% concatenate the total files in U and V
    X=[data.TUVosn.U data.TUV.U data.TUVosn.V data.TUV.V];

    %% remove any rows with NaNs
    X = X(all(~isnan(X),2),:);
    
    %% calculate the statistics between the total files in U
    rho=corr(X(:,1),X(:,2));
    p=polyfit(X(:,1),X(:,2),1);
    fU=polyval(p,-60:1:60);
    rms_diff_cross=sqrt(mean((X(:,1)-X(:,2)).^2));
    
     %% calculate the statistics between the total files in V
    rhoV=corr(X(:,3),X(:,4));
    pV=polyfit(X(:,3),X(:,4),1);
    fV=polyval(p,-60:1:60);
    rms_diff_crossV=sqrt(mean((X(:,3)-X(:,4)).^2));
    
%% Plot the U comparison
    subplot 211
    hold on
    plot(data.TUVosn.U,data.TUV.U,'bs')
    xlabel('U smooth (cm/s)')
    ylabel('U original (cm/s)')
    title (datestr(data.TUV.TimeStamp,21))
    grid on
    box on
    axis equal
    axis([-200 200 -200 200])
    
    text1= sprintf('slope:%.2g  y-int:%.3g',p(1),p(2));
    text2=sprintf('r:%.3g',rho);
    text3=sprintf('RMSD %.4g cm/s',rms_diff_cross);

    text(-190,150,text1)
    text(-190,100,text2)
    text(-190,-150,text3)
    
    %% plot the least square line
    plot(-60:1:60,fU,'g-','LineWidth',3)
    %% plot the 1:1 line
    plot(-60:1:60,-60:1:60,'k-','LineWidth',1)

    %% Plot the V comparison
    subplot 212
    hold on
    plot(data.TUVosn.V,data.TUV.V,'r*')
    xlabel('V smooth (cm/s)')
    ylabel('V original (cm/s)')
    grid on
    box on
    axis equal
    axis([-200 200 -200 200])
    
    text4= sprintf('slope:%.2g  y-int:%.3g',pV(1),pV(2));
    text5=sprintf('r:%.3g',rhoV);
    text6=sprintf('RMSD %.4g cm/s',rms_diff_crossV);

    text(-190,150,text4)
    text(-190,100,text5)
    text(-190,-150,text6)
    
    %% plot the least square line
    plot(-60:1:60,fV,'g-','LineWidth',3)
    %% plot the 1:1 line
    plot(-60:1:60,-60:1:60,'k-','LineWidth',1)
    
timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/scatter_U_V.m')

output_filename = ['Tot_' conf.HourPlot.DomainName  '_scatter_' datestr(data.TUV.TimeStamp,'yyyymmddTHHMM') '.png'];

%% print the image
print(1, '-dpng', [output_directory output_filename]);
        
close all
clear data

end


toc
