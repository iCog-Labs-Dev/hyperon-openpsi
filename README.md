# Hyperon-OpenPSI

This repository contains MeTTa experiments for the OpenPsi Architecture, a project to create a cognitive architecture based on the principles of self-organizing systems. OpenPsi aims to provide a framework for building intelligent agents that can learn and adapt in complex environments.

## Project Structure

The project is organized into the following directories:

- **main**: Contains the core logic of the OpenPsi architecture, including:
  - **mind-agents**: Implements the core cognitive functions of the agent, such as:
    - **action-planner**: A hill-climbing planner that finds a sequence of actions to achieve a goal.
    - **demand-updater**: Manages the agent's internal "demands" or motivations.
    - **feeling-updater**: Updates the agent's emotional state.
    - **modulator-updater**: Modulates the agent's cognitive processes.
    - **monitor-changes**: Monitors changes in the agent's external environment.
    - **perception-updater**: Processes sensory information.
  - **demand**: Represents the agent's needs.
  - **emotion**: Defines the agent's emotional states.
  - **modulator**: Modulates the agent's cognitive processes.
  - **rules**: Contains the functions to work with rules that govern the agent's behavior.
- **psi-utilities**: Provides utility functions for the project.
- **test**: Contains test script to run test-cases with in every component of the project.
- **use-cases**: Demonstrates how to use the OpenPsi architecture to build intelligent agents, including:
  - **curious-agent**: An agent that is motivated by curiosity and uses a large language model (Google Gemini) to correlate its internal state with a set of rules.
  - **ping-pong**: A simple example of a cyclical interaction between two states.
- **utilities-module**: A github submodule, contains commonly used MeTTa functions for the OpenCog components.

## Getting Started

To get started with the project, you will need to have [Hyperon](https://github.com/trueagi/hyperon-experimental) installed. Then, you can run the examples in the `use-cases` directory.

For example, to run the ping-pong example, you can execute the following command:

```
metta use-cases/ping-pong/ping-pong.metta
```

## Contributing

Contributions to the project are welcome. Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License.

