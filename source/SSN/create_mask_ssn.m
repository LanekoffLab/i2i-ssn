function mask = create_mask_ssn(stn_time)
% Creates a mask covering all time points. Used when no mask is supplied to 
% the STN. 
    [rowCount, ~] = size(stn_time);
    mask = zeros(rowCount, 3);
    mask(:, 1) = (1:rowCount)';
    mask(:, 2) = stn_time(:, 1);
    mask(:, 3) = max(stn_time, [], 2);
end