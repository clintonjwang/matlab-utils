function filename_map = load_config(filename)
%LOAD_CONFIG Summary of this function goes here
%   Detailed explanation goes here
    filename_map = containers.Map;
    fid = fopen(filename);
    tline = fgetl(fid);
    while ischar(tline)
       matches = strfind(tline, ':');
       filename_map(tline(1:matches(1)-1)) = tline(matches(1)+2:end);
       tline = fgetl(fid);
    end
    fclose(fid);
end

