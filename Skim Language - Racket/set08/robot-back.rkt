;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname robot-back) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;(check-location "08" "robot.rkt")

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

;(provide path)
;(provide eval-plan)

;=========================================================================================
;                                      CONSTANTS
;=========================================================================================
;; constant for move step
(define STEP 1)
;; constants for directions
(define NE "ne")
(define SE "se")
(define NW "nw")
(define SW "sw")

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

;; get-complete-path : Position Position ListOfPosition Direction Move -> MaybePlan
;; GIVEN:
;;          1. the starting position of the robot,
;;          2. the target position that robot is supposed to reach
;;          3. A list of the blocks on the board
;;          4. direction to move next 
;;          5. previous move
;; RETURNS: a plan that, when executed, will take the robot from
;;          the starting position to the target position without passing over any
;;          of the blocks, or false if no such sequence of moves exists.
;; EXAMPLES:

;; STRATEGY: 
(define (get-complete-path startpos endpos lop dir premove)
  (cond
    [(equal? dir NE)
     (if (equal? NE (move-dir premove))
         (cons (list dir (+ 1 (move-step premove)))
           (get-complete-path
            (get-next-pos startpos dir) endpos lop
            (next-dir-to-move startpos endpos) (list dir (+ 1 (move-step premove)))))
         (cons (list dir STEP)
           (get-complete-path
            (get-next-pos startpos dir) endpos lop
            (next-dir-to-move startpos endpos) (list dir STEP))))]
    [(equal? dir SE)]
    [(equal? dir NW)]
    [(equal? dir SW)]))

;;
(define (get-plan pre-dir cur-dir prev-step startpos endpos lop)
  (if (equal? cur-dir pre-dir)
         (cons (list cur-dir (+ 1 prev-step))
           (get-complete-path
            (get-next-pos startpos cur-dir) endpos lop
            (next-dir-to-move startpos endpos) (list cur-dir (+ 1 prev-step))))
         (cons (list cur-dir STEP)
           (get-complete-path
            (get-next-pos startpos cur-dir) endpos lop
            (next-dir-to-move startpos endpos) (list cur-dir STEP)))))

;; get-next-pos : Position Direction -> Position
;; GIVEN:
;;          1. the starting position of the robot,
;;          2. direction to move next
;; RETURNS: next position of the roboat based on the direction
;; EXAMPLES: see tests below

;; STARTEGY: using cases on dir
(define (get-next-pos startpos dir)
  (cond
    [(equal? dir NE) (list (+ (pos-x startpos) 1) (- (pos-y startpos) 1))]
    [(equal? dir SE) (list (+ (pos-x startpos) 1) (+ (pos-y startpos) 1))]
    [(equal? dir SW) (list (- (pos-x startpos) 1) (+ (pos-y startpos) 1))]
    [(equal? dir NW) (list (- (pos-x startpos) 1) (- (pos-y startpos) 1))]))

;; TESTS:
(begin-for-test
  (check-equal? (get-next-pos '(1 2) NE) '(2 1))
  (check-equal? (get-next-pos '(1 2) SE) '(2 3))
  (check-equal? (get-next-pos '(1 2) SW) '(0 3))
  (check-equal? (get-next-pos '(1 2) NW) '(0 1)))

;; next-dir-to-move : Position Position -> Direction
;; GIVEN:
;;          1. the cuurent position of the robot,
;;          2. the target position that robot is supposed to reach
;; RETURNS: direction for next step
;; EXAMPLES: see tests below

;; STRATEGY: using cases on curpos and endpos
(define (next-dir-to-move curpos endpos)
  (cond
    [(and (>= (pos-x endpos) (pos-x curpos)) (<= (pos-y endpos) (pos-y curpos))) NE]
    [(and (>= (pos-x endpos) (pos-x curpos)) (>= (pos-y endpos) (pos-y curpos))) SE]
    [(and (<= (pos-x endpos) (pos-x curpos)) (>= (pos-y endpos) (pos-y curpos))) SW]
    [(and (<= (pos-x endpos) (pos-x curpos)) (<= (pos-y endpos) (pos-y curpos))) NW]))

;; TESTS:
(begin-for-test
  (check-equal? (next-dir-to-move '(1 2) '(2 1)) NE)
  (check-equal? (next-dir-to-move '(1 2) '(2 3)) SE)
  (check-equal? (next-dir-to-move '(1 2) '(0 3)) SW)
  (check-equal? (next-dir-to-move '(1 2) '(0 1)) NW)
  (check-equal? (next-dir-to-move '(1 2) '(3 2)) NE))

;; unreachable-block? : Position Position -> Boolean
;; GIVEN:
;;          1. the cuurent position of the robot,
;;          2. the target position that robot is supposed to reach
;; RETURNS: true iff the target block is unreachable adjacent block
;; EXAMPLES: see tests below

;; STRATEGY: using cases on curpos and endpos
(define (unreachable-block? curpos endpos)
  (or
   (equal? (list (+ (pos-x curpos) 1) (pos-y curpos)) endpos)
   (equal? (list (- (pos-x curpos) 1) (pos-y curpos)) endpos)
   (equal? (list (pos-x curpos) (+ (pos-y curpos) 1)) endpos)
   (equal? (list (pos-x curpos) (- (pos-y curpos) 1)) endpos)))

;; TESTS:
(begin-for-test
  (check-equal? (unreachable-block? '(2 1) '(1 1)) #t)
  (check-equal? (unreachable-block? '(2 1) '(2 2)) #t)
  (check-equal? (unreachable-block? '(2 1) '(3 1)) #t)
  (check-equal? (unreachable-block? '(2 1) '(2 0)) #t)
  (check-equal? (unreachable-block? '(2 1) '(1 1)) #t)
  (check-equal? (unreachable-block? '(2 1) '(2 5)) #f))

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