!(register-module! ../../../hyperon-openpsi)
!(register-module! ../../utilities-module)

!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:use-cases:qwestor:helpers)
!(import! &self hyperon-openpsi:use-cases:qwestor:setup_kb)
!(bind! &ruleSpace (new-space))

!(populateRuleSpace &ruleSpace)

!(assertEqual (checkRuleFromSpace 
                ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal ambiguous_query 0.9 0.6) assess_scope)) (Goal optimal_research_strategy 1.0 1.0)))
                &ruleSpace) True)
!(assertEqual (checkRuleFromSpace 
                ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal new_query 0.9 0.6) assess_scope)) (Goal optimal_research_strategy 1.0 1.0)))
                &ruleSpace) False)
!(assertEqual (checkRuleFromSpace ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal old_query 0.9 0.2) assess_scope)) (Goal optimal_new_strategy 1.0 1.0)))
                                  &ruleSpace) False)
