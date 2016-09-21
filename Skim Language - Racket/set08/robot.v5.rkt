;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname robot.v5) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
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
(define DIR-LIST (list NE SE SW NW))
;; costant for invalid move
(define INVALID-MOVE (list "invalid" 1))

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


;; invalid move is represented by (list "invalid" 1), where direction is set to "invalid"
;; to check if robot ends with no possible move to reach target block

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
(define (path startpos endpos lop)
  (local
    ((define plan
       (get-plan "" (next-dir-to-move startpos endpos) 0 startpos endpos lop '()
                 startpos)))
(if (invalid-plan? plan)
        false
        (remove-rep plan))))

;; TESTS:
;; constants
(define wall1
  '((0 3)(2 3)(4 3)
    (0 5)     (4 5)
    (0 7)(2 7)(4 7)))
(define wall2
  '((-3 4)(-3 2)(-3 0)(-3 2)
    (-1 4)            (-1 2)
    (1 4)              (1 2)
    (3 4) (3 -2) (3 0)(3 2)))
(define two-walls
  '((0 3)(4 3)
    (0 5)(4 5)
    (0 7)(4 7)
    (0 9)(4 9)
    (0 11)(4 11)))

(begin-for-test
  (check-equal? (path '(0 0) '(-2 -2) '()) (list (list "nw" 2)))
  (check-equal? (path '(0 0) '(0 2) '()) (list '("ne" 1) '("se" 1)))
  (check-equal? (path '(0 0) '(10 2) '())
                (list (list "se" 3) (list "sw" 1) (list "se" 1) (list "sw" 1)
                      (list "se" 1) (list "sw" 1) (list "se" 1) (list "sw" 1)))
  (check-false (path '(0 0) '(1 -2) '())))

;; invalid-plan? : 
(define (invalid-plan? plan)
  (ormap
   ;; Move -> Boolean
   ;; GIVEN: A move
   ;; RETURNS: true iff move is invalid
   (lambda (mv) (equal? (move-dir mv) (move-dir INVALID-MOVE)))
   plan))

;; remove-rep : Plan -> Plan
;; GIVEN:   A Plan of the robot moves
;; WHERE:   plan contains the repetative moves if robot moved single direction multiple
;;          times
;; RETURNS: A plan similar to original one, but successive moves on single direction
;;          are combined together
;; EXAMPLES: see tests below

;; STRATEGY: call more general function
(define (remove-rep plan)
  (remove-successive-rep (first plan) (rest plan)))

;; TESTS:
;; constants for testing
(define plan
  (list '("ne" 1) '("ne" 2) '("ne" 3)
        '("se" 1) '("se" 2) '("se" 3)
        '("ne" 1) '("se" 1) '("sw" 1)
        '("se" 4) '("nw" 1) '("nw" 2)))
(define result-plan
  (list '("ne" 3) '("se" 3) '("ne" 1)
        '("se" 1) '("sw" 1) '("se" 4)
        '("nw" 2)))

(begin-for-test
  (check-equal? (remove-rep plan) result-plan))

;; remove-successive-rep : Move Plan -> Plan
;; GIVEN:
;;          1. Previous move pre
;;          2. Plan representing the next moves done by robot
;; WHERE:   pre represent previous move before the plan
;; RETURNS: plan after removing successive repetation of move in same direction
;; EXAMPLES: see tests below

;; STRATEGY: general recursion on plan
;; HALTING MEASURE:
;; TERMINATION ARGUMENT:
(define (remove-successive-rep pre plan)
  (cond
    [(empty? plan) (list pre)]
    [else
     (if (equal? (move-dir pre) (move-dir (first plan)))
         (remove-successive-rep (first plan) (rest plan))
         (append (list pre) (remove-successive-rep (first plan) (rest plan))))]))

;; TESTS:
(begin-for-test
  (check-equal? (remove-successive-rep '("ne" 1) (list '("ne" 2) '("ne" 3)))
                (list '("ne" 3)))
  (check-equal? (remove-successive-rep '("ne" 1) '()) (list '("ne" 1))))

;; get-plan :
;;      Direction Direction PosInt Position Position ListOfPosition ListOfPosition -> Plan
;; GIVEN:
;;          1. Previous moves direction
;;          2. Direction to move
;;          3. Previous moves step
;;          4. The starting position of the robot
;;          5. The target position of the robot
;;          6. A list of the blocks on the board
;;          8. A list of blocks previously traversed
;; RETURNS: the plan of moves for the next move
;; EXAMPLES:

;; STRATEGY:
;; HALTING MEASURE:
;; TERMINATION ARGUMENT: 
(define (get-plan predir curdir stepcnt curpos endpos lop prevpos instartpos)
  (if (and (equal? curdir "invalid") (equal? instartpos curpos))
      (list INVALID-MOVE lop)
      (local
        ((define unreachable? (unreachable-block? curpos endpos))
         (define nextpos (get-next-pos curpos curdir)))
        (if (list-contains? lop nextpos)
            (change-plan predir curdir stepcnt curpos endpos lop prevpos instartpos)
            (if unreachable?
                (list INVALID-MOVE)
                (if (equal? nextpos endpos)
                    (if (equal? curdir predir)
                        (cons (list curdir (+ 1 stepcnt)) empty)
                        (cons (list curdir STEP) empty))
                    (move-next predir curdir stepcnt curpos endpos nextpos lop
                               prevpos instartpos)))))))

;; move-next : 
(define (move-next predir curdir stepcnt curpos endpos nextpos lop
                   prevpos instartpos)
  (local
    ((define blockeddirs (get-blocked-dirs curpos lop DIR-LIST))
     (define next-dir (next-dir-to-move nextpos endpos)))
    (if (equal? curdir predir)
        (append (list (list curdir (+ 1 stepcnt)))
                (get-plan
                 curdir next-dir (+ 1 stepcnt) nextpos endpos lop
                 curpos instartpos))
        (append (list (list curdir STEP))
                (get-plan
                 curdir next-dir STEP nextpos endpos lop
                 curpos instartpos)))))

;; change-plan :
;;      Direction Direction PosInt Position Position Position ListOfPosition
;;      ListOfPosition -> Plan
;; GIVEN:
;;          1. Previous moves direction
;;          2. Direction to move
;;          3. Previous moves step
;;          4. The starting position of the robot
;;          5. The target position of the robot
;;          6. Blocked position
;;          7. A list of the blocks on the board 
;; RETURNS: the changed plan since the nextpost was blocked
;; EXAMPLES:
(define (change-plan predir curdir stepcnt curpos endpos lop prevpos instartpos)
  (local
    ((define blockeddirs (get-blocked-dirs curpos lop DIR-LIST))
     (define restartdir (change-dir blockeddirs))
     (define newlop (append (list prevpos) (list instartpos) lop))
     (define blocked-dir-cnt (blocked-dirs curpos newlop DIR-LIST 0))
     (define movabledir (get-movable-dir curpos newlop DIR-LIST)))
    (cond
      [(= 3 blocked-dir-cnt) (get-plan curdir movabledir
                                       stepcnt curpos
                                       endpos (append (list curpos) lop) prevpos
                                       instartpos)]
      [(= 4 blocked-dir-cnt)
       (if (equal? curpos instartpos)
           (list INVALID-MOVE)
           (get-plan "" restartdir 0 instartpos endpos (append (list curpos) lop) '()
                     instartpos))]
      [(equal? restartdir "invalid")
       (list INVALID-MOVE)]
      [else (get-plan curdir movabledir stepcnt curpos endpos lop prevpos instartpos)])))

#;(path '(0 0) '(-2 -2) '((-1 -1) (-1 1) (1 1) (1 -1)))
#;(path (list 0 -1) (list 2 3) '((-2 -1) (-2 1) (0 1) (2 1) (2 -1) (2 -3) (0 -3) (-2 -3)))

;; change-dir : Direction -> Direction
;; GIVEN:   a direction
;; RETURNS: new direction based on previous moves at given position
;; EXAMPLES: see tests below

;; STRATEGY: using cases on olddir
(define (change-dir prev-dirs)
  (cond
    [(not (list-contains? prev-dirs NE)) NE]
    [(not (list-contains? prev-dirs SE)) SE]
    [(not (list-contains? prev-dirs SW)) SW]
    [(not (list-contains? prev-dirs NW)) NW]
    [else "invalid"]))

;; blocked-dirs : Position ListOfPosition ListOfDirection NonNegInt -> NonNegInt
(define (blocked-dirs curpos lob dirs mvcnt)
  (cond
    [(empty? dirs) mvcnt]
    [else
     (if
      (list-contains? lob (get-next-pos curpos (first dirs)))
      (blocked-dirs curpos lob (rest dirs) (+ mvcnt 1))
      (blocked-dirs curpos lob (rest dirs) mvcnt))]))

;; TESTS:
;; constants for testing
(define corner-blocks '((1 2) (3 2) (3 0)))
(define wall-blocks-1 '((-1 2) (1 2)))
(define wall-blocks-2 '((-2 -3) (0 -3)))
(define prevpos '(1 0))
(define prevpos-1 '(-2 -1))
(define starpos '(0 -1))

(begin-for-test
  (check-equal?
   (blocked-dirs '(2 1)
                 (append (list prevpos) (list starpos) corner-blocks) DIR-LIST 0) 4)
  (check-equal?
   (blocked-dirs '(0 1)
                 (append (list prevpos) (list starpos) wall-blocks-1) DIR-LIST 0) 3)
  (check-equal?
   (blocked-dirs '(-1 -2)
                 (append (list prevpos-1) (list starpos) wall-blocks-2) DIR-LIST 0) 4))

;; get-movable-dir : Position ListOfPosition ListOfDirection -> MaybeDirection
(define (get-movable-dir curpos lob dirs)
  (cond
    [(empty? dirs) "invalid"]
    [else
     (if
      (not (list-contains? lob (get-next-pos curpos (first dirs))))
      (first dirs)
      (get-movable-dir curpos lob (rest dirs)))]))

;; TESTS:
(begin-for-test
  (check-equal?
   (get-movable-dir '(0 1) (append (list prevpos) (list starpos) wall-blocks-1) DIR-LIST)
   NW)
  (check-equal?
   (get-movable-dir '(2 1) (append (list prevpos) (list starpos) corner-blocks) DIR-LIST)
   "invalid"))

;; list-contains? : ListOfX X -> Boolean
;; GIVEN:   a list of X
;; RETURNS: true iff the list contains X
;; EXAMPLES: see tests below

;; STRATEGY: using HOF ormap on lst
(define (list-contains? lst x)
  (ormap
   ;; X -> Boolean
   (lambda (nx) (equal? nx x))
   lst))

;; TESTS:
;; constant for testing
(define block-list (list (list 1 5) (list 4 2) (list 3 10) (list 2 8)))

(begin-for-test
  (check-equal? (list-contains? block-list (list 3 10)) #t)
  (check-equal? (list-contains? block-list (list 3 15)) #f))

;; get-next-pos : Position Direction -> Position
;; GIVEN:
;;          1. the starting position of the robot,
;;          2. direction to move next
;; RETURNS: next position of the robot based on the direction
;; EXAMPLES: see tests below

;; STARTEGY: using cases on dir
(define (get-next-pos curpos dir)
  (cond
    [(equal? dir NE) (list (- (pos-x curpos) 1) (+ (pos-y curpos) 1))]
    [(equal? dir SE) (list (+ (pos-x curpos) 1) (+ (pos-y curpos) 1))]
    [(equal? dir SW) (list (+ (pos-x curpos) 1) (- (pos-y curpos) 1))]
    [(equal? dir NW) (list (- (pos-x curpos) 1) (- (pos-y curpos) 1))]))

;; TESTS:
(begin-for-test
  (check-equal? (get-next-pos '(0 0) NE) '(-1 1))
  (check-equal? (get-next-pos '(0 0) SE) '(1 1))
  (check-equal? (get-next-pos '(0 0) SW) '(1 -1))
  (check-equal? (get-next-pos '(0 0) NW) '(-1 -1)))

;; get-movable-dirs : Position ListOfPosition ListOfDirection -> MaybeDirection
(define (get-blocked-dirs curpos lob dirs)
  (cond
    [(empty? dirs) empty]
    [else
     (if
      (list-contains? lob (get-next-pos curpos (first dirs)))
      (append (list (first dirs)) (get-blocked-dirs curpos lob (rest dirs)))
      (get-blocked-dirs curpos lob (rest dirs)))]))

;; next-dir-to-move : Position Position -> Direction
;; GIVEN:
;;          1. the cuurent position of the robot,
;;          2. the target position that robot is supposed to reach
;; RETURNS: direction for next step
;; EXAMPLES: see tests below

;; STRATEGY: using cases on curpos and endpos
(define (next-dir-to-move curpos endpos)
  (cond
    [(and (<= (pos-x endpos) (pos-x curpos)) (>= (pos-y endpos) (pos-y curpos))) NE]
    [(and (>= (pos-x endpos) (pos-x curpos)) (>= (pos-y endpos) (pos-y curpos))) SE]
    [(and (>= (pos-x endpos) (pos-x curpos)) (<= (pos-y endpos) (pos-y curpos))) SW]
    [(and (<= (pos-x endpos) (pos-x curpos)) (<= (pos-y endpos) (pos-y curpos))) NW]))

;; TESTS:
(begin-for-test
  (check-equal? (next-dir-to-move '(0 0) '(-2 2)) NE)
  (check-equal? (next-dir-to-move '(0 0) '(2 2)) SE)
  (check-equal? (next-dir-to-move '(0 0) '(2 -2)) SW)
  (check-equal? (next-dir-to-move '(0 0) '(-2 -2)) NW)
  (check-equal? (next-dir-to-move '(0 0) '(0 2)) NE))

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

(path (list 0 -1) (list 2 3) '((-2 -1) (-2 1) (0 1) (2 1) (2 -1) (2 -3) (0 -3)))