function w = compute_weights(imPatch, TargetModel, ColorModel, Nbins)

[n, m] = size(imPatch);
w = zeros(n, m);

for i=1:n
    for j=1:m
        b = b_fun(imPatch(i,j), Nbins);
        w(i,j) = sqrt(TargetModel(b)/ColorModel(b));
    end
end

end