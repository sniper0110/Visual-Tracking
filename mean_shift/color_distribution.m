function [TargetModel] = color_distribution(imPatch, Nbins)

[n, m] = size(imPatch);
hist_vect = zeros(Nbins);
max_dist = sqrt(n^2 + m^2)/2;
w_center = n/2;
h_center = m/2;
C = 255;

for i=1:n
    for j=1:m
        pix_val = imPatch(i, j);
        
        b = b_fun(pix_val, Nbins);
        dist_for_kernel = (sqrt(sum([abs(i-h_center) abs(j-w_center)].^2))/max_dist)^2;
        hist_vect(b) = hist_vect(b) + Ke(dist_for_kernel);        
    end
end

TargetModel = hist_vect/sum(hist_vect);

end



