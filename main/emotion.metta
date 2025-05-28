;; !(register-module! ../utilities-module)
;; !(import! &self utilities-module:utils)

!(bind! &emotion-space (new-space))

;;Data definition for emotion
(: Emotion Type)

;;The below is a constructor on emotion 
(: emotion (-> Atom Number Emotion))
;; Extracts the string value of an emotion
(= (getEmotionString $list)
  (let (emotion $x $_) (superpose $list) $x)
)


;; This function checks if the emotion exists in the space
;; You give it a space contains abstracted emotions and the emotion
;; to be created and checks if the string exists regardless of the value

(= (isAvailable?  $emotion-space $emotion)
    (let* (
        ((emotion $x $y) $emotion)
        ($emotions (get-emotions $emotion-space)) 
        ($emotStrings (collapse (getEmotionString $emotions)))
        (() (println! (emotStrings $emotStrings)))
    )
        (isMember $x $emotStrings)  
    )
)

;; creates new emotion after checking it doesn't exist
;; in the emotion space and if it fulfills the pattern of 
;; what an emotion should look like
(= (create-emotion $emotion-space $emotion)
    (unify $emotion (emotion $y $x)
            (if (isAvailable? $emotion-space $emotion)
                (ERROR is Available)
                (add-atom $emotion-space $emotion) 
            )
            (ERROR Wrong Format)
    )
    
)

;;This function fetches emotions from the
;;emotion space. Otherwise, returns an empty tuple
(= (get-emotions $emotion-space)
    (collapse (match $emotion-space $x $x))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Tests For emotion.metta                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; !(create-emotion &emotion-space (emotion anger 0))
;; !(create-emotion &emotion-space (emotion data 0))
;; !(create-emotion &emotion-space (emotion anger 0))
;; !(isAvailable? &emotion-space (emotion anger 0))
;; !(match &emotion-space $x $x)
;; !(create-emotion &emotion-space data)
;; !(get-emotions &emotion-space)
;; !(getEmotionString (get-emotions &emotion-space))
;; !(get-atoms &emotion-space)