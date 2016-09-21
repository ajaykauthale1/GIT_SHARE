#lang racket

(require "Model.rkt")
(require "ParticleWorld.rkt")
(require "ControllerFactory.rkt")


(define (run rate)
  (let* ((m (new Model%))
         (w (make-world m 600 500)))
    (begin
      (send w add-widget
        (new ControllerFactory% [m m][w w]))
      (send w run rate))))


