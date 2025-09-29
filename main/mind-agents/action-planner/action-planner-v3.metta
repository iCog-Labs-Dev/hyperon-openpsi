!(bind! np (py-atom numpy))
!(bind! &testedActions (new-space))
!(bind! &priorityQueue (new-space)) 
!(bind! &ruleSpace (new-space)) ; for testing 

;get the goal value and desired goal value
(= (goal-value (Goal $goal $value $dgv) $ruleSpace)
    $value
)
(= (desired-goal-value (Goal $goal $value $dgv) $ruleSpace)
    $dgv
)
;Initializes a priority queue with the initial state, a cost of 0, and an empty plan.
;Uses a visited space to track explored states and avoid cycles.
;In aStarLoop, it pops the state with the lowest cost from the priority queue.
;If the popped state is the goal, it returns the associated plan.
;If the state is unvisited, it:Marks the state as visited and tested.
;Retrieves applicable actions, filters out tested ones, and applies them to generate new states.
;For each new state, calculates a new cost (current cost + heuristic distance to goal) and adds it to the priority queue with the updated plan.
;Continues until the goal is found or the priority queue is empty (no path exists).

more A* than pure Dijkstra due to heuristic in costs.

(= (aStarPlanner $initialState $goal $testedActions $ruleSpace)
   (let* (
          ($pq &priorityQueue) ; priority queue to store (cost, state, plan) tuples
          ($visited (new-space))  
          (() (add-atom $pq (0 $initialState ()))) ; Initialize with (cost=0, initialState, empty plan)
         )
     (aStarLoop $pq $goal $testedActions $visited $ruleSpace)
   )
)

(= (aStarLoop $pq $goal $testedActions $visited $ruleSpace)
   (if (== (length (get-atoms $pq)) 0) ; if priority queue is empty, no path found
     ()
     (let* (
            (($cost $state $plan) (popMin $pq)) ; get state with minimum cost
            ($isVisited (isMember $state $visited))
           )
       (if $isVisited
         (aStarLoop $pq $goal $testedActions $visited $ruleSpace) 
         (let* (
                (() (add-atom $visited $state)) ; mark state as visited
                ($isGoal (== $state $goal))
               )
           (if $isGoal
             $plan ; return plan if goal reached
             (let* (
                    ($applicableActions (collapse (match $ruleSpace 
                                                  (: $handle (IMPLICATION_LINK (AND_LINK (($state) $action)) $g))
                                                  $action)))
                    ($untriedActions (filterUntriedRulesList $applicableActions (getTestedActions $state $testedActions) ()))
                    ($newStates (applyActions $untriedActions $state () $ruleSpace))
                    (() (addNewStates $newStates $cost $plan $pq $goal $ruleSpace))
                   )
               ;(addNewStates $newStates $cost $plan $pq $goal $ruleSpace)
               (aStarLoop $pq $goal $testedActions $visited $ruleSpace)
             )
           )
         )
       )
     )
   )
)
;changed 
(= (addNewStates $newStates $currentCost $currentPlan $pq $goal $ruleSpace)
   (if (== $newStates ())
     ()
     (let* (
            (($head $tail) (decons-atom $newStates))
            (($action $state) (decons-atom $head)) ; Changed to expect ($action $state)
            ($newCost (+ $currentCost (distance $state $goal $ruleSpace)))
            ($newPlan (cons-atom $action $currentPlan))
           )
       (superpose (
         (add-atom &testedActions ($state $action))
         (add-atom $pq ($newCost $state $newPlan))
         (addNewStates $tail $currentCost $currentPlan $pq $goal $ruleSpace)
       ))
     )
   )
)

(= (popMin $pq)
   (let* (
          ($minEntry (findMinEntry $pq))
          ($dummy (remove-atom $pq $minEntry)) ; remove minimum entry
         )
         $minEntry
   )
)


(= (findMinEntry $pq)
   (let* (
          ($candidates (match $pq ($cost $state $plan) (if (== $cost (minCost $pq)) ($cost $state $plan) ())))
          (($head $tail) (decons-atom $candidates)) ; Take the first one
         )
        $candidates
   )
)
(= (min $a $b) (if (> $a $b) $b $a))
(= (minCost $pq)
   (let* (
          ($match (collapse (match $pq ($cost $state $plan) $cost)))
         )
      (if (== $match ()) 1000 (min-atom $match))   
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
(= (applyActions $actions $state $acc $ruleSpace)
   (if (== $actions ())
     $acc
     (let* (
            (($head $tail) (decons-atom $actions))
            ($res (match $ruleSpace 
                        (: $handle (IMPLICATION_LINK (AND_LINK ($state_pattern $action)) $g))
                        (if (and (== $state_pattern $state) (== $action $head))
                            (($head $g))
                            ())))
            ($final_res (car-atom $res))
            ($new_acc (if (== $final_res ()) $acc (cons-atom $final_res $acc)))
           )
       (applyActions $tail $state $new_acc $ruleSpace)
     )
   )
)
(= (isMember $item $space)
   (not (== (collapse (match $space ($item $action) true)) ()))
)
(= (listContains $item $list)
   (if (== $list ())
     False
     (let* ((($head $tail) (decons-atom $list)))
       (if (== $item $head)
         True
         (listContains $item $tail)
       )
     )
   )
)
(= (filterUntriedRulesList $actions $tested $acc)
     (if (== $actions ())
       $acc
       (let* ((($head $tail) (decons-atom $actions)))
         (if (listContains $head $tested)
           (filterUntriedRulesList $tail $tested $acc)
           (filterUntriedRulesList $tail $tested (cons-atom $head $acc))
         )
       )
     )
)
;changed
(= (getTestedActions $key $space)
   (collapse (match $space (($key) $action) $action))
)
;each function tests 
;!(assertEqual (union-atom (a b) (c d)) (a b c d)) ; returns [()]
;goal-value, desired-goal-value
;!(add-atom &ruleSpace (Goal init 0.9 0.6))
;!(assertEqual (goal-value (Goal init 0.9 0.6) &ruleSpace) 0.9)
;!(assertEqual (desired-goal-value (Goal init 0.9 0.6) &ruleSpace) 0.6)
;isMember
;!(add-atom &testedActions (state1 action1))
;!(assertEqual (isMember state1 &testedActions) True)
;!(assertEqual (isMember state2 &testedActions) False)
;getTestedActions
;!(add-atom &testedActions (state1 action2))
;!(assertEqual (getTestedActions state1 &testedActions) (action1 action2))
;filterUntriedRulesList
;!(assertEqual (filterUntriedRulesList (action1 action3 action4) (action1 action2) ()) (action4 action3))
;distance
;!(add-atom &ruleSpace (Goal mission_complete 1.0 1.0))
;!(assertEqual (distance (Goal init 0.9 0.6) (Goal mission_complete 1.0 1.0) &ruleSpace) 0.5)
;applyActions
; Define the rule space
;!(add-atom &ruleSpace (: r1 (IMPLICATION_LINK (AND_LINK ((Goal init 0.9 0.6) explore)) (Goal found_target 1.0 1.0))))
;!(add-atom &ruleSpace (: r2 (IMPLICATION_LINK (AND_LINK ((Goal active 0.8 0.5) move)) (Goal reached 0.9 0.7))))
;!(applyActions (explore) (Goal init 0.9 0.6) () &ruleSpace) ; results [((explore (Goal found_target 1.0 1.0)))]
;!(assertEqual 
  (applyActions (explore) (Goal init 0.9 0.6) () &ruleSpace) 
  ((explore (Goal found_target 1.0 1.0))))
;minCost
;!(add-atom &priorityQueue (5 state1 ()))
;!(add-atom &priorityQueue (2 state2 ()))
;!(assertEqual (minCost &priorityQueue) 2)
;findMinEntry
;!(findMinEntry &priorityQueue)
;!(assertEqual (findMinEntry &priorityQueue) (2 state2 ()))
;popMin
;!(assertEqual (popMin &priorityQueue) (2 state2 ()))
;!(assertEqual (get-atoms &priorityQueue) (5 state1 ()))
; test addNewStates with multiple states
!(add-atom &ruleSpace (: r1 (IMPLICATION_LINK (AND_LINK ((Goal init 0.9 0.6) explore)) (Goal found_target 1.0 1.0))))
!(add-atom &ruleSpace (: r2 (IMPLICATION_LINK (AND_LINK ((Goal active 0.8 0.5) move)) (Goal reached 0.9 0.7))))
!(addNewStates 
   ((explore (Goal found_target 1.0 1.0))) 
   0 
   () 
   &pq 
   (Goal found_target 1.0 1.0) 
   &ruleSpace)  ; returns [(), ()]
!(get-atoms &testedActions)  ; returns [(((Goal found_target 1.0 1.0)) explore)]
!(assertEqual 
   (getTestedActions (Goal found_target 1.0 1.0) &testedActions) 
   (explore))
!(getTestedActions (Goal found_target 1.0 1.0) &testedActions)




; Verify &testedActions
;!(assertEqual
;   (match &testedActions ($state $action) ($state $action))
;   ((Goal found_target 1.0 1.0) explore))


;!(addNewStates ((explore (Goal found_target 1.0 1.0))) 1 (move) &priorityQueue (Goal mission_complete 1.0 1.0) &ruleSpace)
;!(addNewStates ((explore (Goal found_target 1.0 1.0)) (move (Goal init 0.9 0.6))) 1 () &priorityQueue (Goal mission_complete 1.0 1.0) &ruleSpace)
;!(assertEqual (getTestedActions (Goal found_target 1.0 1.0) &testedActions) (explore))
;!(assertEqual (getTestedActions (Goal init 0.9 0.6) &testedActions) (move))



 
 



;!(remove-atom &priorityQueue)
;!(get-atoms &priorityQueue)

;!(findMinEntry &priorityQueue)
;!(min-atom (5 2))
;!(get-atoms &priorityQueue)
;!(get-atoms &ruleSpace)
;!(match &ruleSpace (: $handle (IMPLICATION_LINK (AND_LINK ((Goal init 0.9 0.6) explore)) $g)) (explore $g)) ; returns [(explore (Goal found_target 1.0 1.0))]
;!(union-atom ("explore" ("Goal found_target 1.0 1.0")) ()) ;return [("explore" ("Goal found_target 1.0 1.0"))]
;!(applyActions (explore) (Goal init 0.9 0.6) () &ruleSpace)
;!(collapse (explore (Goal found_target 1.0 1.0))) ; returns [((explore (Goal found_target 1.0 1.0)))]

;!(union-atom (a b) (c d)) (a b c d)
;!(assertEqual (union-atom (a b) (c d)) (a b c d))
;!(assertEqual (union-atom () (c d)) (c d))
;!(assertEqual (union-atom (a b) ()) (a b))
;!(assertEqual (union-atom () ()) ())

