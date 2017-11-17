function [new_mean, new_std] = update_params(frame, alpha, old_mean, old_std)

new_mean = alpha .* frame + (1-alpha) .* old_mean;
d = abs(frame - new_mean);
new_std = sqrt(alpha .* d.^2 + (1-alpha) .* old_std.^2);

end