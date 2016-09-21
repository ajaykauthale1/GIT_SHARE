;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname class-lists) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor mixed-fraction #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Author: Ajay Baban Kauthale
;; Date: 10/12/2015
;; Program for class lists using HOF

;(check-location "05" "class-lists.rkt")

(require rackunit)
(require "extras.rkt")

(provide felleisen-roster shivers-roster make-slip slip-color slip-name1 slip-name2)

;=========================================================================================
;                                      CONSTANTS
;=========================================================================================
(define YELLOW "yellow")
(define BLUE "blue")

;=========================================================================================
;                                      DATA DEFINITIONS
;=========================================================================================
;; A Color is one of
;; -- "yellow"
;; -- "blue"

;; TEMPLATE:
#|(define (color-fn c)
  (string=? c))|#

(define-struct slip (color name1 name2))
;; A slip is a (make-slip Color String String)
;; INTERPRETATION:
;; color is a Color
;; name1 is either first name or last name of student
;; name2 is either first name or last name of student

;; slips for testing purpose
(define felleisen-slip (make-slip YELLOW "Ajay" "Kauthale"))
(define felleisen-slip-duplicate (make-slip YELLOW "Kauthale" "Ajay"))
(define felleisen-slip-not-duplicate (make-slip YELLOW "Sam" "Johnson"))
(define shivers-slip (make-slip BLUE "Ajay" "Kauthale"))
(define shivers-slip-duplicate (make-slip BLUE "Kauthale" "Ajay"))
(define shivers-slip-not-duplicate (make-slip BLUE "Sam" "Johnson"))

;; TEMPLATE:
;; slip-fn -> ??
#|(define (slip-fn s)
  ....
  (slip-color s)
  (slip-name1 s)
  (slip-name2 s)
  ....))|#

;; A List of Slip (ListOfSlip) is one of:
;; -- empty
;; -- (cons s ListOfSlip)
;; INTERPRETATION:
;; empty represents the empty list
;; (cons s ListOfSlip) represents the list of slips with newly added slip s

;; TEMPLATE:
;; ListOfSlip-fn -> ??
#|(define (ListOfSlip-fn slips)
  (cond
    [(empty? slips) ... ]
    [else (... (first slips)
               (ListOfSlip-fn (rest slips)))]))|#

;; ListOfSlip for testing purpose
(define list-felleisen (list felleisen-slip felleisen-slip-not-duplicate))
(define list-felleisen-repeated (list felleisen-slip felleisen-slip-duplicate))
(define list-felleisen-same-repeated (list felleisen-slip felleisen-slip))
(define list-shivers (list shivers-slip shivers-slip-not-duplicate))
(define list-shivers-repeated (list shivers-slip shivers-slip-duplicate))
(define mixed-list-of-slips (list (make-slip YELLOW "Ajay" "Kauthale")
                                  (make-slip BLUE "Wang" "Xi")
                                  (make-slip BLUE "Sam" "Johnson")
                                  (make-slip YELLOW "Ajay" "Kauthale")
                                  (make-slip YELLOW "Kauthale" "Ajay")
                                  (make-slip YELLOW "Wang" "Xi")
                                  (make-slip BLUE "Xi" "Wang")
                                  (make-slip YELLOW "Wang" "Xi")
                                  (make-slip YELLOW "Xi" "Wang")
                                  (make-slip BLUE "Kauthale" "Ajay")
                                  (make-slip YELLOW "abc" "cde")
                                  (make-slip YELLOW "cde" "abc")))
(define list-of-slips-yellow (list (make-slip YELLOW "Ajay" "Kauthale")
                                   (make-slip YELLOW "Ajay" "Kauthale")
                                   (make-slip YELLOW "Kauthale" "Ajay")
                                   (make-slip YELLOW "Wang" "Xi")
                                   (make-slip YELLOW "Wang" "Xi")
                                   (make-slip YELLOW "Xi" "Wang")
                                   (make-slip YELLOW "abc" "cde")
                                   (make-slip YELLOW "cde" "abc")))

;=========================================================================================
;                                      FUNCTIONS
;=========================================================================================
;; felleisen-roster : ListOfSlip -> ListOfSlip
;; GIVEN: a list of slips
;; RETURNS: a list of slips containing all the students in Professor 
;; Felleisen's class, without duplication.
;; EXAMPLES:
;; (felleisen-roster list-felleisen-repeated) = (list felleisen-slip empty)
;; (felleisen-roster list-felleisen-same-repeated) = (list felleisen-slip empty)
;; (felleisen-roster list-felleisen) = (list felleisen-slip felleisen-slip-not-duplicate)

;; STRATEGY: Generalization on slip color
(define (felleisen-roster slips)
  (get-roster (color-filter slips YELLOW)))

;; shivers-roster : ListOfSlip -> ListOfSlip
;; GIVEN: a list of slips
;; RETURNS: a list of slips containing all the students in Professor
;; Shivers' class, without duplication.
;; EXAMPLES:
;; (shivers-roster list-shivers-repeated) = (list shivers-slip empty)
;; (shivers-roster list-shivers) = (list shivers-slip shivers-slip-not-duplicate)

;; STRATEGY: Generalization on slip color
(define (shivers-roster slips)
  (get-roster (color-filter slips BLUE)))

;;;; Helper function ;;;;;

;; get-roster : ListOfSlip String -> ListOfSlip
;; GIVEN: a list of slips and color string
;; RETURNS: the non-duplcate list of slips belonging to the specified color
;; EXAMPLES:
;; (get-roster list-shivers-repeated YELLOW) = (list shivers-slip empty)

;; STRATEGY: using template of ListOfSlip on slips
(define (get-roster slips)
  (cond
    [(empty? slips) empty]
    [else (if (not (already-exist? (rest slips) (first slips)))
              (cons (first slips) (get-roster (rest slips))) (get-roster (rest slips)))]))

;; already-exist? : ListOfSlip slip -> Boolean
;; GIVEN: slips- ListOfSlip, a slip
;; RETURN: true iff the duplicate slip is present in the ListOfSlip
;; EXAMPLES:
;; (already-exist? mixed-list-of-slips felleisen-slip) = true

;; STRATEGY: using HOF ormap on slips
(define (already-exist? slips s)
  (ormap
   ;; String -> Boolean
   (lambda (slip)
     (or
      (and (string=? (slip-name1 s) (slip-name1 slip))
           (string=? (slip-name2 s) (slip-name2 slip)))
      (and (string=? (slip-name1 s) (slip-name2 slip))
           (string=? (slip-name2 s) (slip-name1 slip)))))
   slips))

;; color-filter : ListOfSlip String -> ListOfSlip
;; GIVEN: slips- ListOfSlip and color string
;; RETURNS: the ListOfSlip filtered on basis of given color
;; EXAMPLES:
;; (color-filter mixed-list-of-slips YELLOW) = list-of-slips-yellow

;; STRATEGY: using HOF filter on slips
(define (color-filter slips color)
  (filter
   ;; String -> Boolean
   (lambda (slip) (string=? (slip-color slip) color))
   slips))

;; TESTS:
(begin-for-test
    (check-equal? (felleisen-roster list-felleisen-repeated)
                  (list felleisen-slip-duplicate))
    (check-equal? (felleisen-roster list-felleisen-same-repeated)
                  (list felleisen-slip))
    (check-equal? (felleisen-roster list-felleisen)
                  (list felleisen-slip felleisen-slip-not-duplicate))
    (check-equal? (shivers-roster list-shivers-repeated) (list shivers-slip-duplicate))
    (check-equal? (shivers-roster list-shivers)
                  (list shivers-slip shivers-slip-not-duplicate)))