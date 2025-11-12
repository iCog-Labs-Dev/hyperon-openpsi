; ((: r1 ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Conversation-Started 0.9 0.6) initiate-dialogue)) (Goal Send-Greeting 1.0 1.0)))) 4)
;; This action planner expects this kind of rule representation and
;; finds the most convenient actions to take to achieve the goal from the given state.

!(bind! &testedActions (new-space))

(= (Tested Actions) &testedActions)

(= (hillClimbingPlanner $state $goal $testedActions $plan $ruleSpace) (
    if (== $state $goal)
        (reverse $plan ())
        (let* (
            ($tested (getTestedActions $state $testedActions))
            ($applicableActions (getApplicableActions $state $ruleSpace))
            ($untriedActions (filterUntriedRules $applicableActions $tested ()))
            (() (println! (Untried Actions $untriedActions)))
        ) (if (== $untriedActions ())
            ()
            (let* (
                ($newStates (applyCurrentActions $untriedActions $state () $ruleSpace))
                (($minDistance $bestPair) (findMinDistance $newStates $goal 1000 () $ruleSpace))
                ($currentDistance (distance $state $goal $ruleSpace))
                ($bestAction (car-atom $bestPair))
                (($bestState) (cdr-atom $bestPair))
                ($_ (println! (Is Reached? $bestState === $goal)))
            ) (if (>= $currentDistance $minDistance)
                (let $_ (update-action-atom $testedActions ($state $bestAction) ($bestState $bestAction))
                    (hillClimbingPlanner $bestState $goal $testedActions (cons-atom $bestAction $plan) $ruleSpace)
                )
                (let $res (allTested $untriedActions $tested) (let $m (markAllTested $state $untriedActions $testedActions) ()))
            ))
        ))
))

(= (getTestedActions $state $testedActionsSpace) (
    collapse (match $testedActionsSpace ($state $action) $action)
))

(= (getApplicableActions $context $ruleSpace) (
    collapse (match $ruleSpace ((: $handle ($ttv (IMPLICATION_LINK (AND_LINK ((Goal $context $a $b) $action)) (Goal $goal $c $d)))) $weight) $action)
))

(= (filterUntriedRules $actions $tested $acc) (
    if (== $actions ()) 
        $acc
        (let ($head $tail) (decons-atom $actions) 
            (if (isMember $head $tested)
                (filterUntriedRules $tail $tested $acc)
                (filterUntriedRules $tail $tested (cons-atom $head $acc)))
        )
))

(= (applyCurrentActions $actions $state $acc $ruleSpace) (
    if (== $actions ())
        $acc
        (let* (
            (($action $tail) (decons-atom $actions))
            ($res (collapse (match $ruleSpace ((: $handle ($ttv (IMPLICATION_LINK (AND_LINK ((Goal $state $a $b) $action)) (Goal $goal $c $d)))) $weight) ($action $goal))))
            ($rest (applyCurrentActions $tail $state (union-atom $res $acc) $ruleSpace))
        )
        (if (== $action ())
            (union-atom $acc $res)
            $rest)
        )
))

(= (findMinDistance $newStates $goal $minDistance $bestPair $ruleSpace) (
    if (== $newStates ())
        ($minDistance $bestPair)
        (let* (
            ((($action $state) $tail) (decons-atom $newStates))
            ($dist (distance $state $goal $ruleSpace))
        ) (if (< $dist $minDistance)
            (findMinDistance $tail $goal $dist ($action $state) $ruleSpace)
            (findMinDistance $tail $goal $minDistance $bestPair $ruleSpace)
        ))
))

(= (distance $state $goal $ruleSpace) (
    let* (
        ($gv-diff (- (get-goal-value $goal $ruleSpace) (get-goal-value $state $ruleSpace)))
        ($dgv-diff (- (get-desired-goal-value $goal $ruleSpace) (get-desired-goal-value $state $ruleSpace)))
    ) (+ $gv-diff $dgv-diff)
))

(= (update-action-atom $space $old-atom $new-atom) (
    let $_ (remove-atom $space $old-atom) (add-atom $space $new-atom)
))

(= (allTested $actions $tested) (
    let $res (union-atom $actions $tested) (unique-atom $res)
))


(= (markAllTested $state $untriedActions $testedActions) (
    if (== $untriedActions ())
        ()
        (let* (
            (($head $tail) (decons-atom $untriedActions))
            ($_ (add-atom $testedActions ($state $head)))
        ) (if (== $head ())
            ()
            (markAllTested $state $tail $testedActions)
        ))
))

(= (get-goal-value $goal $ruleSpace) (
    let* (
        ($goal-value (collapse (match $ruleSpace ((: $handle ($ttv (IMPLICATION_LINK (AND_LINK ((Goal $context $a $b) $action)) (Goal $goal $c $d)))) $weight) $c)))
        ($context-value (collapse (match $ruleSpace ((: $handle ($ttv (IMPLICATION_LINK (AND_LINK ((Goal $goal $a $b) $action)) (Goal $g $c $d)))) $weight) $a)))
        ($both (union-atom $goal-value $context-value))
    ) (if (> (size-atom $both) 0)
        (car-atom $both)
        0
    )
))

(= (get-desired-goal-value $goal $ruleSpace) (
    let* (
        ($goal-value (collapse (match $ruleSpace ((: $handle ($ttv (IMPLICATION_LINK (AND_LINK ((Goal $context $a $b) $action)) (Goal $goal $c $d)))) $weight) $d)))
        ($context-value (collapse (match $ruleSpace ((: $handle ($ttv (IMPLICATION_LINK (AND_LINK ((Goal $goal $a $b) $action)) (Goal $g $c $d)))) $weight) $b)))
        ($both (union-atom $goal-value $context-value))
    ) (if (> (size-atom $both) 0)
        (car-atom $both)
        0
    )
))


(=(reverse $list $acc) (
    if(== $list ()) 
      $acc
      (let ($head $tail ) (decons-atom $list) (reverse $tail (cons-atom $head $acc) ))
))
