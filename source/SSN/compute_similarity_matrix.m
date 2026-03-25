function output = compute_similarity_matrix(analyte_matrix, metric)
prctileValues = cellfun(@(x) prctile(x, 99.9, 'all'), analyte_matrix, 'UniformOutput', true);
totalIterations = length(analyte_matrix);
output = zeros(totalIterations);

h = waitbar(0, 'Running SSN: 0%');
if strcmp(metric,'Cosine')
    for j = 1:totalIterations
        anchor = analyte_matrix{j} ./ prctileValues(j);
        for i = j:totalIterations
            current_im = analyte_matrix{i} ./ prctileValues(i);
            similarity = dot(current_im(:), anchor(:)) / (norm(current_im(:)) * norm(anchor(:)));
            output(i, j) = 1 - similarity;
        end
        waitbar(j / totalIterations, h, sprintf('Running SSN: %.2f%%', (j / totalIterations) * 100));
    end
    close(h);

elseif strcmp(metric,'MSE')
    for j = 1:totalIterations
        anchor = analyte_matrix{j} ./ prctileValues(j);
        for i = j:totalIterations
            current_im = analyte_matrix{i} ./ prctileValues(i);
            mse = mean((current_im - anchor).^2, 'all');   % Mean Squared Error
            output(i, j) = mse;
        end
        waitbar(j / totalIterations, h, sprintf('Running SSN: %.2f%%', (j / totalIterations) * 100));
    end
    close(h);

else
    for j = 1:totalIterations
        anchor = analyte_matrix{j} ./ prctileValues(j);
        for i = j:totalIterations
            current_im = analyte_matrix{i} ./ prctileValues(i);
            dff = sum(abs(current_im - anchor).^2, 'all');
            output(i, j) = dff;
        end
        waitbar(j / totalIterations, h, sprintf('Running SSN: %.2f%%', (j / totalIterations) * 100));
    end
    close(h);
end
