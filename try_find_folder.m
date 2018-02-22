function output_path = try_find_folder( search_dir, pattern, msg, get_first )
%TRY_FIND_FOLDER Tries to find a file matching a given pattern in path.
%   Assumes the folder has at least 2 files within

    if nargin < 4
        get_first = false;
    end

    f=dir(fullfile(search_dir, pattern));

    if get_first && ~isempty(f)
        output_path = f(1).folder;
    elseif ~isempty(f) && strcmp(f(1).folder, f(end).folder)
        output_path = f(1).folder;
    else
        output_path = uigetdir(search_dir, msg);
    end
end

