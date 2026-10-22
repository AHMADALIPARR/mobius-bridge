"""Deterministic CPU fallback used by acceptance tests."""
import numpy as np

def evaluate(theta):
    theta = np.asarray(theta, dtype=np.float64)
    local = np.sum(np.sin(theta)**2)
    coupling = 0.0
    for i in range(len(theta)):
        for j in range(i+1, len(theta)):
            coupling += 0.1 * np.cos(theta[i] - theta[j])
    return float(local + coupling), 1.0 / np.sqrt(1024)
