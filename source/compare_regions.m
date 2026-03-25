% Compare region k1 and k2. k1 and k2 are the output lists from the
% find_all_feat2.m function. min_hits are the minimum frequency of detecing
% a given ion in the list, intenisty is the minimum average intensity of
% that ion and fold is the fold change between two equal features.

function [unique_peaks,upreg] = compare_regions(region1,region2,min_hits,fold,ppmgap)
min_hits = min_hits/100;

% Generate a matrix that contains the ppm difference of all features
diff_regions = abs((region1(:,2)-region2(:,2)'))./(region2(:,2)')*1e6;
% Find locations where the difference is less than the treshold.
diff_region_logical = diff_regions<ppmgap;                                  %less than 5

featurelist2 = zeros(1,9);
featurelist1 = zeros(1,9);
unique_peaks = zeros(1,9);
o = 1;
u=1;


% Extract features
for i = 1:size(diff_region_logical,1)
    % Extract features that are detected in both k1 and k2 otherwise save
    % the feature in the unique_peaks variable.
    if sum(diff_region_logical(i,:)) >= 1 %&& region2(diff_region_logical(i,:),5)>min_hits
        featurelist1(o,:) = region1(i,:);
        featurelist2(o,:) = mean(region2(diff_region_logical(i,:),:),1);
        %fold = bigregion(k4(:,i),6)/smallregion(i,6);
        o = o+1;
    else
        unique_peaks(u,:) = region1(i,:);
        u=u+1;
    end
    
end

%calculate fold change for features that are detected in both regions

foldchange = featurelist1(:,6)./featurelist2(:,6);
foldchange_logic = foldchange>fold;
upreg = featurelist1(foldchange_logic,:);
upreg = [upreg foldchange(foldchange_logic)];
t_test = (featurelist1(:,6)-featurelist2(:,6))./(sqrt(featurelist1(:,8).^2./featurelist1(:,9)+featurelist2(:,8).^2./featurelist2(:,9)));
upreg = [upreg t_test(foldchange_logic)];
%upreg = upreg(upreg(:,5)>min_hits,:);

%unique_peaks = unique_peaks(unique_peaks(:,5)>min_hits,:);
unique_peaks = [unique_peaks zeros(size(unique_peaks,1),2)];
end
