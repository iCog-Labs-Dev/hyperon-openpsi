!(register-module! ../../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:modulator:modulator)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:modulator-updaters)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:tests:modulator-updater-test-helpers)
!(register-module! ../../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:main:demand:demand)
!(insert-modulators &modulator-space)
!(assertEqual (ActivationHelper 4 3 2) 4.8743169398907105)
!(assertEqual (SecuringThresholdHelper 4 3) 70.0)
!(assertEqual (SelectionThresholdHelper 3 4) 8)
!(assertEqual (compareModulatorValues (modulator arousal 0.5) (modulator arousal 0.5)) True)
!(assertEqual (compareModulatorValues (modulator selection-threshold 0.5) (modulator arousal 0.5)) False)
!(assertEqual (compareModulatorValues (modulator arousal 0.4) (modulator arousal 0.5)) False)
!(assertEqual (compareModulators &modulator-space &demandspace) True)

