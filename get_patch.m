function img_patch = get_patch(img, X, Y, kwargs)
    % Returns an RF centered (in degrees) square patch from an image file. X and Y coordinate meshgrids to be provided. 
    % Patch dimensions in degrees or pixels as specified (follows half-space convention, i.e., the full square will be of 
    % side length 2*half_length).
    arguments
        img double
        X double
        Y double
        kwargs.RF_center (1, 2) double = [0, 0]
        kwargs.half_length double = 2 
        kwargs.deg (1, 1) logical = true
        kwargs.mode (1, 1) string = "RGB"
    end

    x_axis_deg = X(1, :);
    y_axis_deg = Y(:, 1);

    x_dpp = x_axis_deg(2) - x_axis_deg(1);
    y_dpp = y_axis_deg(2) - y_axis_deg(1);

    azi_deg = kwargs.RF_center(1); ele_deg = kwargs.RF_center(2);

    % Convert to pixel coordinates
    [~, azi_px] = min(abs(x_axis_deg - azi_deg));
    [~, ele_px] = min(abs(y_axis_deg(end:-1:1) - ele_deg));

    if kwargs.deg % Extract patch of 2 x specified degrees width and height
        x_ppd = 1/x_dpp;
        y_ppd = 1/y_dpp;
        try
            hlx = round(kwargs.half_length(1)*x_ppd, 0);
            hly = round(kwargs.half_length(2)*y_ppd, 0);
        catch
            hlx = round(kwargs.half_length*x_ppd, 0);
            hly = round(kwargs.half_length*y_ppd, 0);
        end
    else % Extract patch of 2 x specified pixels width and height
        try
            hlx = kwargs.half_length(1);
            hly = kwargs.half_length(2);
        catch
            hlx = kwargs.half_length;
            hly = hlx;
        end
    end
    if kwargs.mode == "RGB" % Has color channels
        img_patch = uint8(img((ele_px - hly):(ele_px + hly - 1), (azi_px - hlx):(azi_px + hlx - 1), :));
    else % Assumes 2D grayscale or 'L'
        img_patch = uint8(img((ele_px - hly):(ele_px + hly - 1), (azi_px - hlx):(azi_px + hlx - 1), 1)); % The 1 is usually not necessary, but our TIF files have been saved as 24bit depth
    end
end