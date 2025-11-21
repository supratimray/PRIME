function [V1, V4, all_bad_trials] = get_ebt(dir)
    % Returns V1 & V4 electrode information, as well as bad trials for all electrodes. Example use case:
    % [V1, V4, all_bad_trials] = get_ebt(dir);
    arguments
        dir (1, 1) struct
    end
    [~, subject] = fileparts(dir.RF);
    grid_type = strsplit(dir.stim, '\'); grid_type = grid_type(find(grid_type == subject, 1) + 1);
    RF_data = fullfile(dir.RF, strcat(subject, grid_type, "RFData.mat"));
    valid_elecs = load(RF_data).highRMSElectrodes;
    if subject == "dona"
        V1.list = 1:48;
        V4.list = 49:96;
        if isfolder(dir.resp)
            V4.bad_elecs = load(fullfile(dir.resp, "badTrialsV4.mat")).badElecs;
            all_bad_trials = load(fullfile(dir.resp, "badTrialsV4.mat")).allBadTrials;
            all_bad_trials(1:48) = load(fullfile(dir.resp, "badTrialsV1.mat")).allBadTrials;
        end
    elseif subject == "jojo"
        V1.list = 49:96;
        V4.list = 1:48;
        if isfolder(dir.resp)
            V4.bad_elecs = [];
            all_bad_trials = load(fullfile(dir.resp, "badTrialsV1.mat")).allBadTrials; 
        end
    end
    if isfolder(dir.resp), V1.bad_elecs = load(fullfile(dir.resp, "badTrialsV1.mat")).badElecs; end
    V1.valid_elecs = intersect(V1.list, valid_elecs);
    V4.valid_elecs = intersect(V4.list, valid_elecs);
    if isfolder(dir.resp)
        V1.good_elecs = setdiff(V1.valid_elecs, V1.bad_elecs);
        V4.good_elecs = setdiff(V4.valid_elecs, V4.bad_elecs);
    end
end