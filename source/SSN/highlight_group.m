function highlight_group(group, h, mathematicalGraph, nodeNames2)
    
    if ~isempty(group)
        mzNodes = str2double(nodeNames2);  
        mzGroup = group;
        [~, nodeIndices] = ismembertol(mzGroup, mzNodes, 1e-6);
        nodeIndices = nodeIndices(nodeIndices > 0);  % remove unmatc
        if ~isempty(nodeIndices)
            highlight(h, nodeIndices, 'NodeColor', 'r');
            edgesInGroup1 = findedge(mathematicalGraph, nodeIndices, nodeIndices);
            edgesInGroup1(edgesInGroup1 == 0) = [];
            highlight(h, 'Edges', edgesInGroup1, 'EdgeColor', 'r', 'LineWidth', 1.5);
        end
    end
end