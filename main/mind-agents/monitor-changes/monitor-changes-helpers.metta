(= (extractTvFromRule $rule $space)
   (let (TTV $ts $tv) (getTV $rule $space) $tv)
   )

(: symmetricDifference (-> Expression Expression Expression))
(= (symmetricDifference $exp1 $exp2)
   (let* (
	  ($res1 (subtraction-atom $exp1 $exp2))
	  ($res2 (subtraction-atom $exp2 $exp1))
	)
     (union-atom $res1 $res2)
))

;;This function changes the truth value of a rule
(: changeTruthValue (-> Expression Expression Expression))
(= (changeTruthValue $rule (STV $x $y))
	(let (: $handle ((TTV $time (STV $bel $conf))  (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $rule 
	  	(: $handle ((TTV $time (STV $x $y)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
)

(= (extract-timestamp (TimeValue $time-stamp $atom)) $time-stamp)

(= (get-timevals $prev_times) 
   (collapse (let $x (superpose $prev_times) (extract-timestamp $x)))
   )

(= (get-previous-times $space) 
   (collapse (match $space (TimeValue $time-stamp $atom) (TimeValue $time-stamp $atom)))
  )


;;This function filps the truth-value of a rule and updates the atomspace.
(: flipTruthValue (-> hyperon::space::DynSpace Expression Expression))
(= (flipTruthValue &space $atom)
   	(let* (
		($_ (remove-atom $space $atom))
		($newAtom (changeTruthValue $atom (STV 1 1)))

	)
	  	(add-atom $space $newAtom)
	  )
)
