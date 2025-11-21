% A pipeline to isolate neural responses for every (image, electrode RF) pair for a subject.
% Prereq. Vars:
subject = "Dona"; % Dona, Jojo
date = 241007; % 241007, 250526, 250728 %yymmdd numeric
protocol = "NIL";
idx = 1;

% Directories:
pdir = fileparts(pwd);
img_dir = fullfile(pdir, "data/Images");
save_dir = "savedData";
if ~isfolder(fullfile(save_dir, "responses")), mkdir(fullfile(save_dir, "responses")), end

% Analysis hyperparameters
hparams.bl_range = [-0.5, 0];
hparams.st_range = [0.25, 0.75];
hparams.tapers = [1, 1]; % [TW, K], where TW is the time-bandwidth product, and K <= 2TW - 1 is the number of tapers being used
hparams.movingWin = [0.25, 0.025]; % Window width (s) and step width (s)

% If file exists, load it:
fname = sprintf("%s_%s_%s_%d_bl_%g_%g_st_%g_%g_.mat", lower(subject), ddmmyy(date), protocol, idx, ...
    hparams.bl_range(1), hparams.bl_range(2), hparams.st_range(1), hparams.st_range(2));
if isfile(fullfile(save_dir, "responses", fname))
    response_table = load(fullfile(save_dir, "responses", fname)).response_table;
    return % Terminate script execution
end

% Helper Functions:
slice_vector = @(v, slice) v(slice); % Anon. fn. to enable slice chaining

% Script:
dir = get_dir(subject, date=date, protocol=protocol, idx=idx, pdir=pdir);
[V1, V4] = get_ebt(dir);

% Preparing table to store response information:
response_cell = cell(length(slice_vector(string(ls(img_dir)), startsWith(string(ls(img_dir)), "Image"))), ... 
    length([V1.list, V4.list])); % 128 images
common_bt = 0; % Set to 1 if using common bad trials, I prefer removing them for each electrode

% Boilerplate code:
bp.unit_ID = 0;
bp.grid_type = "Microelectrode";
bp.side_choice = [];
bp.ref = "";
[bp.grat.a, bp.grat.e, bp.grat.s, bp.grat.o, bp.grat.c, bp.grat.t] = deal(1);
bp.remove_ERP = 0;

for j = [V1.good_elecs, V4.good_elecs] % High RMS Electrodes
    fprintf("Elec%d\n", j)
    % Electrode information:
    if subject == "Dona"
        if j <= 48, bt_suffix = "V1"; else, bt_suffix = "V4"; end 
    elseif subject == "Jojo"
        if j > 48, bt_suffix = "V1"; else, bt_suffix = "V4"; end
    end
    data = getSpikeLFPDataSingleChannel(lower(subject), ddmmyy(date), strcat(protocol, sprintf("_%03d", idx)), ...
    pdir, j, bp.unit_ID, bp.grid_type, bp.side_choice, char(bp.ref), char(bt_suffix), common_bt);
    for i = 1:size(response_cell, 1)
        fprintf("Stim%d\n", i)
        data_ = getDataGRF(data, bp.grat.a, bp.grat.e, bp.grat.s, i, bp.grat.o, bp.grat.c, bp.grat.t, ...
        hparams.bl_range, hparams.st_range, bp.remove_ERP, hparams.tapers, hparams.movingWin);
        response_cell{i, j} = rmfield(data_, ["timeVals", "freqBL", "freqST", "SBL", "SST", "timeTF", "freqTF", "STF", "raster", "frTimeVals", "blRange", "stRange"]);
        
        response_cell{i, j}.ERP = response_cell{i, j}.erp;
        response_cell{i, j} = rmfield(response_cell{i, j}, "erp");
        response_cell{i, j}.del_PSD = response_cell{i, j}.deltaPSD;
        response_cell{i, j} = rmfield(response_cell{i, j}, "deltaPSD");
        response_cell{i, j}.del_TF = response_cell{i, j}.deltaTF;
        response_cell{i, j} = rmfield(response_cell{i, j}, "deltaTF");
        response_cell{i, j}.FR = response_cell{i, j}.frVals;
        response_cell{i, j} = rmfield(response_cell{i, j}, "frVals");
        
        response_cell{i, j}.del_PSD = response_cell{i, j}.del_PSD';
        response_cell{i, j}.del_TF = response_cell{i, j}.del_TF';
    end
end

rnames = strcat("Image", string(1:size(response_cell, 1)));
cnames = strcat("Elec", string(1:size(response_cell, 2)));

response_table = cell2table(response_cell, RowNames=rnames, VariableNames=cnames);

good_elecs = [V1.good_elecs, V4.good_elecs];
t = data_.timeVals;
f_bl = data_.freqBL;
f_st = data_.freqST;
t_TF = data_.timeTF;
f_TF = data_.freqTF;
t_FR = data_.frTimeVals;

save(fullfile(save_dir, "responses", fname), "good_elecs", "t", "f_bl", "f_st", "t_TF", "f_TF", "t_FR", "response_table")