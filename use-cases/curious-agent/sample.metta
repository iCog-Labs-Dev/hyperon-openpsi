!(import! &self utils) 

(= (loop) 
   (let* (
        ($userInput (pyModule getUserInput ()))
        ($response (pyModule generateResponse ($userInput)))
        (($content $summary) (extractTuple $response))
        ;($rules (getRules))
        ;($rule (pyModule correlation_matcher ($summary $rules $content)))
        ;($emotion (pyModule psi-agent-loop ($rule &kb)))
        ;($res (pyModule generateResponse ($emotion)))
      )
      (
        if(== $userInput "exit")
          ()
          (loop)
      )
    )
   )

(= (extractTuple $response) 
   (let* (
          ($messages ((py-dot $response get) "messages" ""))
          ($last_message ((py-dot $messages __getitem__) -1))
          ($content (py-dot $last_message content))
          ($summary ((py-dot $response get) "summary" ""))
        )
        ($content $summary)
     )
   )

!(loop)
