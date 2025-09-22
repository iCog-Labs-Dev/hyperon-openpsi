import random
from math import sqrt, log, exp
from typing import Optional

import matplotlib.pyplot as plt

class BetaSampler:
    """
    A random sampler for the Beta distribution using rejection sampling.
    “BA” algorithm, developed by R. C. H. Cheng in 1978.
    Reference: https://learn.microsoft.com/en-us/archive/msdn-magazine/2018/february/test-run-thompson-sampling-using-csharp
    """

    def __init__(self, seed: Optional[int] = None) -> None:
        self.rng = random.Random(seed)

    def sample(self, a: float, b: float) -> float:
        """
        Draw a single sample from a Beta(a, b) distribution.

        Returns
            Random sample from Beta(a, b).
        """
        if a <= 0 or b <= 0:
            raise ValueError("Parameters 'a' and 'b' must be positive.")

        alpha = a + b

        # Compute beta scaling factor
        if min(a, b) <= 1:
            beta = max(1 / a, 1 / b)
        else:
            beta = sqrt((alpha - 2) / (2 * a * b - alpha))

        gamma = a + 1 / beta

        while True:
            u1 = self.rng.random()
            u2 = self.rng.random()

            v = beta * log(u1 / (1 - u1))
            w = a * exp(v)

            if alpha * log(alpha / (b + w)) + (gamma * v) - 1.3862944 >= log(u1 * u1 * u2):
                return w / (b + w)


def plot_distribution(a: float, b: float, n_samples: int = 100_000, seed: Optional[int] = None) -> None:
    """
    Generate samples from Beta(a, b) and plot their histogram.

    Parameters
    ----------
    a : float
        First shape parameter.
    b : float
        Second shape parameter.
    n_samples : int
        Number of samples to draw.
    seed : Optional[int]
        Seed for reproducibility.
    """
    sampler = BetaSampler(seed=seed)
    samples = [sampler.sample(a, b) for _ in range(n_samples)]

    plt.figure(figsize=(8, 5))
    plt.hist(samples, bins=100, density=True, alpha=0.7, color="steelblue", edgecolor="black")
    plt.title(f"Beta({a}, {b}) Distribution Samples")
    plt.xlabel("Value")
    plt.ylabel("Density")
    plt.grid(alpha=0.3)
    plt.show()


if __name__ == "__main__":
    plot_distribution(a=20, b=10, n_samples=500_000, seed=42)
