;; (= (fuzzy_equal $x $t $a)
;;     (/ 1
;;         (+ 1
;;             (* $a (*(- $x $t) (- $x $t)))
;;         )  
;;     )     
;; )
(: ActivationHelper (-> Number Number Number Number))
(= (ActivationHelper $competence $energy $stimulus)
    (+  (* 2 $stimulus)
             (* (/ $competence (+ $competence 0.5) )
                (/ $energy (+ 0.05 $energy) )
             )
         )
)

(: SecuringThresholdHelper (-> Number Number Number))
(= (SecuringThresholdHelper  $integrity $stimulus)
     (+  (* 2 $stimulus)
             (pow-math 
             $integrity 3)
         
        )

)

(: SelectionThresholdHelper (-> Number Number Number))
(= (SelectionThresholdHelper $competence $stimulus)
     (+  (* 2 $stimulus)
             (fuzzy_equal $competence 1 15)
         )
)

(= (modulatorUpdaterAgent $modulatorSpace $competence-demand $affiliation-demand $energy-demand)

	(let* (
	       	($stimulus (random-float &rng 0 1))
		    ($integrity (random-float &rng 0 1))
       		((demand competence $competenceValue) $competence-demand)
		    ((demand affiliation $affiliationValue) $affiliation-demand)
		    ((demand energy $energyValue) $energy-demand)
		    ($activationValue (ActivationHelper $competenceValue $energyValue $stimulus))
		    ($securingValue (SecuringThresholdHelper $integrity $stimulus))
		    ($selectionValue (SelectionThresholdHelper $competenceValue $stimulus))
		    ($activationModulator (fetch-modulator $modulatorSpace arousal))
		    ($securingModulator (fetch-modulator $modulatorSpace securing-threshold))
		    ($selectionModulator (fetch-modulator $modulatorSpace selection-threshold))
		    ($_ (update-atom $modulatorSpace $activationModulator (modulator arousal $activationValue)))
		    ($_ (update-atom $modulatorSpace $securingModulator (modulator securing-threshold $securingValue)))
		    ($_ (update-atom $modulatorSpace $selectionModulator (modulator selection-threshold $selectionValue)))
	
 	)
	  ()


	)
)