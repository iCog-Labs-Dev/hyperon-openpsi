!(register-module! ../../../../../hyperon-openpsi)
!(register-module! ../../../../utilities-module)

!(import! &self hyperon-openpsi:main:mind-agents:monitor-changes:monitor-changes)
!(import! &self hyperon-openpsi:main:mind-agents:monitor-changes:monitor-changes-helpers)
!(import! &self hyperon-openpsi:main:mind-agents:perception-updater:perception-updater)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)

!(import! &self utilities-module:utils)

;;Test setPreviousTime function
!(assertEqual (setPreviousTime (10 15 20 40)) (20 40))

;;Test update-drmtc-chng-tv function that updates the predicate (Predicate has-dramatic-changes)
!(bind! &t (new-space))
!(update-drmtc-chng-tv (Predicate has-dramatic-changes) &t (STV 0 0))
!(update-drmtc-chng-tv (Predicate has-dramatic-changes) &t (STV 1.0 1.0))
!(assertEqual (get-atoms &t) ((Predicate has-dramatic-changes) (STV 1.0 1.0)))

!(bind! &z (new-space))
!(record-changes-tv &z ((L1 A) (L2 A)))
!(record-changes-arg &z (L1 L2 ))
!(assertEqual (collapse (get-atoms &z))  
              (
                (LIST_LINK (L1 A)) (LIST_LINK (L1 L2)) (LIST_LINK (L2 A)) 
                (REFERENCE_LINK ((Predicate change-with-tv) (LIST_LINK (L1 A)))) 
                (REFERENCE_LINK ((Predicate change-with-tv) (LIST_LINK (L2 A)))) 
                (REFERENCE_LINK ((Predicate change-with-arg) (LIST_LINK (L1 L2))))
              )
)

;monitor-changes test
!(bind! &test-space (new-space)) 
!(addRule &test-space a (a1 a2) action g (TTV 10 (STV 0.1 0.1)))
!(addRule &test-space b (b1 b2) action g (TTV 40 (STV 0.1 0.1)))
!(addRule &test-space c (c1 c2) action g (TTV 20 (STV 0.1 0.1)))
!(addRule &test-space d (d1 d2) action g (TTV 15 (STV 0.1 0.1)))
!(addRule &test-space e (e1 e2) action g (TTV 13 (STV 0.1 0.1)))

(= (kb) (superpose 
          (
            (TimeValue 10 a)
            (TimeValue 40 b)
            (TimeValue 20 c)
            (TimeValue 15 d)
            (TimeValue 13 e)

            (TimeValue 15 a)
            (TimeValue 45 b)
            (TimeValue 25 b)
            (TimeValue 20 d)
            (TimeValue 18 e)
          )
        )
)

!(add-reduct &test-space (kb))
!(add-atom &test-space (tv_delta 0.1)) ;add the minimum threshold value for acceptable tv change

!(monitor-changes &test-space)
!(let $res (match &test-space ((Predicate has-dramatic-change) $tv) $tv) (assertEqual $res (STV 1.0 1.0)))
!(let $res (collapse (match &test-space (REFERENCE_LINK $change) $change)) (assertEqual (((Predicate change-with-tv) (LIST_LINK (b b)))) $res))
