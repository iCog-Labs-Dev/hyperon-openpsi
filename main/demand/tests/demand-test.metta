!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:main:demand:demand)

!(bind! &demandSpace (new-space))

!(addDemand &demandSpace energy 0.6)
!(addDemand &demandSpace affiliation 0.5)
!(addDemand &demandSpace competence 0.2)
!(skipDemand &demandSpace competence)


!(assertEqual (exists-In &demandSpace (demand energy 0.6)) True)
!(assertEqual (exists-In &demandSpace (demand competence 0.2)) True)
!(assertEqual (getAllDemands &demandSpace )  ((demand energy 0.6) (demand affiliation 0.5) (demand competence 0.2)))
!(assertEqual (exists-In &demandSpace (skip competence)) True)

!(setDemandValue &demandSpace energy 0.8)
!(assertEqual (exists-In &demandSpace (demand energy 0.6)) False)
!(assertEqual (exists-In &demandSpace (demand energy 0.8)) True)

!(assertEqual (fetch-demand &demandSpace energy)  (demand energy 0.8))
!(assertEqual (fetch-demand-val &demandSpace energy) 0.8)
!(assertEqual (getEnabledDemands &demandSpace) ((demand energy 0.8) (demand affiliation 0.5) ))
