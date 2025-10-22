(= (populateRuleSpace $self $ruleSpace)
    (add-reduct $ruleSpace 
                (match $self 
                      ((: $ruleId ((TTV $ts $stv) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $val)
                      ((: $ruleId ((TTV $ts $stv) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $val)
                    )
    )
)

(= (addDemandGoalRels $self $space)
   (add-reduct $space
    (match $self (: $demand (Goal $goal_name $gv $dgv)) (: $demand (Goal $goal_name $gv $dgv)))
    )
)

(= (populateDemandSpace $demandspace) 
   (add-reduct $demandspace 
    (superpose 
      (
        (demand affiliation 0.5) 
        (demand energy 0.9) 
        (demand competence 0.9)
        (demand certainty 0.1)
        (demand integrity 1.0)
        )
      )
    )
)

(= (fetchModulatorsFromDb)
    (collapse (match &self (modulators $modulators) $modulators))
)

(= (fetchDemandsFromDb)
    (collapse (match &self (demands $demands) $demands))
)
