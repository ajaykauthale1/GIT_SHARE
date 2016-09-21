;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname |new logic|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

;; constants for directions
(define NE "ne")
(define SE "se")
(define NW "nw")
(define SW "sw")
(define DIR-LIST (list NE SE SW NW))

;; constants for testing
(define corner-blocks '((1 2) (3 2) (3 0)))
(define wall-blocks-1 '((-1 2) (1 2)))
(define wall-blocks-2 '((-2 -3) (0 -3)))
(define prevpos '(1 0))
(define prevpos-1 '(-2 -1))
(define starpos '(0 -1))


;; change-dir : Direction -> Direction
;; GIVEN:   a direction
;; RETURNS: new direction based on previous moves at given position
;; EXAMPLES: see tests below

;; STRATEGY: using cases on olddir
(define (change-dir startpos prev-dirs)
  (cond
    [(not (list-contains? prev-dirs NE)) NE]
    [(not (list-contains? prev-dirs SE)) SE]
    [(not (list-contains? prev-dirs SW)) SW]
    [(not (list-contains? prev-dirs NW)) NW]
    [else "invalid"]))

;; TESTS:
(define lst (list "se"))

#;(begin-for-test
  (check-equal? (change-dir '(3 5) lst) "invalid")
  (check-equal? (change-dir '(2 5) lst) SE)
  (check-equal? (change-dir '(4 5) lst) NE)
  (check-equal? (change-dir '(1 1) lst) SW)
  (check-equal? (change-dir '(2 1) lst) NW))

;; get-movable-dirs : Position ListOfPosition ListOfDirection -> MaybeDirection
(define (get-blocked-dirs curpos lob dirs)
  (cond
    [(empty? dirs) empty]
    [else
     (if
      (list-contains? lob (get-next-pos curpos (first dirs)))
      (append (list (first dirs)) (get-blocked-dirs curpos lob (rest dirs)))
      (get-blocked-dirs curpos lob (rest dirs)))]))

;; next-dir-to-move : Position Position ListOfDirection -> Direction
;; GIVEN:
;;          1. the cuurent position of the robot,
;;          2. the target position that robot is supposed to reach
;; RETURNS: direction for next step
;; EXAMPLES: see tests below

;; STRATEGY: using cases on curpos and endpos
(define (next-dir-to-move curpos endpos lod)
  (cond
    [(and (not (list-contains? lod NE))
          (and (<= (pos-x endpos) (pos-x curpos))
               (>= (pos-y endpos) (pos-y curpos)))) NE]
    [(and (not (list-contains? lod SE))
          (and (>= (pos-x endpos) (pos-x curpos))
               (>= (pos-y endpos) (pos-y curpos)))) SE]
    [(and (not (list-contains? lod SW))
          (and (>= (pos-x endpos) (pos-x curpos))
               (<= (pos-y endpos) (pos-y curpos)))) SW]
    [(and (not (list-contains? lod NW))
          (and (<= (pos-x endpos) (pos-x curpos))
               (<= (pos-y endpos) (pos-y curpos)))) NW]))

;; TESTS:
(begin-for-test
  (check-equal? (next-dir-to-move '(0 0) '(-2 2) '()) NE)
  (check-equal? (next-dir-to-move '(0 0) '(2 2) '()) SE)
  (check-equal? (next-dir-to-move '(0 0) '(2 -2) '()) SW)
  (check-equal? (next-dir-to-move '(0 0) '(-2 -2) '()) NW)
  (check-equal? (next-dir-to-move '(0 0) '(0 2) '()) NE))

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
