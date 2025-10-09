# Curious Agent

This project implements a "Curious Agent" that leverages the Hyperon symbolic AI framework in conjunction with a Large Language Model (LLM) to create an interactive and adaptive system.

## Getting Started

### Prerequisites

- Python 3.11 or higher

### Python Setup

1. **Create a virtual environment:**

    ```bash
    python3 -m venv .venv
    ```

2. **Activate the virtual environment:**

    - On macOS and Linux:

        ```bash
        source .venv/bin/activate
        ```

    - On Windows:

        ```bash
        .\.venv\Scripts\activate
        ```

3. **Install the required Python packages:**

    ```bash
    pip install -r requirements.txt
    ```

4. **Set up your environment variables:**

    ```
    export GEMINI_API_KEY="your_api_key_here"
    ```

## Usage

### Running the Curious Agent

The main entry point for the agent is the `main.metta` file. To run the agent, execute the following command in your terminal:

```bash
metta main.metta
```

This will start the agent's main loop, which interacts with the user and the LLM.