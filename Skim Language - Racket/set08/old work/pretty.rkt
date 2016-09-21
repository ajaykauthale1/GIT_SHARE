;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname pretty) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;(check-location "08" "outlines.rkt")

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

;(provide expr-to-strings)
;(provide make-sum-exp)
;(provide sum-exp-exprs)
;(provide make-diff-exp)
;(provide diff-exp-exprs)

;=========================================================================================
;                                      DATA DEFINITIONS
;=========================================================================================
(define-struct sum-exp (exprs))
;; Sum-Exp is a (make-sum-exp LOExpr)
;; ITNERPRETATION:
;; LOExpr is the list of expressions

;; TEMPLATE:
;;sum-exp-fn : Sum-Exp -> ??
#;(define (sum-exp-fn ex)
  ....
  (sum-exp-exprs ex)
  ...)

(define-struct diff-exp (exprs))
;; Diff-Exp is a (make-diff-exp LOExpr)
;; ITNERPRETATION:
;; LOExpr is the list of expressions

;; TEMPLATE:
;; diff-exp-fn : Diff-Exp -> ??
#;(define (diff-exp-fn ex)
  ....
  (diff-exp-exprs ex)
  ...)

;; An Expr is one of
;; -- Integer
;; -- (make-sum-exp NELOExpr)
;; -- (make-diff-exp NELOExpr)
;; ITNERPRETATION:
;; a sum-exp represents a sum and a diff-exp represents a difference calculation.

;; A LOExpr is one of
;; -- empty
;; -- (cons Expr LOExpr)
;; ITNERPRETATION:
;; empty represents empty LOExpr
;; (cons Expr LOExpr) represents the LOExpr with newly added Expr

;; A NELOExpr is a non-empty LOExpr.

;=========================================================================================
;                                      FUNCTIONS
;=========================================================================================
;; expr-to-strings : Expr NonNegInt -> ListOfString
;; GIVEN: An expression and a width
;; RETURNS: A representation of the expression as a sequence of lines, with
;; each line represented as a string of length not greater than the width.
;; EXAMPLES:

;; STRATEGY:
#;(define (expr-to-strings expr w)
 (get-string-rep expr w "") )

;;
#;(define (get-string-rep expr w prevspace)
  (cond
    [(< (string-length (get-expr-string expr prevspace)) w)
     (list (get-expr-string expr prevspace))]
    [(sum-exp? expr)
     (append (get-expr-string (make-sum-exp (list (firts (sum-exp-exprs)))) prevspace))]
    [(diff-exp? expr)
     (list
      (string-append "(-" (get-string-rep (first (diff-exp-exprs expr)) w prevspace)
      (get-string-rep (rest (diff-exp-exprs expr))
                      w
                      (string-length
                       (get-expr-string (first (diff-exp-exprs expr))
                                        prevspace))))
      ")")]))


;; get-expr-string : Expr String -> String
(define (get-expr-string expr prevspace)
  (cond
    [(empty? expr) ""]
    [(integer? expr) (string-append " " (number->string expr))]
    [(sum-exp? expr)
     (get-sum-expr-string expr prevspace)]
    [(diff-exp? expr)
     (get-diff-expr-string expr prevspace)]
    [else
     (string-append
      (get-expr-string (first expr) prevspace)
      (get-expr-string (rest expr) prevspace))]))

;; sum-exp-1
;;
(define (get-sum-expr-string expr prevspace)
  (cond
    [(empty? (sum-exp-exprs expr)) ""]
    [else
     (string-append prevspace "(+" (get-expr-string (sum-exp-exprs expr) " ") ")")]))

;;
(define (get-diff-expr-string expr prevspace)
  (cond
    [(empty? (diff-exp-exprs expr)) ""]
    [else
     (string-append prevspace "(-" (get-expr-string (diff-exp-exprs expr) " ") ")")]))


;; get-req-disp-size-expr : Expr -> NonNegInt
;; GIVEN: An expression
;; RETURNS: the size of the expression
;; EXAMPLES:
;;

;; STRATEGY:
(define (get-req-disp-size-expr expr)
  (cond
    [(empty? expr) 0]
    [(integer? expr) (get-char-count expr)]
    [(sum-exp? expr)
     (get-sum-expr-length expr)]
    [(diff-exp? expr)
     (get-diff-expr-length expr)]
    [else
     (+ (get-req-disp-size-expr (first expr)) (get-req-disp-size-expr (rest expr)))]))

;; TESTS:
;; constants for tests
(define sum-exp-1 (make-sum-exp (list 1 2)))
(define diff-exp-1 (make-diff-exp (list 2 3)))
(define sum-exp-2 (make-sum-exp (list 1 diff-exp-1)))
(define diff-exp-2 (make-diff-exp (list 2 sum-exp-2)))
(define sum-exp-3 (make-sum-exp (list 1 2 -5)))

(begin-for-test
  (check-equal? (get-req-disp-size-expr (make-sum-exp '())) 0)
  (check-equal? (get-req-disp-size-expr (make-diff-exp '())) 0)
  (check-equal? (get-req-disp-size-expr sum-exp-1) 7)
  (check-equal? (get-req-disp-size-expr diff-exp-1) 7)
  (check-equal? (get-req-disp-size-expr sum-exp-2) 13)
  (check-equal? (get-req-disp-size-expr diff-exp-2) 19)
  (check-equal? (get-req-disp-size-expr sum-exp-3) 10))

;; get-char-count : Integer -> NonNegInt
;; GIVEN: an integer
;; WHERE: int can be positive or negative
;; RETURNS: if int is positive then count of all digits
;;          if int is negative then count of all digits + 1 (sice symbol '-' holds one
;;          space)
;; EXAMPLES:
;; (get-char-count -999) = 4
;; (get-char-count 12344) = 5

;; STRATEGY:
(define (get-char-count int)
  (cond
    [(< int 0) (+ 1 (get-char-count (- 0 int)))]
    [else
     (if (< int 10)
         1 (+ 1 (get-char-count (/ int 10))))]))

;; TESTS:
(begin-for-test
  (check-equal? (get-char-count -999) 4)
  (check-equal? (get-char-count 12344) 5))

;; get-sum-expr-length : Sum-Expr -> NonNegInt
;; GIVEN: a Sum-Expr
;; RETURNS: the length of the Sum-Expr
;; EXAMPLES:

;; STRATEGY:
(define (get-sum-expr-length expr)
  (cond
    [(empty? (sum-exp-exprs expr)) 0]
    [else
     (+ 3 (length (sum-exp-exprs expr))
        (get-req-disp-size-expr (sum-exp-exprs expr)))]))

;; get-diff-expr-length : Diff-Expr -> NonNegInt
;; GIVEN: a Diff-Expr
;; RETURNS: the length of the Diff-Expr
;; EXAMPLES:

;; STRATEGY:
(define (get-diff-expr-length expr)
  (cond
    [(empty? (diff-exp-exprs expr)) 0]
    [else
     (+ 3 (length (diff-exp-exprs expr))
        (get-req-disp-size-expr (diff-exp-exprs expr)))]))

;;
#;(define (display-expr expr n)
    (display-strings! (expr-to-strings expr n)))