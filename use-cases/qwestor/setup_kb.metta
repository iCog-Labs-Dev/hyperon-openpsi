(= (populateRuleSpace $ruleSpace) 
    (add-reduct $ruleSpace (superpose (
        ((: r1
            ((TTV 1 (STV 0.8 0.7))
                (IMPLICATION_LINK
                (AND_LINK ((Goal Conversation-Started 0.9 0.6) initiate-dialogue))
                (Goal Send-Greeting 1.0 1.0))))
         4)
         ((: r2
                ((TTV 1 (STV 0.9 0.8))
                (IMPLICATION_LINK
                (AND_LINK ((Goal Task-Assigned 1.0 1.0) (Belief Knowledge-Gap 0.9 0.7)))
                (Goal Acquire-Information 1.0 0.9))))
         5)
        ((: r3
        ((TTV 1 (STV 0.85 0.75))
            (IMPLICATION_LINK
            (AND_LINK ((Goal Execute-Task 1.0 1.0) (Belief Uncertain-Understanding 0.8 0.7)))
            (Goal Clarify-Concepts 1.0 0.9))))
        5)


        ((: r4
        ((TTV 1 (STV 0.9 0.8))
            (IMPLICATION_LINK
            (Goal Completed-Research-Step 1.0 1.0)
            (Goal Document-Reasoning 1.0 1.0))))
            4)
((: r5
   ((TTV 1 (STV 0.95 0.9))
    (IMPLICATION_LINK
      (AND_LINK ((Goal Share-Result 1.0 1.0) (Belief Ethical-Concern 0.8 0.6)))
      (Goal Validate-Ethics 1.0 0.9))))
 6)

((: r6
   ((TTV 1 (STV 0.85 0.8))
    (IMPLICATION_LINK
      (AND_LINK ((Goal Task-Completed 1.0 1.0) (Belief Performance-Suboptimal 0.8 0.6)))
      (Goal Self-Improve 1.0 0.9))))
 5)

        
    )))
)

(= (addDemandGoalRels $space)
    (superpose (

        ;; Social connection and collaboration
        (: affiliation (Goal Send-Greeting 1.0 1.0))

        ;; Renewal and optimization
        (: energy (Goal Self-Improve 1.0 0.9))

        ;; Mastery and learning
        (: competence (Goal Acquire-Information 1.0 0.9))

        ;; Understanding and reducing uncertainty
        (: certainty (Goal Clarify-Concepts 1.0 0.9))

        ;; Ethical and cognitive consistency
        (: integrity (Goal Validate-Ethics 1.0 0.9))
    
    ))

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