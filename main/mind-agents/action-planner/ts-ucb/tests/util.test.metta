!(register-module! ../../../../../../hyperon-openpsi)
;!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:util)
;!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:math)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:ts-ucb:util)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:ts-ucb:math)

;; Unit tests for utility functions
!(assertEqual (confidenceToCount 0.5) 800.0)
!(assertEqual (countToConfindence 800.0) 0.5)

!(assertEqual (stvToBeta (0.25 0.5)) (200.0 600.0))
!(assertEqual (betaToSTV (200.0 600.0)) (0.25 0.501))


;create a test space
!(bind! &test_space (new-space))

;add 3 simple rules with known STVs
!(add-atom &test_space (: Rule 10 (TTV 0) (STV 0.9 0.8) (Complexity 1) (Context ()) (Action TEST1) (Goal TEST)))
!(add-atom &test_space (: Rule 20 (TTV 0) (STV 0.6 0.7) (Complexity 1) (Context ()) (Action TEST2) (Goal TEST)))
!(add-atom &test_space (: Rule 30 (TTV 0) (STV 0.2 0.9) (Complexity 1) (Context ()) (Action TEST3) (Goal TEST)))

; define ruleIds 
!(bind! &test_ruleIds (10 20 30))

;!(get-atoms &test_space) 
;!(get-atoms &test_space) ; returns [(: Rule 10 (TTV 0) (STV 0.9 0.8) (Complexity 1) (Context ()) (Action TEST1) (Goal TEST)), (: Rule 20 (TTV 0) (STV 0.6 0.7) (Complexity 1) (Context ()) (Action TEST2) (Goal TEST)), (: Rule 30 (TTV 0) (STV 0.2 0.9) (Complexity 1) (Context ()) (Action TEST3) (Goal TEST))]
!(get_alphas_betas &test_ruleIds &test_space) ; [(10 2880.0 320.0), (20 1120.0 747.0), (30 1440.0 5760.0)]
  
