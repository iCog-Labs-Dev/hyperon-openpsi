!(register-module! ../../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v3)

!(bind! &ruleSpace (new-space)) 
!(add-atom &ruleSpace (: r1 (IMPLICATION_LINK (AND_LINK (Goal init 0.9 0.6) explore) (Goal found_target 1.0 1.0))))
!(add-atom &ruleSpace (: r2 (IMPLICATION_LINK (AND_LINK (Goal active 0.8 0.5) move) (Goal reached 0.9 0.7))))
;!(bind! &testedActions (new-space))
; test cases


;addNewStates
!(addNewStates 
   ((explore (Goal found_target 1.0 1.0))) 
   0 
   () 
   &pq 
   (Goal found_target 1.0 1.0) 
   &ruleSpace)  ; returns [(), ()]
;!(get-atoms &testedActions)  ; returns [(((Goal found_target 1.0 1.0)) explore)]
!(assertEqual 
   (getTestedActions (Goal found_target 1.0 1.0) &testedActions) 
   (explore))
;!(getTestedActions (Goal found_target 1.0 1.0) &testedActions) ; returns [(explore)]


;findMinEntry
!(add-atom &priorityQueue (5 (Goal init 0.9 0.6) ())) 
!(add-atom &priorityQueue (2 (Goal found_target 1.0 1.0) (explore))) 
!(add-atom &priorityQueue (10 (Goal active 0.8 0.5) (move)))
!(assertEqual (findMinEntry &priorityQueue) (2 (Goal found_target 1.0 1.0) (explore)))


;popMin
!(assertEqual (popMin &priorityQueue) (2 (Goal found_target 1.0 1.0) (explore)))
;!(get-atoms &priorityQueue); returns [(5 (Goal init 0.9 0.6) ()), (10 (Goal active 0.8 0.5) (move))]
!(assertEqual (findMinEntry &priorityQueue) (5 (Goal init 0.9 0.6) ()))


;applyActions
;!(applyActions (explore) (Goal init 0.9 0.6) () &ruleSpace) ; results [((explore (Goal found_target 1.0 1.0)))]
!(assertEqual 
  (applyActions (explore) (Goal init 0.9 0.6) () &ruleSpace) 
  ((explore (Goal found_target 1.0 1.0))))


;filterUntriedRulesList
!(add-atom &testedActions ((Goal init 0.9 0.6) move))
!(assertEqual (filterUntriedRulesList ((explore) (move)) () ()) ((move) (explore)))
!(assertEqual (filterUntriedRulesList ((explore) (move)) ((move)) ()) ((explore))) 


;isMember
!(assertEqual (isMember (Goal active 0.8 0.5) &testedActions) False)
!(assertEqual (isMember (Goal init 0.9 0.6) &testedActions) True)


;goal-value
!(add-atom &ruleSpace (: r3 (IMPLICATION_LINK (AND_LINK (Goal init 0.9 0.6) search) (Goal intermediate 0.95 0.65))))
!(assertEqual (goal-value (Goal init 0.9 0.6) &ruleSpace) 0.9)
!(assertEqual (desired-goal-value (Goal init 0.9 0.6) &ruleSpace) 0.6)


;distance
!(assertEqual (distance (Goal init 0.9 0.6) (Goal found_target 1.0 1.0) &ruleSpace) 0.5)
!(assertEqual (distance (Goal init 0.9 0.6) (Goal unknown 0.0 0.0) &ruleSpace) -1.5)

;aStarPlanner
!(aStarPlanner (Goal init 0.9 0.6) (Goal found_target 1.0 1.0) &testedActions &ruleSpace)







;!(aStarPlanner (Goal init 0.9 0.6) (Goal found_target 1.0 1.0) &testedActions &ruleSpace)



;!(assertEqual (aStarPlanner (Goal init 0.9 0.6) (Goal found_target 1.0 1.0) &testedActions &ruleSpace) (explore))
;!(get-atoms &ruleSpace)

;!(assertEqual (aStarPlanner (Goal active 0.8 0.5) (Goal reached 0.9 0.7) &testedActions &ruleSpace) (move))
;!(assertEqual (aStarPlanner (Goal init 0.9 0.6) (Goal reached 0.9 0.7) &testedActions &ruleSpace) ())
;!(assertEqual (aStarPlanner (Goal found_target 1.0 1.0) (Goal found_target 1.0 1.0) &testedActions &ruleSpace) ())



;!(add-atom &ruleSpace (Goal mission_complete 1.0 1.0))
(distance (Goal init 0.9 0.6) (Goal mission_complete 1.0 1.0) &ruleSpace) 0.5