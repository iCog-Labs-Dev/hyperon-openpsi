!(register-module! ../../../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:util)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:math)

;; Unit tests for utility functions
!(assertEqual (confidenceToCount 0.5) 800.0)
!(assertEqual (countToConfindence 800.0) 0.5)

!(assertEqual (stvToBeta (0.25 0.5)) (200.0 600.0))
!(assertEqual (betaToSTV (200.0 600.0)) (0.25 0.501))

