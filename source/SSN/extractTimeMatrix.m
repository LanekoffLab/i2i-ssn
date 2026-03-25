function time_out = extractTimeMatrix(time_data)
    % Extracts and constructs the time matrix from the provided time_data
    
    % Get the maximum number of scans in one line scan to initialize the matrix
    number_of_datapoints = zeros(size(time_data, 1), 1);
    for i = 1:size(time_data, 1)
        number_of_datapoints(i) = size(time_data{i}, 1);
    end
    
    % Initialize the time matrix
    time_out = zeros(size(time_data, 1), max(number_of_datapoints));
    
    % Construct the time matrix
    for i = 1:size(time_data, 1)
        time_out(i, 1:length(time_data{i})) = time_data{i}';
    end
end