;
; Feeling updaters
; How emotions emerge from the system?
;
; Step 1. Define a small set of proto-dimentions in terms of basic demands and 
;         modulators. 
;
; Step 2. Different emotions are then indentified with corresponding regions in 
;         the space spanned by these dimentions
;
; Step 1 in detail:
;
; We choose five dimentions, all the four modulators plus pleasure, listed below:
;
; 1. Activation. 
;    It controls the agent's readiness for action, the higher the activation, the 
;    pressing it has become to react to the situation at hand, and faster decisions 
;    are sought. 
;    A higher activation would lead to few details and less schematic depth. 
;
; 2. Resolution. 
;    It affects perception. 
;    A low resolution level tends to miss differences, then the agent would get a
;    better overview
;
; 3. SecuringThreshold. 
;    The frequency of the securing behavior is inversily determined by SecuringThreshold.
;    The value of securing threshold is proportional to the strength of the current motive, 
;    i.e. in the face of urgency, there will be less orientation. 
;    It also depends on the uncertainty in the current context.
;    An undetermined environment requires more orientation, i.e. lower securing threshold. 
;
; 4. SelectionThreshold.
;    It is a bias added to the strength of the currently selected motive (Demand Goal). 
;    A higher selection threshold leads to "stubbornness", makes it harder to switch 
;    motives (Demand Goals), then oscillations can be avoided.
;    While a lower one results in opportunism/flexibility, or even motive fluttering. 
;
; 5. Pleasure. 
;    For the moment, it is simply measured by how well the previous and current
;    demand goals are satisfied. 
;
; Step 2 in detail:
;
; Different emotions with their corresponding occupation in the space spanned by the dimentions above.
; ( Note: We only tuned parameters for happy, sad, anger and fear )
;       
;   Emotion       ||    Activation    Resolution    SecuringThreshold    SelectionThreshold    Pleasure
;  ======================================================================================================
;   happiness     ||        H             L                                       H                H
;  ------------------------------------------------------------------------------------------------------ 
;   sadness       ||        L             H                                       EL               EL
;  ------------------------------------------------------------------------------------------------------ 
;   anger         ||        H             L                                       L                EL
;  ------------------------------------------------------------------------------------------------------ 
;   fear          ||        EL            EH               L                                       EL 
;  ------------------------------------------------------------------------------------------------------ 
;   excitement    ||        H             L                                       L                EH/EL  
;  ------------------------------------------------------------------------------------------------------ 
;   pride         ||                      L                H                      H                H 
;  ------------------------------------------------------------------------------------------------------ 
;   love          ||                      EL               EH                     EH               EH 
;  ------------------------------------------------------------------------------------------------------ 
;   hate          ||        EH            EL               EH                                      EL
;  ------------------------------------------------------------------------------------------------------ 
;   gratitude     ||                                                              H                H
;
;   ( H = high, L = low, M = medium, E = extremely )


; Thresholds for fuzzy high, low, medium etc.
;; !(register-module!  ../../hyperon-openpsi)
;; !(register-module! ../utilities-module)
;; !(import! &self utilities-module:utils)
;; !(import! &self hyperon-openpsi:utils:psi_utils)

(= (modulator_high_threshold) 0.7)
(= (modulator_extremely_high_threshold) 0.85)
(= (modulator_low_threshold) 0.3)
(= (modulator_extremely_low_threshold) 0.15)
(= (modulator_medium_threshold) 0.5)

;) Used by 'modulator_to_feeling_dimension' below
(= (modulator_extremely_low_indicator )-2)
(= (modulator_low_indicator) -1)
(= (modulator_medium_indicator) 0)
(= (modulator_high_indicator) 1)
(= (modulator_extremely_high_indicator) 2)
(= (modulator_undefined_indicator) 3)
(= (get_pleasure_value) 0.5)
(= (sum $list)
    (foldl + 0 $list)
)

; Ma)p a modulator t)o corresponding feeling dimension
; indicator equals to -2 means extremely low, -1 low, 0 medium, 1 high, 2 extremely high,
; others not defined (would return 0) 
(= (modulator_to_feeling_dimension $modulator_value $indicator)
    (if (== $indicator (modulator_extremely_low_indicator))
        (fuzzy_less_than $modulator_value (modulator_extremely_low_threshold) 50)
        (if (== $indicator (modulator_low_indicator))
            (fuzzy_less_than $modulator_value (modulator_low_threshold) 50)

            (if (== $indicator (modulator_medium_indicator))
                (fuzzy_equal $modulator_value (modulator_medium_threshold) 50)
                (if (== $indicator (modulator_high_indicator))
                    (fuzzy_greater_than $modulator_value (modulator_high_threshold) 50)
                

                    (if (== $indicator (modulator_extremely_high_indicator))
                        (fuzzy_greater_than $modulator_value (modulator_extremely_high_threshold) 50)
                        0
                    )
            )
        )
        )
    );cond 
)

; Calculate the feeling based on modulator indicators (low, high, medium etc.)
; ;1 indicator for Activation
; ;2 indicator for Resolution
; ;3 indicator for SecuringThreshold
; ;4 indicator for SelectionThreshold
; ;5 indicator for Pleasure
; ;6 the number of modulators used during calculation 

(= (feeling_calculator $activation_indicator 
                       $resolution_indicator 
                       $securing_threshold_indicator 
                       $selection_threshold_indicator 
                       $pleasure_indicator 
                       $number_of_used_modulators)
    (let* (
        ($activation-value 0.3)
        ($resolution-value 0.4)
        ($securing-value 0.7)
        ($selection-value 0.4)
        ($feeling-activation (modulator_to_feeling_dimension $activation-value $activation_indicator))
        ($feeling-resolution (modulator_to_feeling_dimension
              $resolution-value 
              $resolution_indicator
          ))
        ($feeling-securing (modulator_to_feeling_dimension 
              $securing-value 
              $securing_threshold_indicator 
          )
        )
        ($feeling-selection (modulator_to_feeling_dimension 
              $selection-value 
              $selection_threshold_indicator 
          ))
        ($feeling-pleasure (modulator_to_feeling_dimension 
              (get_pleasure_value) 
              $pleasure_indicator
          ))
        ($total (sum ($feeling-activation $feeling-securing $feeling-selection $feeling-pleasure)))
    )

    (/ $total
       $number_of_used_modulators
    ); / 
)
)

; Feeling updaters    
(= (happinessFeelingUpdater) 
    (feeling_calculator (modulator_high_indicator)
                        (modulator_low_indicator)
                        (modulator_undefined_indicator) 
                        (modulator_high_indicator)
                        (modulator_high_indicator)
                        4
    )
)    

(= (sadnessFeelingUpdater) 
    (feeling_calculator (modulator_low_indicator)
                        (modulator_high_indicator)
                        (modulator_undefined_indicator)
                        (modulator_extremely_low_indicator)
                        (modulator_extremely_low_indicator)
                        4
    )
)    

(=(angerFeelingUpdater)
    (feeling_calculator (modulator_high_indicator)
                        (modulator_low_indicator)
                        (modulator_undefined_indicator)
                        (modulator_low_indicator)
                        (modulator_extremely_low_indicator)
                        4
    )
)

(= (fearFeelingUpdater) 
    (feeling_calculator (modulator_extremely_low_indicator)
                        (modulator_extremely_high_indicator)
                        (modulator_low_indicator)
                        (modulator_undefined_indicator)
                        (modulator_extremely_low_indicator)
                        4
    )
)

(= (excitementFeelingUpdater) 
    (max (feeling_calculator (modulator_high_indicator)
                             (modulator_low_indicator)
                             (modulator_undefined_indicator)
                             (modulator_low_indicator)
                             (modulator_extremely_high_indicator)
                             4
         )

         (feeling_calculator (modulator_high_indicator)
                             (modulator_low_indicator)
                             (modulator_undefined_indicator)
                             (modulator_low_indicator)
                             (modulator_extremely_low_indicator)
                             4
         )
    )
)

(= (prideFeelingUpdater) 
    (feeling_calculator (modulator_undefined_indicator)
                        (modulator_low_indicator)
                        (modulator_high_indicator)
                        (modulator_high_indicator)
                        (modulator_high_indicator)
                        4
    )
)

(= (loveFeelingUpdater) 
    (feeling_calculator (modulator_undefined_indicator)
                        (modulator_extremely_low_indicator)
                        (modulator_extremely_high_indicator)
                        (modulator_extremely_high_indicator)
                        (modulator_extremely_high_indicator)
                        4
    )
)

(= (hateFeelingUpdater) 
    (feeling_calculator (modulator_extremely_high_indicator)
                        (modulator_extremely_low_indicator)
                        (modulator_extremely_high_indicator)
                        (modulator_undefined_indicator)
                        (modulator_extremely_low_indicator)
                        4
    )
)

(= (gratitudeFeelingUpdater) 
    (feeling_calculator (modulator_undefined_indicator)
                        (modulator_undefined_indicator)
                        (modulator_undefined_indicator)
                        (modulator_high_indicator)
                        (modulator_high_indicator)
                        2
    )
)

;; ==================================================================================
;;                                  Tests for feeling updaters
;; ==================================================================================

;; !(modulator_to_feeling_dimension 0.85 1)
;; !(feeling_calculator 1 1 1 1 1 5)
;; !(happinessFeelingUpdater)
;; !(sadnessFeelingUpdater)
;; !(angerFeelingUpdater)
;; !(hateFeelingUpdater)
;; !(gratitudeFeelingUpdater)
