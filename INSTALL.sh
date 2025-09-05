#!/bin/bash
set -e  

VENV_DIR="venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# === Step 1: Upgrade pip to required version ===
echo "Upgrading pip..."
python3 -m pip install --upgrade pip==23.1.2

# === Step 2: Install dependencies ===
echo "Installing numpy==2.2.1..."
pip install numpy==2.2.1

echo "Installing hyperon==0.2.3..."
python3 -m pip install hyperon==0.2.3

# === Step 3: Initialize submodules ===
echo "Updating submodules..."
git submodule update --init --recursive

echo "Setup complete!"
