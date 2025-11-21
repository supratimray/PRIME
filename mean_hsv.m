function [h, s, v] = mean_hsv(img, kwargs)
    % Vector averaging for H, S as expected in a cylindrical basis, and standard averaging for V
    arguments
        img uint8
        kwargs.mask logical = true([size(img, 1), size(img, 2)])
    end
    if length(size(img)) == 2 % Grayscale
        h = 0;
        s = 0;
        v = mean(img(kwargs.mask))/255;
    elseif length(size(img)) == 3 % Color
        img = rgb2hsv(img);
        H = img(:, :, 1);
        H = H(kwargs.mask);
        S = img(:, :, 2);
        S = S(kwargs.mask);
        V = img(:, :, 3);
        V = V(kwargs.mask);
        N = numel(H);
        x_tot = sum(S.*cos(2*pi*H));
        y_tot = sum(S.*sin(2*pi*H));
        h = (2*pi*(atan2(y_tot, x_tot) < 0) + atan2(y_tot, x_tot))/(2*pi); % atan2 has output in radians [-pi, pi], which we convert to [0, 2pi]. This function takes care of signs so we don't have to
        s = (((x_tot)^2 + (y_tot)^2)^0.5)/N;
        v = mean(V);
    end    
end