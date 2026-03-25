function [updatedSimilarmzItems, updatedGroupNames, matchedMz] = show_database_matches(similarmzItems, selectedGroup, analytes, groups, cutoffppm, useRounding)
    % Initialize variables
    numGroups = length(groups);
    groupNames = arrayfun(@(x) sprintf('Group %d', x), 1:numGroups, 'UniformOutput', false); % Generate group names
    updatedGroupNames = groupNames; % Copy for modification
    updatedSimilarmzItems = cell(size(similarmzItems)); % Preallocate
    matchedMz = cell(numGroups, 1);  % Store matched m/z values per group

    % Update SimilarmzListBox items
    if ~isempty(analytes) && ~isempty(selectedGroup)
        for idx = 1:length(selectedGroup)
            selectedMz = selectedGroup(idx);
            selectedMzStr = sprintf('%.4f', selectedMz);

            if useRounding
                roundedGroupMz = round(selectedGroup);
                matchIdx = find(round(analytes{:, 1}) == roundedGroupMz(idx), 1);
                matched = ~isempty(matchIdx);
            else
                ppmDifferences = abs((analytes{:, 1} - selectedMz) ./ selectedMz) * 1E6;
                matchIdx = find(ppmDifferences <= cutoffppm, 1);
                matched = ~isempty(matchIdx);
            end

            % Update SimilarmzItems
            if matched
                updatedSimilarmzItems{idx} = sprintf('%s 🟢', selectedMzStr);
            else
                updatedSimilarmzItems{idx} = selectedMzStr;
            end
        end
    else
        updatedSimilarmzItems = similarmzItems; % No changes if data is missing
    end

    % Update GroupsListBox items and collect matched m/z
    if ~isempty(analytes)
        for groupIdx = 1:numGroups
            groupMzValues = groups{groupIdx};
            matchedMz{groupIdx} = [];  % Initialize empty list

            if useRounding
                roundedGroupMzValues = round(groupMzValues);
                for mzValue = roundedGroupMzValues'
                    if any(round(analytes{:, 1}) == mzValue)
                        matchedMz{groupIdx}(end+1) = mzValue; %#ok<AGROW>
                    end
                end
            else
                for mzValue = groupMzValues'
                    ppmDifferences = abs((analytes{:, 1} - mzValue) ./ mzValue) * 1E6;
                    if any(ppmDifferences <= cutoffppm)
                        matchedMz{groupIdx}(end+1) = mzValue; %#ok<AGROW>
                    end
                end
            end

            % Append green emoji if any matches
            if ~isempty(matchedMz{groupIdx})
                updatedGroupNames{groupIdx} = sprintf('%s 🟢', groupNames{groupIdx});
            end
        end
    end
end
