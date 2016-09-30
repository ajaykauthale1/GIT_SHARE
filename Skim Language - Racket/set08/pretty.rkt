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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEFINITION FOR COSTANTS 
(define STRING-ADD "+")
(define STRING-DIFF "-")
(define SPACE " ")
(define LEFT-BRACKET "(") 
(define RIGHT-BRACKET ")")

;=========================================================================================
;                                      FUNCTIONS
;=========================================================================================
;; expr-to-strings : Expr NonNegInt -> ListOfString
;; GIVEN:   An expression and a width
;; RETURNS: A representation of the expression as a sequence of lines, with
;;          each line represented as a string of length not greater than the width.
;; EXAMPLES: see tests below

;; STRATEGY: call a more general function
(define (expr-to-strings expr w)
  (get-expr-to-strings expr w "" (string-length (get-exp expr)) 0))

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
  (check-equal? (expr-to-strings hw-example-3 10)
                (list "(- 22"
                      "   333"
                      "   44"
                      "   66)")))


;; get-expr-to-strings : Expr NonNegInt String NonNegInt NonNegInt -> MaybeListOfString
;; GIVEN:   1. An expression
;;          2. width
;;          3. String
;;          4. high represeting the subexprs
;;          5. low represeting the subsexprs 
;; WHERE:   1. expr:  can be sum-exp, diff-exp or number
;;          2. w: maximum width to be ensured for each string from lst
;;          3. pre: the prefix string for the expression (if it needs to placed
;;             at new line)
;;          4. hi: the total number of sub-expressions present in the expr; in
;;             case expr not able to fix in the given width, then for stacking
;;             all sub-exp one below other
;;          5. lo: the current sub-expression number
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

;; STRATEGY: Using cases on expr; further call more general functions. 

(define (get-expr-to-strings expr w pre hi lo)
  (cond
    [(integer? expr) (list (string-append pre (get-exp expr)))]
    [(sum-exp? expr) (sum-edit expr w pre hi lo)]
    [(diff-exp? expr) (diff-edit expr w pre hi lo)]))


;; sum-edit : Expr NonNegInt String NonNegInt NonNegInt -> MaybeListOfString
;; GIVEN:   1. An expression
;;          2. width
;;          3. String
;;          4. high represeting the subexprs
;;          5. low represeting the subsexprs 
;; WHERE:   1. expr:  can be sum-exp, diff-exp or number
;;          2. w: maximum width to be ensured for each string from lst
;;          3. pre: the prefix string for the expression (if it needs to placed
;;             at new line)
;;          4. hi: the total number of sub-expressions present in the expr; in
;;             case expr not able to fix in the given width, then for stacking
;;             all sub-exp one below other
;;          5. lo: the current sub-expression number
;; RETURNS: the list of strings which will represent the expression if it fits into the
;;          given width, otherwise throws an error "not enough room"
;; EXAMPLES: see test below 

;; STRATEGY: Call more general functions 

(define (sum-edit expr w pre hi lo)
  (local
    ((define exp-str (get-exp expr))
     (define sub-exp-str
       (get-sub-exprs
        (sum-exp-exprs expr) w
        (string-append pre "(+ ")
        (length (sum-exp-exprs expr)) 1)))
    (edit-helper expr w pre hi lo exp-str sub-exp-str)))

;; TESTS:
(begin-for-test
  (check-equal? (sum-edit hw-example-1 10 "" 0 0)
                (list "(+ 22" "   333" "   44)")
                "after sum edit, list should add one (+, and limit with in 10 width"))

;; diff-edit : Expr NonNegInt String NonNegInt NonNegInt -> MaybeListOfString
;; GIVEN:   1. An expression
;;          2. width
;;          3. String
;;          4. high represeting the subexprs
;;          5. low represeting the subsexprs 
;; WHERE:   1. expr:  can be sum-exp, diff-exp or number
;;          2. w: maximum width to be ensured for each string from lst
;;          3. pre: the prefix string for the expression (if it needs to placed
;;             at new line)
;;          4. hi: the total number of sub-expressions present in the expr; in
;;             case expr not able to fix in the given width, then for stacking
;;             all sub-exp one below other
;;          5. lo: the current sub-expression number
;; RETURNS: the list of strings which will represent the expression if it fits into the
;;          given width, otherwise throws an error "not enough room"
;; EXAMPLES: See tests below 

;; STRATEGY: Call more general functions

(define (diff-edit expr w pre hi lo)
  (local
    ((define exp-str (get-exp expr))
     (define sub-exp-str
       (get-sub-exprs
        (diff-exp-exprs expr) w
        (string-append pre "(- ")
        (length (diff-exp-exprs expr)) 1)))
    (edit-helper expr w pre hi lo exp-str sub-exp-str)))

;; TESTS:
(begin-for-test
  (check-equal? (diff-edit hw-example-3 10 "" 0 0)
                (list "(- 22""   333""   44""   66)")
                "after diff edit, list should add one (-, and limit with in 10 width"))


;; edit-helper : Expr NonNegInt String NonNegInt NonNegInt
;;                                String MaybeListOfString -> MaybeListOfString
;; PURPOSE: helper functions for sum-edit and diff-edit.
;; GIVEN:   1. An expression
;;          2. width
;;          3. String
;;          4. high represeting the subexprs
;;          5. low represeting the subsexprs
;;          6. local definition exp-str from above functions.
;;          7. local definition sub-exp-str  from above functions.
;; WHERE:   1. expr:  can be sum-exp, diff-exp or number
;;          2. w: maximum width to be ensured for each string from lst
;;          3. pre: the prefix string for the expression (if it needs to placed
;;             at new line)
;;          4. hi: the total number of sub-expressions present in the expr; in
;;             case expr not able to fix in the given width, then for stacking
;;             all sub-exp one below other
;;          5. lo: the current sub-expression number
;;          6. exp-str: one of the function sum-edit or diff-edit's local definition. 
;;          7. sub-exp-str: one of the function sum-edit or diff-edit's local definition.
;; RETURNS: the list of strings which will represent the expression if it fits into the
;;          given width, otherwise throws an error "not enough room"
;; EXAMPLES: see tests below 

;; STRATEGY: call more general functions 
(define (edit-helper expr w pre hi lo exp-str sub-exp-str)
  (if (= lo hi)
      (edit-helper-equal expr w pre hi lo exp-str sub-exp-str)
      (edit-helper-not-equal expr w pre hi lo exp-str sub-exp-str)))

;; TESTS:
(begin-for-test
  (check-equal? (edit-helper hw-example-3 5 "" 2 2 "aaaa" "bbbb")  (list "aaaa")
                "because lo=hi, then call edit-helper-equal function. ")
  
  (check-equal? (edit-helper hw-example-3 5 "" 2 3 "aaaa" "bbbb")  (list "aaaa")
                "because lo=!hi, then call edit-helper-not-equal function. "))

;; edit-helper : Expr NonNegInt String NonNegInt NonNegInt
;;                                String MaybeListOfString -> MaybeListOfString
;; PURPOSE: helper functions for edit-helper when input lo equal to hi
;; GIVEN:   1. An expression
;;          2. width
;;          3. String
;;          4. high represeting the subexprs
;;          5. low represeting the subsexprs
;;          6. local definition exp-str from above functions.
;;          7. local definition sub-exp-str  from above functions.
;; WHERE:   1. expr:  can be sum-exp, diff-exp or number
;;          2. w: maximum width to be ensured for each string from lst
;;          3. pre: the prefix string for the expression (if it needs to placed
;;             at new line)
;;          4. hi: the total number of sub-expressions present in the expr; in
;;             case expr not able to fix in the given width, then for stacking
;;             all sub-exp one below other
;;          5. lo: the current sub-expression number
;;          6. exp-str: one of the function sum-edit and diff-edit's local definition. 
;;          7. sub-exp-str: one of the function sum-edit and diff-edit's local definition 
;; RETURNS: the list of strings which will represent the expression if it fits into the
;;          given width, otherwise throws an error "not enough room"
;; EXAMPLES: see test below 

;; STRATEGY: call more general functions 
(define (edit-helper-equal expr w pre hi lo exp-str sub-exp-str)
  (if (<= (+ (string-length exp-str) (string-length pre) 1) w)
      (list (string-append pre exp-str))
      sub-exp-str))


;; TESTS:
(begin-for-test
  (check-equal? (edit-helper-equal hw-example-3 5 "" 2 2 "aaaa" "bbbb") (list "aaaa")
                "because input sum string lengths is less than width 5 so return
                 a list include the pre string. ")
  
  (check-equal? (edit-helper-equal hw-example-3 3 "" 2 2 "aaaa" "bbbb") "bbbb"
                "because input sum string length is greater than width 3 so return
                 the sub string"))

;; edit-helper : Expr NonNegInt String NonNegInt NonNegInt
;;                                String MaybeListOfString -> MaybeListOfString
;; PURPOSE: helper functions for edit-helper when input lo not equal to hi
;; GIVEN:   1. An expression
;;          2. width
;;          3. String
;;          4. high represeting the subexprs
;;          5. low represeting the subsexprs
;;          6. local definition exp-str from above functions.
;;          7. local definition sub-exp-str  from above functions.
;; WHERE:   1. expr:  can be sum-exp, diff-exp or number
;;          2. w: maximum width to be ensured for each string from lst
;;          3. pre: the prefix string for the expression (if it needs to placed
;;             at new line)
;;          4. hi: the total number of sub-expressions present in the expr; in
;;             case expr not able to fix in the given width, then for stacking
;;             all sub-exp one below other
;;          5. lo: the current sub-expression number
;;          6. exp-str: one of the function sum-edit or diff-edit's local definition. 
;;          7. sub-exp-str: one of the function sum-edit or diff-edit's local definition. 
;; RETURNS: the list of strings which will represent the expression if it fits into the
;;          given width, otherwise throws an error "not enough room"
;; EXAMPLES: see test below 

;; STRATEGY: call more general functions 
(define (edit-helper-not-equal expr w pre hi lo exp-str sub-exp-str)
  (if (<= (+ (string-length exp-str) (string-length pre)) w)
      (list (string-append pre exp-str))
      sub-exp-str))

;; TESTS: 
(begin-for-test
  (check-equal? (edit-helper-not-equal hw-example-3 5 "" 2 2 "aaaa" "bbbb") (list "aaaa")
                "because input sum string lengths is less than width 5 so return
                 a list include the pre string. ")
  
  (check-equal? (edit-helper-not-equal hw-example-3 3 "" 2 2 "aaaa" "bbbb") "bbbb"
                "because input sum string length is greater than width 3 so return
                 the sub string"))


;; get-sub-exprs : LOExpr NonNegInt String NonNegInt NonNegInt -> MaybeListOfString
;; GIVEN:   1. An expression
;;          2. width
;;          3. String
;;          4. high represeting the subexprs
;;          5. low represeting the subsexprs
;; WHERE:   1. expr:  can be sum-exp, diff-exp or number
;;          2. w: maximum width to be ensured for each string from lst
;;          3. pre: the prefix string for the expression (if it needs to placed
;;             at new line)
;;          4. hi: the total number of sub-expressions present in the expr; in
;;             case expr not able to fix in the given width, then for stacking
;;             all sub-exp one below other
;;          5. lo: the current sub-expression number
;; RETURNS: the list of string where each string represents the Expr from exprs provided
;;          that each Expr string length is less than the width, otherwise throws an error
;;          "not enough room"
;; EXAMPLES:
#|
(get-sub-exprs (list 22 33 44) 15 "(+ " 3 1) =
(list "(+ 22"
      "   33"
      "   44)")|#

;; STRATEGY: recur on lo+1; halt when exprs is empty. 
;; HALTING MEASURE: when exprs is non-empty
;; TERMINATION ARGUMENT: when exprs becomes empty
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

;; STRATEGY: Recur on (rest lst); halt when lst is empty 
;; HALTING MEASURE: when lst is not empty
;; TERMINATION ARGUMENT: when lst becomes empty 

(define (append-close-br-last lst hi lo w)
  (cond 
    [(empty? lst) empty]
    [(and (empty? (rest lst)) (= hi lo))
     (not-enough-room lst hi lo w)]
    [else
     (append (list (first lst))
             (append-close-br-last (rest lst) hi lo w))]))

;; ("cond" can not combined with "and" ...still need change here 


;; not-enough-room :  ListOfString NonNegInt NonNegInt NonNegInt -> MaybeListOfString
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

;; STRATEGY: call more general functions
(define (not-enough-room lst hi lo w)
  (list (if (> (string-length (string-append (first lst) ")")) w)
            (error "not enough room")
            (string-append (first lst) ")"))))


;; get-empty-string : NonEmptyString NonNegInt -> String
;; GIVEN:   a non-empty String and non-negative integer
;; WHERE:   pre - is the string representing part of expression ex. "(+ 12"
;;          cnt - indicate the number of the current char in the string
;; RETURNS: the string with exactly same number spaces as characters in previous one
;;          excluding numbers
;; EXAMPLES: see tests below

;; STRATEGY: call more general functions

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

;; STRATEGY: Combine simpler fumction???
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
  (or (string=? ch LEFT-BRACKET) (string=? ch STRING-ADD) (string=? ch STRING-DIFF)
      (string=? ch SPACE) (string=? ch RIGHT-BRACKET)))

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
     (get-sum-diff-exps (sum-exp-exprs expr) 1
                        (length (sum-exp-exprs expr)) STRING-ADD)]
    [(diff-exp? expr)
     (get-sum-diff-exps (diff-exp-exprs expr) 1
                        (length (diff-exp-exprs expr)) STRING-DIFF)]))


;; get-sum-diff-exp : Expr NonNegInt NonNegInt -> String
;; GIVEN:   an expression and two non-negative integers
;; WHERE:   expr - is of type sum-exp
;;          hi - represents the total number sub-exprs in expr
;;          lo - represents the current sub-expr number in expr
;;          inout - represents the signal before a number 
;; RETURNS: the string reresentation of the given expr based on lo and hi
;;          if lo = 1, and input = "+" represents first sub-expr so add prefix "(+ " to it
;;          if lo = 1, and input = "-" represents first sub-expr so add prefix "(- " to it
;;          if lo = hi, represents last sub-expr so add postfix ")" to it
;;          else represents middle sub-expr so add postfix " " to it  
;; EXAMPLES:
;; (get-sum-diff-exp 1 1 2 "+") = "(+ 1"
;; (get-sum-diff-exp 1 1 2 "-") = "(- 1"

;; STRATEGY: using cases on lo, hi and input. 

(define (get-sum-diff-exp expr lo hi input)
  (cond
    [(and (= 1 lo) (equal? input STRING-ADD))
     (string-append "(+ " (get-exp expr) " ")]
    [(and (= 1 lo) (equal? input STRING-DIFF))
     (string-append "(- " (get-exp expr) " ")]
    [(= hi lo)
     (string-append (get-exp expr) ")")]
    [else
     (string-append (get-exp expr) " ")]))

;; TESTS:
(begin-for-test
  (check-equal? (get-sum-diff-exp 1 1 2 STRING-ADD) "(+ 1 "
                "after input is +, then give (+")
  (check-equal? (get-sum-diff-exp 1 1 2 STRING-DIFF) "(- 1 "
                "after input is -, then give (-")
  (check-equal? (get-sum-diff-exp 5555 2 2 "=") "5555)"
                "because lo=hi, then shourld return 5555)")
  (check-equal? (get-sum-diff-exp 55 2 3 "=") "55 "
                "lo is not 1 and hi is not equal lo, so return 55 "))


;; get-sum-diff-exps : LOExpr NonNegInt NonNegInt -> String
;; GIVEN:   a list of expressions and two non-negative integers
;; WHERE:   exprs - a list of sub-expr of some parent expression
;;          hi - represents the total number of expressions in the exprs
;;          lo - represents the current sub-expression number from the exprs
;;          input - represents the 
;; RETURNS: String representing all sub-expressions 
;; EXAMPLES:    (get-sum-exps
;;                 (list
;;                   (make-sum-exp
;;                     (list 1 2)) (make-diff-exp (list 4 5))) 1 2) =
;;                     "(+ (+ 1 2) (- 4 5))"

;; STRATEGY: recur on lo+1; halt when listexprs is empty.
;; HALTING MEASURE: listexprs is not empty
;; TERMINATION ARGUMENT: when listexprs becomes empty 

(define (get-sum-diff-exps listexprs lo hi input)
  (cond
    [(empty? listexprs) ""]
    [else
     (string-append
      (get-sum-diff-exp (first listexprs) lo hi input)
      (get-sum-diff-exps (rest listexprs) (+ lo 1) hi input))]))

;; TESTS:
(begin-for-test
  (check-equal? (get-sum-diff-exps (list 1 2) 1 2 STRING-ADD) "(+ 1 2)"
                "after judging signal plus inside input, so return (+ before the list")
  (check-equal? (get-sum-diff-exps (list 1 2) 1 2 STRING-DIFF) "(- 1 2)"
                "after judging signal minus inside input, so return (- before the list")
  (check-equal?  (get-sum-diff-exps (list 1 2) 2 2 STRING-DIFF) "1)2 "
                 "after judging lo = hi so return just 1)2"))




