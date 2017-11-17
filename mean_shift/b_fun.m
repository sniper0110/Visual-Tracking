function[output] = b_fun(pix_val, nbins)

interval_bins = 256/nbins;

if(pix_val <= interval_bins && pix_val >= 0)
    output = 1;
else
    output = (pix_val-mod(pix_val, interval_bins))/interval_bins + 1;
end


end