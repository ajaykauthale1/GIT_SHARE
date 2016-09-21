#lang racket

;; displays as an outline rectangle with text showing the x
;; coordinate and velocity of the particle.

;; the rectangle is draggable

;; up and down increments or decrements the speed of the particle

(require 2htdp/image)
(require 2htdp/universe)
(require "Interfaces.rkt")
(require "PerfectBounce.rkt")

(provide InputController%)

;; a VelocityController% is a (new VelocityController% [model Model<%>])

(define InputController%
  (class* object% (Controller<%>)

    (init-field model)  ; the model

    ; Nats -- the position of the center of the controller
    (init-field [x 300] [y 250])   

    (init-field [width 160][height 50])
    
     ;; the particle
    (field [p particle])

    (field [half-width  (/ width  2)])
    (field [half-height (/ height 2)])

    ;; fields for dragging
    ;; It there has ever been a button-down in this object, then these
    ;; contain the position of last button-down relative to
    ;; center of viewer.  Else any value
    (field [selected? false])
    (field [controller-selected? false])
    (field [saved-mx 0])
    (field [saved-my 0])

    (super-new)
    (send model register this)

    ;;
    (define/public (get-selected?) selected?)
    
    ;; Signal -> Void
    ;; decodes signal and updates local data
    (define/public (receive-signal sig)
      (cond
        [(particle? sig)
         (begin
           (set! p sig))]))

    ; after-button-down : Integer Integer -> Void
    ; GIVEN: the location of a button-down event
    ; EFFECT: makes the viewer selected
    ; STRATEGY: Cases on whether the event is in this object
    (define/public (after-button-down mx my)
      (begin
        (if (in-handle? mx my)
            (begin
              (set! selected? true)
              (set! saved-mx (- mx x))
              (set! saved-my (- my y)))
            3742)
        (if (in-controller? mx my)
            (set! controller-selected? true)
            3742)))
    
    ; after-button-up : Integer Integer -> Void
    ; GIVEN: the (x,y) location of a button-up event
    ; EFFECT: makes this unselected
    (define/public (after-button-up mx my)
      (begin
        (set! selected? false)
        (set! controller-selected? false)))
      

    ; after-drag : Integer Integer -> Void
    ; GIVEN: the location of a drag event
    ; STRATEGY: Cases on whether this is selected.
    ; If it is selected, move it so that the vector from its position to
    ; the drag event is equal to saved-mx.  Report the new position to
    ; the registered balls.
    (define/public (after-drag mx my)
      (if selected?
        (begin
          (set! x (- mx saved-mx))
          (set! y (- my saved-my)))
        2744))

    (define (in-handle? other-x other-y)
      (and
        (<= (- x half-width) other-x (+ (- x half-width) 10))
        (<= (- y half-height) other-y (+ (- y half-height) 10))))

    (define (in-controller? other-x other-y)
      (and
        (<= (- x half-width) other-x (+ x half-width))
        (<= (- y half-height) other-y (+ y half-height))))

    ;; add-to-scene : Scene -> Scene
    ;; RETURNS: a scene like the given one, but with this wall painted
    ;; on it.
    ;; STRATEGY: place the image centered at x y
    (define/public (add-to-scene scene)
      (place-image (viewer-image) x y scene))
    
    (define/public (after-tick) 'viewer1-after-tick-trap)

    ;; KeyEvent -> Void
    ;; interpret +,- as commands to the model
    ;; +/- alter velocity of the particle
    (define/public (after-key-event kev)
      this)

    (define (current-color)
      (if selected? "red" "black"))

    (define (text-color)
      (if controller-selected? "red" "black"))

    ;; assemble the image of the viewer
    (define (viewer-image)
      (local
        ((define the-data-image (data-image)))
        (place-image
         (square 10 "outline" (current-color))
         (- half-width (- half-width 5))
         (- half-height (- half-height 5))
         (place-image
          the-data-image
          half-width 22
          (place-image
           (rectangle width height "outline" "black")
           half-width half-height
           (empty-scene width height))))))
    
    (define (data-image)
      (above
       (text "Arrow keys change velocity" 11 (text-color))
       (text (string-append
                "X = "
              (get-exact-num (particle-x p))
              " Y = "
              (get-exact-num (particle-y p)))
             12
             (text-color))
       (text (string-append
              "VX = "
              (number->string (particle-vx p))
              " VY = "
              (number->string (particle-vy p)))
             12
             (text-color))))

    (define (get-exact-num num)
      (local
        ((define str (number->string (exact->inexact (particle-x p)))))
        (if (>= (string-length str) 5)
            (substring str 0 5)
            (if (>= (string-length str) 4)
                (substring str 0 4)
                (substring str 0 3)))))
    ))

