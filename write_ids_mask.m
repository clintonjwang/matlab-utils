function write_ids_mask( mask, search_path, save_dir, name, include_mesh, vox_dims )
%MAKE_IDS_MASK Summary of this function goes here
%   write_ids_mask( mask, search_path, save_dir, name )
    
    if ~exist('include_mesh','var') || isempty(include_mesh)
        include_mesh = true;
    end

    if ~exist('search_path','var') || isempty(search_path)
        search_path = pwd();
    end
    
    if max(mask(:)) == 1
        mask = mask * 255;
    end
    if size(mask,1) < size(mask,2)
        mask = permute(mask, [2,1,3]);
    end
    mask = uint8(rot90(mask,2));%transpose_mask_slices(mask, 'w'));
    
    if endsWith(search_path, '.ids')
        fpath = [search_path(1:end-4), '.ics'];
    else
        fpath = try_find_file(search_path, '**/*.ics',...
                    'Select any .ics file for this study', '*.ics', true);
    end
    ids_filename = [save_dir, '\', name, '.ids'];
    fileID = fopen(fpath);
    A = fscanf(fileID,'%c');
    if exist('vox_dims','var') && ~isempty(vox_dims)
        A = replace(A, A(regexp(A, 'parameter\tscale'):regexp(A, 'parameter\taxisX')-3),...
            sprintf('parameter\tscale\t1\t%0.3f\t%0.3f\t%0.3f',vox_dims(1),...
                vox_dims(2),vox_dims(3)));
        A = replace(A, A(regexp(A, 'layout\tsizes'):regexp(A, 'layout\tcoordinates')-3),...
            sprintf('layout\tsizes\t8\t%d\t%d\t%d',size(mask,1),...
                size(mask,2),size(mask,3)));
        A = replace(A, A(regexp(A, 'parameter\torigin'):regexp(A, 'parameter\tscale')-3),...
            sprintf('parameter\torigin\t0\t0.000\t0.000\t0.000'));
    end
    ics_text = replace(A, A(regexp(A, '\nfilename')+1:regexp(A, '.ids')+3),...
        [sprintf('filename\t'), pwd(), '\', ids_filename]);

    fileID = fopen([save_dir, '\', name, '.ics'],'w');
    fwrite(fileID, ics_text);
    
    fileID = fopen(ids_filename,'w');
    fwrite(fileID, mask);
    fclose('all');
    
    if include_mesh
        mask_to_mesh(ids_filename(1:end-4))
    end

end
