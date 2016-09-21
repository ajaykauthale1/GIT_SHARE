#lang racket
(define empty-canvas (empty-scene 400 200))

(require 2htdp/image)
(require 2htdp/universe)

(define image5
  (place-image
    (rectangle 60 60 "outline" "blue")
    100 100
    empty-canvas))
(define image6
 (place-image
  (text "why?" 20 "blue")
  100 100
  (place-image
   (rectangle 60 60 "outline" "blue")
   100 100
   empty-canvas)))

image6