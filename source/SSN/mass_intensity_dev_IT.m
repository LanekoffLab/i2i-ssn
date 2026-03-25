%   Function to extract ion intensites given a mass list MHmass
%   a tolerence cutoffppm. The input data is generated from the function
%   loadfiles_dev2.m and is called apeaks.
%   'fs_time' and a given number of scan events 'NumberOfScans'

function [analyte_matrix, signal_inten] = mass_intensity_dev_IT(MHmass,cutoffppm,apeaks,NumberOfScans)
%   allocate matrices for intensity, closest mass and mass difference.
all_intensities = cell(length(apeaks),1);
all_closest_mass =  cell(length(apeaks),1);
all_mass_diff =  cell(length(apeaks),1);

    % Initialize waitbar
    function nUpdateWaitbar(~)
        waitbar(p/length(apeaks), h);
        p = p + 1;
    end

% Calculate mass differences and find the minimum mass difference between
% the input MHmass and the data. If the number of ions in MHmass is bigger
% than 1 (one) use pralell computing, otherwise do it on a single core.

switch length(MHmass)>1.5
    case 1
        D = parallel.pool.DataQueue;
        h = waitbar(0,'Please wait extracting features...');
        afterEach(D,@nUpdateWaitbar);
        p = 1;
        parfor i = 1:length(apeaks)
            linescan_data = apeaks{i};
            massdiff = zeros(size(MHmass,1),size(linescan_data,1));
            closestmass = zeros(size(MHmass,1),size(linescan_data,1));
            intensities = zeros(size(MHmass,1),size(linescan_data,1));            
            for j = 1:length(linescan_data)              
                scan = linescan_data{j};
                if isempty(scan)
                    scan = [0 0];
                end
                [~, idx1] = min(abs(MHmass - scan(:,1)'),[],2);           
                massdiff(:,j) = (abs((scan(idx1,1)-MHmass)))';
                closestmass(:,j) = scan(idx1,1);
                intensities(:,j) = scan(idx1,2);
            end
            all_mass_diff{i} = massdiff;
            all_closest_mass{i} = closestmass;
            all_intensities{i} = intensities;
            send(D,i);
        end
        

        close(h)
    case 0
        for i = 1:length(apeaks)
            linescan_data = apeaks{i};
            massdiff = zeros(size(MHmass,1),size(linescan_data,1));
            closestmass = zeros(size(MHmass,1),size(linescan_data,1));
            intensities = zeros(size(MHmass,1),size(linescan_data,1));
            for j = 1:length(linescan_data)
                scan = linescan_data{j};
                if isempty(scan)
                    scan = [0 0];
                end

                [~, idx1] = min(abs(MHmass - scan(:,1)'),[],2);
                massdiff(:,j) = (abs((scan(idx1,1)-MHmass)))';
                closestmass(:,j) = scan(idx1,1);
                intensities(:,j) = scan(idx1,2);
            end
            all_mass_diff{i} = massdiff;
            all_closest_mass{i} = closestmass;
            all_intensities{i} = intensities;
            
        end
end
fs_mass_diff = cell(length(apeaks),1);    
fs_closest_mass = cell(length(apeaks),1);   
signal_inten = cell(length(apeaks),1);   
% Save data if the ppm tolerance is good.
for u = 1:length(all_mass_diff)
   
    tmp_diff = all_mass_diff{u};
    tmp_closest_mass = all_closest_mass{u};
    tmp_intensities = all_intensities{u};
    for i = 1:numel(tmp_diff)
        j = tmp_diff(i);
        if j <= cutoffppm
            tmp_diff(i) = tmp_diff(i);
            tmp_closest_mass(i) = tmp_closest_mass(i);
            tmp_intensities(i) = tmp_intensities(i);
        else
            tmp_diff(i) = 0;
            tmp_closest_mass(i) = 0;
            tmp_intensities(i) = 0;
        end
    end
    fs_mass_diff{u} = tmp_diff;
    fs_closest_mass{u} = tmp_closest_mass;
    signal_inten{u} = tmp_intensities;
end

%Extract all intensites from all scans for each target ion into a cell
%array.
analyte_matrix = cell(length(MHmass),1);
for i = 1:length(MHmass)
    tmp_linescan = zeros(length(NumberOfScans),max(NumberOfScans));
    for j = 1:length(signal_inten)
        linescan_data = signal_inten{j};
        b = linescan_data(i,:);
        tmp_linescan(j,1:length(b)) = b;
    end
    analyte_matrix{i} = tmp_linescan;
end
end

