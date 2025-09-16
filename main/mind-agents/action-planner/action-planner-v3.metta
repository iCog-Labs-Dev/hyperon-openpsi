!(bind! np (py-atom numpy))
!(bind! &testedActions (new-space))
!(bind! &priorityQueue (new-space)) ; Space for priority queue


(= (TestedActions) &testedActions)
;Initializes a priority queue with the initial state, a cost of 0, and an empty plan.
;Uses a visited space to track explored states and avoid cycles.
;In dijkstraLoop, it pops the state with the lowest cost from the priority queue.
;If the popped state is the goal, it returns the associated plan.
;If the state is unvisited, it:Marks the state as visited and tested.
;Retrieves applicable actions, filters out tested ones, and applies them to generate new states.
;For each new state, calculates a new cost (current cost + heuristic distance to goal) and adds it to the priority queue with the updated plan.
;Continues until the goal is found or the priority queue is empty (no path exists).


Distance Function: Uses the same heuristic distance function as the hill-climbing planner for edge costs.
(= (dijkstraPlanner $initialState $goal $testedActions $ruleSpace)
   (let* (
          ($pq &priorityQueue) ; Priority queue to store (cost, state, plan) tuples
          ($visited (new-space)) ; Space to track visited states
          (() (add-atom $pq (0 $initialState ()))) ; Initialize with (cost=0, initialState, empty plan)
         )
     (dijkstraLoop $pq $goal $testedActions $visited $ruleSpace)
   )
)

(= (dijkstraLoop $pq $goal $testedActions $visited $ruleSpace)
   (if (== (size $pq) 0) ; If priority queue is empty, no path found
     ()
     (let* (
            (($cost $state $plan) (popMin $pq)) ; Get state with minimum cost
            ($isVisited (isMember $state $visited))
           )
       (if $isVisited
         (dijkstraLoop $pq $goal $testedActions $visited $ruleSpace) ; Skip visited state
         (let* (
                (() (add-atom $visited $state)) ; Mark state as visited
                (() (add-atom $testedActions $state)) ; Mark state as tested
                ($isGoal (== $state $goal))
               )
           (if $isGoal
             $plan ; Return plan if goal reached
             (let* (
                    ($applicableActions (collapse (match $ruleSpace 
                                                  (: $handle (IMPLICATION_LINK (AND_LINK (($state) $action)) $g))
                                                  $action)))
                    ($untriedActions (filterUntriedRules $applicableActions (getTestedActions $state $testedActions) ()))
                    ($newStates (applyActions $untriedActions $state () $ruleSpace))
                   )
               (addNewStates $newStates $cost $state $plan $pq $goal $ruleSpace)
               (dijkstraLoop $pq $goal $testedActions $visited $ruleSpace)
             )
           )
         )
       )
     )
   )
)

(= (addNewStates $newStates $currentCost $currentState $currentPlan $pq $goal $ruleSpace)
   (if (== $newStates ())
     ()
     (let* (
            (($action $state) $tail) (decons-atom $newStates))
            ($newCost (+ $currentCost (distance $state $goal $ruleSpace))) ; Use distance as edge cost
            ($newPlan (cons-atom $action $currentPlan))
           )
       (add-atom $pq ($newCost $state $newPlan))
       (addNewStates $tail $currentCost $currentState $currentPlan $pq $goal $ruleSpace)
     )
   )

(= (popMin $pq)
   (let* (
          ($minEntry (findMinEntry $pq))
          (() (remove-atom $pq $minEntry)) ; Remove minimum entry
         )
     $minEntry
   )
)

(= (findMinEntry $pq)
   (collapse (match $pq ($cost $state $plan) (if (== $cost (minCost $pq)) ($cost $state $plan))))
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

(= (applyActions $actions $goal $acc $ruleSpace)
   (if (== $actions ())
     $acc
     (let* (
            (($head $tail) (decons-atom $actions))
            ($res (collapse (match $ruleSpace (: $handle (IMPLICATION_LINK (AND_LINK (($goal) $head)) $g)) ($head $g))))
            ($rest (applyActions $tail $goal (concatTuple $res $acc) $ruleSpace))
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
   (not (== (collapse (match $space ($item $any) $item)) ()))
)
;tests

(= (pq) ((2 A plan1) (5 B plan2) (1 C plan3)))
!(pq)
;!(popMin pq)
!(add-atom &priorityQueue (2 A plan1))
!(add-atom &priorityQueue (5 B plan2))
!(add-atom &priorityQueue (1 C plan3))

!(popMin &priorityQueue)