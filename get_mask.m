function mask = get_mask(fpath, dcm_path, target_dims)
    if endsWith(fpath,'.ids')
        fpath = fpath(1:end-4);
    end
    fileID = fopen([fpath,'.ics']);
    A = fscanf(fileID,'%c');
    D = sscanf(A(regexp(A, 'sizes\t')+8:regexp(A, 'layout\tcoordinates')-3), '%d');
    N1 = D(1);
    N2 = D(2);
    N3 = D(3);
    scale = sscanf(A(regexp(A, 'scale\t')+8:regexp(A, 'parameter\taxisX')-3), '%f');
    pad = sscanf(A(regexp(A, 'origin\t')+8:regexp(A, 'parameter\tscale')-3), '%f');

    fileID = fopen([fpath,'.ids']);
    A = fread(fileID);
    ind = find(A);
    [i, j, k]=ind2sub([N1,N2,N3],ind);
    fclose('all');

    mask = zeros(N1,N2,N3);
    for count=1:length(i) 
        mask(i(count),j(count),k(count))=1;
    end
    
%     mask = rot90(mask, 2);
    
    if exist('dcm_path','var') && ~isempty(dcm_path)
        [~,spatial,~] = dicomreadVolume(dcm_path);
        vox_dims = [spatial.PixelSpacings(1:2), abs(spatial.PatientPositions(2,3) - spatial.PatientPositions(1,3))];
        scale = scale' ./ vox_dims;
        mask = imresize3(mask,round(scale .* [N1, N2, N3]));
        mask = uint8(mask > 0.01)*255;
        pad = pad' ./ vox_dims;
        mask = padarray(mask,round(pad),0,'post');
%         mask = padarray(mask,[round(pad(0)), round(pad(1)), 0],0,'post');
%         mask = padarray(mask,[0,0,round(pad(2))],0,'pre');
        mask = permute(mask, [2,1,3]);
        
        if exist('target_dims','var') && ~isempty(target_dims)
            dx = (target_dims - size(mask)) / 2;
            mask = padarray(mask,ceil(dx),0,'pre');
            mask = padarray(mask,floor(dx),0,'post');
        end
    end
%     320,250,80
%     if transpose
%         mask = transpose_mask_slices(mask, 'r');
%     end
end 