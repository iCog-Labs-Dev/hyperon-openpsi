import numpy as np
import random

from comparision import StandardTS, run_bandit
from ts_ucb_implementation import TSUCB
from plotter import plot_average_reward, plot_cumulative_regret


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

std_cumulative, std_regret, std_avg = run_bandit(
    StandardTS, n_arms, true_probs, trials, n_runs
)

ucb_cumulative, ucb_regret, ucb_avg = run_bandit(
    TSUCB, n_arms, true_probs, trials, n_runs
)

print("\n" + "="*60)
print(f"True best arm probability: {max(true_probs):.3f}")
print(f"Average reward over {n_runs} runs after {trials} trials:")
print(f" Standard Thompson Sampling : {std_avg:.3f}")
print(f" TS-UCB : {ucb_avg:.3f}")
print(f" Improvement : +{ucb_avg - std_avg:.3f} ({(ucb_avg/std_avg - 1)*100:+.1f}%)")
print("="*60)


plot_average_reward(std_cumulative, ucb_cumulative, true_probs, trials, n_runs)
plot_cumulative_regret(std_regret, ucb_regret, n_runs)


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

print("Standard TS posterior means:",
      std_bandit.alpha / (std_bandit.alpha + std_bandit.beta))

print("TS-UCB posterior means :",
      tsucb_bandit.alpha / (tsucb_bandit.alpha + tsucb_bandit.beta))

