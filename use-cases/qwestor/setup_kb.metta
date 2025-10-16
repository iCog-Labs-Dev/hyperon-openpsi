(= (populateRuleSpace $ruleSpace) 
    (add-reduct $ruleSpace (superpose (
        ;; r1: initiate dialogue when conversation starts
((: r1 
    ((TTV 1 (STV 0.8 0.7)) 
      (IMPLICATION_LINK 
        (AND_LINK ((Goal Conversation-Started 0.9 0.6) initiate-dialogue)) 
        (Goal Send-Greeting 1.0 1.0))))
  3)

;; r2: collect information after greeting
((: r2 
    ((TTV 1 (STV 0.75 0.65)) 
      (IMPLICATION_LINK 
        (AND_LINK ((Goal Send-Greeting 1.0 1.0) gather-information)) 
        (Goal Information-Collected 1.0 1.0))))
  4)

;; r3: analyze after collecting information
((: r3 
    ((TTV 1 (STV 0.7 0.6)) 
      (IMPLICATION_LINK 
        (AND_LINK ((Goal Information-Collected 1.0 1.0) analyze-data)) 
        (Goal Insights-Extracted 1.0 1.0))))
  3)

;; r4: generate summary after insights are extracted
((: r4 
    ((TTV 1 (STV 0.68 0.6)) 
      (IMPLICATION_LINK 
        (AND_LINK ((Goal Insights-Extracted 1.0 1.0) summarize-findings)) 
        (Goal Summary-Ready 1.0 1.0))))
  3)

;; r5: prepare report after summary is ready
((: r5 
    ((TTV 1 (STV 0.7 0.65)) 
      (IMPLICATION_LINK 
        (AND_LINK ((Goal Summary-Ready 1.0 1.0) compile-report)) 
        (Goal Report-Prepared 1.0 1.0))))
  2)

;; r6: send report after preparation
((: r6 
    ((TTV 1 (STV 0.8 0.7)) 
      (IMPLICATION_LINK 
        (AND_LINK ((Goal Report-Prepared 1.0 1.0) deliver-results)) 
        (Goal Report-Sent 1.0 1.0))))
  2)

;; r7: reflect after sending report
((: r7 
    ((TTV 1 (STV 0.75 0.65)) 
      (IMPLICATION_LINK 
        (AND_LINK ((Goal Report-Sent 1.0 1.0) self-reflect)) 
        (Goal Reflection-Complete 1.0 1.0))))
  4)

        
    )))
)

(= (addDemandGoalRels $space)
    (add-reduct $space (superpose (

        ;; Affiliation → initiating social engagement
        (: affiliation (Goal Send-Greeting 1.0 1.0))

        ;; Competence → mastering the process of collecting and structuring knowledge
        (: competence (Goal Information-Collected 1.0 1.0))
        (: competence (Goal Summary-Ready 1.0 1.0))

        ;; Certainty → ensuring understanding and extracting insights
        (: certainty (Goal Insights-Extracted 1.0 1.0))

        ;; Integrity → ensuring that the work is documented and reported accurately
        (: integrity (Goal Report-Prepared 1.0 1.0))

        ;; Affiliation again → sharing outcomes for social and collaborative connection
        (: affiliation (Goal Report-Sent 1.0 1.0))

        ;; Energy → reflection and rejuvenation after completing intellectual work
        (: energy (Goal Reflection-Complete 1.0 1.0))
    
    )))

)

(= (populateDemandSpace $demandspace) 
   (add-reduct $demandspace 
    (superpose 
      (
        (demand affiliation 0.5) 
        (demand energy 0.9) 
        (demand competence 0.9)
        (demand certainty 0.1)
        (demand integrity 1.0)
        )
      )
    )
   )