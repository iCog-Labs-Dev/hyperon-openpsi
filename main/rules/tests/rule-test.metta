!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)

!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self hyperon-openpsi:main:types)
!(import! &self utilities-module:utils)

!(bind! &r (new-space)) 

!(assertEqual (addAndLink &r (a b) c) (AND_LINK ((a b) c)))

; add the same AND_LINK the second time, it should not be added again. It should 
; return the Already existing AND_LINK.
!(assertEqual (addAndLink &r (a b) c) (AND_LINK ((a b) c)))

;if rule is added with the addRule function then the &psiRules index knows 
;about it


!(addRule  &r x (x1 x2) y z (TTV 1 (STV 1.0 1.0)))
!(assertEqual (getContext  &r x) (x1 x2))
!(assertEqual (getAction  &r x) y)
!(assertEqual (getGoal  &r x) z)
!(assertEqual (getTV x &r) (TTV 1 (STV 1.0 1.0)))
!(assertEqual (getImplication x &r) (IMPLICATION (AND_LINK ((x1 x2) y)) z))

!(addRule  &r w (x3 x2) y z (TTV 1 (STV 1.0 1.0)))
; ;if rule is not added with the addRule function then the &psiRules index does not know
; about it
; but we can get context, action and goal of the rule

!(add-atom &r (: rule1 (IMPLICATION_LINK 
                            (AND_LINK ((c1 c2) action))
                            goal )))
!(assertEqual (getContext &r rule1) (c1 c2))
!(assertEqual (getGoal &r rule1) goal)
!(assertEqual (getAction &r rule1) action)
!(assertEqual (getImplication rule1 &r) (IMPLICATION (AND_LINK ((c1 c2) action)) goal))


!(assertEqual (existsIn &psiRules rule1) False)

!(assertEqual (existsIn &psiRules x) True)

!(assertEqual (addGoal reduceHunger 1 0 &self) reduceHunger)
!(assertEqual (addGoal reduceHunger 1 1 &self)  (Goal With Id reduceHunger Already Exists))
!(assertEqual (addGoal reduceHunger 10 1 &self) (Invalid goal/dgv Value))
!(assertEqual (addGoal reduceHunger 1 10 &self) (Invalid goal/dgv Value))
!(assertEqual (addGoal run 1 () &self) run)


!(assertEqual (relatedGoals &r y) (z))

;Category tests
!(assertEqual (addCategory testI) testI)

!(assertEqual (addToCategory x testII) x)
!(assertEqual (addToCategory x testII )(addToCategory: Rule x Already Exists in testII))

!(assertEqual (len (getCategories)) 2)
!(assertEqual (contextStv ((STV 0.5 0.4) (STV 0.6 0.8))) (STV 0.315 0.4))
!(assertEqual (contextStv ((STV 1 1) (STV 1 1))) (STV 1.0 1.0))
!(assertEqual (contextStv ((STV 0 0) (STV 0 0))) (STV 0 0))

;urge Tests 

!(addGoal (pinged) 0.75 1.0 &self)
!(assertEqual (goal-value  (pinged) &self) 0.75)
!(assertEqual (urge-value  (pinged) &self) 0.25)

!(increase-urge (pinged) 0.15 &self)
!(assertEqual (urge-value  (pinged) &self) 0.4)
!(increase-urge (pinged) 0.3 &self)
!(assertEqual (urge-value  (pinged) &self) 0.7)

!(decrease-urge (pinged) 0.45 &self)
!(assertEqual (urge-value  (pinged) &self) 0.25)

