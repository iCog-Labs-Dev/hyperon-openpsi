!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:main:emotion:emotion)
!(bind! &test-space (new-space))

;;Tests for emotion 
!(assertEqual (create-emotion &test-space (emotion new-emotion 0)) ())
;; !(get-emotions &test-space)
!(assertEqual (create-emotion &test-space (emotion new-emotion 5)) (ERROR is Available))
!(assertEqual (isAvailable? &test-space (emotion old-emotion 6)) False)
!(assertEqual (isAvailable? &test-space (emotion new-emotion 5)) True)
!(assertEqual (create-emotion &test-space old-emotion) (ERROR Wrong Format))

