!(bind! np (py-atom numpy))
!(bind! &testedActions (new-space))
!(bind! &priorityQueue (new-space)) 


;get the goal value and desired goal value
;get the goal value and desired goal value
(= (goal-value (Goal $goal $value $dgv) $ruleSpace)
    $value
)
(= (desired-goal-value (Goal $goal $value $dgv) $ruleSpace)
    $dgv
)
(= (distance $current $goal $ruleSpace)
   (let* (
          ($x (- (goal-value $goal $ruleSpace) (goal-value $current $ruleSpace)))
          ($y (- (desired-goal-value $goal $ruleSpace) (desired-goal-value $current $ruleSpace)))
         )
     (+ $x $y)
   )
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
                ($dummyy (add-atom $visited $state)) ; mark state as visited
                ($isGoal (== $state $goal))
               ) 
           (if $isGoal
             $plan ; return plan if goal reached
             (let* (
                    ($applicableActions (collapse (match $ruleSpace (: $handle (IMPLICATION_LINK (AND_LINK $state $action) $g)) $action)))
                    ($untriedActions (filterUntriedRulesList $applicableActions (getTestedActions $state $testedActions) ()))
                    ($newStates (applyActions $untriedActions $state () $ruleSpace))
                    ($holder (addNewStates $newStates $cost $plan $pq $goal $ruleSpace))
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
(= (addNewStates $newStates $currentCost $currentPlan $pq $goal $ruleSpace)
   (if (== $newStates ())
     ()
     (let* (
            (($head $tail) (decons-atom $newStates))
            (($action $state) (decons-atom $head)) ; Changed to expect ($action $state)
            ($newCost (+ $currentCost (distance (car-atom $state) $goal $ruleSpace)))
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
(= (applyActions $actions $state $acc $ruleSpace)
   (if (== $actions ())
     $acc
     (let* (
            (($head $tail) (decons-atom $actions))
            ($res (match $ruleSpace 
                        (: $handle (IMPLICATION_LINK (AND_LINK $state_pattern $action) $g))
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
(= (getTestedActions $key $space)
   (collapse (match $space (($key) $action) $action))
)
