!(register-module! ../../../../../../hyperon-openpsi)
;!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:math)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:ts-ucb:math)

;ts-ucb

!(assertEqual (min_list_with_index (5 2 8 1 9)) (1 3))
!(assertEqual (min_list_with_index (3)) (3 0))
!(assertEqual (min_list_with_index (1.5 0.5 2.0 0.5)) (0.5 1))
!(assertEqual (min_list_with_index (100 50 75)) (50 1))

!(assertEqual (sum_list (1 2 3 4 5)) 15)
!(assertEqual (sum_list (10)) 10)
!(assertEqual (sum_list ()) 0)
!(assertEqual (sum_list (1.5 2.5 3.0)) 7.0)
!(assertEqual (sum_list (-1 2 -3 4)) 2)