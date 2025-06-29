!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:main:modulator:modulator)

!(bind! &modulator-space (new-space))

!(insert-modulators &modulator-space)
!(assertEqual (fetch-modulator &modulator-space securing-threshold) ((modulator securing-threshold 0.5)))
!(assertEqual (fetch-modulator-val &modulator-space securing-threshold) 0.5)
!(assertEqual(normalize-value 6.0) 0.8571428571428571)
!(assertEqual(normalize-value 9.0) (ERROR (provide unique values)))
!(assertEqual (add-modulator &modulator-space (modulator custom 0.8)) ())
!(assertEqual (add-modulator &modulator-space (modulator custom 1.8)) (Error (value is incorrect) BadType))


