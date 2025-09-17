!(bind! np (py-atom numpy))
!(bind! &testedActions (new-space))
!(bind! &priorityQueue (new-space)) 


(= (append $l1 $l2)
   (if (== $l1 ())
       $l2
       (let (($head $tail) (decons-atom $l1))
            (cons-atom $head (append $tail $l2)))))
;to ensure the system doesn’t fail if the rule space lacks specific Goal
(= (goal-value $state $ruleSpace) 0) 
(= (desired-goal-value $state $ruleSpace) 0) 

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
   (if (== (size-atom $pq) 0) ; if priority queue is empty, no path found
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
                    ($untriedActions (filterUntriedRules $applicableActions (getTestedActions $state $testedActions) ()))
                    ($newStates (applyActions $untriedActions $state () $ruleSpace))
                   )
               (addNewStates $newStates $cost $plan $pq $goal $ruleSpace)
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
            (($action $state) $tail) (decons-atom $newStates))
            ($newCost (+ $currentCost (distance $state $goal $ruleSpace))) ; use distance as edge cost
            ($newPlan (cons-atom $action $currentPlan))
           )
       (add-atom &testedActions ($state $action))  
       (add-atom $pq ($newCost $state $newPlan))
       (addNewStates $tail $currentCost $currentPlan $pq $goal $ruleSpace)
     )
   )

(= (popMin $pq)
   (let* (
          ($minEntry (findMinEntry $pq))
          (() (remove-atom $pq $minEntry)) ; remove minimum entry
         )
     $minEntry
   )
)

(= (findMinEntry $pq)
   (let* (
          ($candidates (collapse (match $pq ($cost $state $plan) (if (== $cost (minCost $pq)) ($cost $state $plan) ()))))
          (($head $tail) (decons-atom $candidates)) ; Take the first one
         )
     $head
   )
)

(= (minCost $pq)
   (let ($costs (collapse (match $pq ($cost $state $plan) $cost)))
     (if (== $costs ()) 1000 (fold-atom min $costs 1000))
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
            ($res (collapse (match $ruleSpace (: $handle (IMPLICATION_LINK (AND_LINK (($state) $head)) $g)) ($head $g))))
            ($rest (applyActions $tail $state (append $res $acc) $ruleSpace)) ; Use append
           )
       (if (== $res ()) ; Fixed to check $res, not $head; skip if empty
         (applyActions $tail $state $acc $ruleSpace)
         $rest
       )
     )
   )
)

(= (filterUntriedRules $actions $tested $acc)
   (if (== $actions ())
     $acc
     (let (($head $tail) (decons-atom $actions))
       (if (isMember $head $tested)
         (filterUntriedRules $tail $tested $acc)
         (filterUntriedRules $tail $tested (cons-atom $head $acc))
       )
     )
   )
)

(= (getTestedActions $key $space)
   (collapse (match $space ($key $action) $action))
)

(= (isMember $item $space)
   (not (== (collapse (match $space $item true)) ()))
)