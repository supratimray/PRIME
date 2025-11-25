% A pipeline to isolate patches for every (image, electrode RF) pair for a subject.
% Prereq. Vars:
subject = "Dona"; % Dona, Jojo
hl = 2; % Half length of patch in degrees visual angle (dva)

% Directories:
pdir = fileparts(pwd);
img_dir = fullfile(pdir, "data/images");
save_dir = "savedData/patches";
if ~isfolder(save_dir), mkdir(save_dir), end

% If file exists, load it:
if isfile(fullfile(save_dir, sprintf("%s_hl%d.mat", lower(subject), hl)))
    patch_table = load(fullfile(save_dir, sprintf("%s_hl%d.mat", lower(subject), hl))).patch_table;
    return % Terminate script execution
end

% Helper Functions:
slice_vector = @(v, slice) v(slice); % Anon. fn. to enable slice chaining

% Script:
dir = get_dir(subject, pdir=pdir);
grid_type = strsplit(dir.stim, '\'); grid_type = grid_type(find(grid_type == lower(subject), 1) + 1);
RF_data = fullfile(dir.RF, strcat(lower(subject), grid_type, "RFData.mat"));
RF_stats = load(RF_data).rfStats;
[V1, V4] = get_ebt(dir);

% Preparing table to store patch information:
patch_cell = cell(length(slice_vector(string(ls(img_dir)), startsWith(string(ls(img_dir)), "Image"))), ... 
    length([V1.list, V4.list])); % 128 images

[X, Y] = monitor_XY_deg;
for j = [V1.valid_elecs, V4.valid_elecs] % High RMS Electrodes
    fprintf("Elec%d\n", j)
    RF_center = [RF_stats(j).meanAzi, RF_stats(j).meanEle];
    for i = 1:length(slice_vector(string(ls(img_dir)), startsWith(string(ls(img_dir)), "Image")))
        fprintf("Stim%d\n", i)
        img = imread(fullfile(img_dir, sprintf("Image%d.tif", i)));
        if i <= 64
            img_patch = get_patch(img, X, Y, RF_center=RF_center, half_length=hl, deg=true, mode="RGB");
        else
            img_patch = get_patch(img, X, Y, RF_center=RF_center, half_length=hl, deg=true, mode="L");
        end
        patch_cell{i, j} = img_patch;
    end
end
w_px = size(patch_cell{i, j}, 2); % Width of img_patch in px
h_px = size(patch_cell{i, j}, 1); % Height of img_patch in px

x_axis_deg = X(1, :);
y_axis_deg = Y(:, 1)';

x_axis_deg = x_axis_deg((find(abs(x_axis_deg) == min(abs(x_axis_deg)), 1) - floor(w_px/2)):...
    (find(abs(x_axis_deg) == min(abs(x_axis_deg)), 1) - floor(w_px/2) + w_px - 1));
y_axis_deg = y_axis_deg((find(abs(y_axis_deg) == min(abs(y_axis_deg)), 1) - floor(h_px/2)):...
    (find(abs(y_axis_deg) == min(abs(y_axis_deg)), 1) - floor(h_px/2) + h_px - 1));

rnames = strcat("Image", string(1:size(patch_cell, 1)));
cnames = strcat("Elec", string(1:size(patch_cell, 2)));

patch_table = cell2table(patch_cell, RowNames=rnames, VariableNames=cnames);
save(fullfile(save_dir, sprintf("%s_hl%d.mat", lower(subject), hl)), "patch_table", "x_axis_deg", "y_axis_deg")