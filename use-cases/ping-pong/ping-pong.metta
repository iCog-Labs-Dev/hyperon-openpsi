!(register-module! ../../../hyperon-openpsi)
!(register-module! ../../utilities-module)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)

;; Define truth values
(= (FALSE_TV) (False (STV 0.0 1.0)))
(= (TRUE_TV) (True (STV 1.0 1.0)))

;; Define ball states with explicit types
(: neutral Concept)
(: pinged Concept)
(: ponged Concept)
(: ball Concept)

;; Set initial ball state
!(add-atom &psiRules (State ball neutral))
!(trace! "Initial ball state set to neutral" ())

;; Define goals
!(addGoal ping 0.0 1.0 &psiRules)
!(setGv ping 0.0 &psiRules)
!(addGoal pong 0.0 1.0 &psiRules)
!(setGv pong 0.0 &psiRules)

;; Ping action: neutral -> pinged
(: ping-action (-> Atom))
(= (ping-action)
  (let* (($old-state (match &psiRules (State ball $current) (State ball $current)))
         ($remove-old (if (not (== $old-state ())) (remove-atom &psiRules $old-state) (empty)))
         ($result (State ball pinged))
         ($add-result (add-atom &psiRules $result))
         ($set-ping (setGv ping 0.0 &psiRules))
         ($set-pong (setGv pong 0.2 &psiRules)))
    (trace! "Just pinged" $result)))

;; Ping context: triggers when state is neutral
(: ping-context Expression)
(= (ping-context)
  (AndLink (State ball neutral)))

;; Pong action: pinged -> ponged -> neutral
(: pong-action (-> Atom))
(= (pong-action)
  (let* (($old-state (match &psiRules (State ball $current) (State ball $current)))
         ($remove-old (if (not (== $old-state ())) (remove-atom &psiRules $old-state) (empty)))
         ($result (State ball ponged))
         ($add-result (add-atom &psiRules $result))
         ($set-pong (setGv pong 0.2 &psiRules))
         ($set-ping (setGv ping 1.0 &psiRules))
         ($remove-ponged (remove-atom &psiRules $result))
         ($reset-state (add-atom &psiRules (State ball neutral))))
    (trace! "Just ponged" $result)))

;; Pong context: triggers when state is pinged and urge is 0.8
(: pong-context Expression)
(= (pong-context)
  (AndLink (State ball pinged)))

;; Pong stepper: increments urge until 0.8
(: pong-step (-> Atom))
(= (pong-step)
  (let* (($urge (goal-value pong &psiRules))
         ($trace-urge (trace! ("Pong urge =" $urge) ())))
    (if (< $urge 0.8)
      (let* (($result ())
             ($trace-result (trace! ("Not yet ponging. Urge =" $urge) $result))
             ($set-result (setGv pong (+ $urge 0.2) &psiRules)))
        $result)
      (let* (($trace-result (trace! ("Ready to pong. Urge =" $urge) ()))
             ($result (pong-action) )
             ($ping-result (ping-action)))
             $result)
        )))

;; Add rules
!(addRule &psiRules ping-rule ping-context (ping-action) ping (STV 1.0 1.0))
!(addCategory ping-component)
!(addToCategory ping-rule ping-component)

!(addRule &psiRules pong-rule pong-context (pong-action) pong (STV 1.0 1.0))
!(addCategory pong-component)
!(addToCategory pong-rule pong-component)

;; Run component: executes ping or pong logic
(: run-component (-> Symbol Atom))
(= (run-component $component)
  (if (== $component ping-component)
    (let* (($context ping-context)
           ($match-result (collapse (match &psiRules $context $context))))
      (if (not (== $match-result ())) (ping-action) ()))
    (pong-step)))

;; Run loop: alternates ping and pong for 16 steps
(: run-loop (-> Number Atom))
(= (run-loop $iteration)
  (if (< $iteration 16)
    (let* (($pong-result (run-component pong-component))
           ($ping-result (run-component ping-component)))
      (run-loop (+ $iteration 1)))
    (trace! "Simulation complete" ())))

!(trace! "Starting ping-pong simulation..." ())
!(run-loop 0)