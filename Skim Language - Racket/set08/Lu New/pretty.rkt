;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname pretty) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;(check-location "08" "outlines.rkt")

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

(provide expr-to-strings)
(provide make-sum-exp)
(provide sum-exp-exprs)
(provide make-diff-exp)
(provide diff-exp-exprs)

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
;; GIVEN:   An expression and a width
;; RETURNS: A representation of the expression as a sequence of lines, with
;;          each line represented as a string of length not greater than the width.
;; EXAMPLES: see tests below

;; STRATEGY: using cases on expr, further call more general function
(define (expr-to-strings expr w)
  (cond
    [(sum-exp? expr)
     (get-expr-to-strings expr w "" 0 0)]
    [(diff-exp? expr)
     (get-expr-to-strings expr w "" 0 0)]
    [(integer? expr)
     (get-expr-to-strings expr w "" 0 0)]
    [else empty]))


;; TESTS:
;; constants for test

(define hw-example-1
  (make-sum-exp (list 22 333 44)))

(define hw-example-2
  (make-sum-exp
   (list
    (make-diff-exp (list 22 3333 44))
    (make-diff-exp
     (list
      (make-sum-exp (list 66 67 68))
      (make-diff-exp (list 42 43))))
    (make-diff-exp (list 77 88)))))

(define hw-example-3
  (make-diff-exp (list 22 333 44 66)))



(begin-for-test
  (check-equal? (expr-to-strings hw-example-1 15)
                (list "(+ 22 333 44)"))
  (check-equal? (expr-to-strings hw-example-1 10)
                (list "(+ 22"
                      "   333"
                      "   44)"))
  (check-error (expr-to-strings hw-example-1 5))
  (check-equal? (expr-to-strings hw-example-2 100)
                (list "(+ (- 22 3333 44) (- (+ 66 67 68) (- 42 43)) (- 77 88))")) 
  (check-equal? (expr-to-strings hw-example-2 50)
                (list "(+ (- 22 3333 44)"
                      "   (- (+ 66 67 68) (- 42 43))"
                      "   (- 77 88))"))
  (check-equal? (expr-to-strings hw-example-2 20)
                (list "(+ (- 22 3333 44)"
                      "   (- (+ 66 67 68)"
                      "      (- 42 43))"
                      "   (- 77 88))"))
  
  (check-equal? (expr-to-strings hw-example-2 15)
                (list "(+ (- 22"
                      "      3333"
                      "      44)"
                      "   (- (+ 66"
                      "         67" 
                      "         68)"
                      "      (- 42"
                      "         43))"
                      "   (- 77 88))"))
  (check-equal? (expr-to-strings 1 15) (list "1"))
  (check-equal? (expr-to-strings "abc" 15) empty)
  (check-equal? (expr-to-strings hw-example-3 10)
                (list "(- 22"
                      "   333"
                      "   44"
                      "   66)")))



;; get-expr-to-strings : Expr NonNegInt String NonNegInt NonNegInt -> MaybeListOfString
;; GIVEN:   An expression, width, String, and high and low for represeting the subexprs
;; WHERE:   expr - can be sum-exp, diff-exp or number.
;;          pre - represents the prefix string for the expression (if it needs to placed
;;          at new line)
;;          hi - represents the total number of sub-expressions present in the expr; in
;;          case expr not able to fix in the given width, then for stacking all sub-exp
;;          one below other
;;          lo - represents the current sub-expression number
;; RETURNS: the list of strings which will represent the expression if it fits into the
;;          given width, otherwise throws an error "not enough room"
;; EXAMPLES:
#|
(get-expr-to-strings hw-example-2 15 "" 0 0) =
(list "(+ (- 22"
      "      3333"
      "      44)"
      "   (- (+ 66"
      "         67" 
      "         68)"
      "      (- 42"
      "         43))"
      "   (- 77 88))")|#

;; STRATEGY:
;; HALTING MEASURE: when expr is of type number

(define (get-expr-to-strings expr w pre hi lo)
  (cond
    [(integer? expr) (list (string-append pre (get-exp expr)))]
    [(sum-exp? expr) (sum-edit expr w pre hi lo)]
    [(diff-exp? expr) (diff-edit expr w pre hi lo)]))

(define (sum-edit expr w pre hi lo)
   (local
       ((define exp-str (get-exp expr))
        (define sub-exp-str
          (get-sub-exprs
           (sum-exp-exprs expr) w
           (string-append pre "(+ ")
           (length (sum-exp-exprs expr)) 1)))
       (if (= lo hi)
           (if (<= (+ (string-length exp-str) (string-length pre) 1) w)
               (list (string-append pre exp-str))
               sub-exp-str)
           (if (<= (+ (string-length exp-str) (string-length pre)) w)
               (list (string-append pre exp-str))
               sub-exp-str))))

(define (diff-edit expr w pre hi lo)
  (local
       ((define exp-str (get-exp expr))
        (define sub-exp-str
          (get-sub-exprs
           (diff-exp-exprs expr) w
           (string-append pre "(- ")
           (length (diff-exp-exprs expr)) 1)))
       (if (= lo hi)
           (if (<= (+ (string-length exp-str) (string-length pre) 1) w)
               (list (string-append pre exp-str))
               sub-exp-str) 
           (if (<= (+ (string-length exp-str) (string-length pre)) w)
               (list (string-append pre exp-str))
               sub-exp-str))))

;; get-sub-exprs : LOExpr NonNegInt String NonNegInt NonNegInt -> MaybeListOfString
;; GIVEN:   a list of expressions, width, prefix string and two non-neg integers
;; WHERE:   exprs - a list of sub-expr of some parent expression
;;          pre - represents the prefix string for the each expr from list
;;          hi - represents the total number of expressions in the exprs
;;          lo - represents the current sub-expression number from the exprs
;; RETURNS: the list of string where each string represents the Expr from exprs provided
;;          that each Expr string length is less than the width, otherwise throws an error
;;          "not enough room"
;; EXAMPLES:
#|
(get-sub-exprs (list 22 33 44) 15 "(+ " 3 1) =
(list "(+ 22"
      "   33"
      "   44)")|#

;; STRATEGY:
;; HALTING MEASURE: when exprs is empty
(define (get-sub-exprs exprs w pre hi lo)
  (cond
    [(empty? exprs) empty]
    [else
     (local
       ((define firstexp (get-expr-to-strings (first exprs) w pre hi lo)))
       (append
        (append-close-br-last firstexp hi lo w)
        (get-sub-exprs (rest exprs) w (get-empty-string pre 1) hi (+ lo 1))))]))

;; append-close-br-last : ListOfString NonNegInt NonNegInt NonNegInt -> MaybeListOfString
;; GIVEN:   a list of string and three non-negative integers
;; WHERE:   lst - is a list of strings
;;          hi - represents the total number of strings in lst
;;          lo - represents the current string number from the lst
;;          w - maximum width to be ensured for each string from lst
;; RETURNS: the list of strings same as original one, but last string is appended by
;;          closing bracket ")" when hi = lo. If last string size will become greater
;;          than width after appending closing bracket throws an error "not enough room"
;; EXAMPLES:
#|
(append-close-br-last (list "(+ 22" "   33" "   44") 3 3 15) =
(list "(+ 22" "   33" "   44)")|#

;; STRATEGY:
;; HALTING MEASURE: when lst is empty
(define (append-close-br-last lst hi lo w)
  (cond 
    [(empty? lst) empty]
    [(and (empty? (rest lst)) (= hi lo))
     (list (if
            (> (string-length (string-append (first lst) ")")) w)
            (error "not enough room")
            (string-append (first lst) ")")))]
    [else
     (append (list (first lst))
             (append-close-br-last (rest lst) hi lo w))]))

;; get-empty-string : NonEmptyString NonNegInt -> String
;; GIVEN:   a non-empty String and non-negative integer
;; WHERE:   pre - is the string representing part of expression ex. "(+ 12"
;;          cnt - indicate the number of the current char in the string
;; RETURNS: the string with exactly same number spaces as characters in previous one
;;          excluding numbers
;; EXAMPLES: see tests below

;; STRATEGY:
(define (get-empty-string pre cnt)
  (if (not (special-char? (string-last pre)))
      (get-empty-string (substring pre 0 (- (string-length pre) 1)) cnt)
      (get-pre-string pre "")))

;; TESTS:
(begin-for-test
  (check-equal? (string-length (get-empty-string "(+ (- 55" 1)) 6))

;; get-pre-string : String String -> String
;; GIVEN:   two strings
;; WHERE:   pre - is the string representing prefix of some expression ex. "(+ "
;;          str - represents the string with blank spaces only
;; RETURNS: the string with exactly same number spaces as characters in previous
;; EXAMPLES:
; (string-length (get-pre-string "(+ " "")) = 3

;; STRATEGY:
(define (get-pre-string pre str)
  (cond
    [(= 0 (string-length pre)) str]
    [else
     (get-pre-string (string-rest pre) (string-append " " str))]))

;; special-char? : 1String -> Boolean
;; GIVEN:   a 1String
;; RETURNS: true iff the ch is either "(", "+", "-", " " or ")"
;; EXAMPLES:
;; (special-char? ")") = true

;; STRATEGY: combine using simpler function
(define (special-char? ch)
  (or (string=? ch "(") (string=? ch "+") (string=? ch "-")
      (string=? ch " ") (string=? ch ")")))

;; string-last : NonEmptyString -> 1String
;; GIVEN:   a non-empty String
;; RETURNS: the last 1String from the given string
;; EXAMPLES:
;; (string-last "abcd") = "d"

;; STRATEGY: combine using simpler function
(define (string-last input-string)
  (substring input-string (- (string-length input-string) 1)))

;; string-rest: NonEmptyString -> String
;; GIVEN: the non empty string
;; RETURNS: the string after removing first char
;; EXAMPLES:
;; (string-rest "Hello") = "ello"

;; STRATEGY: combine using simpler function 
(define (string-rest input-string)
  (substring input-string 1))

;; get-exp : Expr -> String
;; GIVEN: an expression 
;; RETURNS: the string representation of the expression
;; EXAMPLES:
;; (get-exp (make-sum-exp (list 1 2 3))) = "(+ 1 2 3)"
;; (get-exp (make-diffs-exp (list 1 2 3))) = "(- 1 2 3)"

;; STRATEGY: using cases on expr, further call more general functions

(define (get-exp expr)
  (cond
    [(integer? expr) (number->string expr)]
    [(sum-exp? expr)
     (get-sum-diff-exps (sum-exp-exprs expr) 1 (length (sum-exp-exprs expr)) "+"  )]
    [(diff-exp? expr)
     (get-sum-diff-exps (diff-exp-exprs expr) 1 (length (diff-exp-exprs expr)) "-"  )]))


;; get-sum-diff-exp : Expr NonNegInt NonNegInt -> String
;; GIVEN:   an expression and two non-negative integers
;; WHERE:   expr - is of type sum-exp
;;          hi - represents the total number sub-exprs in expr
;;          lo - represents the current sub-expr number in expr
;; RETURNS: the string reresentation of the given expr based on lo and hi
;;          if lo = 1, represents first sub-expr so add prefix "(+ " to it
;;          if  lo = hi, represents last sub-expr so add postfix ")" to it
;;          else represents middle sub-expr so add postfix " " to it  
;; EXAMPLES:
;; (get-sum-diff-exp 1 1 2 "+") = "(+ 1"
;; (get-sum-diff-exp 1 1 2 "-") = "(- 1"

;; STRATEGY: using cases on lo, hi and input. 

(define (get-sum-diff-exp expr lo hi input)
  (cond
    [(and (= 1 lo) (equal? input "+"))
     (string-append "(+ " (get-exp expr) " ")]
    [(and (= 1 lo) (equal? input "-"))
     (string-append "(- " (get-exp expr) " ")]
    [(= hi lo)
     (string-append (get-exp expr) ")")]
    [else
     (string-append (get-exp expr) " ")]))


;; get-sum-diff-exps : LOExpr NonNegInt NonNegInt -> String
;; GIVEN:   a list of expressions and two non-negative integers
;; WHERE:   exprs - a list of sub-expr of some parent expression
;;          hi - represents the total number of expressions in the exprs
;;          lo - represents the current sub-expression number from the exprs
;; RETURNS: String representing all sub-expressions 
;; EXAMPLES:    (get-sum-exps
;;                 (list
;;                   (make-sum-exp
;;                     (list 1 2)) (make-diff-exp (list 4 5))) 1 2) =
;;                     "(+ (+ 1 2) (- 4 5))"

;; STRATEGY: Call more general functions. 

(define (get-sum-diff-exps exprs lo hi input)
  (cond
    [(empty? exprs) ""]
    [else
     (string-append
      (get-sum-diff-exp (first exprs) lo hi input)
      (get-sum-diff-exps (rest exprs) (+ lo 1) hi input))]))


(define (display-expr expr n)
  (display-strings! (expr-to-strings expr n)))