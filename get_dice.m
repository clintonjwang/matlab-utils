function dice = get_dice()
% Try to detect masks automatically, otherwise prompt to select them

    f=dir(fullfile('.', '*.ids'));
    if length(f) == 2
        path1 = [f(1).folder, '\', f(1).name];
        path2 = [f(2).folder, '\', f(2).name];
    else
        [fname,outpath] = uigetfile('*.ids', 'Select first segmentation');
        path1 = [outpath,fname];

        [fname,outpath] = uigetfile('*.ids', 'Select second segmentation');
        path2 = [outpath,fname];
    end

    % Try to automatically detect .ics files corresponding to one of them
    fileID = fopen([path1(1:end-4), '.ics']);
    if fileID == -1
        [fname,outpath] = uigetfile('*.ics', ['Select the ics file corresponding to ', path1]);
        fileID = fopen([outpath,fname]);
    end

    A = fscanf(fileID,'%c');
    ics_text = strsplit(A(regexp(A, '\nlayout\tsizes\t8\t')+length('layout\tsizes\t8') :...
                regexp(A, '\nlayout\tcoordinates')-2));
    dims = cellfun(@str2num, ics_text);

    mask1 = get_mask(path1, dims(1), dims(2), dims(3));
    mask2 = get_mask(path2, dims(1), dims(2), dims(3));

    A1 = sum(sum(sum(mask1)));
    A2 = sum(sum(sum(mask2)));
    overlap = sum(sum(sum(mask1 & mask2)));
    dice = 2 * overlap / (A1+A2);
end