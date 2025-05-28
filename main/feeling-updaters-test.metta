!(register-module!  ../../hyperon-openpsi)
!(register-module! ../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:utils:psi_utils)
!(import! &self hyperon-openpsi:main:feeling-updaters)

!(assertEqual (modulator_to_feeling_dimension 0.85 1) 1)
!(assertEqual (feeling_calculator 1 1 1 1 1 5) 0.3252525252525253)
!(assertEqual (happinessFeelingUpdater) 0.15656565656565663)
!(assertEqual (sadnessFeelingUpdater) 0.3456937799043062)
!(assertEqual (angerFeelingUpdater) 0.22953216374269003)
!(assertEqual (hateFeelingUpdater) 0.16823865409076727)
!(assertEqual (gratitudeFeelingUpdater) 0.2575757575757577)

