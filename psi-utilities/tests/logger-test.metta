;; Load the logger module
!(register-module! ../../../hyperon-openpsi)

;; Import the logger definitions 
!(import! &self hyperon-openpsi:psi-utilities:log)

;; -----------------------------
;; Existing examples (modulator)
;; -----------------------------

!(assertEqual (log-event modulator_change (Volume 0.5 0.75)) "[MODULATOR_UPDATE]-Volume 0.5' -> 0.75   diff=0.25")

!(assertEqual (log-event modulator_debug (FilterCutoff 800 650)) "[MODULATOR_UPDATE]-FilterCutoff 800' -> 650   diff=-150.0")

;; -----------------------------
;; New PSI: feeling updates
;; -----------------------------

!(assertEqual (log-event feeling_update_debug (Joy 0.6 0.8)) "[FEELING_UPDATE]-Joy 0.6' -> 0.8  ")

!(assertEqual (log-event feeling_update_debug (Fear 0.2 0.15)) "[FEELING_UPDATE]-Fear 0.2' -> 0.15  ")

;; -----------------------------
;; New PSI: schema updates
;; -----------------------------

!(assertEqual (log-event schema_update (Schema-Approach-Reward activated "Triggered by Goal(FindFood)")) "[SCHEMA_UPDATE]-Schema-Approach-Reward activated \"Triggered by Goal(FindFood)\"")

!(assertEqual (log-event schema_update (Schema-Avoid-Threat strengthened "Connection to Concept(LoudNoise) increased")) "[SCHEMA_UPDATE]-Schema-Avoid-Threat strengthened \"Connection to Concept(LoudNoise) increased\"")

!(assertEqual (log-event schema_update (ComplexSchemaID modified "Sub-node 'X' value changed")) "[SCHEMA_UPDATE]-ComplexSchemaID modified \"Sub-node 'X' value changed\"")

;; -----------------------------------------------
;; Graceful fallback: non-numeric modulator change
;; -----------------------------------------------

!(assertEqual (log-event feeling_update (Mood Calm Tense)) "[FEELING_UPDATE]-Mood Calm' -> Tense  ")

;; -----------------------------------------------
;; Errors and unknown events (should still print)
;; -----------------------------------------------

!(assertEqual (log-event unknown_event (Data1 Data2)) "log-event: No handler found for event type 'unknown_event'")

!(assertEqual (log-event modulator_change (ReverbDecay 2.5 3.0)) "[MODULATOR_UPDATE]-ReverbDecay 2.5' -> 3.0   diff=0.5")


