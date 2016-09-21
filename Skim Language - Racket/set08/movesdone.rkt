;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname movesdone) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

(define lst (list '((3 5) "ne") '((3 5) "se") '((2 5) "ne") '((3 5) "ne") '((3 5) "sw")
                  '((3 5) "nw")))

(define (unique-moves-done-at-pos pos lop moves)
  (cond
    [(empty? lop) empty]
    [else
     (if (and
          (equal? pos (first (first lop)))
          (not (subset? (list (second (first lop))) moves)))
         (append
          (list (second (first lop)))
          (unique-moves-done-at-pos
           pos (rest lop)
           (append (list (second (first lop)))
                   moves)))
         (unique-moves-done-at-pos pos (rest lop) moves))]))

(define (change-dir startpos prevblocks olddir)
  (local
    ((define prev-dirs (unique-moves-done-at-pos startpos prevblocks '())))
    (cond
    [(not (list-contains? SE)) SE]
    [(not (list-contains? SW)) SW]
    [(not (list-contains? NW)) NW]
    [(not (list-contains? NE)) NE])))

(define (backtrack pos moves))


;; list-contains? : ListOfX X -> Boolean
;; GIVEN:   a list of X
;; RETURNS: true iff the list contains X
;; EXAMPLES: see tests below

;; STRATEGY: using HOF ormap on lop
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