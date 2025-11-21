% A pipeline to isolate features for every patch.
% Prereq. Vars:
subject = "Jojo"; % Dona, Jojo
hl = 2; % patch half-length
r = 1; % IN mask radius/half length

% Directories:
pdir = fileparts(pwd);
save_dir = "savedData";
sw_parent_path = fullfile(pdir, "Programs/SoftwareMAP"); sw_parent_path = char(sw_parent_path); sw_parent_path(sw_parent_path == '\') = '/'; sw_parent_path = string(sw_parent_path); 
if ~isfolder(fullfile(save_dir, "features")), mkdir(fullfile(save_dir, "features")), end

% If file exists, load it:
if isfile(fullfile(save_dir, "features", sprintf("%s_r%d.mat", lower(subject), r)))
    measure_type = load(fullfile(save_dir, "features", sprintf("%s_r%d.mat", lower(subject), r))).measure_type;
    feat_tensor = load(fullfile(save_dir, "features", sprintf("%s_r%d.mat", lower(subject), r))).feat_tensor;
    return % Terminate script execution
end

% Helper Functions:
rect = @(X, Y, h, k, a, b) (abs(X - h) <= a) & (abs(Y - k) <= b); % Anon function for rectangular boundaries. a & b are half-lengths.

% Script:
[X, Y] = monitor_XY_deg;
in_mask_sq = logical(patch(rect(X, Y, 0, 0, r, r), X, Y, mode="L")); % square version of in_mask
a = sum(sum(in_mask_sq == 1, 1) > 0); % square mask width
b = sum(sum(in_mask_sq == 1, 2) > 0); % square mask height

% Preparing tensor to store feature information:
patch_table = load(fullfile(save_dir, "patches", sprintf("%s_hl%d.mat", lower(subject), hl))).patch_table;
measure_type = ["ACMO", "BREN", "CONT", "CURV", "DCTE", "DCTR", "GDER", "GLVA", "GLLV", "GLVN", "GRAE", ...
    "GRAT", "GRAS", "HELM", "HISE", "HISR", "LAPE", "LAPM", "LAPV", "LAPD", "SFIL", "SFRQ", "TENG", "TENV", ...
    "VOLA", "WAVS", "WAVV", "WAVR"];
feat_tensor = NaN*zeros([size(patch_table), length(measure_type)]);

% The high RMS electrodes can be determined from the patch table:
high_RMS = [];
for j = 1:size(patch_table, 2)
    try cell2mat(patch_table{:, j});
        if cell2mat(patch_table{:, j}) ~= [], high_RMS = [high_RMS, j]; end
    catch
        high_RMS = [high_RMS, j];
    end
end

rm_conflict(@entropy, sw_parent_path) % which('entropy'), sanity check to ensure we're using the MATLAB inbuilt function
rm_conflict(@fspecial, sw_parent_path) % which('fspecial')

K = length(measure_type); % Required to stop parfor fromm complaining, see below:
parfor i = 1:size(patch_table, 1) % OMG this is RIDICULOUSLY faster, WTF!!!
    fprintf("Stim%d\n", i)
    for j = high_RMS
        img_patch = cell2mat(patch_table{i, j});
        if length(size(img_patch)) == 3, img_patch = rgb2gray(img_patch); end % fmeasure is only defined on grayscale images
        img_patch = reshape(img_patch(in_mask_sq), [b, a]);
        for k = 1:K
            feat_tensor(i, j, k) = fmeasure(img_patch, measure_type(k));
        end
    end
end

% Save the computed feature tensor to a .mat file
save(fullfile(save_dir, "features", sprintf("%s_r%d.mat", lower(subject), r)), "measure_type", "feat_tensor");