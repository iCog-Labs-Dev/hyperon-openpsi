!(import! &self general-helpers)
; 32-bit modulus constant representing 2^32
(= MOD32 4294967296)

; MT19937-specific parameters
(= N 624)                   ; Size of the state array
(= M 397)                   ; Middle term offset for twisting
(= UPPER_MASK 2147483648)   ; 0x80000000 - Upper 31 bits mask
(= LOWER_MASK 2147483647)   ; 0x7fffffff - Lower 31 bits mask
(= MATRIX_A 2567483615)     ; 0x9908b0df - Magic constant for tempering

; ############################################################################# Helper Functions ##############################################################

; Ensures a number stays within 32-bit range
(= (mod32 $x) (% $x 4294967296))

; Extracts the least significant bit of a number
(= (lsb $x) (% $x 2))

; Simulates a right shift by n bits
; Returns: Number - $x shifted right by $n bits

(= (bit-shift-right $x $n) (/ $x (pow-math 2 $n)))

; Simulates a left shift by n bits, keeping within 32 bits
; Returns: Integer - $x shifted left by $n bits, modulo 2^32

(= (bit-shift-left $x $n) (% (* $x (pow-math 2 $n)) 4294967296))

; Performs a bitwise AND operation recursively
; Returns: Integer - Bitwise AND of $x and $y, modulo 2^32

(= (bit-and $x $y)
  (if (= (+ $x $y) 0)
      0
      (let* (($lsbx (lsb $x))
             ($lsby (lsb $y))
             ($low (* $lsbx $lsby))  ; Ensure bit is 0 or 1
             ($rest (bit-and (bit-shift-right $x 1) (bit-shift-right $y 1)))
             ($result (+ $low (* 2 $rest))))  ; Combine: low + 2 * rest
        $result)))

; Performs a bitwise XOR operation recursively
; Returns: Integer - Bitwise XOR of $x and $y, modulo 2^32

(= (bit-xor $x $y)
   (if (== (+ $x $y) 0)
       0
       (let* (
         ($low (% (+ (lsb $x) (lsb $y)) 2))          ; XOR of least significant bits (sum mod 2)
         ($rest (bit-xor (bit-shift-right $x 1) (bit-shift-right $y 1)))  ; Recurse on remaining bits
         ($result (mod32 (+ $low (bit-shift-left $rest 1))))
       )
       $result)))  ; Reconstruct number

; ##################################################################################### State Initialization ########################################################

; Loops to initialize state array elements from index 1 to N-1
; Returns: String - "state-ready"

(= (init-state-loop $i)
   (if (<= N $i)                                   ; Corrected condition to <=
       ("state-ready")                ; Return error if index exceeds N
       (let* (
         ($prev (match &self ((mt (- $i 1)) $v) $v))  ; Previous state value
         ($temp (bit-xor $prev (bit-shift-right $prev 30)))  ; XOR with right shift
         ($new (mod32 (+ (* 1812433253 $temp) $i)))  ; MT19937 formula
         ($_ (add-atom &self ((mt $i) $new)))         ; Store new value
         ($new_i (+ $i 1))
       )
       (init-state-loop $new_i))))

; Initializes the state array with a given seed
; Returns: String - "init-complete"

(= (init-state $seed)
   (let* (
     ($init (mod32 $seed))                        ; Initial state value
     ($_ (add-atom &self ((mt 0) $init)))          ; Set mt[0]
     ($_2 (init-state-loop 1))                     ; Fill rest of the array
     ($_3 (add-atom &self (index 0)))              ; Set initial index
   ) ("init-complete")))


; ##################################################################################### State Twisting ############################################################

; Updates the state array for the next set of random numbers
; $i: Integer - Current index
; Returns: String - "twisted"
(= (twist-loop $i)
   (if (<= N $i)                                   ; Corrected condition to <=
       ("twisted")
       (let* (
         ($val_i (match &self ((mt $i) $v) $v))      ; mt[i]
         ($val_i1 (match &self ((mt (% (+ $i 1) N)) $v) $v))  ; mt[i+1] with wraparound
         ($val_m (match &self ((mt (% (+ $i M) N)) $v) $v))   ; mt[i+M] with wraparound
         ($y (+ (bit-and $val_i UPPER_MASK) (bit-and $val_i1 LOWER_MASK)))  ; Combine upper and lower bits
         ($yshr (bit-shift-right $y 1))              ; Right shift by 1
         ($mat (if (== (% $y 2) 0) 0 MATRIX_A))      ; Conditional matrix application
         ($t (bit-xor $yshr $mat))                   ; XOR with matrix
         ($new (bit-xor $val_m $t))                  ; Final new value
         ($_ (add-reduct &self ((mt $i) (mod32 $new))))  ; Update state
         ($new_i (+ $i 1))
       )
       (twist-loop $new_i))))

; Triggers the twist operation
; Returns: String - "twisted"
(= (twist)
   (let* (
     ($_ (twist-loop 0))                           ; Start twisting from index 0
     ($_2 (add-atom &self (index 0)))              ; Reset index
   ) ("twisted")))

; ########################################################################################## Number Extraction ##############################################################

; Applies tempering transformation to improve randomness
; Returns: Integer - Tempered value, modulo 2^32

(= (temper $y)
   (let* (
     ($y1 (bit-xor $y (bit-shift-right $y 11)))   ; First tempering step
     ($y2 (bit-xor $y1 (bit-and (bit-shift-left $y1 7) 2636928640)))  ; Second step with mask 0x9D2C5680
     ($y3 (bit-xor $y2 (bit-and (bit-shift-left $y2 15) 4022730752))) ; Third step with mask 0xEFC60000
     ($y4 (bit-xor $y3 (bit-shift-right $y3 18))) ; Final tempering step
   ) (mod32 $y4)))

; Extracts the next random number and updates the index
; Returns: Integer - Tempered random number


(= (extract-number)
   (let* (
     ($idx (match &self (index $v) $v))           ; Current index
     ($y (if (== $idx 0)                          ; If index is 0, twist first
             (let* (
               ($_tw (twist))
               ($v0 (match &self ((mt 0) $v) $v))
             ) $v0)
             (match &self ((mt $idx) $v) $v)))    ; Otherwise, get current value
     ($t (temper $y))                             ; Temper the value
     ($_ (add-atom &self (index (% (+ $idx 1) N)))) ; Increment index with wraparound
   ) $t))

; ############################################################################### Public Function  ############################################################

; Seeds the generator with an initial value
; Returns: String - "init-complete"

(= (seed $value)
   (init-state $value))

; Generates a random integer in the range [a, b]
; Returns: Integer - Random number between $a and $b


(= (random-int $a $b)
   (let* (
     ($range (+ (- $b $a) 1))                     ; Range size
     ($num (extract-number))                      ; Raw random number
     ($scaled (% $num $range))                    ; Scale to range
   ) (+ $a $scaled)))



; Generates a random float in the range [a, b)
; Returns: Float - Random number between $a and $b


(= (random-float $a $b)
  (let* (
     ($range (+ (- $b $a) 1))
     ($num (extract-number))
     ($scale (/ $num $range)))
   (+ $a $scale)
   ))
###################################################################################### Testing ################################################################
!(random-int 1 100)
!(random-float 0.0 100.0)