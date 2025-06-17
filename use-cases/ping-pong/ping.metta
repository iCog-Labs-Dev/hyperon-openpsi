!(register-module! ../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)

;; Define truth values
(= (FALSE_TV) (False (STV 0.0 1.0)))  ; False, with maximum confidence
(= (TRUE_TV) (True (STV 1.0 1.0)))    ; True, with maximum confidence

;; Define ball states with explicit types
(: neutral Concept)
(: pinged Concept)
(: ball Concept)
(: state-var Atom)  ; Use Atom instead of Variable to avoid type issues

;; Set initial ball state
!(add-atom &self (State ball neutral))

;; Define ping goal
!(addGoal ping 0.0 1.0 &self)  ; Goal 'ping' with initial value 0.0 and desired value 1.0
!(setGv ping 0.0 &self)

;; Define ping action
(: ping-action (-> Atom))  ; Renamed to avoid confusion with :ping type
(= (ping-action)
  (let ()
    (add-atom &self (State ball pinged))
    (setGv ping 0.0 &self)
  )) 
!(ping-action)  ; Register the ping action
;; Define ping context
(: ping-context (-> Expression))
(= (ping-context)
  (addAndLink
    (State ball state-var)
    (Equal state-var neutral)))
!(ping-context)
;; Add ping rule
!(addRule ping-rule (ping-context) (ping-action) ping (STV 1.0 1.0))  ; Use ping-action as the action

;; Add ping component
!(addCategory ping-component)
!(addToCategory ping-rule ping-component)


;; Simulate running the ping component
(= (run-component )
  (let* (($context (ping-context))
        ($result (collapse (match &self $context $context)))
      )  ; Explicitly capture match result
    (if (not (== $result ()))
        (ping-action)
        ("No match found")
    )
  )
)
;; Start the ping simulation
!(run-component)