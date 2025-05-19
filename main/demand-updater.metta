

(= (EnergyDemandUpdater)
; is there similar function as (get_latest_predicate_truth_value_mean)
    (get_latest_predicate_truth_value_mean energy)
)
(= (WaterDemandUpdater)
    (- 1
       (get_latest_predicate_truth_value_mean thirst) 
    ) 
)   


(= (AffiliationDemandUpdater)
    (let* ( ($tv_unanswered (get_predicate_truth_value has_unanswered_question))
            ($tv_changes (get_predicate_truth_value has_dramatic_changes))
            ($mean_unanswered (get_truth_value_mean $tv_unanswered))
            ($mean_changes (get_truth_value_mean $tv_changes))
            ($random (random-float 0 1))
          )
          (- (+ 0.75 (* $random 0.25))
             (+ (* 0.4 $mean_unanswered) (* 0.35 $mean_changes)))
    )
)

; If the world changes more frequently, more certainty demand is required 
(= (CertaintyDemandUpdater)
    (let* 
            ; something has to be done with get_changes_with_tv, get_changes_with_arg

         ( ($hanges_with_tv (get_changes_with_tv) )
           ($changes_with_arg (get_changes_with_arg) )
           ($change_with_tv_level 0)
           ($change_with_arg_level 0)
            ($change_with_tv_level
             (/ 1
                (+ 1 
                   (* 0.001 
                      (+ (len $changes_with_tv) (* 20 (random-float 0 1)) )
                      (+ (len $changes_with_tv) (* 20 (random-float 0 1)) )
                   )  
                )
             )
            )
          ($change_with_arg_level
             (/ 1
                (+ 1 
                   (* 0.001
                      (+ (len $changes_with_arg) (* 1 (random-float 0 1)) )
                      (+ (len $changes_with_arg) (* 1 (random-float 0 1)) )
                   )  
                )
             )
            )
         ($goal_mean (get_latest_predicate_truth_value_mean CertaintyDemandGoal))
         )

         ; Return certainty level
         (+ (* 0.45 $change_with_tv_level) 
            (* 0.35 $change_with_arg_level)
            (* 0.20 $goal_mean)
         )
    ) 
)


(= (CompetenceDemandUpdater)
    (let* ( ($plan_done_at_time_link_list 
                (collapse (match $self (find_at_time_link "actionDone") $action_done)) 
            )

            ($plan_failed_at_time_link_list
                (collapse (match $self (find_at_time_link "actionFailed") $action_failed)) 
            )

            ($plan_done_number (size-atom $plan_done_at_time_link_list) )
            ($plan_failed_number (size-atom $plan_failed_at_time_link_list) )
          )
 
          ; avoid division by zero and decimal part will force guile return floating
          ; numbers while division. That is return 0.33333, rather than 1/3, 
          ; which will confuse the caller via cpp code. 
          (let* (
            ($plan_done_number
              (+ $plan_done_number 
                 (+ (* (random-float 0 1) 2) 
                 3.0123 )
              )
            )

            ($plan_failed_number
              (+ $plan_failed_number 
                (+ (* (random-float 0 1) 1) 
                 0.0123
                 )
              ) 
            )
          )
          )
          (/ $plan_done_number
             (+ $plan_done_number (pow-math $plan_failed_number 1.5) )
          )
;
;          (/ plan_done_number
;             (+ plan_done_number (* 4 plan_failed_number) )
;          )
    ); let*
)

