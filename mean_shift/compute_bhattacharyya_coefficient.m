function rho = compute_bhattacharyya_coefficient(p,q)

sqrt_q = sqrt(q);
sqrt_p = sqrt(p);

rho = sum(sqrt_q .* sqrt_p);

end