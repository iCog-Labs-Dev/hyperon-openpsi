!(bind! &psiRules (new-space))
!(bind! &categoryIndex (new-space))

(= (FALSE_TV) (False (STV 0.0 1.0))) ;False, with Maximum confidence
(= (TRUE_TV) (True (STV 1.0 1.0))) ;True, with Maximum confidence

(= (PsiRules) &psiRules)

(: addAndLink (-> Expression Action Expression))
(= (addAndLink $context $action)
   (let $res 
        (collapse (match &self (AND_LINK ($context $action)) (AND_LINK ($context $action))))
        (if (not (== $res ()))
          (car-atom $res)
          (let () (add-atom &self (AND_LINK ($context $action))) (AND_LINK ($context $action)))
        )
     )
)

;(: addRuleLink (-> Symbol Goal Expression Expression))
(= (addRuleLink $handle $goal $andLink)
   (let*
     (
      ($rule (collapse (get-type $handle)))
      )
      (if (not (== $rule (%Undefined%))) 
            () 
            (
              let* (
                    ($newRule (: $handle (IMPLICATION_LINK $andLink $goal)))
                    ($_ (add-atom &self $newRule))
                    ($_ (add-atom &self (: $handle (TTV 0 (STV 0.0 0.0)))))
                    ($_ (add-atom &self (isExecuted $handle (DEFAULT_TV)))) ;TODO: define DEFAULT_TV
                  )
                  ()
            )
      )
     )
)

(: existsIn Grounded Atom Bool)
(= (existsIn $space $atom)
   ( let $res (collapse (get-type-space $space $atom)) (not (== (%Undefined%) $res)) )
)

;(: addRule (-> Symbol Expression Action Symbol Goal Expression))
(= (addRule $ruleHandle $context $action $goal $tv)
    (let* (
            ($andLink (addAndLink $context $action))
            ($_ (addRuleLink $ruleHandle $goal $andLink))
            ($exists (existsIn &psiRules $ruleHandle))
          )
          (if $exists 
              $ruleHandle
              (let* 
                (
                  ($res (getRuleType $ruleHandle &self))
                  ($_ (if (== (len $res) 2) ; Important to avoid adding another $tv to $ruleHandle as type.
                          (update-atom &self (: $ruleHandle (TTV 0 (STV 0.0 0.0))) (: $ruleHandle $tv)) 
                          () ))
                  ($_ (update-atom &self (isExecuted $ruleHandle (DEFAULT_TV)) (isExecuted $ruleHandle (FALSE_TV))))
                )
                (let () (if (== (len $context) 1)
                    (add-atom &psiRules (: $ruleHandle ($context $action $goal (car-atom $context))))
                    (add-atom &psiRules (: $ruleHandle ($context $action $goal (AND_LINK $context))))
                  )
                  $ruleHandle
                )
              )
          )
    )
)
 
(: getAction (-> Symbol Expression))
(= (getAction $rule) 
   (
    case (getRuleType $rule &self) 
      (
        (((TTV $timestamp $stv) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) $action)
        (((IMPLICATION_LINK (AND_LINK ($context $action)) $goal) (TTV $timestamp $stv)) $action)
        (((IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) $action )
        ($_ %Undefined%)
      )
   )
)

;(: getGoal (-> Symbol Expression))
(= (getGoal $rule)  
  ( 
   case (getRuleType $rule &self) 
    (
      (((TTV $timestamp $stv) (IMPLICATION_LINK $andLink $goal)) $goal)
      (((IMPLICATION_LINK $andLink $goal) (TTV $timestamp $stv)) $goal)
      (((IMPLICATION_LINK $andLink $goal)) $goal )
      ($_ %Undefined%)
    )
   )
)

(: getContext (-> Symbol Expression))
(= (getContext $rule)
   (
    case (getRuleType $rule &self) 
      (
        (((TTV $timestamp $stv) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) $context)
        (((IMPLICATION_LINK (AND_LINK ($context $action)) $goal) (TTV $timestamp $stv)) $context)
        (((IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) $context )
        ($_ %Undefined%)
      )

    )
)


(= (getRuleType $id $space) (collapse (get-type-space $space $id)))

(: getTV (-> Symbol Grounded Expression))
(= (getTV $id $space) 
   (
    case (getRuleType $id $space)
    (
      (((TTV $timestamp $stv) $link) (TTV $timestamp $stv))
      (($link (TTV $timestamp $stv)) (TTV $timestamp $stv))
      ($_ (TTV 0 (STV 0.0 0.0))) ;default case
    )
  )
)


;(: x (Goal $value $dgv))
(: addGoalHelper (-> Symbol Number Number Grounded Atom))
(= (addGoalHelper $name $value $dgv $space)
   (if (and (isGvValid $value) (isGvValid $dgv)) 
      (if (goalExists $name $space)
          (Goal With Id $name Already Exists)
          (let () 
              (add-atom $space (Goal $name $value $dgv)) 
              $name
          )
        )
      (Invalid goal/dgv Value) 
    )
)

(: isGvValid (-> Number Bool))
(= (isGvValid $value)
   (and (>= $value 0.0) (<= $value 1.0))
   )

;This function accepts an optional third argument,
;dgv(desiredGoalValue), if () is passed then a default value of 1.0 is used.
;Returns the symbol representing the added goal.
(: addGoal (-> Symbol Number Atom Grounded Expression))
(= (addGoal $name $value $dgv $space)
   (if (== () $dgv) 
      (addGoalHelper $name $value 1.0 $space) 
      (addGoalHelper $name $value $dgv $space)
    )
   )

(: setGv (-> Symbol Number Grounded (->)))
(= (setGv $goal $value $space)
   (if (goalExists $goal $space)
          (match $space (Goal $goal $oldGv $oldDgv) (update-atom $space (Goal $goal $oldGv $oldDgv) (Goal $goal $value $oldDgv)))
          (Invalid Goal Id)
    )
   )

(: setDgv (-> Symbol Number Grounded (->)))
(= (setDgv $goal $value $space)
   (if (goalExists $goal $space)
          (match $space (Goal $goal $oldGv $oldDgv) (update-atom $space (Goal $goal $oldGv $oldDgv) (Goal $goal $oldGv $value))) 
          (Invalid Goal Id)
    )
   )

(= (goalExists $goal $space) (not (== (collapse (match $space (Goal $goal $value $dgv) $goal)) ())))

;For each AndLink, get all ImplicationLink atoms pointing to it.
;Filter these to keep only valid PSI rules using the isRule predicate function.
;arg1: a tuple of andLinks
;arg2: an accumulator
;return: a tuple of valid psiRules

(= (filterPsiRules $andLinks $acc)
   (if (== $andLinks ())
      $acc
      (let* (
              (($head $tail) (decons-atom $andLinks))
              ($handles (collapse (match &self (: $handle (IMPLICATION_LINK $head $goal)) $handle)))
              ($rulesList (concatTuple $handles $acc))
              ($res (filterPsiRules $tail $rulesList))
            )
        (if (== $head ())
          $acc
          $res
          )
        )
   )
  )

(= (isRule $rule) (existsIn (PsiRules) $rule))

;Returns a list of all of the goals that are associated with an action, which
;is passed to it as arg.A goal is associated with an action whenever the goal appears in
;a psi-rule with that action in it.
;arg: action
;returns: a tuple of goals

(= (relatedGoals $action)
   (let* (
          ($andLinks (collapse (match &self (AND_LINK ($context $action)) (AND_LINK ($context $action)))))
          ($rules (filterPsiRules $andLinks ()))
          ($goals (collapse (getGoal (superpose $rules))))
          ($res (collapse (unique (superpose $goals)))) ; remove duplicate goals
        )
        $res
      )
   )


;Declare a new category by adding the following structured atom into the
;atomspace
;        (: CategoryName Category)
;
;Such categorization is helpful in defining custom behaviors per category.
;
;arg: newCategory The node reprsenting the new category.
;return: Node that represents the category.

(: addCategory (-> Symbol Expression))
(= (addCategory $newCategory)
   (if (not (existsIn &categoryIndex $newCategory))
     (let () 
       (add-atom &categoryIndex (: $newCategory Category))
       $newCategory
       )
      $newCategory
     )
   )

;Add a node to a category. The representation is as follows
;   (isA rule category)
;
;arg1: rule A rule to be categorized.
;arg2: category An atom that represents the category.
;return: The rule that was passed in.
 
(: addToCategory (-> Symbol Symbol Expression))
(= (addToCategory $rule $category)
   (let* (
        ($catgry (addCategory $category)) ; add the category incase it hasn't been added
        ($rulePred (isA $rule $category))
      )
     (if (not (isMember $rulePred (collapse (get-atoms &categoryIndex))))
          (let () (add-atom &categoryIndex $rulePred) $rule)
          (addToCategory: Rule $rule Already Exists in $category))
    )
   )

;Returns all the categories that were added using add_to_category.
;
;return: A tuple of symbols that represent the categories.

(: getCategories (->) Expression)
(= (getCategories) (collapse (match &categoryIndex (: $category Category) $category)) )



(: goal-value (-> Symbol Grounded Number))
(= (goal-value $goal $space)
    (match $space (Goal $goal $value $dgv) $value)
)

(: desired-goal-value (-> Symbol Grounded Number))
(= (desired-goal-value $goal $space)
   (match $space (Goal $goal $value $dgv) $dgv)
   )



(= (cogTvMean ($tv $val $conf))
    (/ (+ $val $conf) 2)
)

(= (cogTvConfidence ($tv $val $conf))
  $conf
)

(= (min $head $tail) (if (< $head $tail) $head $tail))


(= (contextStv $stvList)
    (let* (
      ($firDegree (collapse (cogTvMean (superpose $stvList))))
      ($secDegree (collapse (cogTvConfidence (superpose $stvList))))
      ($firResult (foldr * 1 $firDegree))
      ($secResult (foldr min 1 $secDegree))
    
    )
      (STV $firResult $secResult)
    )
)
(= (isSatisfiable $rule $satisfiableChecker)
    (== (STV 1 1)  ($satisfiableChecker $rule))
)

;; (= (checkSatisfiability))
;; !(foldl * 1 (1 2 3 4 5))
;; !(foldl min 1 (1 2 3 4 5))
;; !(contextStv ((stv 0.5 0.4) (stv 0.6 0.8)))
