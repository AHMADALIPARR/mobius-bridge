function candidates = generate_candidates(center, n, radius)
% Generate bounded phase candidates around a center point

dim = numel(center);
candidates = zeros(dim, n);
lb = -pi; ub = pi;

for k = 1:n
    noise = radius * randn(dim,1);
    cand = max(min(center(:) + noise, ub), lb);
    candidates(:,k) = cand;
end
end
