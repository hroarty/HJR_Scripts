function [Rorig]=driver_rad_vel_no_concat(D,conf,ii,cleanflag,maskflag)

% function gets the directory listing of all the radial files, loads the
% files, cleans and masks based on the flag setting then temporall
% concatenates the data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get filenames together
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    F = filenames_standard_filesystem( conf.Radials.BaseDir, conf.Radials.Sites{ii}, ...
                                       conf.Radials.Types{ii}, D,  ...
                                       conf.Radials.MonthFlag, ...
                                       conf.Radials.TypeFlag);

    %% Get rid of any missing/empty radials and temporally concat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Radials work - load in all at once, masking, cleaning interpolation
    %
    % When loading, for each time, load all radials from all sites in an
    % element of a single cell array - this will be useful for later saving
    % radials from each time with the appropriate totals files.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Rorig = loadRDLFile(F,1);

    % Deal with possible missing files
    % Since a file that contains only header information will create a struct
    % entry with a SiteName, but 0 x n U,V, and LonLat variable.  Key on one of
    % these instead of the SiteName.
    jj = false(size(Rorig));
    for j = 1:numel(Rorig)
        jj(j) = numel(Rorig(j).U) == 0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     missingRadials.FileNames = [ Rorig(ii).FileName ];
%     [missingRadials.TimeStamps,missingRadials.Sites,missingRadials.Types] ...
%         = parseRDLFileName( missingRadials.FileNames );
    
    for j =1:numel(Rorig)
        if jj(j)
            Rorig(j).RadComp = NaN;
            Rorig(j).U = NaN;
            Rorig(j).V = NaN;
        end
    end

    if isempty(Rorig)
      fprintf('No radial data for %s %s for the entire time ending %s ... skipping\n', ...
               conf.Radials.Sites{ii},conf.Radials.Types{ii},datestr(D(end)));
      return;
    end
    
if cleanflag
    %% Remove radials above MaxRadSpeed threshold
    disp('Radial Cleaning')
    Rorig = cleanRadials( Rorig, conf.Radials.MaxRadSpeed );
end

if maskflag
    %% Remove radials over land
     disp('Radial masking')
     Rorig = maskRadials( Rorig, conf.Radials.MaskFile, 0);
end

end
     