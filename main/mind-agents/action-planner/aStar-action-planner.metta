!(bind! np (py-atom numpy))
!(bind! &testedActions (new-space))
!(bind! &priorityQueue (new-space))


;get the goal value and desired goal value

(= (goal-value (Goal $goal $value $dgv) $ruleSpace)
    $value
)
(= (desired-goal-value (Goal $goal $value $dgv) $ruleSpace)
    $dgv
)
;computes heuristic distance
(= (distance $current $goal $ruleSpace)
   (let* (
          ($x (- (goal-value $goal $ruleSpace) (goal-value $current $ruleSpace)))
          ($y (- (desired-goal-value $goal $ruleSpace) (desired-goal-value $current $ruleSpace)))
         )
     (abs-math (+ $x $y)) ; to make it heuristic
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
          ($visited (new-space))  
          (() (add-atom &priorityQueue (0.0 $initialState ()))) ; Initialize with (cost=0.0, initialState, empty plan)
         )
      (aStarLoop &priorityQueue $goal $testedActions $visited $ruleSpace)
   )
)
;recursive A* loop: Pops min-cost state; skips if visited; expands untried actions if not goal
(= (aStarLoop $pq $goal $testedActions $visited $ruleSpace)
   (if (== (collapse (get-atoms $pq)) ())
       ()
       (let* (
         (($cost $state $plan) (popMin $pq))
         ($isVisted (isMember $state $visited))
         )
       (if $isVisted
         (aStarLoop $pq $goal $testedActions $visited $ruleSpace)
         (let* (
            (() (add-atom $visited $state))
            ($isGoal (== $state $goal))
            )
            (if $isGoal
               $plan
               (let* (
                  ($applicableActions (collapse (match $ruleSpace (: $handle (IMPLICATION_LINK (AND_LINK $_ $action) $g)) $action)))
                  ($untriedActions (filterUntriedRulesList $applicableActions (getTestedActions $state $testedActions) ()))
                  ($newState (applyActions $untriedActions $state () $ruleSpace))
                  (() (addNewStates $newState $cost $plan $pq $goal $ruleSpace))
                  )
                  (aStarLoop $pq $goal $testedActions $visited $ruleSpace)
                )
            )
             
         ) 
       )
       
       ) 
       
   ) 
      
)
;recursively adds new states to pq, computes new cost and plan , records tested actions 
(= (addNewStates $newStates $currentCost $currentPlan $pq $goal $ruleSpace)
   (if (== $newStates ())
     ()
     (let* (
            (($head $tail) (decons-atom $newStates)) ; returns [((explore (Goal found_target 1.0 1.0)) ())]
            (($action $state) (decons-atom $head)) ; Changed to expect ($action $state) returns (explore ((Goal found_target 1.0 1.0)))
            ($newCost (+ $currentCost (distance (car-atom $state) $goal $ruleSpace))) ;returns [0.0]
            ($newPlan (cons-atom $action $currentPlan)) ; returns [(explore)]
            (() (add-atom &testedActions ($state $action)))
            (() (add-atom $pq ($newCost (car-atom $state) $newPlan)))
           )  
        (addNewStates $tail $currentCost $currentPlan $pq $goal $ruleSpace)   
 
     )
   )

)
;pops and returns min-cost entry from pq 
(= (popMin $pq)
   (let* (
          ($minEntry (findMinEntry $pq))
          (() (remove-atom $pq $minEntry)) ; remove minimum entry
         )
         $minEntry
   )
)
;find min-cost candidates
(= (findMinEntry $pq)
   (let* (
          ($candidates (match $pq ($cost $state $plan) (if (== $cost (minCost $pq)) ($cost $state $plan) ())))
          (($head $tail) (decons-atom $candidates)) ; Take the first one
         )
        $candidates
   )
)
(= (min $a $b) (if (> $a $b) $b $a))
;computes minimum cost in pq
(= (minCost $pq)
   (let* (
          ($match (collapse (match $pq ($cost $state $plan) $cost)))
         )
      (if (== $match ()) 1000 (min-atom $match))   
   )
)
;applies actions to state, and returns list of (action new-state) pairs
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
;check if item exists in space
(= (isMember $item $space)
   (not (== (collapse (match $space ($item $action) true)) ()))
)
;recursive check if item is in list 
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
;filters actions to exclude tesed ones 
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
; retrives tested actions for a specific state key 
(= (getTestedActions $key $space)
   (collapse (match $space (($key) $action) $action))
)
