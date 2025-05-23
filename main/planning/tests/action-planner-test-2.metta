!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)

!(import! &self hyperon-openpsi:main:planning:action-planner)
!(import! &self hyperon-openpsi:main:types)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self utilities-module:utils)

!(addGoal (P1 doesn't have the ball) 0.0 () &self)
!(addGoal (P2 doesn't have the ball) 0.0 () &self)
!(addGoal (P3 doesn't have the ball) 0.0 () &self)
!(addGoal (P4 doesn't have the ball) 0.0 () &self)

!(addGoal (P1 has the ball) 0.1 1.0 &self)
!(addGoal (P2 has the ball) 0.4 1.0 &self)
!(addGoal (P3 has the ball) 0.7 1.0 &self)
!(addGoal (P4 has the ball) 0.8 1.0 &self)
!(addGoal (Goal Scored) 1.0 1.0 &self)

;                   Test Description:
; The scenario is  a robot soccer game  where the players try to kick the ball to the goal and score.  
; requires players to kick the ball  — P1, P2, P3 and P4 
; The final goal is to score a goal, and get a point. However:
; - P1 can have the ball by giving to it.
; - P2 can have the ball  if P1 is kicked to it or by giving to it.
; - P3 can only have the ball if P2  kick it to P3.
; - P4 can have the ball if P3 is kicked to it or by giving to it.
; - Goal is scored only if P4 kicked the ball to the Goal 

!(addRule r1' ((P1 doesn't have the ball)) (Give ball to P1) (P1 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule r1 ((P1 has the ball)) (P1 Kick to P2) (P2 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule r2' ((P2 doesn't have the ball)) (Give ball to P2) (P2 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule r2 ((P2 has the ball)) (P2 Kick to P3) (P3 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule r3 ((P3 has the ball)) (P3 Kick to P4) (P4 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule r4' ((P4 doesn't have the ball)) (Give ball to P4) (P4 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule r4 ((P4 has the ball)) (P4 Kick to Goal) (Goal Scored) (TTV 0 (STV 1.0 1.0)))


; !(assertEqual (hillClimbingPlanner (P1 has the ball) (P3 has the ball) (TestedActions) () &self) ((P2 Kick to P3) (P1 Kick to P2)))
; !(assertEqual (hillClimbingPlanner (P1 has the ball) (Goal Scored) (TestedActions) () &self) ((P4 Kick to Goal) (P3 Kick to P4) (P2 Kick to P3) (P1 Kick to P2)) )
; !(assertEqual (hillClimbingPlanner (P2 has the ball) (Goal Scored) (TestedActions) () &self) ((P4 Kick to Goal) (P3 Kick to P4) (P2 Kick to P3)))
; !(assertEqual (hillClimbingPlanner (P2 has the ball) (P4 has the ball) (TestedActions) () &self) ((P3 Kick to P4) (P2 Kick to P3)))
; !(assertEqual (hillClimbingPlanner (P1 doesn't have the ball) (Goal Scored) (TestedActions) () &self) ((P4 Kick to Goal) (P3 Kick to P4) (P2 Kick to P3) (P1 Kick to P2) (Give ball to P1)))
; !(assertEqual (hillClimbingPlanner (P2 doesn't have the ball) (Goal Scored) (TestedActions) () &self) ((P4 Kick to Goal) (P3 Kick to P4) (P2 Kick to P3) (Give ball to P2)))
; !(assertEqual (hillClimbingPlanner (P3 doesn't have the ball) (Goal Scored) (TestedActions) () &self) ()) ; no actions taken since there is no rule to apply
; !(assertEqual (hillClimbingPlanner (P4 doesn't have the ball) (Goal Scored) (TestedActions) () &self) ((P4 Kick to Goal) (Give ball to P4)))
; !(assertEqual (hillClimbingPlanner (P4 has the ball) (P1 has the ball) (TestedActions) () &self) ()) ; no rules to go backward 


