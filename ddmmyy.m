function out = ddmmyy(in)
% Converts a 6 digit yymmdd numeric to a ddmmyy string, the convention in our lab.
    out = char(string(in));
        if length(out) < 6, out = [repmat('0', 1, 6 - length(out)), out]; end % Ensures the leading 0s are kept
    dd = out([5, 6]);
    mm = out([3, 4]);
    yy = out([1, 2]);
    out = string([dd, mm, yy]);
end