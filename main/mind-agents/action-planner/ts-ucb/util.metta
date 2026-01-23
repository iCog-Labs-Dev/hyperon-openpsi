;; Utility functions for ts-usb taken from Thompson Sampling based action planner

;; Convert confidence to count
(: confidenceToCount (-> Number Number))
(= (confidenceToCount $confidence) (
    / (* $confidence 800) (- 1 $confidence)
))

;; Convert count to confidence
(: countToConfindence (-> Number Number))
(= (countToConfindence $count) (
    / $count (+ 800 $count)
))

;; Convert strength and confidence to alpha and beta parameters of Beta distribution
(: stvToBeta (-> (Number Number) (Number Number)))
(= (stvToBeta ($strength $confidence)) (
    let* (
        ($count (confidenceToCount $confidence))
        ($alpha (* $strength $count))
        ($beta (- $count $alpha))
    ) ($alpha $beta)
))

;; Convert alpha and beta parameters of Beta distribution to strength and confidence
(: betaToSTV (-> (Number Number) (Number Number)))
(= (betaToSTV ($alpha $beta)) (
    let* (
        ($count (+ $alpha $beta))
        ($strength (round (/ $alpha $count) 2))
        ($confidence (+ 0.001 (round (countToConfindence $count) 2))) ;; A small value should be added to avoid 0 when rounding
    ) ($strength $confidence)
))

;; Match goal in the rule space and return applicable rule IDs
(: matchGoal (-> Expression hyperon::space::DynSpace Expression))
(= (matchGoal $goal $space) (
    collapse (match $space (: Rule $id $ttv $stv $comp $context $action (Goal $goal)) $id)
))

;; Get rule details by rule ID
(: getRule (-> Number hyperon::space::DynSpace Expression))
(= (getRule $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp $context $action $goal) (: Rule $ruleId $ttv $stv $comp $context $action $goal)
))

;; Get specific attributes (Contexts) of a rule by rule ID
(: getContext (-> Number hyperon::space::DynSpace Expression))
(= (getContext $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp (Context $context) $action $goal) $context
))

;; Get specific attributes (STV) of a rule by rule ID
(: getSTV (-> Number hyperon::space::DynSpace (Number Number)))
(= (getSTV $ruleId $space) (
    match $space (: Rule $ruleId $ttv (STV $s $c) $comp $context $action $goal) ($s $c)
))

;; Get specific attributes (Action) of a rule by rule ID
(: getAction (-> Number hyperon::space::DynSpace Expression))
(= (getAction $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp $context (Action $action) $goal) $action
))

;; Match context with rule contexts and return matching rule ID or Empty. All the contexts in the rule must match.
(: matchContext (-> Number Expression hyperon::space::DynSpace Expression))
(= (matchContext $ruleId $context $space) (
    let* (
        ($ruleContext (getContext $ruleId $space))
        ($contextCount (size-atom $ruleContext))
        ($intersection (intersection-atom $ruleContext $context))
        ($matchCount (size-atom $intersection))
    ) (if (== $contextCount $matchCount)
        $ruleId
        Empty
    )
))

;; Match multiple contexts with rule contexts and return matching rule IDs
(: matchContexts (-> Expression Expression hyperon::space::DynSpace Expression))
(= (matchContexts $ruleIds $context $space) (
    collapse (let $ruleId (superpose $ruleIds) (matchContext $ruleId $context $space))
))

;; Thompson Sampling to select a rule based on its STV values
(: thompsonSample (-> Expression hyperon::space::DynSpace (Number Number)))
(= (thompsonSample $ruleIds $space) (
    if (== $ruleIds ())
        (-1 0) ; (RuleID, Sampled Value)
    (let* (
        (($ruleId $rest) (decons-atom $ruleIds))
        ($_ (println! ("Considering rule: " $ruleId)))
        (($strength $confidence) (getSTV $ruleId $space))
        (($alpha $beta) (stvToBeta ($strength $confidence)))
        ($sample (betaSample $alpha $beta))
        ($_ (println! ("Rule " $ruleId " gave sample: " $sample)))
        (($chosenId $chosenSample) (thompsonSample $rest $space))
    ) (if (>= $sample $chosenSample) 
        ($ruleId $sample) 
        ($chosenId $chosenSample)
    ))
))

;; Perform the action associated with the rule in the given context and return result (1 for success, 0 for failure)
(: performAction (-> Number Expression hyperon::space::DynSpace Number))
(= (performAction $ruleId $context $space) (
    let* (
        ($action (getAction $ruleId $space))
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
(: updateAtom (-> Grounded Atom Atom (->)))
(= (updateAtom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

;; Update STV of a rule by rule ID
(: updateSTV (-> Number (Number Number) hyperon::space::DynSpace (->)))
(= (updateSTV $ruleId ($s $c) $space) (
    let* (
        ($rule (getRule $ruleId $space))
        ($_ (println! ("Old rule: " $rule)))
        ((: Rule $ruleId $ttv (STV $os $oc) $comp $context $action $goal) $rule)
        ($newRule (: Rule $ruleId $ttv (STV $s $c) $comp $context $action $goal))
        ($_ (updateAtom $space $rule $newRule))
        ($_ (println! ("New rule: " $newRule)))
    ) ()
))

;; Update rule after action execution based on result (1 for success, 0 for failure)
(: updateRule (-> Number Number hyperon::space::DynSpace (->)))
(= (updateRule $ruleId $result $space) (
    let* (
        (($strength $confidence) (getSTV $ruleId $space))
        (($alpha $beta) (stvToBeta ($strength $confidence)))
        ($newAlpha (if (== $result 1) (+ $alpha 1) $alpha))
        ($newBeta (if (== $result 1) $beta (+ $beta 1)))
        (($newStrength $newConfidence) (betaToSTV ($newAlpha $newBeta)))
        ($_ (updateSTV $ruleId ($newStrength $newConfidence) $space))
    ) ()
))

;added for ts-ucb 

;reverse function 
(= (reverse $lst) 
   (superpose $lst)
)
;get alphas/betas for a list of ruleIds
(: get_alphas_betas (-> Expression hyperon::space::DynSpace Expression))
(= (get_alphas_betas $ruleIds $space) (
    collapse (let $ruleId (superpose $ruleIds)
        (let* (
            (($strength $confidence) (getSTV $ruleId $space))
            (($alpha $beta) (stvToBeta ($strength $confidence)))
        ) ($ruleId $alpha $beta)
    ))
))

(: max_list (-> Expression Number))
(= (max_list $vals) (
    if (== (size-atom $vals) 1)
        (car-atom $vals)
        (let* (
            ($head (car-atom $vals))
            ($tail (cdr-atom $vals))
            ($tail_max (max_list $tail))
        )
            (if (> $head $tail_max) $head $tail_max)
        )
))
(= (compute_max_total $ab_list)
   (let* (
        (($id $a $b) (superpose $ab_list))         
        ($sum (+ $a $b))
        )
       $sum
    )
)

; sample thetas for all rules: input superposed (ruleId a b), output superposed (ruleId theta)
(: sample_thetas (-> Expression Expression))
(= (sample_thetas $ab_list) (
    collapse (let ($id $a $b) (superpose $ab_list)
        (let $theta (betaSample $a $b)
            (superpose ($id $theta))
        )
    )
))

; estimate f_tilde: sample m times, each time max(theta samples), then mean
(: estimate_f_tilde (-> Expression Number Number))
(= (estimate_f_tilde $ab_list $m) (
    mean_list (collect_opt_samples $ab_list $m ())
))

(: collect_opt_samples (-> Expression Number Expression Expression))
(= (collect_opt_samples $ab_list $m $samples) (
    if (== $m 0)
        $samples
        (let* (
            ($thetas (collapse (let ($id $theta) (superpose (sample_thetas $ab_list)) $theta)))
            ($opt (max_list $thetas))
        ) (collect_opt_samples $ab_list (- $m 1) (superpose $samples $opt))
    )
))

; get superposed means: from (ruleId a b) → mean = a / (a+b)
(: get_means (-> Expression Expression))
(= (get_means $ab_list) (
    collapse (let ($id $a $b) (superpose $ab_list) (/ $a (+ $a $b)))
))

; get superposed totals: from (ruleId a b) → a + b
(: get_totals (-> Expression Expression))
(= (get_totals $ab_list) (
    collapse (let ($id $a $b) (superpose $ab_list) (+ $a $b)))
)
; get superposed radii: sqrt( log(2*(max_total +1)) / (2 * total) ), min 1e-6
(: get_radii (-> Number Expression Expression))
(= (get_radii $max_total $totals) (
    collapse (let $total (superpose $totals)
        (max 1e-6 (sqrt (/ (log (* 2 (+ $max_total 1))) (* 2 $total))))
    )
))

; get superposed scores: (f_tilde - mean) / radius for each
(: get_scores (-> Number Expression Expression Expression))
(= (get_scores $f_tilde $means $radii) (
    collapse (let* (
        (($m_head $m_tail) (decons-atom $means))
        (($r_head $r_tail) (decons-atom $radii))
    ) (superpose (/ (- $f_tilde $m_head) $r_head) (get_scores $f_tilde $m_tail $r_tail)))
))

; ts-ucb selector
(: ts_ucb_select (-> Expression hyperon::space::DynSpace Number (Number Number)))
(= (ts_ucb_select $ruleIds $space $m) (
    if (== $ruleIds ())
        (-1 0)  
        (let* (
            ($ab_list (get_alphas_betas $ruleIds $space))
            ($max_total (compute_max_total $ab_list))
            ($f_tilde (estimate_f_tilde $ab_list $m))
            ($means (get_means $ab_list))
            ($totals (get_totals $ab_list))
            ($radii (get_radii $max_total $totals))
            ($scores (get_scores $f_tilde $means $radii))
            (($min_score $min_index) (min_list_with_index $scores))
            ($chosenId (nth-atom $ruleIds $min_index))  
            ($_ (println! ("TS-UCB: f_tilde=" $f_tilde " scores=" $scores " chose=" $chosenId)))
        ) ($chosenId $min_score)
    )
))

;; get nth item from superposed list 
(: nth-atom (-> Expression Number Expression))
(= (nth-atom $list $n) (
    if (== $n 0)
        (car-atom $list)
        (nth-atom (cdr-atom $list) (- $n 1))
))
 