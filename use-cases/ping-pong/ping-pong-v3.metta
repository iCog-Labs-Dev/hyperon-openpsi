!(bind! &r (new-space)) 
!(bind! &testedActions (new-space))
!(bind! sleep (py-atom time.sleep))
!(bind! random (py-atom random.random))

!(bind! energy-threshold 0.25) ;; energy threshold for performing actions
!(bind! success-rate 0.8) ;; chance that opponent misses
!(bind! energy-decrease 0.2) ;; energy decrease after performing an action
!(bind! energy-increase 0.1) ;; enery increase until opponent returns the ball

;; Here MOTIVATION is treated as ENERGY for simplicity.


;; Consumes Energy. Fails if motivation is too low.
(= (ping) 
    (let* (
        ($energy-val (goal-value (agent motivation) &r))
        ($t (sleep 0.5))
        )
        (if (< $energy-val energy-threshold)
            ;; failure Case
            (let $_ (println! (format-args "   [Action] Missed! Too tired (Energy: {}). Game Over ❌" ($energy-val)))
                (setGv (ball lost) 1.0 &r)
            )

            ;; success Case
            (let* (
                ($_ (println! (format-args "   [Action] SMASH! Returning ball... (Energy: {})" ($energy-val))))

                ($_ (setGv (ball heading-to-agent) 0.0 &r))
                ($_ (setGv (ball heading-to-opponent) 1.0 &r))

                ;; We just spent energy. it'll increase tiredness.
                ;; Urge = desired-energy - current-energy.
                ;; So reducing energy makes urge go UP. ∴ increase-urge
                ($_ (increase-urge (agent motivation) energy-decrease &r))
            ) (ball heading-to-opponent))
        )
    )
)


;; Simulates Opponent Turn. Recovers Energy.
(= (exec-wait) 
    (let* (
        ($chance (random))
        ($t (sleep 0.5))
        ($_ (println! "   [Action] Waiting for opponent ..."))
        ($_ (println! (format-args "   [Play] Chance value: {} "($chance))))
    )
        (if (> $chance success-rate)
            (let $_ (println! "   [Play] Opponent Missed! You Win! 🥇")
                (setGv (ball lost) 1.0 &r)
            )
            (let* (
                ($_ (println! "   [Play] Opponent returns the ball."))
                ($_ (setGv (ball heading-to-opponent) 0.0 &r))
                ($_ (setGv (ball heading-to-agent) 1.0 &r))

                ;; Waiting restores energy. it'll decrease tiredness.
                ;; That means current-energy moves closer to desired-energy.
                ;; So urge (unmet need for energy) goes DOWN. ∴ decrease-urge
                ($_ (decrease-urge (agent motivation) energy-increase &r))
            ) (ball heading-to-agent))
        )
    )
)

;; Agent loop execute plan

(= (execute-plan $plan)
    (if (== $plan ())
        True
        (let* (
            (($head $rest) (decons-atom $plan))
        )
            (if (== $head act-ping)
                (let* (
                    ($res (ping))
                    ($lost (collapse (match &r (Goal (ball lost) 1.0 $d) (ball lost))))
                    )
                    (if (== () $lost) True False))

                (if (== $head act-wait)
                    (let* (
                        ($res (exec-wait))
                        ($lost (collapse (match &r (Goal (ball lost) 1.0 $d) (ball lost))))
                        )
                        (if (== () $lost) True False))
                    (println! "Unknown Action")
                )
            )
        )
    )
)

(= (clear-space $space)
    (let $atoms (get-atoms $space)
        (remove-atom $space $atoms)
    )
)

;; Main loop
(= (main-loop $step)
    ;; 1. Check Game Over
    (let $is_lost (collapse (match &r (Goal (ball lost) 1.0 $d) True))
        (if (== $is_lost True)
            (println! "\nGAME OVER")
            (let* (
                ($ball-at-agent (goal-value (ball heading-to-agent) &r))
                ($current-state (if (== $ball-at-agent 1.0) (ball heading-to-agent) (ball heading-to-opponent)))
                ($target-state  (if (== $ball-at-agent 1.0) (ball heading-to-opponent) (ball heading-to-agent)))
            )
                (let* (
                    ($_ (println! (format-args "\nTurn {} | State: {}" ($step $current-state))))
                    ($__ (collapse(clear-space &testedActions))) 
                    
                    ($plan (hillClimbingPlanner $current-state $target-state &testedActions () &r))
                    ; ($_ (println! (Generated Plan: $plan)))
                )
                    (if (== $plan ())
                        (println! "No plan found!")
                        (let $continue (execute-plan $plan)
                            (if $continue
                                (main-loop (+ $step 1))
                                (println! "\nGAME OVER")
                            )
                        )
                    )
                )
            )
        )
    )
)