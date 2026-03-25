% Tidy up data to extract data from the correct scan event.
% The datastructure with the ion intensites, time matrix and total ion
% current matrix is adjusted.

function [analyte_matrix,time_out] = scanevent3(signal_inten,time_data,MHmass)
   

    % Initialize new cell array and extract scan m out of n events.
    signal_inten_out = signal_inten;

    
    %Get the maximum number of scans in one line scan, to ininialize the
    %matrix.
    number_of_datapoints = zeros(size(time_data,1),1);
    for i = 1:size(time_data,1)
        number_of_datapoints(i) = size(time_data{i},1);
    end 
    
    %Initialize time matrix and construct the time matrix.
    time_out = zeros(size(time_data,1),max(number_of_datapoints));
    for i = 1:size(time_data,1)
        time_out(i,1:length(time_data{i})) = time_data{i}';
    end
    
    %Filter out unwanted scan events in the time matrix and tic matrix
   % time_out = time_data;
%     tic_out{1} = tot_ion_current(:,m:n:size(tot_ion_current,2));
    
    %Package output with regards to MHmass
    analyte_matrix = cell(length(MHmass),1);
    for i = 1:length(MHmass)
        tmp = zeros(1);
        for j = 1:length(signal_inten_out)
            %a = signal_inten_out{j};
            linescan_specific_ion = signal_inten_out{j}(i,:);
            tmp(j,1:length(linescan_specific_ion)) = linescan_specific_ion;
        end
        analyte_matrix{i} = tmp;
    end