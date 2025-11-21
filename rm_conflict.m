function rm_conflict(func, sw_parent_path)
% Removes the directory containing a conflicting function/s for a MATLAB session.
%{
Provide the function handle (with @) as input! Requires the path to the software parent directory (use '/' for file separation).
Example usage: rm_conflict(@pca, "E:/Programs/SoftwareMAP") allows spikesort_gui to work by removing the EEGLAB folder 
from the path for the current session, as it has a 'pca' that conflicts with MATLAB's inbuilt.
%}
    func_path = string(which(func2str(func))); func_path = strsplit(func_path, '\');
    
    sw_parent_path = strsplit(sw_parent_path, '/');
    
    sw_idx = find(func_path == sw_parent_path(end)) + 1;
    
    sw_path = func_path(1:sw_idx);
    for i = 1:(length(sw_path) - 1), sw_path(i) = strcat(sw_path(i), "/"); end
    sw_path = strjoin(sw_path, "");

    rmpath(genpath(sw_path))
end

