!(register-module! ../../../hyperon-openpsi)
!(register-module! ../../utilities-module)

!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v2)
!(import! &self hyperon-openpsi:main:types)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)


!(import! &self hyperon-openpsi:main:modulator:modulator)
!(import! &self hyperon-openpsi:main:demand:demand)

!(bind! &r (new-space)) 
!(bind! &modulator-Space (new-space))
!(bind! &demand-Space (new-space))


(=(reverse $list $acc)  
    (if(== $list ()) $acc
    (let ($head $tail ) (decons-atom $list) (reverse $tail (cons-atom $head $acc) ))
    )
)

; ping pong goal
!(addGoal (Paddle is right) 0.3 1.0 &r)
!(addGoal (Paddle is center) 0.4 1.0 &r)
!(addGoal (Paddle is left) 0.5 1.0 &r)
!(addGoal (Paddle is aligned) 0.7 1.0 &r)

!(addGoal (Ball missed) 0.8 1.0 &r)
!(addGoal (Ball is hit) 1.0 1.0 &r)


; energy goal
!(addGoal (Fuel is low) 0.0 1.0 &r)
!(addGoal (Fuel is high) 1.0 1.0 &r)



;   Rules

; Paddle moves from right to center
!(addRule &r r1 ((Paddle is right)) (Go Left1) (Paddle is center) (TTV 0 (STV 1.0 1.0)))

; Paddle moves from center to left
!(addRule &r r2 ((Paddle is center)) (Go Left2) (Paddle is left) (TTV 0 (STV 1.0 1.0)))

; Noop action keeps paddle in place 
!(addRule &r r3 ((Paddle is left)) (Noop) (Paddle is aligned) (TTV 0 (STV 1.0 1.0)))

; Fire action hits the ball if paddle aligned with ball
!(addRule &r r4 ((Paddle is aligned)) (Fire) (Ball is hit) (TTV 0 (STV 1.0 1.0)))

; Fill the fuel if level of fuel is low
!(addRule &r r5 ((Fuel is low)) (Fill) (Fuel is high) (TTV 0 (STV 1.0 1.0)))

; Action Planner
; !(let $planner (hillClimbingPlanner (Paddle is right) (Ball is hit) (TestedActions) () &r) (reverse $planner ()))
; !(let $planner (hillClimbingPlanner (Fuel is low) (Fuel is high) (TestedActions) () &r) (reverse $planner ()))


; experiment with modulators and demands
; Plan Actions based on modulator and demand values

; modulators
!(insert-modulators &modulator-Space)

; fetch modulator value and plan the actions
; if selection-threshold is high, plan actions to hit the ball
!(let $st (fetch-modulator-val  &modulator-Space selection-threshold) 
        (if (>  $st 0.45) 
            (let $planner (hillClimbingPlanner (Paddle is right) (Ball is hit) (TestedActions) () &r) (reverse $planner ()))
            ()
        )
) 



; demands 
!(addDemand &demand-Space energy 0.3)

; fetch demands value and plan the actions
; if energy is low, plan actions to fill the fuel   
!(let $energy (fetch-demand-val &demand-Space energy) 
        (if (<  $energy 0.5) 
            (let $planner (hillClimbingPlanner (Fuel is low) (Fuel is high) (TestedActions) () &r) (reverse $planner ()))
            ()
        )
)

