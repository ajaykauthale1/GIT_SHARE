#lang racket


(define (main t)
  (big-bang
   (on-tick expand)
   (to-draw drawit)))

(define (expand ))
