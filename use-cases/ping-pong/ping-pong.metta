!(register-module! ../../../hyperon-openpsi)
!(register-module! ../../utilities-module)

!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)

;;!(import! &self utilities-module:utils)
;; Define truth values


(= (FALSE_TV) (False (STV 0.0 1.0)))  ; False, with maximum confidence
(= (TRUE_TV) (True (STV 1.0 1.0)))    ; True, with maximum confidence

;; Define ball states with explicit types
(: neutral Concept)
(: pinged Concept)
(: ponged Concept)
(: ball Concept)
(: state-var Variable)

;; Set initial ball state
!(add-atom! &psiRules (State ball neutral))

;; Define ping goal
!(addGoal ping 0.0 1.0 &psiRules)  ; Goal: ping, initial value: 0.0, desired value: 1.0
!(setGv ping 0.0 &psiRules)        ; Initialize ping urge to 0.0 to prevent premature trigger

;; Define pong goal
!(addGoal pong 0.0 1.0 &psiRules)  ; Goal: pong, initial value: 0.0, desired value: 1.0
!(setGv pong 0.0 &psiRules)

;; Define ping action
(: ping-action (-> Atom))
(= (ping-action)
  (let* (($result (State ball pinged))
         ($add-result (add-atom! &psirules $result))
         ($set-ping (setGv ping 0.0 &psiRules))
         ($set-pong (setGv pong (+ (goal-value pong &psiRules) 0.2) &psiRules)))  ; Increment pong urge
    (trace! "Just pinged" $result)))

;; Define ping context
(: ping-context (-> Expression))
(= (ping-context)
  (addAndLink
    (State ball state-var)
    (Equal state-var neutral)))

;; Add ping rule
!(addRule ping-rule (ping-context) (ping-action) ping (STV 1.0 1.0))
!(addCategory ping-component)
!(addToCategory ping-rule ping-component)

;; Define pong action
(: pong-action (-> Atom))
(= (pong-action)
  (let* (($result (State ball ponged))
         ($add-result (add-atom! &psiRules $result))
         ($set-pong (setGv pong 0.0 &psiRules))
         ($set-ping (setGv ping 1.0 &psiRules))
         ($reset-state (add-atom! &psiRules (State ball neutral))))
    (trace! "Just ponged" $result)))

;; Define pong context
(: pong-context (-> Expression))
(= (pong-context)
  (addAndLink
    (State ball state-var)
    (Equal state-var pinged)))

;; Define pong stepper
(: pong-step (-> Atom))
(= (pong-step)
  (let* (($urge (goal-value pong &psiRules))
          (trace! $urge ())
       )
    (if (< $urge 0.8)
      (let* (($result ())
             ($trace-result (trace! ("Not yet feeling like ponging the ball. Urge =" $urge) $result))
             ($set-result (setGv pong (+ $urge 0.2) &psiRules)))
        $result)
      (let* (($trace-result (trace! ("Feeling like ponging the ball. Urge =" $urge) ()))
             ($result (pong-action))
             ($result-pinged (ping-action))
             )
        $result))))

;; Add pong rule
!(addRule pong-rule (pong-context) (pong-action) pong (STV 1.0 1.0))
!(addCategory pong-component)
!(addToCategory pong-rule pong-component)

;; Define run-component
(: run-component (-> Symbol Atom))
(= (run-component $component)
  (if (== $component ping-component)
    (let* (($context (ping-context))
           ($match-result ((collapse (match &psiRules $context $context)))))
      (if (not (== $match-result ()))
        (ping-action)
        ()))
    (pong-step)))

;; Define run-loop to alternate ping and pong
(: run-loop (-> Number Atom))
(= (run-loop $iteration)
  (if (< $iteration 16)  ; Limit to 5 iterations
    (let* (($ping-result (setGv ping 1.0 &psiRules))  ; Trigger ping explicitly
           ($pong-result (run-component pong-component))  ; Check pong urge
           (if (== $pong-result (State ball ponged))
           ($ping-action-result (run-component ping-component)))  ; Execute ping if context matches
            )
      (run-loop (+ $iteration 1)))
    (trace! "Simulation complete" ())))

;; Start the ping-pong simulation
!(trace! "Starting ping-pong simulation..." ())
!(run-loop 0)