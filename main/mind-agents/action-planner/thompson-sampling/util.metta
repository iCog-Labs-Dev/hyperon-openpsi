;; Utility functions for Thompson Sampling based action planner

;; Convert confidence to count
(: confidence-to-count (-> Number Number))
(= (confidence-to-count $confidence) (
    / (* $confidence 800) (- 1 $confidence)
))

;; Convert count to confidence
(: count-to-confidence (-> Number Number))
(= (count-to-confidence $count) (
    / $count (+ 800 $count)
))

;; Convert strength and confidence to alpha and beta parameters of Beta distribution
(: stv-to-beta (-> (Number Number) (Number Number)))
(= (stv-to-beta ($strength $confidence)) (
    let* (
        ($count (confidence-to-count $confidence))
        ($alpha (* $strength $count))
        ($beta (- $count $alpha))
    ) ($alpha $beta)
))

;; Convert alpha and beta parameters of Beta distribution to strength and confidence
(: beta-to-stv (-> (Number Number) (Number Number)))
(= (beta-to-stv ($alpha $beta)) (
    let* (
        ($count (+ $alpha $beta))
        ($strength (round (/ $alpha $count) 2))
        ($confidence (+ 0.001 (round (count-to-confidence $count) 2))) ;; A small value should be added to avoid 0 when rounding
    ) ($strength $confidence)
))

;; Match goal in the rule space and return applicable rule IDs
(: match-goal (-> Expression hyperon::space::DynSpace Expression))
(= (match-goal $goal $space) (
    collapse (match $space (: Rule $id $ttv $stv $comp $context $action (Goal $goal)) $id)
))

;; Get rule details by rule ID
(: get-rule (-> Number hyperon::space::DynSpace Expression))
(= (get-rule $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp $context $action $goal) (: Rule $ruleId $ttv $stv $comp $context $action $goal)
))

;; Get specific attributes (Contexts) of a rule by rule ID
(: get-context (-> Number hyperon::space::DynSpace Expression))
(= (get-context $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp (Context $context) $action $goal) $context
))

;; Get specific attributes (STV) of a rule by rule ID
(: get-stv (-> Number hyperon::space::DynSpace (Number Number)))
(= (get-stv $ruleId $space) (
    match $space (: Rule $ruleId $ttv (STV $s $c) $comp $context $action $goal) ($s $c)
))

;; Get specific attributes (Action) of a rule by rule ID
(: get-action (-> Number hyperon::space::DynSpace Expression))
(= (get-action $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp $context (Action $action) $goal) $action
))

;; Match context with rule contexts and return matching rule ID or Empty. All the contexts in the rule must match.
(: match-context (-> Number Expression hyperon::space::DynSpace Expression))
(= (match-context $ruleId $context $space) (
    let* (
        ($ruleContext (get-context $ruleId $space))
        ($contextCount (size-atom $ruleContext))
        ($intersection (intersection-atom $ruleContext $context))
        ($matchCount (size-atom $intersection))
    ) (if (== $contextCount $matchCount)
        $ruleId
        Empty
    )
))

;; Match multiple contexts with rule contexts and return matching rule IDs
(: match-contexts (-> Expression Expression hyperon::space::DynSpace Expression))
(= (match-contexts $ruleIds $context $space) (
    collapse (let $ruleId (superpose $ruleIds) (match-context $ruleId $context $space))
))

;; Thompson Sampling to select a rule based on its STV values
(: thompson-sample (-> Expression hyperon::space::DynSpace (Number Number)))
(= (thompson-sample $ruleIds $space) (
    if (== $ruleIds ())
        (-1 0) ; (RuleID, Sampled Value)
    (let* (
        (($ruleId $rest) (decons-atom $ruleIds))
        ($_ (println! ("Considering rule: " $ruleId)))
        (($strength $confidence) (get-stv $ruleId $space))
        (($alpha $beta) (stv-to-beta ($strength $confidence)))
        ($sample (beta-sample $alpha $beta))
        ($_ (println! ("Rule " $ruleId " gave sample: " $sample)))
        (($chosenId $chosenSample) (thompson-sample $rest $space))
    ) (if (>= $sample $chosenSample) 
        ($ruleId $sample) 
        ($chosenId $chosenSample)
    ))
))

;; Perform the action associated with the rule in the given context and return result (1 for success, 0 for failure)
(: perform-action (-> Number Expression hyperon::space::DynSpace Number))
(= (perform-action $ruleId $context $space) (
    let* (
        ($action (get-action $ruleId $space))
        ($_ (println! ("Performing action: " $action " in context: " $context)))
    ) (if (and (== $action (ATTACK SWORD)) (== $context ((Position CLOSE_RANGE))))
        1
        (if (and (== $action (ATTACK BOW)) (== $context ((Position MID_RANGE))))
            1
            (if (and (== $action (CAST FIREBALL)) (== $context ((Position LONG_RANGE))))
                1
                0
            )
        )
    )
))

;; Update Atoms in a space
(: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

;; Update STV of a rule by rule ID
(: update-stv (-> Number (Number Number) hyperon::space::DynSpace (->)))
(= (update-stv $ruleId ($s $c) $space) (
    let* (
        ($rule (get-rule $ruleId $space))
        ($_ (println! ("Old rule: " $rule)))
        ((: Rule $ruleId $ttv (STV $os $oc) $comp $context $action $goal) $rule)
        ($newRule (: Rule $ruleId $ttv (STV $s $c) $comp $context $action $goal))
        ($_ (update-atom $space $rule $newRule))
        ($_ (println! ("New rule: " $newRule)))
    ) ()
))

;; Update rule after action execution based on result (1 for success, 0 for failure)
(: update-rule (-> Number Number hyperon::space::DynSpace (->)))
(= (update-rule $ruleId $result $space) (
    let* (
        (($strength $confidence) (get-stv $ruleId $space))
        (($alpha $beta) (stv-to-beta ($strength $confidence)))
        ($newAlpha (if (== $result 1) (+ $alpha 1) $alpha))
        ($newBeta (if (== $result 1) $beta (+ $beta 1)))
        (($newStrength $newConfidence) (beta-to-stv ($newAlpha $newBeta)))
        ($_ (update-stv $ruleId ($newStrength $newConfidence) $space))
    ) ()
))
