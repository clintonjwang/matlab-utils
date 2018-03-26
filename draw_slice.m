function draw_slice(img, mask, slice)
%DRAW_SLICE
    if nargin < 3
        slice = round(size(img, 3) / 2);
    end
    
    if ~exist('mask','var') || isempty(mask)
        imshow(img(:,:,slice), [0,max(img(:))]);
    else
        imshow(img(:,:,slice) .* mask(:,:,slice), [0,max(img(:))]);
    end
end