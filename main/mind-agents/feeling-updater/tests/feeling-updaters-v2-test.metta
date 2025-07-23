!(register-module! ../../../../../hyperon-openpsi)
!(register-module! ../../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:main:mind-agents:feeling-updater:feeling-updaters-v2)
!(import! &self hyperon-openpsi:main:modulator:modulator)
!(bind! &modulator-space (new-space))


! (insert-modulators &modulator-space)
!(assertEqual (happy-feeling-updater (all-modulators &modulator-space)) 0.2666666666666667)
!(assertEqual (sad-feeling-updater (all-modulators &modulator-space)) 0.18947368421052632)
!(assertEqual (angry-feeling-updater (all-modulators &modulator-space)) 0.22807017543859648)
!(assertEqual (fear-feeling-updater (all-modulators &modulator-space))  0.1508771929824561)
