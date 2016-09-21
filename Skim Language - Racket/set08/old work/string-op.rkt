;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname string-op) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

(define str "(+ 1 (- 2 5 (+ 10 5 (- 10 4 8 ))))")

(define (get-expr-tokens expstr lst)
  (cond
    [(= 0 (string-length expstr)) lst]
    [else
     (get-expr-tokens (string-rest expstr)
                          (append lst (list (string-first expstr))))]))


;; get-expr-to-strings : ListOfString ListOfString -> ListOfString
(define (get-expr-to-strings lst newlst w)
  (cond
    [(empty? lst) newlst]
    [else
     (if (<= (string-length (last newlst)) w)
         (get-expr-to-strings
          (rest lst) (list ) w))
     (list
      (string-append (first lst) (first (rest lst))))]))

;;
(define (last list)
  (first (reverse list)))

;(get-expr-to-strings str 100 '("") 1)


;; string-first: NonEmptyString -> 1String
;; GIVEN: the non empty string
;; RETURNS: the extracted first 1String of the given string
;; EXAMPLE:
;; (string-first "Hello I am Ajay") = "H"
;; (string-first "Good to see you") = "G"
(define (string-first input-string)
  (substring input-string 0 1))

;; TESTS:
#;(begin-for-test
  (check-equal? (string-first "Hello I am Ajay") "H"
                "should return first 1String as 'H'")
  (check-equal? (string-first "Good to see you") "G"
                "should return first 1String as 'G'"))

;; string-rest: NonEmptyString -> String
;; GIVEN: the non empty string
;; RETURNS: the string after removing first char
;; EXAMPLE:
;; (string-rest "Hello I am Ajay") = "ello I am Ajay"
;; (string-rest "Good to see you") = "ood to see you"
(define (string-rest input-string)
  (substring input-string 1))

;; TESTS:
#;(begin-for-test
  (check-equal? (string-rest "Hello I am Ajay") "ello I am Ajay"
                "should return rest string by removing 'H'")
  (check-equal? (string-rest "Good to see you") "ood to see you"
                "should return rest string by removing 'G'"))
 
;;
(define (string-last input-string)
  (substring input-string (- (string-length input-string) 1)))

;;
(define (pre-spaces str sp)
  (cond
    [(special-char? (string-first str))
     (pre-spaces (string-rest str) (string-append sp " ") )]
    [else
     sp]))

;;
(define (special-char? ch)
  (or (string=? ch "(")
         (string=? ch "+")
         (string=? ch "-")
         (string=? ch " ")))


;(get-expr-to-strings str 5 '("") 1)