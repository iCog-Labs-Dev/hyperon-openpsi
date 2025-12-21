
## TS-UCB Implementation

## Overview 

TS-UCB is a simple yet powerful enhancement to classic Thompson Sampling (TS) for multi-armed and contextual bandit problems. It achieves significantly lower regret than standard TS with negligible extra computation, while matching or outperforming the state-of-the-art Information-Directed Sampling (IDS) algorithm in many cases.
The key insight: instead of selecting the arm with the highest posterior sample (as in TS), TS-UCB scores arms using a ratio that incorporates both posterior samples and upper confidence bounds (UCBs). This better balances exploration and exploitation by favoring arms with high potential reward relative to their uncertainty.

## How TS-UCB works 

- Draw m full posterior samples and estimate the optimal reward f̃_t (average max across samples).

- Compute posterior mean for each arm.

- Compute confidence radius (uncertainty) for each arm.

- Score each arm: (f̃_t - mean_arm) / radius_arm

- Select the arm with the lowest score (small regret relative to uncertainty).

This approximates IDS's "information ratio" but replaces expensive information gain with a cheap confidence radius.


Reference: 
paper: https://proceedings.mlr.press/v206/baek23a/baek23a.pdf 