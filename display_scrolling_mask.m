function display_scrolling_mask(img_name, img_dir, mask_dir, orig_mask_names, mask_display_names)
%DISPLAY_SCROLLING_MASK Summary of this function goes here
%   Detailed explanation goes here
    
    % Remember which masks were given which color and display name
    orig_mask_names = get_mask_names(orig_mask_names, mask_dir);
    colors_default = {'or', 'ob', 'og'};
    colors_default = colors_default(1:length(orig_mask_names));
    
    color_map = containers.Map(orig_mask_names, colors_default);
    name_map = containers.Map(orig_mask_names, mask_display_names);
    
    mask_names = orig_mask_names;
    [img, orig_img] = obtain_3d_mask(img_name, mask_names, img_dir, mask_dir);
    
    [~,~,max_slice,~] = size(img);
    slice_num = round(max_slice/2);

    img_slice = squeeze(img(:,:,slice_num,:));
    figure('Name', [img_name, ' masked']);
    image(img_slice,'CDataMapping','scaled');
    hold on;
    title([img_name, ' masked']);
    
    replot_legend();

    if ~isempty(mask_display_names)
        uicontrol('Style', 'checkbox', 'String', ['Show ', name_map(char(mask_names(1)))],...
            'Position', [20 70 120 20], 'Value', 1,...
            'Callback', @toggle_vasc);
        if length(mask_display_names) > 1
            uicontrol('Style', 'checkbox', 'String', ['Show ', name_map(char(mask_names(2)))],...
                'Position', [20 45 120 20], 'Value', 1,...
                'Callback', @toggle_nec);
            if length(mask_display_names) > 2
                uicontrol('Style', 'checkbox', 'String', ['Show ', name_map(char(mask_names(3)))],...
                    'Position', [20 20 120 20], 'Value', 1,...
                    'Callback', @toggle_tumor);
            end
        end
    end

    % Create slider
    uicontrol('Style', 'slider',...
        'Min',1,'Max',max_slice,'Value',slice_num,...
        'Position', [400 20 120 20],...
        'Callback', @shift_slice);

    % Add a text uicontrol to label the slider.
    uicontrol('Style','text',...
        'Position',[400 45 120 20],...
        'String','Slice (fraction)');
    
    function replot_legend
        for i = 1:length(mask_names)
            legend_names{i} = name_map(char(mask_names(i)));
        end

        if ~isempty(mask_names)
            h(1) = plot(NaN,NaN, color_map(char(mask_names(1))));
            if length(mask_names) > 1
                h(2) = plot(NaN,NaN, color_map(char(mask_names(2))));
                if length(mask_names) > 2
                    h(3) = plot(NaN,NaN, color_map(char(mask_names(3))));
                end
            end
            legend(h, legend_names, 'Interpreter', 'none');
        end
    end
    
    function shift_slice(source,~)
        old_slice = slice_num;
        slice_num = round(source.Value);
        if old_slice ~= slice_num
            replot(false);
        end
    end

    function toggle_vasc(source,~)
        toggle_mask(orig_mask_names(1), source);
    end

    function toggle_nec(source,~)
        toggle_mask(orig_mask_names(2), source);
    end

    function toggle_tumor(source,~)
        toggle_mask(orig_mask_names(3), source);
    end

    function toggle_mask(mask_name, source)
        if source.Value == source.Max
            mask_names{length(mask_names) + 1} = char(mask_name);
        else
            todelete = false(size(mask_names));
            for c = 1:length(mask_names)
                todelete(c) = strcmp(mask_names{c}, char(mask_name)) == 1;
            end
            mask_names(todelete) = [];
        end

        replot(true);
    end

    function replot(get_new_image)
        if get_new_image
            img = apply_mask(orig_img, mask_names, mask_dir);
        end
        img_slice = squeeze(img(:,:,slice_num,:));
        image(img_slice,'CDataMapping','scaled');
        
        for x = 1:length(mask_names)
            legend_names{x} = name_map(mask_names{x});
        end
        
        h = zeros(length(mask_names), 1);
        if ~isempty(mask_names)
            h(1) = plot(NaN,NaN, color_map(char(mask_names(1))));
            if length(mask_names) > 1
                h(2) = plot(NaN,NaN, color_map(char(mask_names(2))));
                if length(mask_names) > 2
                    h(3) = plot(NaN,NaN, color_map(char(mask_names(3))));
                end
            end
            legend(h, legend_names, 'Interpreter', 'none');
        end
    end
end

function mask_names = get_mask_names(mask_names, data_dir)
    for i = 1:length(mask_names)
        [~,mask_names{i},~] = fileparts(try_find_file(data_dir, ['**/*', mask_names{i}, '*.ids'],...
                    'Select the masks to apply', '*.ids'));
    end
end

function [img, unmasked_img] = obtain_3d_mask(img_name, mask_names, img_dir, mask_dir)
%TKTK Displays MRI slice with binary mask overlay
%   Mask is colored

    nii_ext = {'*.nii; *.hdr; *.img; *.nii.gz'};
    
    data = load_nii(try_find_file(img_dir, ['**/', img_name, '.nii*'],...
            'Select the base image for the masks (usually arterial phase).', nii_ext));
    img = double(flip_image(data.img));
    
    img = img/max(max(max(img)));
    img(:,:,:,2) = img(:,:,:,1);
    img(:,:,:,3) = img(:,:,:,1);
    
    unmasked_img = img;
    img = apply_mask(img, mask_names, mask_dir);
end


function img = apply_mask(img, mask_names, mask_dir)
%TKTK Displays MRI slice with binary mask overlay
%   Mask is colored

    [N1,N2,N3,~] = size(img);
    if ~isempty(mask_names)
        f = try_find_file(mask_dir, ['**/', char(mask_names{1}), '.ids'],...
                    'Select the first mask to apply', '*.ids');
        mask = logical(get_mask(f, N1,N2,N3));
%         img(:,:,:,2) = img(:,:,:,2) .* ~mask;
%         img(:,:,:,3) = img(:,:,:,3) .* ~mask;
        img(:,:,:,1) = img(:,:,:,1) + (1 - img(:,:,:,1)) .* (mask * 0.1);

        if length(mask_names) > 1
            f = try_find_file(mask_dir, ['**/', char(mask_names{2}), '.ids'],...
                        'Select the second mask to apply', '*.ids');
            mask = logical(get_mask(f, N1,N2,N3));

%             img(:,:,:,1) = img(:,:,:,1) .* ~mask;
%             img(:,:,:,2) = img(:,:,:,2) .* ~mask;
            img(:,:,:,3) = img(:,:,:,3) + (1 - img(:,:,:,3)) .* (mask * 0.1);

            if length(mask_names) > 2
                f = try_find_file(mask_dir, ['**/', char(mask_names{3}), '.ids'],...
                            'Select the third mask to apply', '*.ids');
                mask = logical(get_mask(f, N1,N2,N3));

                img(:,:,:,2) = img(:,:,:,2) + (1 - img(:,:,:,2)) .* (mask * 0.1);
            end
        end
    end
end