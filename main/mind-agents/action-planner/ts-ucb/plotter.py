import numpy as np
import matplotlib.pyplot as plt


def plot_average_reward(std_cumulative, ucb_cumulative, true_probs, trials, n_runs):
    plt.figure(figsize=(10, 6))

    plt.plot(
        std_cumulative / (np.arange(trials) + 1),
        label="Standard Thompson Sampling",
        color="orange",
        alpha=0.9
    )

    plt.plot(
        ucb_cumulative / (np.arange(trials) + 1),
        label="TS-UCB",
        color="teal",
        linewidth=2.5
    )

    plt.axhline(
        max(true_probs),
        color="black",
        linestyle="--",
        alpha=0.6,
        label="Optimal reward"
    )

    plt.title(f"Comparison – Average Reward per Step ({n_runs} runs)")
    plt.xlabel("Trial")
    plt.ylabel("Average reward")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.ylim(0, max(true_probs) * 1.1)
    plt.tight_layout()
    plt.show()


def plot_cumulative_regret(std_regret, ucb_regret, n_runs):
    plt.figure(figsize=(10, 6))

    plt.plot(
        std_regret,
        label="Standard Thompson Sampling",
        color="orange",
        alpha=0.9
    )

    plt.plot(
        ucb_regret,
        label="TS-UCB",
        color="teal",
        linewidth=2.5
    )

    plt.title(f"Cumulative Regret Comparison ({n_runs} runs)")
    plt.xlabel("Trial")
    plt.ylabel("Cumulative expected regret")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.show()

