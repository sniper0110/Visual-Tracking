function [TP, TN, FP, FN] = find_quantities(frame, ground_truth)

[n, m] = size(frame);

TP = 0;
TN = 0;
FP = 0;
FN = 0;

for i=1:n
    for j=1:m
        pixel1 = frame(i,j);
        pixel2 = ground_truth(i,j);
        if(pixel1 == 255 && pixel2 == 255)
            TP = TP + 1;
        elseif(pixel1 == 0 && pixel2 == 0)
            TN = TN + 1;
        elseif(pixel1 == 255 && pixel2 == 0)
            FP = FP + 1;
        elseif(pixel1 == 0 && pixel2 == 255)
            FN = FN + 1;
        end
    end
end




end