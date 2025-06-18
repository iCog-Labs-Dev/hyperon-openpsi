!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)

!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self hyperon-openpsi:main:types)
!(import! &self utilities-module:utils)

!(bind! &space (new-space)) 

!(assertEqual (addAndLink &space (a b) c) (AND_LINK ((a b) c)))

; add the same AND_LINK the second time, it should not be added again. It should 
; return the Already existing AND_LINK.
!(assertEqual (addAndLink &space (a b) c) (AND_LINK ((a b) c)))

;if rule is added with the addRule function then the &psiRules index knows 
;about it


!(addRule  &space x (x1 x2) y z (TTV 1 (STV 1.0 1.0)))
!(assertEqual (getContext  &space x) (x1 x2))
!(assertEqual (getAction  &space x) y)
!(assertEqual (getGoal  &space x) z)
!(assertEqual (getTV x &space) (TTV 1 (STV 1.0 1.0)))
!(assertEqual (getImplication &space x) (IMPLICATION_LINK (AND_LINK ((x1 x2) y)) z))

!(addRule  &space w (x3 x2) y z (TTV 1 (STV 1.0 1.0)))
; ;if rule is not added with the addRule function then the &psiRules index does not know
; about it
; but we can get context, action and goal of the rule

!(add-atom &space (: rule1 (IMPLICATION_LINK 
                            (AND_LINK ((c1 c2) action))
                            goal )))
!(assertEqual (getContext &space rule1) (c1 c2))
!(assertEqual (getGoal &space rule1) goal)
!(assertEqual (getAction &space rule1) action)
!(assertEqual (getImplication &space rule1) (IMPLICATION_LINK (AND_LINK ((c1 c2) action)) goal))


!(assertEqual (existsIn &space rule1) True)
!(assertEqual (existsIn &space x) True) 
!(assertEqual (existsIn &space y) False) ;; y named data are not stored

        ;; If we want to check exists atom from psiRule atomespace should bind in this file,
        ;;  before execute here like !(bind! psiRules (new-space)) then...
; !(assertEqual (existsIn &psiRules rule1) False)  ;;nothing stored still
; !(assertEqual (existsIn &psiRules x) False)      ;;nothing stored still
; !(assertEqual (existsIn &psiRules y) False)      ;;nothing stored still

!(assertEqual (addGoal reduceHunger 1 0 &self) reduceHunger)
!(assertEqual (addGoal reduceHunger 1 1 &self)  (Goal With Id reduceHunger Already Exists))
!(assertEqual (addGoal reduceHunger 10 1 &self) (Invalid goal/dgv Value))
!(assertEqual (addGoal reduceHunger 1 10 &self) (Invalid goal/dgv Value))
!(assertEqual (addGoal run 1 () &self) run)

!(assertEqual (relatedGoals &space y) (z))

;Category tests
!(assertEqual (addCategory testI) testI)

!(assertEqual (addToCategory x testII) x)
!(assertEqual (addToCategory x testII )(addToCategory: Rule x Already Exists in testII))

!(assertEqual (len (getCategories)) 2)
!(assertEqual (contextStv ((STV 0.5 0.4) (STV 0.6 0.8))) (STV 0.315 0.4))
!(assertEqual (contextStv ((STV 1 1) (STV 1 1))) (STV 1.0 1.0))
!(assertEqual (contextStv ((STV 0 0) (STV 0 0))) (STV 0 0))

