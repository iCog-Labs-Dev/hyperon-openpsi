!(register-module!  ../utils)
!(register-module! ../main)
!(import! &self utils:psi_utils)
!(import! &self main)

;; Test EnergyDemandUpdater
;!(TestEnergyDemand
;   (let* (
;           ($tv (get_latest_predicate_truth_value "energy"))
;           ($mean (TVMean $tv))
;         )
         ;(assertEqual $mean (get_latest_predicate_truth_value_mean "energy")))
;)

;; Test WaterDemandUpdater
!(TestWaterDemand
   (let* (
           ($thirst_mean (get_latest_predicate_truth_value_mean "thirst"))
           ($expected (- 1 $thirst_mean))
         )
         (assertEqual $expected (WaterDemandUpdater)))
)

;; Test AffiliationDemandUpdater
!(TestAffiliationDemand
   (let* (
           ($eval_unanswered (get_evaluation_link "has_unanswered_question"))
           ($eval_changes (get_evaluation_link "has_dramatic_changes"))
           ($tv_unanswered (get-tv $eval_unanswered))
           ($tv_changes (get-tv $eval_changes))
           ($mean_unanswered (TVMean $tv_unanswered))
           ($mean_changes (TVMean $tv_changes))
           ($random (random-float 0 1))
           ($expected (- (+ 0.75 (* $random 0.25)) (+ (* 0.4 $mean_unanswered) (* 0.35 $mean_changes))))
         )
         (assertEqual $expected (AffiliationDemandUpdater)))
)

;; Test CertaintyDemandUpdater (assuming get_changes_with_tv/arg return lists)
!(TestCertaintyDemand
   (let* (
           ($changes_tv (get_changes_with_tv))
           ($changes_arg (get_changes_with_arg))
           ($tv_level (/ 1 (+ 1 (* 0.001 (+ (size-atom $changes_tv) (* 20 (random-float 0 1))) (+ (size-atom $changes_tv) (* 20 (random-float 0 1)))))))
           ($arg_level (/ 1 (+ 1 (* 0.001 (+ (size-atom $changes_arg) (* 1 (random-float 0 1))) (+ (size-atom $changes_arg) (* 1 (random-float 0 1)))))))
           ($goal_tv (get-tv (match &self CertaintyDemandGoal CertaintyDemandGoal)))
           ($goal_mean (TVMean $goal_tv))
           ($expected (+ (* 0.45 $tv_level) (* 0.35 $arg_level) (* 0.20 $goal_mean)))
         )
         (assertEqual $expected (CertaintyDemandUpdater)))
)

!(TestCompetenceDemand
   (let* (
           ($done_list (find_at_time_link "actionDone"))
           ($failed_list (find_at_time_link "actionFailed"))
           ($done_num (+ (size-atom $done_list) (* (random-float 0 1) 2) 3.0123))
           ($failed_num (+ (size-atom $failed_list) (* (random-float 0 1) 1) 0.0123))
           ($expected (/ $done_num (+ $done_num (pow-math $failed_num 1.5))))
         )
         (assertEqual $expected (CompetenceDemandUpdater)))
)