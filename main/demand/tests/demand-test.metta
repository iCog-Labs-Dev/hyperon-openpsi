!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:main:demand:demand)

!(bind! &demandSpace (new-space))
(= (random $x $y) 0.2) ;; For deterministic testing only

;; Adding demands
!(addDemand &demandSpace energy 0 1 0.4)
!(addDemand &demandSpace affiliation 0 1 1.2)
!(addDemand &demandSpace competence 0 1 0.2)
!(skipDemand &demandSpace competence)

!(assertEqual (getDemandByName &demandSpace energy) (demand energy 0 1 0.4))
!(assertEqual (getAllDemands &demandSpace)  ((demand energy 0 1 0.4) (demand affiliation 0 1 1.2) (demand competence 0 1 0.2)))

;; Existence checks
!(assertEqual (exists-In &demandSpace (demand energy 0 1 0.4)) True)
!(assertEqual (exists-In &demandSpace (demand competence 0 1 0.2)) True)
!(assertEqual (exists-In &demandSpace (skip competence)) True)
!(assertEqual (exists-In &demandSpace (demand energy 0 1 0.9)) False)

!(updateDemandValue &demandSpace competence 0.8)
!(assertEqual (fetchDemand &demandSpace energy)  (demand energy 0 1 0.4))
!(assertEqual (fetchDemand &demandSpace competence)  (demand competence 0 1 0.8))
!(assertEqual (getEnabledDemands &demandSpace) ((demand affiliation 0 1 1.2) (demand energy 0 1 0.4)))
!(assertEqual (fetchDemandVal &demandSpace energy) 0.4)
!(assertEqual (fetchDemandMinVal &demandSpace affiliation) 0)
!(assertEqual (fetchDemandMaxVal &demandSpace affiliation) 1)

; ;; Demand Decay Tests
!(decaySkippedDemands &demandSpace 0.05)
!(assertEqual (fetchDemandVal &demandSpace competence) 0.75)

!(decayAllDemands &demandSpace 0.02)
!(assertEqual (fetchDemandVal &demandSpace energy) 0.38)
!(assertEqual (fetchDemandVal &demandSpace affiliation) 1.18)
!(assertEqual (fetchDemandVal &demandSpace competence) 0.73)

;; Demand Satisfaction Tests
!(assertEqual (calculateDemandSatisfaction &demandSpace energy) 0.8400000000000001)
!(assertEqual (calculateDemandSatisfaction &demandSpace affiliation) 0.92)
!(assertEqual (fetchLeastSatisfiedDemand &demandSpace) (demand energy 0 1 0.38))