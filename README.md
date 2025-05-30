# Hyperon-OpenPsi

- This repository encompasses the implementation of the theory of emotion and motivation under opencog-hyperon.

## Introduction

## Running the code

Below a step by step instruction guide has been provided based on different operating systems. Follow the one matching your os.

### Linux/Mac

This guide will walk you through setting up your development environment for **MeTTa** on Linux or macOS.

#### Prerequisites

- A Linux or macOS operating system.
- Python 3.12 or a newer version installed on your system.

#### Setup Steps

1. **Ensure Python 3.12+ is Installed**

    - Verify your Python version:

        Bash

        ```
        python3 --version
        ```

    - If Python 3.12 or newer is not installed, we recommend using a version manager like `pyenv` or your system's package manager:
        - **Linux (Debian/Ubuntu-based):**

            Bash

            ```
            sudo apt update
            sudo apt install python3.12 python3.12-venv
            ```

            (Adjust `python3.12` to the latest desired version if needed).
        - **macOS (using Homebrew):**

            Bash

            ```
            brew update
            brew install python@3.12
            ```

            Ensure `python3` points to the newly installed version. You might need to adjust your PATH.
2. **Create a Virtual Environment**

    - Create a project directory (e.g., `metta_project`):

        Bash

        ```
        mkdir metta_project
        ```

    - Navigate into your project directory:

        Bash

        ```
        cd metta_project
        ```

    - Create a virtual environment named `venv` within your project:

        Bash

        ```
        python3 -m venv venv
        ```

3. **Activate the Virtual Environment**

    - Activate the virtual environment:

        Bash

        ```
        source venv/bin/activate
        ```

        You should see `(venv)` at the beginning of your terminal prompt, indicating activation.
4. **Install the MeTTa Package**

    - With the virtual environment activated, install the `hyperon` package:

        Bash

        ```
        pip install hyperon==0.2.3
        ```

5. **Verify MeTTa Installation**

    - Confirm **MeTTa** is installed by running:

        Bash

        ```
        metta --version
        ```

#### Running code

1. **Fork the repository**

2. **Pull in data from git submodule directory**
 In the directory `hyperon-openpsi`

```
  cd hyperon-openpsi
  git submodule update --init --recursive
```

 3. **Run the tests**

```bash
  python test/run_tests.py
```

All the test cases must execute successfully if you have followed each step correctly. Otherwise, you need to find where you might have missed something and fix things.

### Windows

This guide will walk you through setting up your development environment for **MeTTa** on Windows, leveraging the Windows Subsystem for Linux (WSL).

#### Prerequisites

- A Windows operating system.

#### Setup Steps

1. **Enable Windows Subsystem for Linux (WSL)**

    - Search for "turn Windows features on or off" in the Windows search bar and open it.
    - Locate and select "WSL Windows Subsystem for Linux" in the features list.
    - Click "OK" and restart your computer if prompted.
2. **Install a Linux Distribution**

    - Open PowerShell from the Windows search bar.
    - To view available distributions, run:

        Bash

        ```
        wsl --list --online
        ```

    - Install your preferred distribution (Ubuntu 24.04 is recommended) using:

        Bash

        ```
        wsl --install <distribution_name>
        ```

        For example: `wsl --install Ubuntu-24.04`.
3. **Set up User Information for Linux**

    - Once the installation is complete, open the newly installed Linux distribution (e.g., "Ubuntu") from your Windows applications.
    - Follow the prompts in the terminal to create a username and password for your Linux subsystem.
4. **Update the Linux System**

    - In your Linux terminal, run the following command and enter your password when prompted:

        Bash

        ```
        sudo apt update
        ```

5. **Install Python and Virtual Environment**

    - Verify Python 3 installation:

        Bash

        ```
        python3 --version
        ```

    - Add the necessary repository:

        Bash

        ```
        sudo add-apt-repository ppa:deadsnakes/ppa
        ```

    - Press Enter when prompted to proceed.
    - Install the Python 3 virtual environment package:

        Bash

        ```
        sudo apt install python3.12-venv
        ```

6. **Create a Virtual Environment**

    - Create a project directory (e.g., `metta_project`):

        Bash

        ```
        mkdir metta_project
        ```

    - Navigate into your project directory:

        Bash

        ```
        cd metta_project
        ```

    - Create a virtual environment named `venv` within your project:

        Bash

        ```
        python3 -m venv venv
        ```

7. **Activate the Virtual Environment**

    - Activate the virtual environment:

        Bash

        ```
        source venv/bin/activate
        ```

        You should see `(venv)` at the beginning of your terminal prompt, indicating activation.
8. **Install the MeTTa Package**

    - With the virtual environment activated, install the `hyperon` package:

        Bash

        ```
        pip install hyperon==0.2.3
        ```

9. **Verify MeTTa Installation**

    - Confirm **MeTTa** is installed by running:

        Bash

        ```
        metta --version
        ```

10. **Install Numpy library**

```bash
  pip install numpy==2.2.1
```

#### Running code

1. **Fork the repository**

2. **Pull in data from git submodule directory**
 In the directory `hyperon-openpsi`

```
  cd hyperon-openpsi
  git submodule update --init --recursive
```

 3. **Run the tests**

```bash
  python test/run_tests.py
```

All the test cases must execute successfully if you have followed each step correctly. Otherwise, you need to find where you might have missed something and fix things.

## Contributing

Before you start contributing to this repository, make sure to read the [CONTRIBUTING.md](.github/workflows/contributing.md) file from our repository

## References

- Cai, Zhenhua, et al  (2011) OpenPsi: Realizing Dorner’s “Psi” Cognitive Model in the OpenCog Integrative AGI Architecture.[Link](https://goertzel.org/OpenPsi_agi_11.pdf)
- Bach, Joscha (2009) Principles of Synthetic Intelligence. Psi: An Architecture of Motivated Cognition.
- Cai, Zhenhua et al (2012) OpenPsi: A novel computational affective model and its application in video games.
