% Function to find all m/z features from the linescans in the apeaks
% structure in the defined time regions in the variable region1. The
% algorithm accounts for mass tolerance (ppmgap), frequency of detection (min_hits)

% 
 

function [masses_out] = find_all_feat2(peak_data,ppmgap,min_hits,time_matrix,region1,intensity_thresh,max_hits,max_int)


min_hits = min_hits/100;
max_hits = max_hits/100;
time_matrix(time_matrix==0)=NaN;
region_of_interest = cell(length(peak_data),1);

% Extract timestamps from region1 variable. Region one is a n by 3 matrix
% where each row represents a linescan. The first column is the number of
% the linescan, the second column is the time in minutes where the region
% starts and the third column is the time in minutes where the region ends.
for i = 1:size(region1,1)
    if ~isnan(region1(i,2)) || ~isnan(region1(i,3))
       minimum_t = region1(i,2)*60;
       maximum_t = region1(i,3)*60;
       time_gt_min=(time_matrix(i,:)>minimum_t);
       time_lt_max=(time_matrix(i,:)<maximum_t);
       time_span = logical(time_gt_min.*time_lt_max);     
       scan_events = peak_data{i}(:);
       region_of_interest{i} = scan_events(time_span);
    end
end



% Calculate the number of scan events in the region of interest and
% preallocate a vector.
allocate = 0;
num_scan = 0;
for i = 1:size(region_of_interest,1)
    num_scan = num_scan+size(region_of_interest{i,1},1);
    for j = 1:size(region_of_interest{i,1},1)
        allocate = allocate+size(region_of_interest{i,1}{j,1},1);
    end
end



%Stack all massspectra in a preallocated array and an intitialized counter
%variable
comp_masslist = zeros(allocate,2);
count = 1;
for j = 1:size(region_of_interest,1)
    for i = 1:size(region_of_interest{j},1)
        %datnow=region_of_interest{j,1}{i,1};
        datnow = region_of_interest{j,1}{i,1}(:, 1:2);
        comp_masslist(count:count+size(datnow,1)-1,:)=datnow;
        count = count+size(datnow,1);
    end
    %disp(j)
end

% Sort the list of all m/z and intensity values
comp_masslist= comp_masslist(comp_masslist(:,1)~=0,:);
comp_masslist=sortrows(comp_masslist);
% comp_masslist=comp_masslist(comp_masslist(:,2)>intensity_thresh,:);

% Determine peak groups by determining where the ppm error is bigger than
% the treshold ppmgap value. All values that pass the test are sorted into
% the same peak group. The variable pk initializes the ppm calculation
% frame, i is the iterator for comparing with pk and c is the peakgroup
% counter.
i = 2;
pk = 1;
c = 1;
intensity = 0;
mz = 0;
pkgroup = {};
while lt(i,length(comp_masslist))
    
    intensity = intensity+comp_masslist(i,2);
    mz = mz+comp_masslist(i,1)*comp_masslist(i,2);
      
    mz_norm = mz/intensity;
    if abs(comp_masslist(i,1) - mz_norm) <= ppmgap

        i = i+1;
    else
        pkgroup{c,1} = pk:1:i-1;
        c = c+1;
        pk=i;
        intensity = 0;
        mz = 0;
    end
end


% Extract data and calculate statisitcs on the peaks in peak groups that
% are bigger than the threshold min_hits. 
no_features=size(pkgroup,1);
mass_stats = zeros(no_features,9);
for feat=(1:no_features)
    %if size(pkgroup{feat,1},2)/num_scan
        temp_set=comp_masslist(pkgroup{feat,1},:);
%         tmp_avg = zeros(num_scan,1);
%         tmp_avg(1:length(temp_set(:,1))) = temp_set(:,2);
        %Feature number
        mass_stats(feat,1)=feat;
        %Average accurate mass value weighted based on intensity
        mass_stats(feat,2)= sum(temp_set(:,2).*temp_set(:,1))./sum(temp_set(:,2));
        %Standard deviation of accurate masss
        mass_stats(feat,3)=std(temp_set(:,1));
        %Spread of accurate mass
        mass_stats(feat,4)=max(temp_set(:,1))-min(temp_set(:,1));
        %Detection frequency
        mass_stats(feat,5)=size(temp_set,1)/num_scan;
        %Mean intensity over the whole region of interest
        mass_stats(feat,6)=mean(temp_set(:,2));
        %Max intensity
        mass_stats(feat,7)=max(temp_set(:,2));
        %Standard deviation of intensity
        mass_stats(feat,8)=std(temp_set(:,2));
        mass_stats(feat,9)= size(temp_set,1);
    %end
end


% Remove zero vals from master list.
masses_out=mass_stats(mass_stats(:,5)>min_hits,:);
masses_out=masses_out(masses_out(:,6)>intensity_thresh,:);

masses_out=masses_out(masses_out(:,5)<max_hits,:);
masses_out=masses_out(masses_out(:,6)<max_int,:);
end