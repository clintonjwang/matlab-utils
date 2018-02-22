function mask_to_mesh( mask_path, save_path )
%MASK_TO_MESH Summary of this function goes here
%   Detailed explanation goes here

    fileID = fopen([mask_path,'.ics']);
    A = fscanf(fileID,'%c');
    scales = sscanf(A(regexp(A, 'scale\t')+8:regexp(A, 'parameter\taxisX')-3), '%f');
    dims = sscanf(A(regexp(A, 'sizes\t')+8:regexp(A, 'layout\tcoordinates')-3), '%d');
    lims = dims .* scales;
    
    if nargin == 1
        save_path = [mask_path, '.off'];
    end
    
    mask = get_mask(mask_path, false);
    
    [x,y,z] = meshgrid(scales(2):scales(2):lims(2),...
        scales(1):scales(1):lims(1), scales(3):scales(3):lims(3));
    x = single(x);
    y = single(y);
    z = single(z);
    mask = mask > 0.01;
    if size(mask,1) ~= size(x,1)
        mask = permute(mask, [2,1,3]);
    end
        
    [triangles,vertices] = MarchingCubes(x,y,z,mask,0.5);
    triangles = uint32(triangles);
    vertices = single(vertices);
    WriteTriangulatedMeshToOffFile(triangles',vertices',save_path);
end

