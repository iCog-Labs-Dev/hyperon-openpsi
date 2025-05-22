!(register-module!  ../../hyperon-openpsi)
!(import! &self hyperon-openpsi:utils:psi_utils)
!(import! &self hyperon-openpsi:main:demand-updater)

!(import! &self hyperon-openpsi:main:demand-updater)

; Test physiological demand (e.g., hunger) when L > max_l 
(= (test_hunger_high) (demand_updater hunger 25 10 20 0.9 0.1 () 0 () 0)) 
!(assertEqual (test_hunger_high) (new-state (hunger 0.92 9.1 18.1)))

; Test physiological demand (e.g., hunger) when min_l <= L <= max_l 
(= (test_hunger_mid) (demand_updater hunger 15 10 20 0.9 0.1 () 0 () 0)) 
!(assertEqual (test_hunger_mid) (new-state (hunger (+ 0.8 (* 0.2 0.2)) 9.1 18.1)))

<<<<<<< HEAD
; Test certainty demand 
(= (test_certainty) (demand_updater certainty 0 10 20 0.9 0.1 (1000 2000 3000) 4000 () 0)) 
!(assertEqual (test_certainty) (new-state (certainty (calc_certainty (1000 2000 3000) 4000) 9 18)))

; Test competence demand (assuming nf=0 for simplicity) 
(= (test_competence) (demand_updater competence 10 10 20 0.9 0.1 () 0 () 0)) 
!(assertEqual (test_competence) (new-state (competence (calc_competence 10 0) 9 18)))

; Test affiliation demand 
(= (test_affiliation) (demand_updater affiliation 0 10 20 0.9 0.1 () 0 (50 100 150) 200))
!(assertEqual (test_affiliation) (new-state affiliation (calc_affiliation (50 100 150) 200) 9 18))

(= (test_hunger_low)  (demand_updater hunger 5 10 20 0.9 0.1 () 0 () 0) )
!(assertEqual  (test_hunger_low) (new-state (hunger (fuzzy_equal 5 10 150) 9 18)))
=======
!(TestCertaintyDemand
   (let* (
           ($changes_tv (1))
           ($changes_arg (1))
           ($tv_level (/ 1 (+ 1 (* 0.001 (+ (size-atom $changes_tv) (* 20 (random-float 0 1))) ))))
           ($arg_level (/ 1 (+ 1 (* 0.001 (+ (size-atom $changes_arg) (* 1 (random-float 0 1)))))))
           ($goal_mean (get_latest_predicate_truth_value_mean CertaintyDemandGoal))
           ($expected (+ (* 0.45 $tv_level) (+(* 0.35 $arg_level) (* 0.20 $goal_mean))))
           ($CertaintyDemandUpdater CertaintyDemandUpdater)
         )
         (assertEqual $expected ($CertaintyDemandUpdater)))
)
!(TestCompetenceDemand
   (let* (
           ($done_number (find_at_time_link actionDone))
           ($failed_number (find_at_time_link actionFailed))
           ($done_num (+ $done_number (+ (* (random-float 0 1) 2) 3.0123)))
           ($failed_num (+ $failed_number (+ (* (random-float 0 1) 1) 0.0123)))
           ($failed_num (car-atom $failed_num))
           ($expected (/ $done_num (+ $done_num (pow-math $failed_num 1.5))))
           ($CompetenceDemandUpdater CompetenceDemandUpdater)
         )
         (assertEqual $expected ($CompetenceDemandUpdater)))
)
;
>>>>>>> ef62db0cb5775575ba1c1d3ed036aeb62314010b
