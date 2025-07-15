;;(: remove-atoms' (-> hyperon::space::DynSpace Expression Expression))
(= (remove-atoms' $space $expression)
    (if (== $expression ())
        ()
        (let* (
            (($head $tail) (decons-atom $expression))
            ($_  (remove-atom $space $head))
           ($rem (collapse (get-atoms $space)))
           ($_ (println! (remaining-atoms $rem)))
        )
            (remove-atoms' $space $tail)
        )
    )
)
;; This function removes values from a given atomspace
;;(:remove-atoms (-> hyperon::space::DynSpace))
(= (remove-atoms $space)
    (let $atoms (collapse (get-atoms $space))
        (remove-atoms' $space $atoms)
    )
)
;; Remove The remove occurrences function removes values based on a given 
;;pattern for instance a perception updater value can be stored as 
;;(perception value time)
;;(: remove-occurrences (-> hyperon::space::DynSpace Expression Expression)) 
(= (remove-occurrences $space $pattern)
   	(let* (
            ($atoms (collapse (match $space $pattern $pattern)))
            ($_ (println! (atoms-to-remove $atoms)))
           ) 
	  	(remove-atoms' $space $atoms)))

;;The below function is used to synchronize two atomspaces for having the same
;;Replicated value. The updater space belongs to the mind-agent while the atomspace to be synchronized is the 
;; knowledge base atomspace.
(: update-atoms (-> Expression hyperon::space::DynSpace hyperon::space::DynSpace Expression ))
(= (update-atoms $pattern $updater $updated)
   	(let* (
	       ($updater-atoms (collapse (get-atoms $updater)))
	       ($rem-res (remove-occurrences $updated $pattern))
           ($atoms (collapse (get-atoms $updated)))
            ($res (collapse (add-atoms $updated $updater-atoms)))
    
	       )
	  	()	
	)
)