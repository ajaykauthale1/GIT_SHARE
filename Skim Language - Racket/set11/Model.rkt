#lang racket

;; the model consists of a particle, bouncing with its center from x=0
;; to x=200.  It accepts commands and reports when its status changes

(require "extras.rkt")
(require "Interfaces.rkt")
(require "PerfectBounce.rkt")

(provide Model%)

(define Model%
  (class* object% (Model<%>)

    ;; boundaries of the field
    (field [lo-x 0])
    (field [hi-x 150])
    (field [lo-y 0])
    (field [hi-y 100])

    
    ;; position and velocity of the object
    (init-field [x (/ (+ lo-x hi-x) 2)])
    (init-field [y (/ (+ lo-y hi-y) 2)])
    (init-field [vx 0])
    (init-field [vy 0])

    ; ListOfController<%>
    (init-field [controllers empty])   

    (super-new)

    ;; -> Void
    ;; moves the object by v.
    ;; if the resulting x is >= 200 or <= 0
    ;; reports x at ever tick
    ;; reports velocity only when it changes
    (define/public (after-tick)
      (begin
        (set! x (within-limits lo-x (+ x vx) hi-x))
        (set! y (within-limits lo-y (+ y vy) hi-y))
        (publish-particle (make-particle x y vx vy))
        (if (or (= x hi-x) (= x lo-x))
            (begin
              (set! vx (- vx))
              (publish-particle (make-particle x y vx vy)))
            "model.rkt after-tick")
        (if (or (= y hi-y) (= y lo-y))
            (begin
              (set! vy (- vy))
              (publish-particle (make-particle x y vx vy)))
            "model.rkt after-tick")))
    
    (define (within-limits lo val hi)
      (max lo (min val hi)))

    ;; Controller -> Void
    ;; register the new controller and send it some data
    (define/public (register c)
      (begin
        (set! controllers (cons c controllers))
        (send c receive-signal (make-particle x y vx vy))))

    ;; Command -> Void
    ;; decodes the command, executes it, and sends updates to the
    ;; controllers. 
    (define/public (execute-command cmd)
      (cond
        [(particle? cmd)
         (begin
           (set! x (particle-x cmd))
           (set! y (particle-y cmd))
           (set! vx (particle-vx cmd))
           (set! vy (particle-vy cmd))
           (publish-particle cmd))]))
    
    ;; report position or velocity to each controller:
    
    (define (publish-particle cmd)
      (for-each
          (lambda (obs) (send obs receive-signal cmd))
          controllers))))




    

    