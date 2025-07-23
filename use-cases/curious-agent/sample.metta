!(import! &self utils) 

; !(pyModule main ())
(= (loop) (
    let* (

        ($userInput (pyModule getUserInput ()))
        ($response (pyModule generateResponse ($userInput)))
    )
    (
        response :: $response
    )
))

!(loop)