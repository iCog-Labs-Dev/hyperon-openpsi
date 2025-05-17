!(register-module! ../utils)
!(register-module! ../utilities-module)
!(import! &self utils)
!(import! &self utilities-module:utils)
; there is an import error





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
    (let ( ($eval_has_unanswered_question
               (EvaluationLink (PredicateNode has_unanswered_question) )
           )
           ($eval_has_dramatic_changes
               (EvaluationLink (PredicateNode has_dramatic_changes) )
           )
         ) 

         (- (+  0.75 
                (* (random-float 0 0.25) 0.25)
            )

            (+ 
                (* 0.4  (get_truth_value_mean (cog-tv $eval_has_unanswered_question) ) )
                (* 0.35 (get_truth_value_mean (cog-tv $eval_has_dramatic_changes) ) )
            )    
         ); -
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
         )
         ; Normalize levels of changes to [0, 1]
         ;
         ; Note: The formular is 
         ;       xxx_level = 1 / (1 + a*x^2)
         ;
         ; TODO: we add a random number to introduce some noise, which would
         ;       make this function still works even the virtual world is not 
         ;       ready to populate interesting stuff. Remove these random noise later. 
         ;
         
         (let ($change_with_tv_level
             (/ 1
                (+ 1 
                   (* 0.001 
                      (+ (len $changes_with_tv) (* 20 (random-float 0 1)) )
                      (+ (len $changes_with_tv) (* 20 (random-float 0 1)) )
                   )  
                )
             )
         ))

         (let ($change_with_arg_level
             (/ 1
                (+ 1 
                   (* 0.001
                      (+ (len $changes_with_arg) (* 1 (random-float 0 1)) )
                      (+ (len $changes_with_arg) (* 1 (random-float 0 1)) )
                   )  
                )
             )
         )

         ; Return certainty level
         (+ (* 0.45 $change_with_tv_level) 
            (* 0.35 $change_with_arg_level)
            (* 0.20 (get_truth_value_mean (cog-tv CertaintyDemandGoal)) )
         )
    ) 
))


(= (CompetenceDemandUpdater)
    (let* ( ($plan_done_at_time_link_list 
                (match $self (find_at_time_link actionDone) ) 
            )

            ($plan_failed_at_time_link_list
                (match $self (find_at_time_link actionFailed) ) 
            )

            ($plan_done_number (len $plan_done_at_time_link_list) )
            ($plan_failed_number (len $plan_failed_at_time_link_list) )
          )
 
          ; avoid division by zero and decimal part will force guile return floating
          ; numbers while division. That is return 0.33333, rather than 1/3, 
          ; which will confuse the caller via cpp code. 
          (let* (
            ($plan_done_number
              (+ $plan_done_number 
                 (* (random-float 0 1) 2) 
                 3.0123 
              )
            )

            ($plan_failed_number
              (+ $plan_failed_number 
                 (* (random-float 0 1) 1) 
                 0.0123
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