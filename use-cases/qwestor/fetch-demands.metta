!(register-module! ../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:demand:demand)
!(import! &self hyperon-openpsi:use-cases:qwestor:out)

(= (fetchDemandsFromDb)
    (match &self (demands $demands) $demands)
)
!(fetchDemandsFromDb)
