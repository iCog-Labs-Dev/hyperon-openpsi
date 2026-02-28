import numpy as np
import random
from math import sqrt, log, exp
from typing import Optional

class BetaSampler:
    """
    Rejection sampler for Beta distribution (Cheng's BA algorithm, 1978).
    This is your original sampler — unchanged and working perfectly.
    """
    def __init__(self, seed: Optional[int] = None):
        self.rng = random.Random(seed)

    def sample(self, a: float, b: float) -> float:
        if a <= 0 or b <= 0:
            raise ValueError("Parameters 'a' and 'b' must be positive.")
        alpha_total = a + b
        if min(a, b) <= 1:
            beta = max(1 / a, 1 / b)
        else:
            beta = sqrt((alpha_total - 2) / (2 * a * b - alpha_total))
        gamma = a + 1 / beta
        while True:
            u1 = self.rng.random()
            u2 = self.rng.random()
            v = beta * log(u1 / (1 - u1))
            w = a * exp(v)
            if alpha_total * log(alpha_total / (b + w)) + (gamma * v) - 1.3862944 >= log(u1 * u1 * u2):
                return w / (b + w)


class TSUCB:
    """
    TS-UCB bandit: Thompson Sampling improved with UCB-based scoring (Baek & Farias, 2023).
    Replaces standard Thompson Sampling with better exploration/exploitation.
    """
    def __init__(self, n_arms: int, alpha_prior: float = 1.0, beta_prior: float = 1.0, m: int = 1, seed: Optional[int] = None):
        self.n_arms = n_arms
        self.alpha = np.full(n_arms, alpha_prior)
        self.beta = np.full(n_arms, beta_prior)
        self.m = m  # number of samples for estimating optimal reward (m=1 is sufficient for big gains)
        self.sampler = BetaSampler(seed=seed)

    def select_arm(self) -> int:
        # estimate optimal reward f_tilde over m samples
        opt_samples = np.zeros(self.m)
        for _ in range(self.m):
            theta_samples = np.array([self.sampler.sample(self.alpha[i], self.beta[i]) for i in range(self.n_arms)])
            opt_samples[_] = np.max(theta_samples)
        f_tilde = np.mean(opt_samples)

        # posterior means
        means = self.alpha / (self.alpha + self.beta)

        # confidence radii (Laplace approximation for Bernoulli, safe for low counts)
        total_counts = self.alpha + self.beta
        radii = np.sqrt(np.log(2 * (total_counts.max() + 1)) / (2 * total_counts))
        radii = np.maximum(radii, 1e-6)  # Avoid div-by-zero

        # TS-UCB scores => lower = better
        scores = (f_tilde - means) / radii

        return int(np.argmin(scores))

    def update(self, arm: int, reward: float):
        if reward == 1:
            self.alpha[arm] += 1
        else:
            self.beta[arm] += 1

    def get_posterior_means(self):
        return self.alpha / (self.alpha + self.beta)


if __name__ == "__main__":
    np.random.seed(42)
    random.seed(42)

    # for true success probs=> Sword=good close, Bow=good mid, Fireball=good long
    true_probs = [0.9, 0.5, 0.1]  # Example for one range

    bandit = TSUCB(n_arms=3, alpha_prior=1.0, beta_prior=1.0, m=1)

    total_reward = 0
    trials = 1000
    # 0.9 => success rate, expected_max: maximum possible average reward if the algorithm get from first trial 
    expected_max = 0.9 * trials  
    for _ in range(trials):
        arm = bandit.select_arm()
        reward = 1 if random.random() < true_probs[arm] else 0
        bandit.update(arm, reward)
        total_reward += reward

    print("Final posterior means:", bandit.get_posterior_means())
    print(f"Total reward collected: {total_reward} out of {trials} trials")
    print(f"Regret (how much reward was 'lost'): {expected_max - total_reward:.1f}")
    print(f"Average reward: {total_reward}/{trials} ({total_reward/trials*100:.1f}%)")
 