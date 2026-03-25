function patchIdx = generate_patch_indexers(imageSize, N)
%GENERATE_PATCH_INDEXERS Divide image into N x N patches.
%
%   patchIdx = generate_patch_indexers(imageSize, N)
%
%   Inputs:
%       imageSize - a 2-element vector [rows, cols] specifying the size of the image
%       N         - number of patches per dimension (e.g., 2 means 2x2 = 4 patches)
%
%   Output:
%       patchIdx  - cell array of function handles. Each handle extracts a patch.

    rows = imageSize(1);
    cols = imageSize(2);
    patches = N * N;

    xEdges = round(linspace(1, rows + 1, N + 1));
    yEdges = round(linspace(1, cols + 1, N + 1));

    patchIdx = cell(patches, 1);
    count = 1;
    for i = 1:N
        for j = 1:N
            xStart = xEdges(i);
            xEnd = xEdges(i+1) - 1;
            yStart = yEdges(j);
            yEnd = yEdges(j+1) - 1;

            patchIdx{count} = @(img) img(xStart:xEnd, yStart:yEnd);
            count = count + 1;
        end
    end
end