# Thompson Sampling for Action Selection

This directory contains a MeTTa-based implementation of Thompson Sampling, a probabilistic algorithm for online decision-making that balances exploration and exploitation. It is used within OpenPsi for action selection, allowing an agent to intelligently choose the best action in a given context by learning from the outcomes of its choices.

## Overview

Thompson Sampling works by modeling the expected reward of each available action as a probability distribution. When a decision needs to be made, the algorithm draws a sample from each action's distribution and selects the action corresponding to the highest sample. The outcome of the chosen action (e.g., success or failure) is then used to update the parameters of its distribution, refining future choices.

In this implementation, we use the Beta distribution to model the success probability of procedural rules. Each rule is associated with a Strength-Truth-Value (STV), which includes `strength` and `confidence` values. These are mapped to the `alpha` (successes + 1) and `beta` (failures + 1) parameters of a Beta distribution.

## How It Works

1.  **Rule Representation**: Procedural rules are defined with an `STV` atom, for example, `(STV 0.5 0.002)`, representing initial strength and confidence.
2.  **Distribution Mapping**: The `strength` and `confidence` are converted into `alpha` and `beta` parameters for a Beta distribution using the functions in `util.metta`.
3.  **Action Selection**:
    -   Given a goal and a context, the system identifies a set of applicable rules.
    -   For each applicable rule, it draws a random sample from its corresponding Beta distribution using the `beta-sample` function defined in `math.metta`.
    -   The rule that returns the highest sample is selected for execution. This is the core of the "thompson-sample" logic.
4.  **Learning/Update**:
    -   The chosen action is performed, and its outcome is evaluated (1 for success, 0 for failure).
    -   The `alpha` and `beta` parameters of the selected rule's distribution are updated based on the outcome. A success increments `alpha`, and a failure increments `beta`.
    -   The updated `alpha` and `beta` are converted back into `strength` and `confidence` to update the rule's STV.

This process allows the agent to favor rules that have historically led to success while still exploring other rules to discover potentially better options.

## File Descriptions

-   `util.metta`: The core logic for the Thompson Sampling planner. It includes functions for:
    -   Converting between STV and Beta distribution parameters (`stv-to-beta`, `beta-to-stv`).
    -   Matching rules based on goal and context (`match-goal`, `match-contexts`).
    -   Selecting a rule via Thompson Sampling (`thompson-sample`).
    -   Updating a rule's STV based on action outcomes (`update-rule`).
-   `math.metta`: Implements the Beta distribution sampling algorithm (`beta-sample`) and other mathematical utilities in MeTTa.
-   `beta-sampling.py`: A Python implementation of a Beta distribution sampler using Cheng's (1978) algorithm. It serves as a reference and includes a function to plot the distribution for analysis.
-   `tests/`: Contains unit tests for the `math.metta` and `util.metta` files.
-   `monster-combat/`: A practical example demonstrating how to use the Thompson Sampling module.

## Example: Monster Combat

The `monster-combat` directory provides a simple game scenario to illustrate the system in action.

-   `rules.metta`: Defines a set of combat rules. Each rule links a `Context` (e.g., `(Position CLOSE_RANGE)`), an `Action` (e.g., `(ATTACK SWORD)`), and a `Goal` (e.g., `(HIT)`). Some actions are more effective in certain contexts.
-   `play.metta`: A script that runs a simulation. In each iteration, it sets a random context, uses `thompson-sample` to select the most promising action, simulates the action's outcome, and updates the chosen rule.

### Running the Example

To run the monster combat simulation, execute the `play.metta` file from the terminal using the MeTTa runner:

```sh
metta main/mind-agents/action-planner/thompson-sampling/monster-combat/play.metta
```

As the simulation runs, you will observe the STV values of the rules being updated. Rules that are effective in their context (e.g., using a sword at close range) will see their strength and confidence increase, making them more likely to be chosen in the future.
