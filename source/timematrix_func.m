function fs_time_matrix = timematrix_func(time_cell)
    number_of_datapoints = zeros(size(time_cell,1),1);
    for i = 1:size(time_cell,1)
        number_of_datapoints(i) = size(time_cell{i},1);
    end

    fs_time_matrix = zeros(size(time_cell,1),max(number_of_datapoints));
    for i = 1:size(time_cell,1)
        fs_time_matrix(i,1:length(time_cell{i})) = time_cell{i}';
    end