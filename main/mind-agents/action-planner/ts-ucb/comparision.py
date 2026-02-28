
import numpy as np
import random
from beta_sampling import BetaSampler

class StandardTS:
    def __init__(self, n_arms: int, alpha_prior: float = 1.0, beta_prior: float = 1.0, seed=None):
        self.n_arms = n_arms
        self.alpha = np.full(n_arms, alpha_prior)
        self.beta = np.full(n_arms, beta_prior)
        self.sampler = BetaSampler(seed=seed)

    def select_arm(self) -> int:
        theta = [self.sampler.sample(self.alpha[i], self.beta[i]) for i in range(self.n_arms)]
        return int(np.argmax(theta))

    def update(self, arm: int, reward: float):
        if reward == 1:
            self.alpha[arm] += 1
        else:
            self.beta[arm] += 1

def run_bandit(Algorithm, n_arms, true_probs, trials, n_runs=200, seed=42):
    np.random.seed(seed)
    random.seed(seed)
    best_prob = max(true_probs)

    cumulative_rewards = np.zeros((n_runs, trials))
    cumulative_regret = np.zeros((n_runs, trials))
    for run in range(n_runs):
        bandit = Algorithm(n_arms=n_arms, seed=seed + run)
        total = 0.0
        total_regret = 0.0
        for t in range(trials):
            arm = bandit.select_arm()
            reward = 1 if random.random() < true_probs[arm] else 0
            bandit.update(arm, reward)
            total += reward
            total_regret += best_prob - true_probs[arm] 
            cumulative_rewards[run, t] = total
            cumulative_regret[run, t] = total_regret
    avg_cumulative = np.mean(cumulative_rewards, axis=0)
    avg_cumulative_regret = np.mean(cumulative_regret, axis=0)

    final_avg_reward = avg_cumulative[-1] / trials
    return avg_cumulative, avg_cumulative_regret, final_avg_reward

    # return avg_cumulative, final_avg_reward,avg_cumulative_regret