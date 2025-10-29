!(register-module! ../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:psi-utilities:miner)
!(bind! &perceptaSpace (new-space))

;; Add perceptions to the percepta space
!(addPerceptions &perceptaSpace (
  (perception 5 (see ball red))
  (perception 5 (hear alarm loud))
  (perception 5 (feel temperature cold))
  (perception 5 (smell smoke faint))
  (perception 5 (taste food sweet))
  (perception 5 (see door open))
  (perception 5 (detect motion quick))
  (perception 5 (notice light dim))
  (perception 5 (sense danger high))
  (perception 5 (observe person walking))
))

!(miner &perceptaSpace 10)