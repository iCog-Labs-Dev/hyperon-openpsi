!(register-module! ../../../hyperon-openpsi)

!(import! &self hyperon-openpsi:main:rules:rule)
;!(import! &self hyperon-openpsi:use-cases:ping-pong:ping)

!(ping-pong use-case experiment)


;; Define truth values
(= (FALSE_TV) (False (STV 0.0 1.0))) ; False, with maximum confidence
(= (TRUE_TV) (True (STV 1.0 1.0)))   ; True, with maximum confidence

;; Define ball states
(: pinged Concept)
(: ponged Concept)
(: ball Concept)
(: state-var State)

;; Define ping goal
!(addGoal ping 0.0 1.0 &self) ; Goal 'ping' with initial value 0.0 and desired goal value 1.0

;; Define ping action
(: ping-action (-> Atom))
(= (ping-action)
(
     ;(println! "Just pinged")
     (State ball pinged)
     (setGv ping 0.0 &self) ; Reset urge to 0.0 after action
     (setGv pong 1.0 &self) ; Increase pong urge to trigger pong
)
)
!(ping-action)
;; Define ping context
(= (ping-context)
   (addAndLink
     (State ball state-var)
     (Equal state-var ponged)))

;; Add ping rule
!(addRule ping-rule (ping-context) (ping) ping (STV 1.0 1.0))

;; Add ping component
!(addCategory ping-component)
!(addToCategory ping-rule ping-component)

;; Define pong goal
!(addGoal pong 0.0 1.0 &self) ; Goal 'pong' with initial value 0.0 and desired goal value 1.0

;; Define pong action
(: pong-action (-> Atom))
(= (pong-action)
   (
     ;(println! "Just ponged")
     (State ball ponged)
     (setGv pong 0.0 &self) ; Reset urge to 0.0 after action
     (setGv ping 1.0 &self) ; Increase-ve ping urge to trigger ping
  ))
!(pong-action)
;; Define pong context
(= (pong-context)
   (addAndLink
     (State ball state-var)
     (Equal state-var pinged)))

;; Define pong stepper
(: pong-step (-> Atom))
(= (pong-step)
   (let ($urge (goal-value pong &self))
     (if (< $urge 0.7)
       (let ()
         (println!  "Not yet feeling like ponging the ball.")
         (setGv pong (+ urge 0.2) &self)
         ())
       (let ()
         (println!"Feeling like ponging the ball. Urge" )
         (setGv pong (+ urge 0.2) &self)
         (match &self (AND_LINK ((pong-context) (pong))) (pong))
         ()))
     (STV 1 1)))
;; Define psi-get-satisfiable-rules (simplified for this context)

(: psi-get-satisfiable-rules (-> Symbol Expression))
(= (psi-get-satisfiable-rules $component)
  (let ($rules (collapse (match &psiRules (: $rule ($context $action $goal $link)) $rule)))
    (filter-atom $rules $r
      (let ($context (getContext $r))
        (not (== (collapse (match &self $context $context)) ()))))))
;; Define pong action selector
(: pong-action-selector (-> Atom))
(= (pong-action-selector)
   (psi-get-satisfiable-rules pong-component))

;; Add pong rule
!(addRule pong-rule (pong-context) (pong) pong (STV 1.0 1.0))

;; Add pong component
!(addCategory pong-component)
!(addToCategory pong-rule pong-component)


;; Simulate running ping and pong components
(: run-component (-> Symbol Atom))
(= (run-component $component)
   (if (== $component ping-component)
     (let* (($context (ping-context))
           ($action (ping-action)))
       (if (not (== (collapse (match &self $context $context)) ()))
         ($action)
         ()))
     (pong-step)
    )
)

;; Start the ping-pong simulation
!("Starting ping-pong simulation...")
!(run-component ping-component)
