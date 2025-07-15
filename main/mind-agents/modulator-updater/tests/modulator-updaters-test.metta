!(register-module! ../../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:modulator-updaters)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)

!(assertEqual (ActivationHelper 4 3 2) 4.8743169398907105)
!(assertEqual (SecuringThresholdHelper 4 3) 70.0)
!(assertEqual (SelectionThresholdHelper 3 4) 8)
