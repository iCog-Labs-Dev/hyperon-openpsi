!(register-module! ../../../../../hyperon-openpsi)
!(register-module! ../../../../utilities-module)

!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v2)
!(import! &self hyperon-openpsi:main:types)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self utilities-module:utils)

!(addGoal (S1 is off) 0.0 () &self)
!(addGoal (S2 is off) 0.0 () &self)
!(addGoal (S3 is off) 0.0 () &self)
!(addGoal (S4 is off) 0.0 () &self)

!(addGoal (S1 is on) 0.5 1 &self)
!(addGoal (S2 is on) 0.75 1 &self)
!(addGoal (S3 is on) 1.0 1.0 &self)
!(addGoal (S4 is on) 0.0 () &self)

;First test case
                ;Test Description:
;Imagine a system where a device (e.g., a machine or a light)
;requires three switches — S1, S2, and S3—to be turned on in a specific order due to dependencies.
;The final goal is to have S3 on, which activates the device. However:
; - S1 must be turned on first (no prior dependency).
; - S2 can only be turned on if S1 is already on.
; - S3 can only be turned on if S2 is already on.

!(addRule r1 ((S1 is off)) (Turn on S1) (S1 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r2 ((S1 is on)) (Turn on S2) (S2 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r3 ((S2 is on)) (Turn on S3) (S3 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r3' ((S3 is off)) (Turn on S3) (S3 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r4 ((S3 is on)) (Turn on S4) (S4 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r4' ((S4 is off)) (Turn on S4) (S4 is on) (TTV 0 (STV 1.0 1.0)))
;!(addRule r5 ((S1 is on)) (Turn off S1) (S1 is off) (TTV 0 (STV 1.0 1.0)))

!(assertEqual (hillClimbingPlanner (S1 is off) (S3 is on) (TestedActions) () &self) ((Turn on S3) (Turn on S2) (Turn on S1)))


;Second Test Case
;                   Test Description:
; The scenario is  a robot soccer game  where the players try to kick the ball to the goal and score.  
; requires players to kick the ball  — P1, P2, P3 and P4 
; The final goal is to score a goal, and get a point. However:
; - P1 can have the ball by giving to it.
; - P2 can have the ball  if P1 is kicked to it or by giving to it.
; - P3 can only have the ball if P2  kick it to P3.
; - P4 can have the ball if P3 is kicked to it or by giving to it.
; - Goal is scored only if P4 kicked the ball to the Goal 
!(addGoal (P1 doesn't have the ball) 0.0 () &self)
!(addGoal (P2 doesn't have the ball) 0.0 () &self)
!(addGoal (P3 doesn't have the ball) 0.0 () &self)
!(addGoal (P4 doesn't have the ball) 0.0 () &self)

!(addGoal (P1 has the ball) 0.1 1.0 &self)
!(addGoal (P2 has the ball) 0.4 1.0 &self)
!(addGoal (P3 has the ball) 0.7 1.0 &self)
!(addGoal (P4 has the ball) 0.8 1.0 &self)
!(addGoal (Goal Scored) 1.0 1.0 &self)


!(addRule rr1' ((P1 doesn't have the ball)) (Give ball to P1) (P1 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule rr1 ((P1 has the ball)) (P1 Kick to P2) (P2 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule rr2' ((P2 doesn't have the ball)) (Give ball to P2) (P2 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule rr2 ((P2 has the ball)) (P2 Kick to P3) (P3 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule rr3 ((P3 has the ball)) (P3 Kick to P4) (P4 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule rr4' ((P4 doesn't have the ball)) (Give ball to P4) (P4 has the ball) (TTV 0 (STV 1.0 1.0)))
!(addRule rr4 ((P4 has the ball)) (P4 Kick to Goal) (Goal Scored) (TTV 0 (STV 1.0 1.0)))


 !(assertEqual (hillClimbingPlanner (P1 has the ball) (P3 has the ball) (TestedActions) () &self) ((P2 Kick to P3) (P1 Kick to P2)))
 !(assertEqual (hillClimbingPlanner (P1 has the ball) (Goal Scored) (TestedActions) () &self) ((P4 Kick to Goal) (P3 Kick to P4) (P2 Kick to P3) (P1 Kick to P2)) )
 !(assertEqual (hillClimbingPlanner (P2 has the ball) (Goal Scored) (TestedActions) () &self) ((P4 Kick to Goal) (P3 Kick to P4) (P2 Kick to P3)))
 !(assertEqual (hillClimbingPlanner (P2 has the ball) (P4 has the ball) (TestedActions) () &self) ((P3 Kick to P4) (P2 Kick to P3)))
 !(assertEqual (hillClimbingPlanner (P1 doesn't have the ball) (Goal Scored) (TestedActions) () &self) ((P4 Kick to Goal) (P3 Kick to P4) (P2 Kick to P3) (P1 Kick to P2) (Give ball to P1)))
 !(assertEqual (hillClimbingPlanner (P2 doesn't have the ball) (Goal Scored) (TestedActions) () &self) ((P4 Kick to Goal) (P3 Kick to P4) (P2 Kick to P3) (Give ball to P2)))
 !(assertEqual (hillClimbingPlanner (P3 doesn't have the ball) (Goal Scored) (TestedActions) () &self) ()) ; no actions taken since there is no rule to apply
 !(assertEqual (hillClimbingPlanner (P4 doesn't have the ball) (Goal Scored) (TestedActions) () &self) ((P4 Kick to Goal) (Give ball to P4)))
 !(assertEqual (hillClimbingPlanner (P4 has the ball) (P1 has the ball) (TestedActions) () &self) ()) ; no rules to go backward 
