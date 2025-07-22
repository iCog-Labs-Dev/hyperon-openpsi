!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:main:modulator:modulator)

!(bind! &test-space (new-space))

!(insert-modulators &test-space)
!(assertEqual (fetch-modulator &test-space securing-threshold) (modulator securing-threshold 0.5))
!(fetch-modulator &test-space securing-threshold)
!(fetch-modulator-val &test-space securing-threshold)

!(assertEqual (fetch-modulator-val &test-space securing-threshold) 0.5)
!(assertEqual(normalize-value 6.0) 0.8571428571428571)
!(assertEqual(normalize-value 9.0) (ERROR (provide unique values)))
!(assertEqual (add-modulator &test-space (modulator custom 0.8)) ())
!(assertEqual (add-modulator &test-space (modulator custom 1.8)) (Error (value is incorrect) BadType))


