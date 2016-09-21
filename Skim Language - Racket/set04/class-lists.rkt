;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname class-lists) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Author: Ajay Baban Kauthale
;; Date: 10/07/2015
;; Program for class lists

;(check-location "04" "class-lists.rkt")

(require rackunit)
(require "extras.rkt")

(provide felleisen-roster shivers-roster)

;==========================================================================================================================
;                                      CONSTANTS
;==========================================================================================================================
(define YELLOW "yellow")
(define BLUE "blue")

;==========================================================================================================================
;                                      DATA DEFINITIONS
;==========================================================================================================================
(define-struct slip (color name1 name2))
;; A slip is a (make-slip Color String String)
;; INTERPRETATION:
;; A Color is one of
;; -- "yellow"
;; -- "blue"
;; name1 is either first name or last name of student
;; name2 is either first name or last name of student

(define felleisen-slip (make-slip YELLOW "ajay" "kauthale"))
(define felleisen-slip-duplicate (make-slip YELLOW "kauthale" "ajay"))
(define felleisen-slip-not-duplicate (make-slip YELLOW "sam" "johnson"))
(define shivers-slip (make-slip BLUE "ajay" "kauthale"))
(define shivers-slip-duplicate (make-slip BLUE "kauthale" "ajay"))
(define shivers-slip-not-duplicate (make-slip BLUE "sam" "johnson"))

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

(define list-felleisen (cons felleisen-slip (cons felleisen-slip-not-duplicate empty)))
(define list-felleisen-repeated (cons felleisen-slip (cons felleisen-slip-duplicate empty)))
(define list-felleisen-same-repeated (cons felleisen-slip (cons felleisen-slip empty)))
(define list-shivers (cons shivers-slip (cons shivers-slip-not-duplicate empty)))
(define list-shivers-repeated (cons shivers-slip (cons shivers-slip-duplicate empty)))

;===========================================================================================================================
;                                      FUNCTIONS
;===========================================================================================================================
;; felleisen-roster : ListOfSlip -> ListOfSlip
;; GIVEN: a list of slips
;; RETURNS: a list of slips containing all the students in Professor
;; Felleisen's class, without duplication.
;; EXAMPLES:
;; (felleisen-roster list-felleisen-repeated) = (cons felleisen-slip empty)
;; (felleisen-roster list-felleisen-same-repeated) = (cons felleisen-slip empty)
;; (felleisen-roster list-felleisen) = (cons felleisen-slip  (cons felleisen-slip-not-duplicate empty))

;; STRATEGY: using template of ListOfSlip on slips
(define (felleisen-roster slips)
  (cond
    [(empty? slips) empty]
    [else (if (and (equal? (slip-color (first slips)) YELLOW) (already-exist? (rest slips) (first slips)))
               (cons (first slips) empty) (felleisen-roster (rest slips)))]))

;; shivers-roster : ListOfSlip -> ListOfSlip
;; GIVEN: a list of slips
;; RETURNS: a list of slips containing all the students in Professor
;; Shivers' class, without duplication.
;; EXAMPLES:
;; (shivers-roster list-shivers-repeated) = (cons shivers-slip empty)
;; (shivers-roster list-shivers) = (cons shivers-slip  (cons shivers-slip-not-duplicate empty))

;; STRATEGY: using template of ListOfSlip on slips
(define (shivers-roster slips)
  (cond
    [(empty? slips) empty]
    [else (if (and (equal? (slip-color (first slips)) BLUE) (already-exist? (rest slips) (first slips)))
               (cons (first slips) empty) (shivers-roster (rest slips)))]))

;;;; Helper function ;;;;;

;; already-exist? : ListOfSlip slip -> Boolean
;; GIVEN: a ListOfSlip and a slip
;; RETURN: true iff the slip is present in the ListOfSlip

;; STRATEGY: using template of ListOfSlip on slips
(define (already-exist? slips s)
  (cond
    [(empty? slips) false]
    [else (if (or
               (and (equal? (slip-name1 s) (slip-name1 (first slips))) (equal? (slip-name2 s) (slip-name2 (first slips))))
               (and (equal? (slip-name1 s) (slip-name2 (first slips))) (equal? (slip-name2 s) (slip-name1 (first slips)))))
              true
              (already-exist? (rest slips) s))]))

;; TESTS:
(begin-for-test
  (equal? (felleisen-roster list-felleisen-repeated) (cons felleisen-slip empty))
  (equal? (felleisen-roster list-felleisen-same-repeated) (cons felleisen-slip empty))
  (equal? (felleisen-roster list-felleisen) (cons felleisen-slip  (cons felleisen-slip-not-duplicate empty)))
  (equal? (shivers-roster list-shivers-repeated) (cons shivers-slip empty))
  (equal? (shivers-roster list-shivers) (cons shivers-slip  (cons shivers-slip-not-duplicate empty))))