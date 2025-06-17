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
(: state-var Variable)  ; Use Variable for pattern matching

;; Set initial ball state
!(add-atom &self (State ball neutral))

;; Define ping goal
!(addGoal ping 0.0 1.0 &self)  ; Goal 'ping' with initial value 0.0 and desired value 1.0
!(setGv ping 1.0 &self)        ; Set urge to 1.0 to trigger the action

;; Define ping action
(: ping-action (-> Atom))
(= (ping-action)
  (let* (($result (State ball pinged))
         ($add-result (add-atom &self $result))
         ($set-ping (setGv ping 0.0 &self)))  ; Reset urge after action
    (trace! "Just pinged" $result)))  ; Output confirmation

;; Define ping context
(: ping-context (-> Expression))
(= (ping-context)
  (addAndLink
    (State ball state-var)
    (Equal state-var neutral)))

;; Add ping rule
!(addRule ping-rule (ping-context) (ping-action) ping (STV 1.0 1.0))

;; Add ping component
!(addCategory ping-component)
!(addToCategory ping-rule ping-component)

;; Simulate running the ping component
(: run-component (-> Symbol Atom))
(= (run-component $component)
  (let* (($context (ping-context))
         ($match-result (collapse (match &self $context $context))))
    (if (not (== $match-result ()))
      (ping-action)
      (trace! "No match found" ()))))

;; Define run-loop with a limited number of iterations
(: run-loop (-> Number Atom))
(= (run-loop $iteration)
  (if (< $iteration 1)  ; Run once for ping
    (let $result (run-component ping-component)
      (run-loop (+ $iteration 1)))
    (trace! "Ping simulation complete" ())))

;; Start the ping simulation
!(trace! "Starting ping simulation..." ())
!(run-loop 0)