;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname rem-successive-rep) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

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

(begin-for-test
  (check-equal? (remove-rep plan) result-plan))

;; remove-successive-rep : Move Plan PosInt -> Plan
;; GIVEN:
;;          1. Previous move pre
;;          2. Plan representing the next moves done by robot
;;          3. Step count for previous move
;; WHERE:   pre represent previous move before the plan
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