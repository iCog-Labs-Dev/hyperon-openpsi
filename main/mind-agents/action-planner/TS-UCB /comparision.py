
import numpy as np
import random
import matplotlib.pyplot as plt
from beta_sampling import BetaSampler
from ts_ucb_implementation import TSUCB

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

if __name__ == "__main__":
    # TS-UCB Helps More When Probabilities Are Close
    # with large gaps, both TS and TS-UCB quickly identify the best arm
    # Wwth small gaps, standard TS continues random exploration longer
    # TS-UCB incorporates uncertainty-aware regret control, leading to faster exploitation
    # TS-UCB maintains more balanced uncertainty estimates
    
    true_probs = [0.55, 0.54, 0.53, 0.52, 0.51, 0.50, 0.49, 0.48, 0.47, 0.46]
    # true_probs = [0.9, 0.8, 0.7, 0.6, 0.5, 0.4] 
    n_arms = len(true_probs)
    trials = 5000
    n_runs = 300               

    print(f"Running {n_runs} simulations for each algorithm... (this may take a minute)")

    std_cumulative, std_regret, std_avg = run_bandit(StandardTS, n_arms, true_probs, trials, n_runs)
    ucb_cumulative, ucb_regret, ucb_avg = run_bandit(TSUCB, n_arms, true_probs, trials, n_runs)

    print("\n" + "="*60)
    print(f"True best arm probability: {max(true_probs):.3f}")
    print(f"Average reward over {n_runs} runs after {trials} trials:")
    print(f"  Standard Thompson Sampling : {std_avg:.3f}")
    print(f"  TS-UCB       : {ucb_avg:.3f}")
    print(f"  Improvement                 : +{ucb_avg - std_avg:.3f} ({(ucb_avg/std_avg - 1)*100:+.1f}%)")
    print("="*60)

    plt.figure(figsize=(10, 6))
    plt.plot(std_cumulative / (np.arange(trials) + 1), label="Standard Thompson Sampling", color="orange", alpha=0.9)
    plt.plot(ucb_cumulative / (np.arange(trials) + 1), label="TS-UCB", color="teal", linewidth=2.5)
    plt.axhline(max(true_probs), color="black", linestyle="--", alpha=0.6, label="Optimal reward")
    plt.title(f"Comparison – Average Reward per Step ({n_runs} runs)")
    plt.xlabel("Trial")
    plt.ylabel("Average reward")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.ylim(0, max(true_probs) * 1.1)
    plt.tight_layout()
    plt.show()

    plt.figure(figsize=(10, 6))
    plt.plot(std_regret, label="Standard Thompson Sampling", color="orange", alpha=0.9)
    plt.plot(ucb_regret, label="TS-UCB", color="teal", linewidth=2.5)

    plt.title(f"Cumulative Regret Comparison ({n_runs} runs)")
    plt.xlabel("Trial")
    plt.ylabel("Cumulative expected regret")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.show()


    print("\nExample final beliefs from a single illustrative run:")
    
    np.random.seed(123)
    random.seed(123)
    
    std_bandit = StandardTS(n_arms=n_arms, seed=123)
    tsucb_bandit = TSUCB(n_arms=n_arms, m=1, seed=123)
    
    for _ in range(trials):

        arm_std = std_bandit.select_arm()
        reward = 1 if random.random() < true_probs[arm_std] else 0
        std_bandit.update(arm_std, reward)
        
        random.seed(123 + _ + 1000) 
        arm_ucb = tsucb_bandit.select_arm()
        reward = 1 if random.random() < true_probs[arm_ucb] else 0
        tsucb_bandit.update(arm_ucb, reward)
    
    print("Standard TS posterior means:", std_bandit.alpha / (std_bandit.alpha + std_bandit.beta))
    print("TS-UCB posterior means    :", tsucb_bandit.alpha / (tsucb_bandit.alpha + tsucb_bandit.beta))
