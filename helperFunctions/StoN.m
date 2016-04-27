function[out] = StoN(in)
%{
StoN checks if input variable is character and if it is, StoN converts
character to numeric and return the value.
%}
try
    % if char, convert to num and return
    if ischar(in)
        out = str2num(in);
    % if not char, return as it is 
    else 
        out = in;
    end
catch ME
    close all;
    getReport(ME);
    fprintf(['******error in:StoN.m******\n']);
end
end