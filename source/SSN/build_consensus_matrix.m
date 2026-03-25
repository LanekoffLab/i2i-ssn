function pairAgreement = build_consensus_matrix(allGroups)
%BUILD_CONSENSUS_MATRIX Compute consensus pair agreement matrix from patch-wise clusters.
%
%   pairAgreement = build_consensus_matrix(allGroups)
%
%   Inputs:
%       allGroups - cell array of cluster label vectors (one per patch)
%
%   Output:
%       pairAgreement - [numImages x numImages] matrix of pairwise agreement scores in [0, 1]

    patches = numel(allGroups);
    numImages = length(allGroups{1});
    pairAgreement = zeros(numImages);

    for p = 1:patches
        groups = allGroups{p};
        for i = 1:numImages
            for j = i+1:numImages
                sameCluster = (groups(i) == groups(j));
                pairAgreement(i, j) = pairAgreement(i, j) + sameCluster;
                pairAgreement(j, i) = pairAgreement(i, j);  % symmetric
            end
        end
    end

    pairAgreement = pairAgreement / patches;
    pairAgreement(1:numImages+1:end) = 1;  % diagonal = 1
end
