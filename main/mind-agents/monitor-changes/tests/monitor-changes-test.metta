!(register-module! ../../../../../hyperon-openpsi)
!(register-module! ../../../../utilities-module)

!(import! &self hyperon-openpsi:main:mind-agents:monitor-changes:monitor-changes)
!(import! &self hyperon-openpsi:main:mind-agents:perception-updater:perception-updater)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)

!(import! &self utilities-module:utils)

;!(fetchMaxCycle &self)
!(assertEqual (setPreviousTime' (40 20 15 10) 40 10) 20)
;!(removePrevChanges &self)
!(assertEqual (setPreviousTime 40 (10 15 20 40)) (20 40) )

;!(addPredicate has-dramatic-changes &self)
;!(let $x (superpose (1 2 3)) (addPredicate $x))
!(assertEqual (setPreviousTime (fetchMaxCycle &self) (1 2 3 4) ) ((default-value) 0))

!(bind! &t (new-space))
!(update-drmtc-chng-tv (Predicate has-dramatic-changes) &t (STV 0 0))
!(update-drmtc-chng-tv (Predicate has-dramatic-changes) &t (STV 1.0 1.0))
!(assertEqual (get-atoms &t) ((Predicate has-dramatic-changes) (STV 1.0 1.0)))

(LIST_LINK (L1 A))
(REFERENCE_LINK (
                 (Predicate change-with-tv)
                 (LIST_LINK (L1 A)) 
                 )
                )

!(removePrevChanges &self REFERENCE_LINK) ;running this function should remove the REFERENCE_LINK added.
!(assertEqual (match &self (REFERENCE_LINK $x) $x) (empty))



!(bind! &z (new-space))
!(record-changes-tv &z ((L1 A) (L2 A)))
!(record-changes-arg &z (L1 L2 ))
!(assertEqual (collapse (get-atoms &z))  
((LIST_LINK (L1 A)) (LIST_LINK (L1 L2)) (LIST_LINK (L2 A)) (ReferenceLink ((Predicate change-with-tv) (LIST_LINK (L1 A)))) (ReferenceLink ((Predicate change-with-tv) (LIST_LINK (L2 A)))) (ReferenceLink ((Predicate change-with-arg) (LIST_LINK (L1 L2))))))
