(: addGameRules (-> hyperon::space::DynSpace Expression))
(= (addGameRules $space) (
    add-reduct $space 
        (superpose (
            (: Rule 1
                (TTV 0)
                (STV 0.5 0.002)  
                (Complexity 1)
                (Context ((Position CLOSE_RANGE)))
                (Action (ATTACK SWORD))
                (Goal (HIT))  
            )

            (: Rule 2
                (TTV 0)
                (STV 0.5 0.002) 
                (Complexity 1)
                (Context ((Position CLOSE_RANGE)))
                (Action (ATTACK BOW))
                (Goal (HIT))   
            )

            (: Rule 3
                (TTV 0)
                (STV 0.5 0.002) 
                (Complexity 1)
                (Context ((Position CLOSE_RANGE)))
                (Action (CAST FIREBALL))
                (Goal (HIT))  
            )

            (: Rule 4
                (TTV 0)
                (STV 0.5 0.002) 
                (Complexity 1)
                (Context ((Position MID_RANGE)))
                (Action (ATTACK SWORD))
                (Goal (HIT))   
            )

            (: Rule 5
                (TTV 0)
                (STV 0.5 0.002)  
                (Complexity 1)
                (Context ((Position MID_RANGE)))
                (Action (ATTACK BOW))
                (Goal (HIT))  
            )

            (: Rule 6
                (TTV 0)
                (STV 0.5 0.002)  
                (Complexity 1)
                (Context ((Position MID_RANGE)))
                (Action (CAST FIREBALL))
                (Goal (HIT))  
            )

            (: Rule 7
                (TTV 0)
                (STV 0.5 0.002) 
                (Complexity 1)
                (Context ((Position LONG_RANGE)))
                (Action (ATTACK SWORD))
                (Goal (HIT))  
            )

            (: Rule 8
                (TTV 0)
                (STV 0.5 0.002) 
                (Complexity 1)
                (Context ((Position LONG_RANGE)))
                (Action (ATTACK BOW))
                (Goal (HIT))  
            )

            (: Rule 9
                (TTV 0)
                (STV 0.5 0.002) 
                (Complexity 1)
                (Context ((Position LONG_RANGE)))
                (Action (CAST FIREBALL))
                (Goal (HIT))  
            )
        ))
))