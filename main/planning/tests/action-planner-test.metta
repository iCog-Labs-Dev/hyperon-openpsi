!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)

!(import! &self hyperon-openpsi:main:planning:action-planner)
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
!(addRule r5 ((S1 is on)) (Turn off S1) (S1 is off) (TTV 0 (STV 1.0 1.0)))

!(assertEqual (hillClimbingPlanner (S1 is off) (S3 is on) (TestedActions) () &self) ((Turn on S3) (Turn on S2) (Turn on S1)))
