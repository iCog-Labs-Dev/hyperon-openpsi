(demands ((demand affiliation 0.5) (demand competence 0.9) (demand energy 0.9)))
(modulators ((modulator positive-valence 0.5) (modulator goal-directedness 0.5) (modulator resolution-level 0.5) (modulator arousal (normalizeWithSpecificRange 1.6090225563909775 0.0 1)) (modulator securing-threshold (normalizeWithSpecificRange 1.125 0.0 1)) (modulator selection-threshold (normalizeWithSpecificRange (+ 1 (fuzzy_equal 0.9 1 15)) 0.0 1))))
(initiate-dialogue)
