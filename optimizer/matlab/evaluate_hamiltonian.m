function E = evaluate_hamiltonian(theta)
% Frustration Hamiltonian
% H(s) = Σ w_i V_i(s) + Σ_{i<j} J_ij C_ij(s)
% E(θ) = ⟨ψ(θ)|H|ψ(θ)⟩

dim = numel(theta);
w = ones(dim,1);
J = 0.1 * tril(ones(dim), -1);

V = sin(theta).^2;
local = sum(w .* V);

coupling = 0;
for i = 1:dim
    for j = i+1:dim
        Cij = cos(theta(i) - theta(j));
        coupling = coupling + J(j,i) * Cij;
    end
end

E = local + coupling;
end
