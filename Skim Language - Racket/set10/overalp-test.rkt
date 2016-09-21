#lang racket
(define (checkOverlap x1 y1 x2 y2)
  (not
   (or (< (+ x1 20) x2) (< (+ y1 20) y2)
       (> x1 (+ x2 20)) (> y1 (+ y2 20)))))


(define (overlap? x1 y1 x2 y2)
  (not
       (or (<= (+ x1 20) x2) (<= (+ y1 20) y2)
           (>= x1 (+ x2 20)) (>= y1 (+ y2 20)))))