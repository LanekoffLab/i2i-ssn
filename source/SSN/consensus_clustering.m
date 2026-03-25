function [validGroups, consistentGraph, adjacencyMatrix] = consensus_clustering(pairAgreement, mzValues, threshold1, minClusterSize)
%CONSENSUS_CLUSTERING Cluster nodes based on consensus matrix thresholding.
%
%   [validGroups, consistentGraph] = consensus_clustering(pairAgreement, mzValues, threshold1, minClusterSize)
%
%   Inputs:
%       pairAgreement    - [numImages x numImages] consensus matrix (values in [0,1])
%       mzValues         - vector of m/z values (length = numImages)
%       threshold1       - agreement threshold (e.g., 1 for 100% agreement)
%       minClusterSize   - minimum number of members for a cluster to be considered valid
%
%   Outputs:
%       validGroups      - cell array of valid clusters (each a vector of image indices)
%       consistentGraph  - MATLAB graph object built from thresholded consensus

    % Build adjacency matrix based on threshold
    adjacencyMatrix = pairAgreement >= threshold1;

    % Build graph and label nodes with m/z values
    consistentGraph = graph(adjacencyMatrix, 'omitselfloops');
    consistentGraph.Nodes.Name = cellstr(num2str(mzValues));

    % Connected components (clusters)
    finalClusters = conncomp(consistentGraph);
    numFinalClusters = max(finalClusters);

    % Filter clusters based on size
    validGroups = {};
    for i = 1:numFinalClusters
        members = find(finalClusters == i);
        if numel(members) >= minClusterSize
            validGroups{end+1} = members;
        end
    end
end
