;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname ex-13) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Program to calculate distance of a point (x, y) from the origin
;; Author: Ajay Kauthale
;; Date: 09/18/2015

(require rackunit)
(require "extras.rkt")

;=========================================================================
;                              Functions
;=========================================================================

;; distance-to-origin: Real Real -> Real
;; Function to calculate distance of point (x, y) from the origin
;; GIVEN: the x and y coordinate of the point in xy-plane
;; RETURNS: the distance between origin (0, 0) and given point
;; EXAMPLE:
;; (distance-to-origin 3 4) = 5
;; (distance-to-origin -10 -10) = 14.1421...
;; (distance-to-origin 0 0) = 0
;; STRATEGY: combine simpler functions
(define (distance-to-origin x y)
  (inexact->exact
   (sqrt
    (+ (sqr x) (sqr y))))
  )

;; TESTS:
(begin-for-test
  (check-= (distance-to-origin 3 4) 5 0.0 "(distance-to-origin 3 4) should be 5")
  (check-= (distance-to-origin -10 -10) 14.14 0.1 "(distance-to-origin -10 -1) should be 14.14, plus or minus 0.1")
  (check-= (distance-to-origin 0 0) 0 0.0 "(distance-to-origin 0 0) should be 0"))