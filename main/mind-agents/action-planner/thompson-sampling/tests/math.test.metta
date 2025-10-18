!(register-module! ../../../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:math)

;; Unit tests for math functions
!(assertEqual (isBetween 5 1 10) True)
!(assertEqual (isBetween 0 1 10) False)

!(assertEqual (max 5 10) 10)
!(assertEqual (min 5 10) 5)
!(assertEqual (round 3.14159 2) 3.14)

!(assertEqual (let $val (getRandomInt 1 3) (isBetween $val 1 3)) True)
!(assertEqual (let $val (getRandom) (isBetween $val 0 1)) True)
!(assertEqual (log 1) 0)
!(assertEqual (sqrt 4) 2)
!(assertEqual (exp 0) 1)

!(assertEqual (let $val (betaSample 20.0 10.0) (isBetween $val 0 1)) True)