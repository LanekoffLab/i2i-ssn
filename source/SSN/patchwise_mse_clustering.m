function [allGroups, allPairwise] = patchwise_mse_clustering(normalized_images, patchIdx, thresholdPercentile, metric)
%PATCHWISE_MSE_CLUSTERING Patch-wise image clustering with selectable metric.
%
%   IMPORTANT: This version reproduces the ORIGINAL behavior exactly:
%     - thresholdPercentile is used AS-IS (e.g., 0.05 means 0.05th percentile)
%     - distances computed for i..j, then symmetrized via D = D + D' (doubling off-diagonals)
%     - percentile computed over D(:) (includes diagonal zeros & both triangles)
%     - edges where D < thresh (strict)
%     - NaNs are left as-is (prctile ignores NaNs)
%
%   Inputs:
%     normalized_images   - cell array of images (2D matrices)
%     patchIdx            - cell array of function handles, each extracts a patch from an image
%     thresholdPercentile - SAME UNITS as your original call (no rescaling)
%     metric              - 'MSE' (default), 'SSE', or 'cosine'
%
%   Outputs:
%     allGroups   - cell array: for each patch, a component label per image
%     allPairwise - cell array: for each patch, the pairwise distance matrix used

    if nargin < 4 || isempty(metric)
        metric = 'MSE';
    end
    metric = lower(string(metric));

    numImages  = numel(normalized_images);
    numPatches = numel(patchIdx);

    allGroups   = cell(numPatches, 1);
    allPairwise = cell(numPatches, 1);

    parfor p = 1:numPatches
        % Extract patch p from all images
        patch_images = cellfun(patchIdx{p}, normalized_images, 'UniformOutput', false);

        % Pairwise distances (lower = more similar)
        D = zeros(numImages, numImages);

        for i = 1:numImages
            Ai = patch_images{i};
            for j = i:numImages
                Aj = patch_images{j};

                switch metric
                    case "mse"
                        diff  = Ai - Aj;
                        valid = ~isnan(diff);
                        nValid = sum(valid(:));
                        if nValid == 0
                       
                            d = 0 / 0; % NaN
                        else
                          
                            d = nansum(diff(:).^2) / nValid;
                        end

                    case "sse"
                        diff  = Ai - Aj;
                        valid = ~isnan(diff);
                        if ~any(valid(:))
                            d = 0 / 0; % NaN, to mirror original behavior
                        else
                            % sum of squared errors over valid pixels
                            d = nansum(diff(:).^2);
                        end

                    case "cosine"
                        valid = ~isnan(Ai) & ~isnan(Aj);
                        if ~any(valid(:))
                            d = 0 / 0; % NaN
                        else
                            a = Ai(valid); b = Aj(valid);
                            na = norm(a); nb = norm(b);
                            if na == 0 || nb == 0
                                d = 0 / 0; % NaN (undefined similarity)
                            else
                                cos_sim = (a(:)' * b(:)) / (na * nb);
                                d = 1 - cos_sim; % cosine distance (lower = more similar)
                            end
                        end

                    otherwise
                        error('Unknown metric "%s". Use "MSE", "SSE", or "cosine".', metric);
                end

                D(i, j) = d;
            end
        end

        D = D + D';
        allPairwise{p} = D;
        threshVal = prctile(D(:), thresholdPercentile);

        A = (D < threshVal);

        G    = graph(A, 'omitselfloops');
        comp = conncomp(G);

        allGroups{p} = comp;
    end
end
