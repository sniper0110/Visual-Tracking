function [z] = compute_meanshift_vector(imPatch, prev_center, weights)

z = 0;

[n, m] = size(imPatch);

for i=1:n
    for j=1:m
        z = z + [i,j] * weights(i,j);
    end
end

a_sum = sum(sum(weights));
if(a_sum == 0)
    disp('Sum of weights is NULL');
end
    
z = z./(a_sum);

 % + prev_center

end