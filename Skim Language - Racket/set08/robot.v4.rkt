;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname robot.v4) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
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

;=========================================================================================
;                                      DATA DEFINITIONS
;=========================================================================================
;; A Position is a (list Integer Integer)
;; INTERPRETATION:
;; (list x y) represents the position (x,y).
;; WHERE: x and y represents column and row of the robot on the chessboard

;; constants for testing
(define prevpos '(1 0))
(define prevpos-1 '(-2 -1))
(define starpos '(0 -1))

;; List Of Position is (ListOfPosition) is one of
;; -- empty
;; -- (cons p ListOfPosition)
;; INTERPRETATION:
;; empty represents the empty list
;; (cons p ListOfPosition) represents the list of Position with newly added position p

;; constants for testing
(define corner-blocks '((1 2) (3 2) (3 0)))
(define wall-blocks-1 '((-1 2) (1 2)))
(define wall-blocks-2 '((-2 -3) (0 -3)))
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

;; constants for testing
(define plan
  (list '("ne" 1) '("ne" 1) '("ne" 1)
        '("se" 1) '("se" 1) '("se" 1)
        '("ne" 1) '("se" 1) '("sw" 1)
        '("se" 1) '("nw" 1) '("nw" 1)))
(define result-plan
  (list '("ne" 3) '("se" 3) '("ne" 1)
        '("se" 1) '("sw" 1) '("se" 1)
        '("nw" 2)))


;; forward directions are directions where robot can go next excluding the reverse
;; direction where robot come. Ex. if robot at position 1 moves "se" to reach position 2,
;; then forward directions are "ne", "se" and "sw" excluding "nw" since it will go to
;; to previous position by moving "nw" direction

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
;; EXAMPLES: see tests below

;; STRATEGY: using more general function
(define (path startpos endpos lop)
  (local
    ((define plan
       (get-plan "" (next-dir-to-move startpos endpos) startpos endpos lop '()
                 startpos '())))
    (if (equal? false plan)
        false
        (remove-rep plan))))

;; TESTS:
(begin-for-test
  (check-equal? (path '(0 0) '(-2 -2) '()) (list (list "nw" 2)))
  (check-equal? (path '(0 0) '(0 2) '()) (list '("ne" 1) '("se" 1)))
  (check-equal? (path '(0 0) '(10 2) '())
                (list (list "se" 3) (list "sw" 1) (list "se" 1) (list "sw" 1)
                      (list "se" 1) (list "sw" 1) (list "se" 1) (list "sw" 1)))
  (check-false (path '(0 0) '(1 -2) '()))
  (check-false (path '(0 0) '(-2 -2) '((-1 -1) (-1 1) (1 1) (1 -1))))
  (check-equal? (path '(0 0) '(-2 -2) '((-1 1) (1 1) (1 -1))) '(("nw" 2)))
  (check-false (path (list 0 -1) (list 2 3) '((-2 -1) (-2 1) (0 1) (2 1) (2 -1)
                                                      (2 -3) (0 -3) (-2 -3))))
  (check-equal? (path (list 0 -1) (list 2 3) '((-2 1) (0 1) (2 1) (2 -1)
                                                      (2 -3) (0 -3) (-2 -3)))
                (list (list "ne" 1) (list "nw" 1) (list "ne" 2) (list "se" 3)
                      (list "sw" 1) (list "se" 1) (list "sw" 1)))
  (check-false (path (list 2 5) (list 2 6) empty))
  (check-false (path (list 2 5) (list 4 9) wall1)))

;; remove-rep : Plan -> Plan
;; GIVEN:   A Plan of the robot moves
;; WHERE:   plan contains the repetative moves if robot moved single direction multiple
;;          times
;; RETURNS: A plan similar to original one, but successive moves on single direction
;;          are combined together
;; EXAMPLES: see tests below

;; STRATEGY: call more general function
(define (remove-rep plan)
  (remove-successive-rep (first plan) (rest plan) 1))

;; TESTS:
(begin-for-test
  (check-equal? (remove-rep plan) result-plan))

;; remove-successive-rep : Move Plan PosInt -> Plan
;; GIVEN:
;;          1. Previous move pre
;;          2. Plan representing the next moves done by robot
;;          3. Step count for previous move
;; WHERE:   plan is a sub-plan of some large plan0 (oringial) and
;;          pre represent previous move in the plan0 just before the plan
;; RETURNS: plan after removing successive repetation of move in same direction
;; EXAMPLES: see tests below

;; STRATEGY: general recursion on plan
;; HALTING MEASURE:
;; TERMINATION ARGUMENT:
(define (remove-successive-rep pre plan stepcnt)
  (cond
    [(empty? plan) (list (list (move-dir pre) stepcnt))]
    [else
     (if (equal? (move-dir pre) (move-dir (first plan)))
         (remove-successive-rep (first plan) (rest plan) (+ 1 stepcnt))
         (append (list (list (move-dir pre) stepcnt))
                 (remove-successive-rep (first plan) (rest plan) 1)))]))

;; TESTS:
(begin-for-test
  (check-equal? (remove-successive-rep '("ne" 1) (list '("ne" 1) '("ne" 1)) 1)
                (list '("ne" 3)))
  (check-equal? (remove-successive-rep '("ne" 1) '() 1) (list '("ne" 1))))

;; get-plan :
;;      Direction Direction Position Position ListOfPosition Position Position
;;      Plan -> MaybePlan
;; GIVEN:
;;          1. Previous moves direction
;;          2. Direction to move
;;          3. The current position of the robot
;;          4. The target position of the robot
;;          5. A list of the blocks on the board
;;          6. The previous position of the robot
;;          7. The starting position of the robot
;;          8. Plan until the current position
;; RETURNS: the plan until robot arrives target position, if there is no possible
;;          way to reach target for robot then false
;; EXAMPLES: see tests below

;; STRATEGY: using general recursion
;; HALTING MEASURE:
;; TERMINATION ARGUMENT: 
(define (get-plan predir curdir curpos endpos lop prevpos instartpos preplan)
  (local
    ((define unreachable? (unreachable-block? curpos endpos))
     (define nextpos (get-next-pos curpos curdir STEP)))
    (if (list-contains? lop nextpos)
        (change-plan predir curdir curpos endpos lop prevpos instartpos preplan)
        (if unreachable?
            false
            (if (equal? nextpos endpos)
                (append preplan (list (list curdir STEP)))
                (move-next predir curdir curpos endpos nextpos lop prevpos instartpos
                           preplan))))))

;; move-next : Direction Direction Position Position Position ListOfPosition Position
;;             Position Plan -> MaybePlan
;; GIVEN:
;;          1. Previous moves direction
;;          2. Direction to move
;;          3. The current position of the robot
;;          4. The target position of the robot
;;          5. Next position to move
;;          6. A list of the blocks on the board
;;          7. The previous position of the robot
;;          8. The starting position of the robot
;;          9. Plan until the current position
;; RETURNS: the plan until robot arrives target position, if there is no possible
;;          way to reach target for robot then false
;; EXAMPLES: see tests below

;; STRATEGY: using general recursion
;; HALTING MEASURE:
;; TERMINATION ARGUMENT: 
(define (move-next predir curdir curpos endpos nextpos lop prevpos instartpos preplan)
  (local
    ((define blockeddirs (get-blocked-dirs curpos lop DIR-LIST))
     (define next-dir (next-dir-to-move nextpos endpos)))
    (get-plan
     curdir next-dir nextpos endpos lop
     curpos instartpos (append preplan (list (list curdir STEP))))))

;; change-plan :
;;      Direction Direction Position Position ListOfPosition Position Position
;;      Plan -> MaybePlan
;; GIVEN:
;;          1. Previous moves direction
;;          2. Direction to move
;;          3. The current position of the robot
;;          4. The target position of the robot
;;          5. A list of the blocks on the board
;;          6. The previous position of the robot
;;          7. The starting position of the robot
;;          8. Plan until the current position
;; RETURNS: new plan after changing the direction
;; WHERE:   1. if robot is blocked by three forward directions then it can not go
;;             backwords; instead the robot move again restart with initial starting
;;             position, but the current position will be added in block list
;;          2. if robot is blocked by two forward directions, then it will move to
;;             the direction which is open, but current position will be added in block
;;             list
;;          3. if robot has no or only one direction is blocked then it will just change
;;             it's direction and move next
;; EXAMPLES: see tests below

;; STRATEGY: using general recursion
;; HALTING MEASURE:
;; TERMINATION ARGUMENT:
(define (change-plan predir curdir curpos endpos lop prevpos instartpos preplan)
  (local
    ((define blockeddirs (get-blocked-dirs instartpos lop DIR-LIST))
     (define restartdir (change-dir blockeddirs))
     (define newlop (append (list prevpos) (list instartpos) lop))
     (define blocked-dir-cnt (blocked-dirs curpos newlop DIR-LIST 0))
     (define movabledir (get-movable-dir curpos newlop DIR-LIST)))
    (cond
      [(= 3 blocked-dir-cnt)
       (get-plan curdir movabledir curpos endpos (append (list curpos) lop) prevpos
                 instartpos preplan)]
      [(= 4 blocked-dir-cnt)
       (if (equal? curpos instartpos)
           false
           (get-plan curdir restartdir instartpos endpos (append (list curpos) lop) '()
                     instartpos '()))]
      [else
       (get-plan curdir movabledir curpos endpos lop prevpos instartpos preplan)])))

;; change-dir : Direction -> MybeDirection
;; GIVEN:   a direction
;; RETURNS: new direction based on previous directions travelled at given position
;;          and returns "invalid" when all the moves has covered
;; EXAMPLES: see tests below

;; STRATEGY: using cases on (list-contains? prev-dirs Direction)
(define (change-dir prev-dirs)
  (cond
    [(not (list-contains? prev-dirs NE)) NE]
    [(not (list-contains? prev-dirs SE)) SE]
    [(not (list-contains? prev-dirs SW)) SW]
    [(not (list-contains? prev-dirs NW)) NW]
    [else "invalid"]))

;; TESTS:
(begin-for-test
  (check-equal? (change-dir (list NE)) SE)
  (check-equal? (change-dir '()) NE)
  (check-equal? (change-dir (list NE SE)) SW)
  (check-equal? (change-dir (list NE SE SW)) NW))

;; blocked-dirs : Position ListOfPosition ListOfDirection NonNegInt -> NonNegInt
;; GIVEN:
;;          1. current position of the robot
;;          2. list of blocks on the board
;;          3. list of all possible directions (i.e. "ne", "se", "sw" and "nw")
;;          4. integer representing the number of blocked direction
;; WHERE:   if particular direction is blocked then mvcnt get increased by one
;; RETURNS: the number of directions blocked
;; EXAMPLES: see tests below

;; STRATEGY: using general recursion
;; HALTING MEASURE:
;; TERMINATION ARGUMENT:
(define (blocked-dirs curpos lob dirs mvcnt)
  (cond
    [(empty? dirs) mvcnt]
    [else
     (if
      (list-contains? lob (get-next-pos curpos (first dirs) STEP))
      (blocked-dirs curpos lob (rest dirs) (+ mvcnt 1))
      (blocked-dirs curpos lob (rest dirs) mvcnt))]))

;; TESTS:
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
;; GIVEN:
;;          1. current position of the robot
;;          2. list of blocks on the board
;;          3. list of all possible directions (i.e. "ne", "se", "sw" and "nw")
;; RETURNS: the first direction which is not blocked, otherwise returns "invalid" if all
;;          directions are blocked
;; EXAMPLES: see tests below

;; STRATEGY: using general recursion
;; HALTING MEASURE:
;; TERMINATION ARGUMENT:
(define (get-movable-dir curpos lob dirs)
  (cond
    [(empty? dirs) "invalid"]
    [else
     (if
      (not (list-contains? lob (get-next-pos curpos (first dirs) STEP)))
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

;; get-next-pos : Position Direction PosInt -> Position
;; GIVEN:
;;          1. the starting position of the robot,
;;          2. direction to move next
;;          3. number of steps on particular direction
;; RETURNS: next position of the robot based on the direction after moving given steps
;; EXAMPLES: see tests below

;; STARTEGY: using cases on dir
(define (get-next-pos curpos dir step)
  (cond
    [(equal? dir NE) (list (- (pos-x curpos) step) (+ (pos-y curpos) step))]
    [(equal? dir SE) (list (+ (pos-x curpos) step) (+ (pos-y curpos) step))]
    [(equal? dir SW) (list (+ (pos-x curpos) step) (- (pos-y curpos) step))]
    [(equal? dir NW) (list (- (pos-x curpos) step) (- (pos-y curpos) step))]))

;; TESTS:
(begin-for-test
  (check-equal? (get-next-pos '(0 0) NE STEP) '(-1 1))
  (check-equal? (get-next-pos '(0 0) SE STEP) '(1 1))
  (check-equal? (get-next-pos '(0 0) SW STEP) '(1 -1))
  (check-equal? (get-next-pos '(0 0) NW STEP) '(-1 -1)))

;; get-blocked-dirs : Position ListOfPosition ListOfDirection -> ListOfDirection
;; GIVEN:
;;          1. current position of the robot
;;          2. list of blocks on the board
;;          3. list of all possible directions (i.e. "ne", "se", "sw" and "nw")
;; RETURNS: all directions which are not blocked
;; EXAMPLES: see tests below

;; STRATEGY: using general recursion
;; HALTING MEASURE:
;; TERMINATION ARGUMENT:
(define (get-blocked-dirs curpos lob dirs)
  (cond
    [(empty? dirs) empty]
    [else
     (if
      (list-contains? lob (get-next-pos curpos (first dirs) STEP))
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

;=========================================================================================

;; eval-plan : Position ListOfPosition Plan ->  MaybePosition
;; GIVEN:
;;          1. the starting position of the robot,
;;          2. A list of the blocks on the board
;;          3. A plan for the robot's motion
;; RETURNS:
;;          The position of the robot at the end of executing the plan, or false
;;          if  the plan sends the robot to or  through any block.
;; EXAMPLES: see tests below

;; STRATEGY:
(define (eval-plan starpos lob plan)
  (cond
    [(empty? plan) starpos]
    [else
     (local
       ((define lop
          (get-all-pos-on-move
           starpos (move-dir (first plan)) (move-step (first plan)) '()))
        (define nextpos
          (get-next-pos starpos (move-dir (first plan)) (move-step (first plan)))))
       (if (any-pos-blocked? lob lop)
           false
           (eval-plan nextpos lob (rest plan))))]))

;; get-all-pos-on-move : Position Direction PosInt ListOfPosition -> ListOfPosition
;; GIVEN:
;;          1. current position of the robot
;;          2. direction on which move happen
;;          3. Steps taken in that move
;;          4. list of positions travelled while doing this move
;; WHERE:   stepcnt is count decremented by one for every next position and current
;;          position changes for every single step
;; RETURNS: list of all positions traversed by robot until the move end
;; EXAMPLES:

;; STRATEGY: using general recursion
;; HALTING MEASURE:
;; TERMINATION ARGUMENT:
(define (get-all-pos-on-move starpos dir stepcnt lop)
  (cond
    [(= stepcnt 0) lop]
    [else
     (local
       ((define nextpos (get-next-pos starpos dir STEP)))
       (get-all-pos-on-move nextpos dir (- stepcnt 1)
                            (append (list nextpos) lop)))]))
;; any-pos-blocked? : ListOfPosition ListOfPosition -> Boolean
;; GIVEN:
;;          1. list positions of block
;;          2. list of positions travelled while doing this move
;; RETURNS: true iff any position took be robot while moving is blocked one
;; EXAMPLES:

;; STRATEGY: using general recursion
;; HALTING MEASURE:
;; TERMINATION ARGUMENT:
(define (any-pos-blocked? lob lop)
  (cond
    [(empty? lop) false]
    [else
     (if (list-contains? lob (first lop))
         true (any-pos-blocked? lob (rest lop)))]))

;; TESTS:
(begin-for-test
  (check-equal?
   (eval-plan '(0 0) '() (path '(0 0) '(-2 -2) '())) '(-2 -2))
  (check-equal?
   (eval-plan '(0 0) '() (path '(0 0) '(10 2) '())) '(10 2))
  (check-equal?
   (eval-plan '(0 0) '((-1 -1) (-1 1) (1 1) (1 -1))
              (path '(0 0) '(-2 -2) '((-1 1) (1 1) (1 -1)))) false)
  (check-equal?
   (eval-plan '(0 0) '((-1 1) (1 1) (1 -1))
              (path '(0 0) '(-2 -2) '((-1 1) (1 1) (1 -1)))) '(-2 -2))
  (check-equal?
   (eval-plan (list 2 5) (rest wall1) (path (list 2 5) (list 4 9) (rest wall1)))
   (list 4 9))
  (check-equal?
   (eval-plan (list -3 6) two-walls (path (list -3 6) (list 7 6) two-walls))
   (list 7 6)))

;=========================================================================================

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