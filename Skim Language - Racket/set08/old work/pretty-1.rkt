;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname pretty-1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
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
#;(define (expr-to-strings expr wd)
  )


;; get-exp : Expr -> String
(define (get-exp expr)
  (cond
    [(number? expr) (string-append " " (number->string expr))]
    [(sum-exp? expr)
     (get-sum-exps (sum-exp-exprs expr) 1 (length (sum-exp-exprs expr)))]
    [(diff-exp? expr)
     (get-diff-exps (diff-exp-exprs expr) 1 (length (diff-exp-exprs expr)))]))

;; TESTS:
;; constants for tests
(define sum-exp-1
  (make-sum-exp
   (list 1
         (make-diff-exp
          (list 2 5
                (make-sum-exp (list 10 4)))))))

;; get-sum-exp : Expr NonNegInt NonNegInt -> String
(define (get-sum-exp expr lo hi)
  (cond
    [(= 1 lo)
     (string-append " (+" (get-exp expr))]
    [(= hi lo)
     (string-append (get-exp expr) ")")]
    [else
     (string-append (get-exp expr))]))

;; get-sum-exps : LOExpr -> String
(define (get-sum-exps exprs lo hi)
  (cond
    [(empty? exprs) ""]
    [else
     (string-append
      (get-sum-exp (first exprs) lo hi)
     (get-sum-exps (rest exprs) (+ lo 1) hi))]))

;; get-diff-exp : Expr NonNegInt NonNegInt -> String
(define (get-diff-exp expr lo hi)
  (cond
    [(= 1 lo)
     (string-append " (-" (get-exp expr))]
    [(= hi lo)
     (string-append (get-exp expr) ")")]
    [else
     (string-append (get-exp expr))]))

;; get-sum-exps : LOExpr -> String
(define (get-diff-exps exprs lo hi)
  (cond
    [(empty? exprs) ""]
    [else
     (string-append
      (get-diff-exp (first exprs) lo hi)
      (get-diff-exps (rest exprs) (+ lo 1) hi))]))

(get-exp sum-exp-1)