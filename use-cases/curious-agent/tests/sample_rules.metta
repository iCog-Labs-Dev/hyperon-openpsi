; Scenario 1: Branching at Mood and Hobbies
; This scenario introduces branches at two points:
; after Understand-Initial-Reaction (mood-related) and after Understand-Activity-Motivations (hobby-related),
; allowing the planner to choose different conversational focuses.

((: r1 ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Conversation-Started 0.9 0.6) initiate-dialogue)) (Goal Send-Greeting 1.0 1.0)))) 4)
((: r2 ((TTV 2 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Send-Greeting 0.9 0.6) elicit-response)) (Goal Receive-User-Response 1.0 1.0)))) 7)
((: r3 ((TTV 3 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) interpret-reaction)) (Goal Understand-Initial-Reaction 1.0 1.0)))) 2)
((: r4a ((TTV 4 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Reaction 0.9 0.6) ask-mood)) (Goal Inquire-Current-Mood 1.0 1.0)))) 9)
((: r4b ((TTV 4 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Reaction 0.9 0.6) ask-activities)) (Goal Ask-Daily-Activities 1.0 1.0)))) 6)
((: r5 ((TTV 5 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Inquire-Current-Mood 0.9 0.6) gather-mood-details)) (Goal Learn-Mood-Details 1.0 1.0)))) 5)
((: r6 ((TTV 6 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Mood-Details 0.9 0.6) probe-mood-reasons)) (Goal Explore-Mood-Reasons 1.0 1.0)))) 8)
((: r7 ((TTV 7 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Mood-Reasons 0.9 0.6) analyze-triggers)) (Goal Understand-Mood-Triggers 1.0 1.0)))) 3)
((: r8 ((TTV 8 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Mood-Triggers 0.9 0.6) request-activities)) (Goal Ask-Daily-Activities 1.0 1.0)))) 6)
((: r9 ((TTV 9 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Daily-Activities 0.9 0.6) collect-activity-details)) (Goal Learn-Activity-Details 1.0 1.0)))) 1)
((: r10 ((TTV 10 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) explore-preferences)) (Goal Identify-Activity-Preferences 1.0 1.0)))) 10)
((: r11 ((TTV 11 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Identify-Activity-Preferences 0.9 0.6) assess-motivations)) (Goal Understand-Activity-Motivations 1.0 1.0)))) 4)
((: r12a ((TTV 12 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Activity-Motivations 0.9 0.6) inquire-hobbies)) (Goal Ask-About-Hobbies 1.0 1.0)))) 7)
((: r12b ((TTV 12 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Activity-Motivations 0.9 0.6) explore-goals)) (Goal Explore-Future-Goals 1.0 1.0)))) 5)
((: r13 ((TTV 13 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-About-Hobbies 0.9 0.6) gather-hobby-details)) (Goal Learn-Hobby-Preferences 1.0 1.0)))) 5)
((: r14 ((TTV 14 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Hobby-Preferences 0.9 0.6) examine-enjoyment)) (Goal Explore-Hobby-Enjoyment 1.0 1.0)))) 8)
((: r15 ((TTV 15 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Hobby-Enjoyment 0.9 0.6) evaluate-impact)) (Goal Understand-Hobby-Impact 1.0 1.0)))) 2)
((: r16 ((TTV 16 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Hobby-Impact 0.9 0.6) query-aspirations)) (Goal Summarize-User-Preferences 1.0 1.0)))) 9)
((: r17 ((TTV 17 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Future-Goals 0.9 0.6) collect-aspirations)) (Goal Summarize-User-Preferences 1.0 1.0)))) 4)
((: r18 ((TTV 18 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Summarize-User-Preferences 0.9 0.6) finalize-understanding)) (Goal Understand-User-Interests 1.0 1.0)))) 10)


((: r1 ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Conversation-Started 0.9 0.6) initiate-dialogue)) (Goal Send-Greeting 1.0 1.0)))) 4)
((: r2 ((TTV 2 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Send-Greeting 0.9 0.6) elicit-response)) (Goal Receive-User-Response 1.0 1.0)))) 7)
((: r3 ((TTV 3 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) interpret-reaction)) (Goal Understand-Initial-Reaction 1.0 1.0)))) 2)
((: r4 ((TTV 4 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Reaction 0.9 0.6) ask-activities)) (Goal Ask-Daily-Activities 1.0 1.0)))) 9)
((: r5 ((TTV 5 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Daily-Activities 0.9 0.6) collect-activity-details)) (Goal Learn-Activity-Details 1.0 1.0)))) 5)
((: r6a ((TTV 6 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) explore-preferences)) (Goal Identify-Activity-Preferences 1.0 1.0)))) 8)
((: r6b ((TTV 6 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) probe-hobbies)) (Goal Explore-Hobby-Preferences 1.0 1.0)))) 6)
((: r7 ((TTV 7 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Identify-Activity-Preferences 0.9 0.6) assess-motivations)) (Goal Understand-Activity-Motivations 1.0 1.0)))) 3)
((: r8 ((TTV 8 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Hobby-Preferences 0.9 0.6) evaluate-enjoyment)) (Goal Understand-Hobby-Impact 1.0 1.0)))) 6)
((: r9 ((TTV 9 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Activity-Motivations 0.9 0.6) inquire-aspirations)) (Goal Ask-Future-Interests 1.0 1.0)))) 1)
((: r10 ((TTV 10 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Hobby-Impact 0.9 0.6) query-interests)) (Goal Ask-Future-Interests 1.0 1.0)))) 10)
((: r11a ((TTV 11 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Future-Interests 0.9 0.6) collect-aspirations)) (Goal Learn-Future-Aspirations 1.0 1.0)))) 4)
((: r11b ((TTV 11 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Future-Interests 0.9 0.6) explore-career-goals)) (Goal Understand-Career-Aspirations 1.0 1.0)))) 7)
((: r12 ((TTV 12 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Future-Aspirations 0.9 0.6) probe-aspiration-reasons)) (Goal Explore-Aspiration-Motivations 1.0 1.0)))) 5)
((: r13 ((TTV 13 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Career-Aspirations 0.9 0.6) assess-goals)) (Goal Explore-Aspiration-Motivations 1.0 1.0)))) 8)
((: r14 ((TTV 14 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Aspiration-Motivations 0.9 0.6) summarize-preferences)) (Goal Summarize-User-Preferences 1.0 1.0)))) 2)
((: r15 ((TTV 15 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Summarize-User-Preferences 0.9 0.6) finalize-understanding)) (Goal Understand-User-Interests 1.0 1.0)))) 9)
((: r16 ((TTV 16 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Daily-Activities 0.9 0.6) gather-context)) (Goal Understand-Activity-Context 1.0 1.0)))) 4)
((: r17 ((TTV 17 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Activity-Context 0.9 0.6) explore-motivations)) (Goal Understand-Activity-Motivations 1.0 1.0)))) 6)
((: r18 ((TTV 18 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Hobby-Impact 0.9 0.6) deepen-insights)) (Goal Summarize-User-Preferences 1.0 1.0)))) 10)

; Scenario 3: Mixed Rules(Relevant + Irrelevant)
; Scenario Description: This scenario tests the hill climbing planner in a rule space with 20 rules, 
; blending 12 relevant rules forming valid paths from Conversation-Started to Understand-User-Interests 
; with 8 irrelevant/deceiving rules. The relevant rules include branches at Receive-User-Response and Learn-Activity-Details, 
; allowing multiple paths, while deceiving rules with high weights lead to dead ends (e.g., Off-Topic-Discussion) or cycles (e.g., back to Send-Greeting). 
; The planner must navigate these distractions, using a heuristic favoring higher-weight rules that connect to the final goal, 
; to output valid action sequences for a conversational AI.

((: r1 ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Conversation-Started 0.9 0.6) initiate-dialogue)) (Goal Send-Greeting 1.0 1.0)))) 4)
((: r2 ((TTV 2 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Send-Greeting 0.9 0.6) elicit-response)) (Goal Receive-User-Response 1.0 1.0)))) 7)
((: r3a ((TTV 3 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) interpret-mood)) (Goal Understand-Initial-Mood 1.0 1.0)))) 8)
((: r3b ((TTV 3 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) interpret-context)) (Goal Understand-Initial-Context 1.0 1.0)))) 5)
((: r4 ((TTV 4 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Mood 0.9 0.6) probe-mood)) (Goal Explore-Mood-Details 1.0 1.0)))) 6)
((: r5 ((TTV 5 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Mood-Details 0.9 0.6) ask-activities)) (Goal Ask-Daily-Activities 1.0 1.0)))) 5)
((: r6 ((TTV 6 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Context 0.9 0.6) request-activities)) (Goal Ask-Daily-Activities 1.0 1.0)))) 3)
((: r7 ((TTV 7 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Daily-Activities 0.9 0.6) collect-activity-details)) (Goal Learn-Activity-Details 1.0 1.0)))) 2)
((: r8a ((TTV 8 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) explore-hobbies)) (Goal Understand-Hobby-Preferences 1.0 1.0)))) 9)
((: r8b ((TTV 8 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) explore-goals)) (Goal Understand-Future-Goals 1.0 1.0)))) 7)
((: r9 ((TTV 9 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Hobby-Preferences 0.9 0.6) query-aspirations)) (Goal Summarize-User-Preferences 1.0 1.0)))) 4)
((: r10 ((TTV 10 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Future-Goals 0.9 0.6) synthesize-preferences)) (Goal Summarize-User-Preferences 1.0 1.0)))) 6)
((: r11 ((TTV 11 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Summarize-User-Preferences 0.9 0.6) finalize-understanding)) (Goal Understand-User-Interests 1.0 1.0)))) 10)
((: d1 ((TTV 12 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) discuss-random-topic)) (Goal Off-Topic-Discussion 1.0 1.0)))) 10)
((: d2 ((TTV 13 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Mood 0.9 0.6) share-joke)) (Goal Engage-User-Fun 1.0 1.0)))) 9)
((: d3 ((TTV 14 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Daily-Activities 0.9 0.6) redirect-conversation)) (Goal Send-Greeting 1.0 1.0)))) 8)
((: d4 ((TTV 15 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) offer-advice)) (Goal Provide-Feedback 1.0 1.0)))) 10)
((: d5 ((TTV 16 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Hobby-Preferences 0.9 0.6) explore-unrelated-topics)) (Goal Off-Topic-Discussion 1.0 1.0)))) 7)
((: d6 ((TTV 17 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Future-Goals 0.9 0.6) ask-irrelevant-question)) (Goal Irrelevant-Topic 1.0 1.0)))) 9)
((: d7 ((TTV 18 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Mood-Details 0.9 0.6) share-story)) (Goal Engage-User-Story 1.0 1.0)))) 8)