!(register-module!  ../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:demand-updater)
!(import! &self hyperon-openpsi:utils:psi-utils)


;  substitute all 0.2 by (random-float 0 1)

; Test physiological demand (e.g., hunger) when L > max_l 
(= (test_hunger_high) (demand_updater hunger 25 10 20 0.9 0.1 () 0 () 0)) 
!(assertEqual (test_hunger_high) (new-state (hunger 0.92 9.1 18.1)))

; Test physiological demand (e.g., hunger) when min_l <= L <= max_l 
(= (test_hunger_mid) (demand_updater hunger 15 10 20 0.9 0.1 () 0 () 0)) 
!(assertEqual (test_hunger_mid) (new-state (hunger (+ 0.8 (* 0.2 0.2)) 9.1 18.1)))

; Test certainty demand 
(= (test_certainty) (demand_updater certainty 0 10 20 0.9 0.1 (1000 2000 3000) 4000 () 0)) 
!(assertEqual (test_certainty) (new-state (certainty (calc_certainty (1000 2000 3000) 4000) 9 18)))

; Test competence demand (assuming nf=0 for simplicity) 
(= (test_competence) (demand_updater competence 10 10 20 0.9 0.1 () 0 () 0)) 
!(assertEqual (test_competence) (new-state (competence (calc_competence 10 0) 9.1 18.1)))

; Test affiliation demand 
(= (test_affiliation) (demand_updater affiliation 0 10 20 0.9 0.1 () 0 (50 100 150) 200))
!(calc_affiliation (50 100 150) 200)

!(assertEqual (test_affiliation) (new-state (affiliation (calc_affiliation (50 100 150) 200) 9 18)))
(= (test_hunger_low)  (demand_updater hunger 5 10 20 0.9 0.1 () 0 () 0) )
!(assertEqual  (test_hunger_low) (new-state (hunger (fuzzy_equal 5 10 150) 9 18)))
