!(register-module! ../../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:modulator:modulator)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:modulator-updaters)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:tests:modulator-updater-test-helpers)

!(register-module! ../../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:main:demand:demand)
!(import! &self hyperon-openpsi:psi-utilities:normalization)

!(bind! &demandspace (new-space))
!(bind! &modulator-space (new-space))

!(addDemand &demandspace energy -10 10 -15)
!(addDemand &demandspace affiliation -10 10 5)
!(addDemand &demandspace competence -10 10 0)

!(insert-modulators &modulator-space)

!(assertEqual (ActivationHelper 4 3) 0.8743169398907105)
!(assertEqual (SecuringThresholdHelper 4 0.8) 60.23529411764706)
!(assertEqual (SelectionThresholdHelper 3.0) 0.01639344262295082)
!(assertEqual (compareModulatorValues (modulator arousal 0.5) (modulator arousal 0.5)) True)
!(assertEqual (compareModulatorValues (modulator selection-threshold 0.5) (modulator arousal 0.5)) False)
!(assertEqual (compareModulatorValues (modulator arousal 0.4) (modulator arousal 0.5)) False)
!(assertEqual (compareModulators &modulator-space &demandspace) True)

