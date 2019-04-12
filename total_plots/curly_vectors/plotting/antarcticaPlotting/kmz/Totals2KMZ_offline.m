addpath(genpath('/Volumes/home/michaesm/Codar/operational_scripts/'))
addpath(genpath('/Volumes/home/michaesm/matlab/googleplot'));
addpath(genpath('/Volumes/home/michaesm/matlab/googleearth'));
addpath(genpath('/Volumes/home/michaesm/matlab/bin/'));
% Totals.Dirs = {'/Volumes/home/codaradm/data/totals/oi/ascii/5MHz/', '/Volumes/home/codaradm/data/totals/oi/ascii/13MHz/'};
% Totals.Prefix = {'MARA', 'BPU'};
% Totals.Name = {'Long Range (5 MHz)', 'Mid Range (13 MHz)'};
 Totals.Dirs = {'/Volumes/home/codaradm/data/totals/maracoos/oi/ascii/5MHz/',...
                '/Volumes/home/codaradm/data/totals/maracoos/oi/ascii/13MHz/',...
                '/Volumes/home/codaradm/data/totals/maracoos/oi/ascii/25MHz/',...
                '/Volumes/home/codaradm/data/totals/pldp/25MHz/0.5km/oi/ascii/'};
%Totals.Dirs = {'/Volumes/home/codaradm/data/totals/oi/ascii/13MHz/', '/Volumes/home/codaradm/data/totals/oi/ascii/25MHz/'};
 Totals.Prefix = {'MARA', 'BPU', 'MARASR', 'PLDP'};
 Totals.Name = {'Long Range (5 MHz)',...
                'Mid Range (13 MHz)',...
                'Standard Range (25 MHz)',...
                'Antarctica (PLDP - 13/25 MHz)'};
%Totals.Prefix = {'BPU', 'MARASR'};
%Totals.Name = {'Mid Range (13 MHz)', 'Standard Range (25 MHz)'};

nTime = [];
listNames = cell(20,1);  picNames = cell(20,1); 
topFile=blanks(500*24);tfID = 1;

%Get current system time in UTC (seconds)
tN = java.lang.System.currentTimeMillis*.001;
tS = epoch2datenum(tN);

%Create hourly datenums between now and four hours ago
dtime = [tS:-1/24:tS-8/24]; % Intervals of every hour. 

%Convert matlab time to string to remove minutes and seconds then back to
%datenum format
strtime = datestr(dtime, 'dd-mmm-yyyy HH:00:00');
dtime = datenum(strtime);


for y = 1:length(Totals.Dirs)
    disp(Totals.Dirs{y})
    for x = length(dtime):-1:1;
        file_name = [Totals.Dirs{y} 'OI_' Totals.Prefix{y} '_' datestr(dtime(x), 'yyyy_mm_dd_HH00')];
        if exist(file_name)
            nTime = [nTime; dtime(x)];
        end
    end
    
    nTime = [];
    hourly_file = [Totals.Dirs{y} 'OI_' Totals.Prefix{y} '_' datestr(end_time, 'yyyy_mm_dd_HH00')];
    dtime = [end_time:-1/24:end_time-24/24];

    cd('/www/Volumes/home/michaesm/public_html/gearth/codar/colorquiver/kmzs/') 
%         cd('/Volumes/ironman-web/gearth/codar/colorquiver/kmzs')

    [kmlnameA filenameA] = TotalsAverage(dtime, Totals.Dirs{y}, Totals.Prefix{y});
    [kmlnameH filenameH] = TotalsHourly(hourly_file, Totals.Prefix{y});

    link_average = ['http://marine.rutgers.edu/~michaesm/gearth/codar/colorquiver/kmzs/' filenameA];
    link_hourly = ['http://marine.rutgers.edu/~michaesm/gearth/codar/colorquiver/kmzs/' filenameH];

    chunk = ['<NetworkLink>',10,...
        '<name>25 Hour Average</name>',10,...
        '<description>' kmlnameA '</description>',10,...
        '<Link>',10,...
        '<href>' link_average '</href>',10,...
        '<refreshMode>onInterval</refreshMode>',10,...
        '<refreshInterval>2704</refreshInterval>',10,...
        '</Link>',10,...
        '</NetworkLink>',10,...
        '<NetworkLink>',10,...
        '<name>Hourly (Latest Available)</name>',10,...
        '<description>' kmlnameH '</description>',10,...
        '<Link>',10,...
        '<href>' link_hourly '</href>',10,...
        '<refreshMode>onInterval</refreshMode>',10,...
        '<refreshInterval>2704</refreshInterval>',10,...
        '</Link>',10,...
        '</NetworkLink>'];
    chunk = ge_folder_totals(Totals.Name{y}, chunk);

    topFile(tfID+1:tfID+length(chunk)) = chunk;
    tfID = tfID+length(chunk);
end

% topfile = topFile(1:tfID);

topFile = [topFile link];

main_filename = 'MARACOOS_Surface_Currents.kmz';

ge_output(main_filename, topFile, 'name', 'MARACOOS Surface Currents');
