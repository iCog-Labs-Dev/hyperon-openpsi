!(register-module!  ../../hyperon-openpsi)
!(import! &self hyperon-openpsi:utils:psi_utils)
!(import! &self hyperon-openpsi:main:demand-updater)

!(TestEnergyDemand
   (let* (
           ($tv (get_latest_predicate_truth_value energy))
           ($mean (TVMean $tv))
           ($energyDemandUpdater EnergyDemandUpdater)
         )
         (assertEqual $mean ($energyDemandUpdater)))
)

!(TestWaterDemand
   (let* (
           ($thirst_mean (get_latest_predicate_truth_value_mean thirst))
           ($expected (- 1 $thirst_mean))
           ($waterDemandUpdater WaterDemandUpdater)
         )
         (assertEqual $expected ($waterDemandUpdater)))
)

!(TestAffiliationDemandUpdater
   (let* (
           ($tv_unanswered (get_predicate_truth_value has_unanswered_question))
           ($tv_changes (get_predicate_truth_value has_dramatic_changes))
           ($mean_unanswered (get_truth_value_mean $tv_unanswered));
           ($mean_changes (get_truth_value_mean $tv_changes))
           ($random (random-float 0 1))
           ($expected (- (+ 0.75 (* $random 0.25)) (+ (* 0.4 $mean_unanswered) (* 0.35 $mean_changes))))
           ($AffiliationDemandUpdater AffiliationDemandUpdater)
         )
         (assertEqual $expected ($AffiliationDemandUpdater)))
)

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
