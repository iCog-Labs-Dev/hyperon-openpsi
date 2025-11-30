!(bind! &r (new-space)) 
!(bind! &testedActions (new-space))
!(bind! sleep (py-atom time.sleep))
!(bind! random (py-atom random.random))

!(bind! energyThreshold 0.25) ;; energy threshold for performing actions
!(bind! successRate 0.8) ;; probability of opponent returning the ball
!(bind! energyDecrease 0.2) ;; energy decrease after performing an action
!(bind! energyIncrease 0.1) ;; enery increase until opponent returns the ball

;; Here MOTIVATION is treated as ENERGY for simplicity.


;; Consumes Energy. Fails if motivation is too low.
(= (ping) 
    (let* (
        ($energyVal (goal-value (agent motivation) &r))
        ($t (sleep 0.5))
        )
        (if (< $energyVal energyThreshold)
            ;; failure Case
            (let $_ (println! (format-args "   [Action] Missed! Too tired (Energy: {}). Game Over ❌" ($energyVal)))
                (setGv (ball lost) 1.0 &r)
            )

            ;; success Case
            (let* (
                ($_ (println! (format-args "   [Action] SMASH! Returning ball... (Energy: {})" ($energyVal))))

                ($_ (setGv (ball heading-to-agent) 0.0 &r))
                ($_ (setGv (ball heading-to-opponent) 1.0 &r))

                ;; We just spent energy. it'll increase tiredness.
                ;; Urge = desired-energy - current-energy.
                ;; So reducing energy makes urge go UP. ∴ increase-urge
                ($_ (increase-urge (agent motivation) energyDecrease &r))
            ) (ball heading-to-opponent))
        )
    )
)


;; Simulates Opponent Turn. Recovers Energy.
(= (executeWait) 
    (let* (
        ($prob (random))
        ($t (sleep 0.5))
        ($_ (println! "   [Action] Waiting for opponent ..."))
        ($_ (println! (format-args "   [Play] probability value: {}" ($prob))))
    )
        (if (> $prob successRate)
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
                ($_ (decrease-urge (agent motivation) energyIncrease &r))
            ) (ball heading-to-agent))
        )
    )
)

;; Agent loop execute plan

(= (executePlan $plan)
    (if (== $plan ())
        True
        (let* (
            (($head $rest) (decons-atom $plan))
            ; ($_ (println! ("Head and Rest:" $head $rest)))
        )
            (if (== $head act-ping)
                (let* (
                    ($res (ping))
                    ($lost (collapse (match &r (Goal (ball lost) 1.0 $d) (ball lost))))
                    )
                    (if (== () $lost) 
                        (executePlan $rest)
                        False
                    ))

                (if (== $head act-wait)
                    (let* (
                        ($res (executeWait))
                        ($lost (collapse (match &r (Goal (ball lost) 1.0 $d) (ball lost))))
                        )
                        (if (== () $lost) 
                            (executePlan $rest)
                            False
                        ))
                    (println! "Unknown Action")
                )
            )
        )
    )
)

(= (clearSpace $space)
    (let $atoms (get-atoms $space)
        (remove-atom $space $atoms)
    )
)

;; Main loop
(= (mainLoop $step)
    ;; 1. Check Game Over
    (let $isOver (collapse (match &r (Goal (ball lost) 1.0 $d) True))
        (if (== $isOver True)
            (println! "\nGAME OVER")
            (let* (
                ($ballAtAgent (goal-value (ball heading-to-agent) &r))
                ($currentState (if (== $ballAtAgent 1.0) (ball heading-to-agent) (ball heading-to-opponent)))
                ($targetState  (if (== $ballAtAgent 1.0) (ball heading-to-opponent) (ball heading-to-agent)))
            )
                (let* (
                    ($_ (println! (format-args "\nTurn {} | State: {}" ($step $currentState))))
                    ($__ (collapse(clearSpace &testedActions))) 
                    
                    ($plan (hillClimbingPlanner $currentState $targetState &testedActions () &r))
                    ($_ (println! (Generated Plan: $plan)))
                )
                    (if (== $plan ())
                        (println! "No plan found!")
                        (let $continue (executePlan $plan)
                            (if $continue
                                (mainLoop (+ $step 1))
                                (println! "\nGAME OVER")
                            )
                        )
                    )
                )
            )
        )
    )
)