;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname robot) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;(check-location "08" "robot.rkt")

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

;(provide path)
;(provide eval-plan)

;=========================================================================================
;                                      CONSTANTS
;=========================================================================================
;; constant for move initial step
(define INIT-STEP 1)

;=========================================================================================
;                                      DATA DEFINITIONS
;=========================================================================================
;; A Position is a (list Integer Integer)
;; INTERPRETATION:
;; (list x y) represents the position (x,y).
;; WHERE: x and y represents column and row of the robot on the chessboard

;; A Direction is one of
;; -- "ne"
;; -- "se"
;; -- "sw"
;; -- "nw"

;; A Move is a (list Direction PosInt)
;; INTERPRETATION:
;; a move of the specified number of steps in the indicated direction.
;; WHERE: Direction is the digonal direction on which robot moved and PosInt represents
;;        the step

;; A Plan is a ListOfMove
;; WHERE: the list does not contain two consecutive moves in the same
;; direction.
;; INTERPRETATION:
;; the moves are to be executed from the first in the list to the last in the list.

;=========================================================================================
;                                      FUNCTIONS
;=========================================================================================
;; path : Position Position ListOfPosition -> MaybePlan
;; GIVEN:
;;          1. the starting position of the robot,
;;          2. the target position that robot is supposed to reach
;;          3. A list of the blocks on the board
;; RETURNS: a plan that, when executed, will take the robot from
;;          the starting position to the target position without passing over any
;;          of the blocks, or false if no such sequence of moves exists.
;; EXAMPLES:

;; STRATEGY: 
#;(define (path startpos endpos lop)
  )

;; get-complete-path : Position Position ListOfPosition Move -> MaybePlan
;; GIVEN:
;;          1. the starting position of the robot,
;;          2. the target position that robot is supposed to reach
;;          3. A list of the blocks on the board
;;          4. previous move
;; RETURNS: a plan that, when executed, will take the robot from
;;          the starting position to the target position without passing over any
;;          of the blocks, or false if no such sequence of moves exists.
;; EXAMPLES:

;; STRATEGY: 
(define (get-complete-path startpos endpos lop pre-move)
  (cond
    [(not (string=? (move-dir pre-move) "ne"))
     (local
       ()
       (if (equal? startpos endpos)
           (cons (move-northeast startpos endpos lop pre-move) empty)
           (get-complete-path startpos endpos lop '("ne" 0))))]
    [(not (string=? (move-dir pre-move) "se"))
     (local
       ()
       (if (equal? startpos endpos)
           (cons (move-southeast startpos endpos lop pre-move) empty)
           (get-complete-path startpos endpos lop '("se" 0))))]
    [(not (string=? (move-dir pre-move) "nw"))
     (cons pre-move empty)]
    [(not (string=? (move-dir pre-move) "sw"))
     (cons pre-move empty)]))

;; move-northeast : Position Position ListOfPosition Move -> MaybeMove
;; GIVEN:
;;          1. the starting position of the robot,
;;          2. the target position that robot is supposed to reach
;;          3. A list of the blocks on the board
;;          4. previous move
;; RETURNS: the move after moving robot at northeast direction
;; EXAMPLES: see tests below

;; STRATEGY:
(define (move-northeast startpos endpos lop pre-move)
  (local
    ((define nextpos (list (+ (pos-x startpos) 1) (- (pos-y startpos) 1))))
    (if (next-pos-blocked? lop nextpos)
        (get-complete-path startpos endpos lop pre-move)
        (cond
          [(equal? startpos endpos) pre-move]
          [(not (invalid-move? nextpos endpos "ne"))
           (move-northeast
            nextpos endpos lop
            (list (move-dir pre-move) (+ 1 (move-step pre-move))))]
          [else (get-complete-path nextpos endpos lop pre-move)]))))

;; TESTS:
(begin-for-test
  (check-equal? (move-northeast (list 4 5) (list 5 4) '() '("ne" 0)) '("ne" 1))
  (check-equal? (move-northeast (list 3 4) (list 5 2) '() '("ne" 0)) '("ne" 2)))


;; move-southeast : Position Position ListOfPosition Move -> MaybeMove
;; GIVEN:
;;          1. the starting position of the robot,
;;          2. the target position that robot is supposed to reach
;;          3. A list of the blocks on the board
;;          4. previous move
;; RETURNS: the move after moving robot at sotheast direction
;; EXAMPLES: see tests below

;; STRATEGY:
(define (move-southeast startpos endpos lop pre-move)
  (local
    ((define nextpos (list (+ (pos-x startpos) 1) (+ (pos-y startpos) 1))))
    (if (next-pos-blocked? lop nextpos)
        (get-complete-path startpos endpos lop pre-move)
        (cond
          [(equal? startpos endpos) pre-move]
          [(not (invalid-move? nextpos endpos "se"))
           (move-southeast
            nextpos endpos lop
            (list (move-dir pre-move) (+ 1 (move-step pre-move))))]
          [else (get-complete-path nextpos endpos lop pre-move)]))))

;; TESTS:
(begin-for-test
  (check-equal? (move-southeast (list 4 3) (list 5 4) '() '("se" 0)) '("se" 1))
  (check-equal? (move-southeast (list 3 4) (list 5 6) '() '("se" 0)) '("se" 2)))

;; next-pos-blocked? : ListOfPosition Position -> Boolean
;; GIVEN:   a list of block positions and next position of robot
;; RETURNS: true iff next position is already blocked
;; EXAMPLES: see tests below

;; STRATEGY:
(define (next-pos-blocked? lop nextpos)
  (cond
    [(empty? lop) false]
    [else
     (if (and (= (pos-x nextpos) (pos-x (first lop)))
              (= (pos-y nextpos) (pos-y (first lop))))
         true
         (next-pos-blocked? (rest lop) nextpos))]))

;; TESTS:
;; constant for testing
(define block-list (list (list 1 5) (list 4 2) (list 3 10) (list 2 8)))

(begin-for-test
  (check-equal? (next-pos-blocked? block-list (list 3 10)) #t)
  (check-equal? (next-pos-blocked? block-list (list 3 15)) #f))

;; invalid-move? : Position Position Direction -> Boolean
;; GIVEN:
;;          1. the cuurent position of the robot,
;;          2. the target position that robot is supposed to reach
;;          3. direction of the robots next move
;; RETURNS: true iff the following move is make robot to cross the target block
;; EXAMPLES: see tests below

;; STRATEGY: using cases on dir
(define (invalid-move? curpos endpos dir)
  (cond
    [(string=? dir "ne")
     (and (< (pos-x endpos) (pos-x curpos)) (> (pos-y endpos) (pos-y curpos)))]
    [(string=? dir "se")
     (and (< (pos-x endpos) (pos-x curpos)) (< (pos-y endpos) (pos-y curpos)))]
    [(string=? dir "sw")
     (and (> (pos-x endpos) (pos-x curpos)) (< (pos-y endpos) (pos-y curpos)))]
    [(string=? dir "nw")
     (and (> (pos-x endpos) (pos-x curpos)) (> (pos-y endpos) (pos-y curpos)))]))

;; TESTS:
(begin-for-test
  (check-equal? (invalid-move? '(5 2) '(4 3) "ne") #t)
  (check-equal? (invalid-move? '(2 5) '(4 3) "ne") #f)
  (check-equal? (invalid-move? '(1 2) '(2 3) "nw") #t)
  (check-equal? (invalid-move? '(4 5) '(2 3) "nw") #f)
  (check-equal? (invalid-move? '(5 6) '(4 5) "se") #t)
  (check-equal? (invalid-move? '(2 3) '(4 5) "se") #f)
  (check-equal? (invalid-move? '(1 6) '(2 5) "sw") #t)
  (check-equal? (invalid-move? '(4 3) '(2 5) "sw") #f))

;; pos-x : Position -> Integer
;; GIVEN:   a Position
;; RETURNS: first element from the list which represents the column of the robot
(define (pos-x lst)
  (first lst))

;; pos-y : Position -> Integer
;; GIVEN:   a Position
;; RETURNS: second element from the list which represents the row of the robot
(define (pos-y lst)
  (second lst))

;; move-dir : Move -> Direction
;; GIVEN:   a Move
;; RETURNS: first element from the list which represents direction of the move
(define (move-dir mv)
  (first mv))

;; move-step : Move -> PosInt
;; GIVEN:   a Move
;; RETURNS: second element from the list which represents step for the move
(define (move-step mv)
  (second mv))
