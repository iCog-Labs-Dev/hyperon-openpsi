!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)

!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v2)
!(import! &self hyperon-openpsi:use-cases:ping-pong:ping-pong-v3)
!(import! &self hyperon-openpsi:main:types)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self utilities-module:utils)

;; STATE DEFINITIONS
;; 1. (ball heading-to-agent)
;; 2. (ball heading-to-opponent)
;; 3. (ball lost) - End of game

!(addGoal (ball heading-to-agent)    1.0 0.0 &r)
!(addGoal (ball heading-to-opponent) 0.0 0.0 &r)
!(addGoal (ball lost)                0.0 0.0 &r)
!(addGoal (agent motivation)         1.0 1.0 &r) ;; Target 1.0 if it drops too low, agent makes mistakes.



;; Rule 1: If ball is coming -> Return it -> Ball goes to opponent
!(add-atom &r 
    ((: r_return 
        ( 
            (TTV 0 (STV 1.0 1.0)) 
            (IMPLICATION_LINK 
                (AND_LINK ((Goal (ball heading-to-agent) 1.0 1.0) act-ping)) 
                (Goal (ball heading-to-opponent) 1.0 1.0)
            )
        ) 
     ) 1.0)
)

;; Rule 2: If ball is with opponent -> Wait -> Ball comes back (if they don't miss)
!(add-atom &r 
    ((: r_wait 
        ( 
            (TTV 0 (STV 1.0 1.0)) 
            (IMPLICATION_LINK 
                (AND_LINK ((Goal (ball heading-to-opponent) 1.0 1.0) act-wait)) 
                (Goal (ball heading-to-agent) 1.0 1.0)
            )
        )
     ) 1.0)
)

!(println! "Starting Ping-Pong Agent ...")
!(setGv (agent motivation) 1.0 &r)
!(mainLoop 1)