!(register-module! ../../../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:monster-combat:rules)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:util)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:math)

;; A simple monster combat scenario using Thompson Sampling for action selection
(: gameLoop (-> Expression Expression hyperon::space::DynSpace Expression))
(= (gameLoop $context $goal $ruleSpace) (
    let* (
        ($applicableGoals (matchGoal $goal $ruleSpace))
        ($applicableRules (matchContexts $applicableGoals $context $ruleSpace))
        ($_ (println! ("Applicable rules: " $applicableRules)))
        (($chosenActionId $score) (thompsonSample $applicableRules $ruleSpace))
        ($result (performAction $chosenActionId $context $ruleSpace))
        ($_ (println! (# $chosenActionId was chosen and executed and resulted in $result)))
        ($updatedRule (updateRule $chosenActionId $result $ruleSpace))
    ) ()
))

;; Function to get a random context (CLOSE_RANGE, MID_RANGE, LONG_RANGE)
(: getRandomContext (-> Expression))
(= (getRandomContext) (
    let* (
        ($random (getRandomInt 1 3))
    ) (if (== $random 1)
        ((Position CLOSE_RANGE))
        (if (== $random 2)
            ((Position MID_RANGE))
            ((Position LONG_RANGE))
        )
)))

;; Initialize rule space and add game rules
!(bind! &rules (new-space))
!(addGameRules &rules)

(: run (-> Number Expression))
(= (run $iter) (
    if (== $iter 0)
        ()
        (let* (
            ($context (getRandomContext))
            ($_ (println! (--- Iteration  $iter with context $context  ---)))
            ($_ (gameLoop $context (HIT) &rules))
            ($_ (println! (--- After iteration $iter ---)))
        ) (run (- $iter 1))
    )
))

;; Run 10 iterations of the game loop with random contexts
!(run 10)

!(get-atoms &rules)

;; Remark: After sampling rules 1, 5, and 9 should have higher STV values
;; where as other rules should have lower STV values if they were ever sampled.