function dir = get_dir(subject, kwargs)
    % Essential directories associated with an experiment. Example use case:
    % dir = get_dir(subject="Dona", protocol="NIL", idx=1, date=241007);
    % Assigns dummy directories to dir.stim and dir.resp if only subject specified, in case only dir.RF matters.
    arguments
        subject (1, 1) string
        kwargs.protocol (1, 1) string = "XXX"
        kwargs.idx (1, 1) double = 0
        kwargs.date (1, 1) double = 999999
        kwargs.pdir (1, 1) string = "E:"
        kwargs.grid_type (1, 1) string = "Microelectrode"
    end
    dir.RF = fullfile(kwargs.pdir, "data/rfData", lower(subject));
    dir.stim = fullfile(kwargs.pdir, "data", lower(subject), kwargs.grid_type, ddmmyy(kwargs.date), ...
    sprintf(kwargs.protocol + "_%03d", kwargs.idx), "extractedData");
    dir.resp = fullfile(fileparts(dir.stim), "segmentedData");
end