;; example_logger.metta or your main psi.metta

!(import! &self log) ;; Make sure path points to the logger file

;; --- Existing Wrappers ---
(= (log-modulator $name $old-value $new-value)
   (log-event modulator_change ($name $old-value $new-value))
)
(= (log-modulator-debug $name $old-value $new-value)
   (log-event modulator_debug ($name $old-value $new-value))
)

;; --- NEW PSI Wrappers ---
(= (log-feeling $feeling-name $old-value $new-value)
   ;; Uses the "feeling_update" event type (INFO level by default)
   (log-event feeling_update ($feeling-name $old-value $new-value))
)

(= (log-feeling-debug $feeling-name $old-value $new-value)
   ;; Uses the "feeling_update_debug" event type (DEBUG level by default)
   (log-event feeling_update_debug ($feeling-name $old-value $new-value))
)

(= (log-schema $schema-id $update-type $details)
   ;; Uses the "schema_update" event type (DEBUG level by default)
   ;; Note: $details should resolve to a symbol or string-like atom
   (log-event schema_update ($schema-id $update-type $details))
)


;; --- Example Usage ---

;; Existing examples
!(log-modulator Volume 0.5 0.75)
!(log-modulator-debug FilterCutoff 800 650)

;; New PSI examples
!(log-feeling Joy 0.6 0.8)
!(log-feeling-debug Fear 0.2 0.15)
!(log-schema Schema-Approach-Reward activated "Triggered by Goal(FindFood)")
!(log-schema Schema-Avoid-Threat strengthened "Connection to Concept(LoudNoise) increased")
!(log-schema ComplexSchemaID modified "Sub-node 'X' value changed")

;; Example of non-numeric feeling update (handled gracefully by Python)
!(log-feeling Mood Calm Tense)

;; Examples of unknown/direct calls still work
!(log-event unknown_event (Data1 Data2)) ;; Will log "No handler found" error
!(log-event modulator_change (ReverbDecay 2.5 3.0))