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
;; ============================================
;; Demand Arbitration - Tie-Break Tests
;; Priority order: energy > competence > affiliation
;; ============================================

!(bind! &tieSpace (new-space))

;; --- Test: energy vs competence tie ---
;; Both values are inside their [min,max] range, so under the
;; deterministic (random $x $y) 0.2 override, both get satisfaction
;; = 0.8 + 0.2*0.2 = 0.84 -- an exact tie.
!(addDemand &tieSpace energy 0 1 0.5)
!(addDemand &tieSpace competence 0 1 0.5)

!(assertEqual (calculateDemandSatisfaction &tieSpace energy) 0.8400000000000001)
!(assertEqual (calculateDemandSatisfaction &tieSpace competence) 0.8400000000000001)

;; energy should win, since it's higher priority than competence
!(assertEqual (fetchLeastSatisfiedDemand &tieSpace) (demand energy 0 1 0.5))


;; --- Test: competence vs affiliation tie ---
!(bind! &tieSpace2 (new-space))
!(addDemand &tieSpace2 competence 0 1 0.5)
!(addDemand &tieSpace2 affiliation 0 1 0.5)

;; competence should win, since it's higher priority than affiliation
!(assertEqual (fetchLeastSatisfiedDemand &tieSpace2) (demand competence 0 1 0.5))


;; --- Test: three-way tie (all equal) ---
!(bind! &tieSpace3 (new-space))
!(addDemand &tieSpace3 affiliation 0 1 0.5)
!(addDemand &tieSpace3 competence 0 1 0.5)
!(addDemand &tieSpace3 energy 0 1 0.5)

;; energy should win overall, since it's top of the priority order
!(assertEqual (fetchLeastSatisfiedDemand &tieSpace3) (demand energy 0 1 0.5))


;; --- Test: no tie, priority irrelevant ---
;; competence is genuinely less satisfied (below its min), so it
;; should win regardless of priority order -- priority only matters on ties.
!(bind! &tieSpace4 (new-space))
!(addDemand &tieSpace4 energy 0 1 0.5)
!(addDemand &tieSpace4 competence 0 1 -0.5)

!(assertEqual (fetchLeastSatisfiedDemand &tieSpace4) (demand competence 0 1 -0.5))