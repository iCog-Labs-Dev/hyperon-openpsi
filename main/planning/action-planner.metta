!(bind! np (py-atom numpy))
!(bind! &testedActions (new-space))

(= (TestedActions) &testedActions)

(= (hillClimbingPlanner $initialState $goal $testedActions $plan $ruleSpace)
   (if (== $initialState $goal) ;if thecurrent state is the goal or a path from $initalState to $goal has been found, return the plan.
     $plan
     (let* (
            ($tested (getTestedActions $initialState $testedActions)) ;query tested actions for initialState.
            ($applicableActions (collapse (match $ruleSpace 
                                                 (: $handle (IMPLICATION_LINK (AND_LINK (($initialState) $action)) $g))
                                                 $action))) ;get applicable actions and.
            ($untriedActions (filterUntriedRules $applicableActions $tested () )) ;Filter out the ones that already have been tested.
            ;(() (println! ( tested --> $tested untried --> $untriedActions applicable --> $applicableActions plan --> $plan)))
          )
       (if (== $untriedActions ()) ;No untested actions, return () to back
         ()
         (let* (
                ($newStates (applyActions $untriedActions $initialState () $ruleSpace)) ;Apply all actions to get new states.
                (($minDistance $bestPair) (findMinDistance $newStates $goal 1000 () $ruleSpace)) ;find the least distance among the new states.
                ($currentDistance (distance $initialState $goal $ruleSpace))
                ($bestAction (car-atom $bestPair))
                ($bestState (cadr-atom $bestPair))
                ;(() (println! (new-stateus (bestAction $bestAction) (appActions $newStates) (currState $initialState) 
                ;(plan $plan) (currDistance $currentDistance) (minDis $minDistance))))
              )
           (if (>= $currentDistance $minDistance)
            (let () (update-atom $testedActions ($initialState $bestAction) ($bestState $bestAction)) 
              (hillClimbingPlanner $bestState $goal $testedActions (cons-atom $bestAction $plan) $ruleSpace) ;recursively explore the best state
              )
              ;No improvement, mark all untried actions as tested and return () to backtrack
             (let $res (allTested $untriedActions $tested) (let $m (markAllTested $initialState $untriedActions $testedActions) ()))
            )
          )
         )
      )
    )
   )

(= (distance $current $goal $ruleSpace)
   (let* (
          ($x (- (goal-value $goal $ruleSpace) (goal-value $current $ruleSpace)))
          ($y (- (desired-goal-value $goal $ruleSpace) (desired-goal-value $current $ruleSpace)))
          )
     (+ $x $y)
     )
  )

(= (applyActions $actions $goal $acc $ruleSpace)
   (if (== $actions ())
     $acc
     (let* (
            (($head $tail) (decons-atom $actions))
            ($res (collapse (match $ruleSpace (: $handle (IMPLICATION_LINK (AND_LINK (($goal) $head)) $g) ) ($head $g))))
            ($rest (applyActions $tail $goal (concatTuple $res $acc) $ruleSpace))
            ;(() (println! (appAc $res )))
          )
       (if (== $head ())
         (concatTuple $acc $res)
         $rest
         )
      )
     )
   )
   
(= (filterUntriedRules $actions $tested $acc)
     (if (== $actions ())
      $acc
      (let ($head $tail) (decons-atom $actions)
        (if (isMember $head $tested)
          (filterUntriedRules $tail $tested $acc)
          (filterUntriedRules $tail $tested (cons-atom $head $acc))
          )
       )
    )
   )

(= (findMinDistance $newStates $goal $minDistance $bestPair $ruleSpace)
   (if (== $newStates ())
     ($minDistance $bestPair)
     (let* (
            ((($action $state) $tail) (decons-atom $newStates))
            ($dist (distance $state $goal $ruleSpace))
            )
          (if (< $dist $minDistance)
            (findMinDistance $tail $goal $dist ($action $state) $ruleSpace)
            (findMinDistance $tail $goal $minDistance $bestPair $ruleSpace)
            )
      )
    )
   )

(= (allTested $actions $tested)
   (if (== $actions ())
     $tested
     (let $res (union-atom $actions $tested) (unique-atom $res))
     )
   )

(= (markAllTested $state $list $space)
   (if (== $list ())
     ()
     (let* (
            ($head (car-atom $list))
            ($tail (cdr-atom $list))
            )
       (if (== $head ())
         ()
         (let () (add-atom $space ($state $head)) (markAllTested $state $tail $space))
         )
       )
     )
   )

(= (getTestedActions $key $space)
   (collapse (match $space ($key $action) $action))
   )
