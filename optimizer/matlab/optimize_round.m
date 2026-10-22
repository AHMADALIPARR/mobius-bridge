function [candidates, energies] = optimize_round(prev_params, energy, uncertainty, opts)
% MÖBIUS-14 MATLAB numeric solver
% Derivative-free method suitable for noisy measurements

if nargin < 4
    opts = struct('max_evals', 50, 'tol', 1e-4);
end

dim = numel(prev_params);
lb = -pi * ones(dim,1);
ub =  pi * ones(dim,1);

x0 = max(min(prev_params(:), ub), lb);

obj = @(theta) evaluate_hamiltonian(theta);

options = optimset('Display','off', 'MaxFunEvals', opts.max_evals, ...
                   'TolX', opts.tol, 'TolFun', opts.tol);

[x_opt, f_opt] = fminsearch(obj, x0, options);

n_cand = 5;
candidates = zeros(dim, n_cand);
energies  = zeros(1, n_cand);

candidates(:,1) = x_opt;
energies(1) = f_opt;

for k = 2:n_cand
    noise = 0.05 * randn(dim,1);
    cand = max(min(x_opt + noise, ub), lb);
    candidates(:,k) = cand;
    energies(k) = obj(cand);
end
end
