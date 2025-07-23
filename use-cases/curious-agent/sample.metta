!(import! &self utils) 

(= (loop) (
    let* (

        ($userInput (pyModule getUserInput ()))
        ($response (pyModule generateResponse ($userInput)))
        (($content $summary) (extractTuple $response))
    )
    (
        response :: ($content $summary)
    )
))

(= (extractTuple $response) 
   (let* (
        ($messages ((py-dot $response __getitem__) "messages"))
        ($message ((py-dot $messages __getitem__) -1))
        ($content (py-dot $message content))
        ($summary ((py-dot $response __getitem__) "summary"))
        )
        ($content $summary)
     )
   )

!(loop)
