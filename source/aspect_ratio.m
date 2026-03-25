% aspect ratio

function x = aspect_ratio(fs_time,velocity,spacing)
    NumberOfLines = size(fs_time,1);
    max_t = max(fs_time{1,1});
    Dimension1 = velocity*max_t*60;
    Dimension2 = NumberOfLines*spacing;
    
    x = Dimension1/Dimension2;
%     width = 700; %in pixels
%     height = width / x; %divide by the w/h ratio of the aligned ion image
%     set(gcf, 'position', [500, 100, width, height])
%     pbaspect([x 1 1]);
end
    