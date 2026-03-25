% Align data from different scan events to time. The pixel width in the
% scanning direction is directly proportional to the time of aqusition. But
% the aqusition time is slightly different in each line scan. A time axis
% is defined from 0 to the biggest number in the time matrix fs_time.
% Values for the empty space is interpolated to the nearest pixels with the
% same numeric value. This allows for fast and easy adjustment of pixel
% intensities on the same time scale which allows for proper representation
% of the ion image.

function [aligned_matrix,time_simulated] = align_dev2(time_out,analyte_matrix)
% Initialize paralell pool and variables.
    function nUpdateWaitbar(~)
        waitbar(p/length(analyte_matrix), h);
        p = p + 1;
    end
D = parallel.pool.DataQueue;
max_time = max(time_out,[],'all');
time_simulated = linspace(0,max_time,max_time*20*60);
aligned_matrix = cell(length(analyte_matrix),1);

% If there are more than 4 ions in the list run the code in paralell
%   

switch length(analyte_matrix)>4
    case 1
            h = waitbar(0,'Please wait aligning features...');
            afterEach(D,@nUpdateWaitbar);
            p = 1;
            k = time_out>0;
        parfor i = 1:length(analyte_matrix)
            ion_image = analyte_matrix{i};
            
            for j = 1:size(ion_image,1)                
                time_axis = time_out(j,k(j,:));
                intensity_value = ion_image(j,k(j,:));
                ind = gt(time_axis,0);
                new_time_axis = linspace(0,max(max_time),length(time_simulated));                
                new_interp_axis = interp1(time_axis(ind),intensity_value(ind),new_time_axis,'nearest','extrap');
                aligned_matrix{i}(j,:) = new_interp_axis;                
            end
            
            send(D,i);
        end

        close(h)
    case 0
        for i = 1:length(analyte_matrix)
            ion_image = analyte_matrix{i};

            for j = 1:size(ion_image,1)
                time_axis = time_out(j,:);
                intensity_value = ion_image(j,:);
                ind = gt(time_axis,0);
                new_time_axis = linspace(0,max(max_time),length(time_simulated));
                new_interp_axis = interp1(time_axis(ind),intensity_value(ind),new_time_axis,'nearest','extrap');
                aligned_matrix{i}(j,:) = new_interp_axis;
            end
          
        end
end
end