(= (ruleComparator $rule $ruleList)
    (if (== $ruleList ())
        False
        (let* (
            (($head $tail) (decons-atom $ruleList))
        )
            (if (== $rule $head)
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

