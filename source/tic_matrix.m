function out = tic_matrix(tot_ion_current,NumScans)
    tot_ion = zeros(size(tot_ion_current,1),max(NumScans));
    for i = 1:size(tot_ion_current, 1)
        tot_ion(i,1:length(tot_ion_current{i,1})) = tot_ion_current{i,1};
    end
    tot_ion(tot_ion==0)=NaN;
   out = cell(1,1);
   out{1} = tot_ion;
end