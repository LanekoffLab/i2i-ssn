function [ssn_graph, nodeNames2] = create_graph(r1, SSELIMIT, similarity_matrix)
            similarity_matrix(similarity_matrix ==0)=NaN;     % Set 0 to NaN.
            SSELIMIT = prctile(similarity_matrix, SSELIMIT, 'all');
            DEGREELIMIT = 0;
            matrixForSSE = similarity_matrix<SSELIMIT;
            nodeNames = num2cell(r1(:,2));
            nodeNames = cellfun(@num2str,nodeNames,'UniformOutput',false);
            mathematicalGraph = graph(matrixForSSE.*similarity_matrix,nodeNames,'lower','omitselfloops'); % Create graph
            degreeVector = degree(mathematicalGraph);
            degreeVector = degreeVector > DEGREELIMIT;
            smallerMatrix = matrixForSSE(degreeVector, degreeVector);
            weightsMatrix = similarity_matrix(degreeVector, degreeVector);
            nodeNames2 = nodeNames(degreeVector);
            % Create the graph and plot it in the specified uiaxes
            ssn_graph = graph(smallerMatrix .* weightsMatrix, nodeNames2, 'lower', 'omitselfloops');
            
end