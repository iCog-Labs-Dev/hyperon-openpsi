

(= (ruleComparator $rule $ruleList)
    (if (== $ruleList ())
        False

        (let* (
            (($head $tail) (decons-atom $ruleList))
            (((: $handle $rule') $weight) $head)
             
            
        )
            (if (== $rule $rule')
                True
                (ruleComparator $rule $tail)
            )
        )
    )
)


(= (checkRuleFromSpace $rule $ruleSpace)
    (let $rules (collapse (get-atoms $ruleSpace))
        (ruleComparator $rule $rules)
    )
)


(= (comparatorFn $rule $ruleList)
    (if (== $ruleList ())
        False

        (let* (
            (($head $tail) (decons-atom $ruleList))
        )
            (if (== $rule $rule')
                True
                (ruleComparator $rule $tail)
            )
        )
    )
)
