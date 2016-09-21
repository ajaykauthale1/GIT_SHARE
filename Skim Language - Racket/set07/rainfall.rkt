;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname rainfall) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Program for rainfall

(require rackunit)
(require 2htdp/universe)
(require 2htdp/image)
(require "extras.rkt")
(require "sets.rkt")

(provide rainfall)

;=========================================================================================
;                                      DATA DEFINITIONS
;=========================================================================================
;; A List of Number (ListOfNumber) is one of:
;; -- empty
;; -- (cons n ListOfNumber)
;; INTERPRETATION:
;; empty represents the empty list
;; (cons n ListOfNumber) represents the list of Number with newly added number n
;; WHERE: n can be -999 which will indicate end of data of interest

;; TEMPLATE:
;; listOfNumber-fn : ListOfNumber -> ??
#|(define (listOfNumber-fn lon)
  (cond
    [(or (empty? secs) (= -999 (first lon)))... ]
    [else (... (first lon)
               (listOfNumber-fn (rest ln)))]))|#


;=========================================================================================
;                                      FUNCTIONS
;=========================================================================================
;; rainfall : ListOfNumber -> NonNegNumber
;; GIVEN: a ListOfNumber
;; WHERE: -999 indicate end of data of interest
;; RETURNS: the avegage of all non-negative numbers from list until end of data of
;; interest
;; EXAMPLES: see the tests below

;; STRATEGY: using more general functions
(define (rainfall lon)
  (if (empty? (get-data-of-interest lon))
      0 (/ (get-rainfall-sum
            (rest (get-data-of-interest lon))
            (first (get-data-of-interest lon)))
           (get-data-of-interest-count
            (get-data-of-interest lon) 0))))

;; TESTS:
;; constants for testing
(define empty-lon empty)
(define lon-1 (list 1 1 -1 -1 2 2 -2 -2 -999 9 10 11))
(define lon-2 (list -999 1 2 42 4))
(define lon-3 (list 5 5 5 5 -5 -999 40))

(begin-for-test
  (check-equal? (rainfall empty-lon) 0)
  (check-equal? (rainfall lon-1) 1.5)
  (check-equal? (rainfall lon-2) 0)
  (check-equal? (rainfall lon-3) 5))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get-rainfall-sum : ListOfNumber NonNegNumber -> NonNegNumber
;; GIVEN: a ListOfNumber and sum- NonNegNumber
;; WHERE: lon is part of some large lon0 and sum indicate the sum of non-negative numbers
;; from lon0 until the sub-list lon occurs. i.e. if lon0 - (list 1 2 3 4),
;; lon - (list 3 4), then sum = 3
;; RETURNS: the sum of all numbers from the list
;; EXAMPLES:
;; (get-rainfall-sum (list 1 2 4) 0) = 7

;; STRATEGY: using HOF foldl on lon
(define (get-rainfall-sum lon sum)
  (foldl
   ;; NonNegNumber NonNegNumber -> NonNegNumber
   ;; GIVEN: two numbers
   ;; RETURNS: a sum of two numbers if first number is non-negative, otherwise returns
   ;; second number
   (lambda (num sum) (if (>= num 0) (+ num sum) sum))
   sum lon))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get-data-of-interest-count : ListOfNumber NonNegNumber -> NonNegNumber
;; GIVEN: a ListOfNumber and NonNegNumber
;; WHERE: lon is part of some large lon0 and cnt indicate the count of non-negative
;; numbers occured in lon0 until the sub-list lon occurs. i.e. if lon0 - (list 1 2 3 4),
;; lon - (list 3 4), then cnt = 2
;; RETURNS: the count of non-negative numbers from the ListOfNumber
;; EXAMPLES:
;; (get-data-of-interest-count (list 1 2 -1 -5 1) 0) = 3

;; STRATEGY: using HOF foldl on lon
(define (get-data-of-interest-count lon cnt)
  (foldl
   ;; NonNegNumber NonNegNumber -> NonNegNumber
   ;; GIVEN: two numbers
   ;; RETURNS: second number incremented by one if first number is non-negative, otherwise
   ;; second number
   (lambda (num cnt) (if (>= num 0) (+ 1 cnt) cnt))
   cnt lon))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get-data-of-interest : ListOfNumber -> ListOfNumber
;; GIVEN: a ListOfNumber
;; WHERE: -999 indicate the end of data of interest
;; RETURNS: the ListOfNumber until first occurance of -999
;; EXAMPLES:
;; (get-data-of-interest (list 1 5 -1 -999 10 3 1)) = (list 1 5 -1)

;; STRATEGY: using template of ListOfNumber on lon
(define (get-data-of-interest lon)
  (cond
    [(or (empty? lon) (= -999 (first lon)))
     empty]
    [else
     (cons (first lon) (get-data-of-interest (rest lon)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;