!(register-module! ../../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:mind-agents:demand-updater:demand-updaters)

; due to the randomness of CertaintyDemandUpdater and AffiliationDemandUpdater we have range of return values 
!(assertEqual (and (> (CertaintyDemandUpdater  (10 20 30  40 50) 25) 0.80) (< (CertaintyDemandUpdater  (10 20 30  40 50) 25) 1.07)) True)
!(assertEqual (and (> (AffiliationDemandUpdater  (10 20 30) 25) 0.74) (< (AffiliationDemandUpdater  (10 20 30) 25) 1.02)) True)
!(assertEqual (CompetenceDemandUpdater 12 20 ) 0.1182933591140401)
!(assertEqual (CompetenceDemandUpdater 12 4) 0.6)

