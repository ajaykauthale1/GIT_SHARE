;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname screensaver-1) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Author: Ajay Baban Kauthale
;; Date: 09/27/2015
;; Program for screensaver-1

;(check-location "03" "screensaver-1.rkt")

(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)

(provide
 screensaver
 initial-world
 world-after-tick
 world-after-key-event
 world-rect1
 world-rect2
 new-rectangle
 rect-x
 rect-y
 rect-vx
 rect-vy
 )

;; Rectangle One/ First Rectangle : is the rectangle present on the canvas with center at (200, 100)
;; Rectangle Two/ Second Rectangle : is the rectangle present on the canvas with center at (200, 200)

;==========================================================================================================================
;                                      CONSTANTS
;==========================================================================================================================
;; constant for displaying canvas
(define MT-SCENE (empty-scene 400 300))
;; constant for displaying rectangle
(define RECTANGLE (rectangle 60 50 "outline" "blue"))
;; constants for rectangle centers
(define RECT1-CENTER-X 200)
(define RECT1-CENTER-Y 100)
(define RECT2-CENTER-X 200)
(define RECT2-CENTER-Y 200)
;; constants for rectangle velocities
(define RECT1-VX -12)
(define RECT1-VY 20)
(define RECT2-VX 23)
(define RECT2-VY -14)
;; constants for checking if rectangle is crossing the canvas boundries
(define CANVAS-MIN-X 30)
(define CANVAS-MAX-X 370)
(define CANVAS-MIN-Y 25)
(define CANVAS-MAX-Y 275)

;==========================================================================================================================
;                                      DATA DEFINITIONS
;==========================================================================================================================
(define-struct Rectangle (x y vx vy))
;; A Rectangle is a (make-Rectangle Integer Integer Integer Integer)
;; INTERPRETATION:
;; x and y are the coordinates of the rectangle center
;; vx and vy are the velocities of the rectangle along with x and y axis respectively

;; TEMPLATE:
;; Rectangle-fn : Rectangle -> ??
#|(define (Rectangle-fn rect)
    ....
    (Rectangle-x rect)
    (Rectangle-y rect)
    (Rectangle-vx rect)
    (Rectangle-vy rect)
    .....)|#

;; Examples of Rectangle for testing purpose
;; rectangle one
(define rect1 (make-Rectangle RECT1-CENTER-X RECT1-CENTER-Y RECT1-VX RECT1-VY))
;; rectangle two
(define rect2 (make-Rectangle RECT2-CENTER-X RECT2-CENTER-Y RECT2-VX RECT2-VY))
;; rectangle one after tick
(define rect1-after-tick (make-Rectangle (+ RECT1-VX RECT1-CENTER-X ) (+ RECT1-VY RECT1-CENTER-Y) RECT1-VX RECT1-VY))
;; rectangle two after tick
(define rect2-after-tick (make-Rectangle (+ RECT2-VX RECT2-CENTER-X) (+ RECT2-VY RECT2-CENTER-Y) RECT2-VX RECT2-VY))
;; rectangle for testing
(define test-rect (make-Rectangle 200 200 -10 10))
;; rectangle one after crossing the canvas
(define rect1-cross-min-x (make-Rectangle 40 200 -10 10))
(define rect1-cross-max-x (make-Rectangle 370 200 -10 10))
(define rect1-cross-min-y (make-Rectangle 200 25 -10 10))
(define rect1-cross-max-y (make-Rectangle 40 285 -10 10))
;; rectangle one at the boundry of canvas
(define rect1-at-boundry-min-x (make-Rectangle 30 200 -10 10))
(define rect1-at-boundry-max-x (make-Rectangle 370 200 -10 10))
(define rect1-at-boundry-min-y (make-Rectangle 200 25 -10 10))
(define rect1-at-boundry-max-y (make-Rectangle 40 275 -10 10))

(define-struct WorldState (rect1 rect2 paused?))
;; A WorldState is a (make-WorldState Rectangle Rectangle Boolean)
;; INTERPRETATION:
;; rect1 and rect2 are two rectangles present on the screensaver
;; paused? is indicator for whether the screensaver is paused or not

;; TEMPLATE:
;; WorldState-fn : WorldState -> ??
#|(define (WorldState-fn ws)
    ....
    (WorldState-rect1 ws)
    (WorldState-rect2 ws)
    (WorldState-paused? ws)
    ....)|#

;; Examples of WorldState for testing purpose
;; initial world state
(define initial-worldState (make-WorldState
                            (make-Rectangle RECT1-CENTER-X RECT1-CENTER-Y RECT1-VX RECT1-VY)
                            (make-Rectangle RECT2-CENTER-X RECT2-CENTER-Y RECT2-VX RECT2-VY)
                            false))
;; paused initial world state
(define paused-initial-worldState (make-WorldState
                                   (make-Rectangle RECT1-CENTER-X RECT1-CENTER-Y RECT1-VX RECT1-VY)
                                   (make-Rectangle RECT2-CENTER-X RECT2-CENTER-Y RECT2-VX RECT2-VY)
                                   true))
;; world after tick
(define worldState-after-tick (make-WorldState
                          (make-Rectangle (+ RECT1-VX RECT1-CENTER-X ) (+ RECT1-VY RECT1-CENTER-Y) RECT1-VX RECT1-VY)
                          (make-Rectangle (+ RECT2-VX RECT2-CENTER-X) (+ RECT2-VY RECT2-CENTER-Y) RECT2-VX RECT2-VY)
                          false))

;===========================================================================================================================
;                                      FUNCTIONS
;===========================================================================================================================
;; screensaver : PosReal -> WorldState
;; GIVEN: the speed of the simulation, in seconds/tick
;; EFFECT: runs the simulation, starting with the initial state as
;; specified in the problem set.
;; RETURNS: the final state of the world
(define (screensaver v)
  (big-bang (initial-world v)
            (on-tick world-after-tick v)
            (on-key world-after-key-event)
            (to-draw world->scene)))

;;; Helper Functions for Screensaver ;;;;

;; world->scene : WorldState -> Image
;; GIVEN: a WorldState
;; RETURNS: the image depicting the current WorldState
;; EXAMPLES:
;; world at initial state:
#| (render-world initial-worldState) = (place-image (overlay (get-velocity-string (WorldState-rect1 initial-worldState)) RECTANGLE)
                                             (Rectangle-x (WorldState-rect1 initial-worldState))
                                             (Rectangle-y (WorldState-rect1 initial-worldState))
                                             (place-image
                                              (overlay (get-velocity-string (WorldState-rect2 initial-worldState)) RECTANGLE)
                                              (Rectangle-x (WorldState-rect2 initial-worldState))
                                              (Rectangle-y (WorldState-rect2 initial-worldState))
                                              MT-SCENE))|#

;; STRATEGY: combine simpler functions and using template of WorldState on ws

(define (world->scene ws)
  (place-image (overlay (get-velocity-string (WorldState-rect1 ws)) RECTANGLE) (Rectangle-x (WorldState-rect1 ws)) (Rectangle-y (WorldState-rect1 ws))
               (place-image
                (overlay (get-velocity-string (WorldState-rect2 ws)) RECTANGLE) (Rectangle-x (WorldState-rect2 ws)) (Rectangle-y (WorldState-rect2 ws))
                MT-SCENE)))

;; get-velocity-string : Rectangle -> Image
;; GIVEN: a Rectangle
;; RETURNS: the text of velocities in the form of (vx, vy)
;; EXAMPLES:
;; (get-velocity-string rect1) = (text "(-12, 20)" 12 "blue")

;; STRATEGY: using template of Rectangle
(define (get-velocity-string rect)
  (text (string-append "(" (number->string (Rectangle-vx rect)) ", " (number->string (Rectangle-vy rect)) ")") 12 "blue"))

;; TESTS:
(begin-for-test
  ;; test if the initial world is rendered correctly
  (check-equal?
   (world->scene initial-worldState)
   (place-image
    (overlay (get-velocity-string (WorldState-rect1 initial-worldState)) RECTANGLE) (Rectangle-x (WorldState-rect1 initial-worldState))
    (Rectangle-y (WorldState-rect1 initial-worldState))
    (place-image
     (overlay (get-velocity-string (WorldState-rect2 initial-worldState)) RECTANGLE) (Rectangle-x (WorldState-rect2 initial-worldState))
     (Rectangle-y (WorldState-rect2 initial-worldState))
     MT-SCENE))))

;=================================================================================================================

;; initial-world : Any -> WorldState
;; GIVEN: any value (ignored)
;; RETURNS: the initial world specified in the problem set
;; EXAMPLES:
;; Get world at initial state
;; (initial-world 0) = initial-worldState
(define (initial-world input)
  (make-WorldState (make-Rectangle RECT1-CENTER-X RECT1-CENTER-Y RECT1-VX RECT1-VY)
                   (make-Rectangle RECT2-CENTER-X RECT2-CENTER-Y RECT2-VX RECT2-VY) false))

;; TESTS:
(begin-for-test
  ;; test if the  method returns the initial world
  (check-equal? (initial-world 0) initial-worldState "initial-world should return the world in initial state"))
;=================================================================================================================

;; world-after-tick : WorldState -> WorldState
;; GIVEN: current worldState
;; RETURNS: the world state that should follow the given world state after a tick
;; EXAMPLES:
;; (world-after-tick initial-worldState) = worldState-after-tick
;; (world-after-tick paused-initial-worldState) = paused-initial-worldState

;; STRATEGY: combine using simpler functions
(define (world-after-tick ws)
  (cond
    [(WorldState-paused? ws) ws]
    [else (make-WorldState (world-rect1 ws) (world-rect2 ws) (WorldState-paused? ws))]))

;; TESTS:
(begin-for-test
  ;; test whether initial world is changed after tick
  (check-equal? (world-after-tick initial-worldState) worldState-after-tick
                "world-after-tick should return new worldstate after tick")
  ;; test whether paused world is remaining same
  (check-equal? (world-after-tick paused-initial-worldState) paused-initial-worldState
                "world-after-tick should return same worldstate after tick for paused world"))
;=================================================================================================================

;; world-after-key-event : WorldState KeyEvent -> WorldState
;; GIVEN: current worldState
;; RETURNS: the WorldState that should follow the given worldstate after the given keyevent
;; EXAMPLES:
;; (world-after-key-event initial-worldState " ") = paused-initial-worldState
;; (world-after-key-event initial-worldState "a") = worldState-after-tick

;; STRATEGY: combine simpler functions and using cases on key event ke
(define (world-after-key-event ws ke)
  (cond
    [(key=? ke " ")
     (make-WorldState (WorldState-rect1 ws) (WorldState-rect2 ws) (not (WorldState-paused? ws)))]
    [else (world-after-tick ws)]))

;; TESTS:
(begin-for-test
  ;; test if the world is paused by pressing bar or not
  (check-equal? (world-after-key-event initial-worldState " ") paused-initial-worldState
                "world-after-key-event should return paused world after space bar event")
  ;; test if the world is not paused for any other event than space bar
  (check-equal? (world-after-key-event initial-worldState "a") worldState-after-tick
                "world-after-key-event should not do anything for this event"))
;=================================================================================================================

;; world-rect1 : WorldState -> Rectangle
;; GIVEN: current worldState
;; RETURNS: the first rectangle from the WorldState
;; EXAMPLES:
;; (world-rect1 initial-worldState) = rect1-after-tick

;; STRATEGY: use templates of WorldState on ws
(define (world-rect1 ws)
  (new-rectangle (rect-x (WorldState-rect1 ws)) (rect-y (WorldState-rect1 ws)) (rect-vx (WorldState-rect1 ws)) (rect-vy (WorldState-rect1 ws)))
  )

;; TESTS:
(begin-for-test
  ;; test if function return the first rectangle after tick or not
  (check-equal? (world-rect1 initial-worldState) rect1-after-tick "world-rect1 should return first rectangle after changing it's coordinates"))
;=================================================================================================================

;; world-rect2 : WorldState -> Rectangle
;; GIVEN: current worldState
;; RETURNS: the second rectangle from the WorldState
;; EXAMPLES:
;; (world-rect1 initial-worldState) = rect2-after-tick

;; STRATEGY: use template of WorldState on ws
(define (world-rect2 ws)
  (new-rectangle (rect-x (WorldState-rect2 ws)) (rect-y (WorldState-rect2 ws)) (rect-vx (WorldState-rect2 ws)) (rect-vy (WorldState-rect2 ws))))

;; TESTS:
(begin-for-test
  ;; test if function return the second rectangle after tick or not
  (check-equal? (world-rect2 initial-worldState) rect2-after-tick "world-rect2 should return second rectangle after changing it's coordinates"))
;=================================================================================================================

;; new-rectangle : NonNegInt NonNegInt Int Int -> Rectangle
;; GIVEN: 2 non-negative integers x and y, and 2 integers vx and vy
;; RETURNS: a rectangle centered at (x,y), which will travel with velocity (vx, vy)
;; EXAMPLES:
;; (new-rectangle 200 200 -10 10) = TEST-RECT
(define (new-rectangle x y vx vy)
  (make-Rectangle x y vx vy))

;; TESTS:
(begin-for-test
  ;; T=test if rectangle is created with the given x and y coordinates and velocity
  (check-equal? (new-rectangle 200 200 -10 10) test-rect "new-rectangle should return new rectangle with given specs"))
;=================================================================================================================

;; rect-x : Rectangle -> NonNegInt
;; GIVEN: a rectangle
;; RETURNS: the x coordinate of the center of the rectangle by adding velocity vx
;; EXAMPLES:
;; (rect-x rect1) = 188
;; (rect-x rect1-cross-min-x) = CANVAS-MIN-X
;; (rect-x rect1-cross-max-x) = CANVAS-MAX-X

;; STRATEGY: use template of Rectangle on rect
(define (rect-x rect)
  (cond
    [(<= (+ (Rectangle-x rect) (rect-vx rect)) CANVAS-MIN-X) CANVAS-MIN-X]
    [(>= (+ (Rectangle-x rect) (rect-vx rect)) CANVAS-MAX-X) CANVAS-MAX-X]
    [else (+ (Rectangle-x rect) (rect-vx rect))]))

;; TESTS:
(begin-for-test
  ;; test when x coordinate of rectangle is not at the edge of canvas
  (check-equal? (rect-x rect1) 188 "rect-x should return x coordinate after adding vx")
  ;; test when x coordinate of rectangle at the left edge of canvas
  (check-equal? (rect-x rect1-cross-min-x) CANVAS-MIN-X "rect-x should return x coordinate CANVAS-MIN-X")
  ;; test when x coordinate of rectangle at the right edge of the canvas
  (check-equal? (rect-x rect1-cross-max-x) CANVAS-MAX-X "rect-x should return x coordinate CANVAS-MAX-X"))
;=================================================================================================================

;; rect-y : Rectangle -> NonNegInt
;; GIVEN: a rectangle
;; RETURNS: the y coordinate of the center of the rectangle
;; EXAMPLES:
;; (rect-y rect1) = 120
;; (rect-y rect1-cross-min-y) = CANVAS-MIN-Y
;; (rect-y rect1-cross-max-y) = CANVAS-MAX-Y

;; STRATEGY: use template of Rectangle on rect
(define (rect-y rect)
  (cond
    [(<= (+ (Rectangle-y rect) (rect-vy rect)) CANVAS-MIN-Y) CANVAS-MIN-Y]
    [(>= (+ (Rectangle-y rect) (rect-vy rect)) CANVAS-MAX-Y) CANVAS-MAX-Y]
    [else (+ (Rectangle-y rect) (rect-vy rect))]))

;; TESTS:
(begin-for-test
  ;; test when y coordinate of rectangle is not at the edge of canvas
  (check-equal? (rect-y rect1) 120 "rect-x should return y coordinate after adding vy")
  ;; test when y coordinate of rectangle at the top edge of canvas
  (check-equal? (rect-y rect1-cross-min-y) CANVAS-MIN-Y"rect-y should return y coordinate CANVAS-MIN-Y")
  ;; test when y coordinate of rectangle at the bottom edge of canvas
  (check-equal? (rect-y rect1-cross-max-y) CANVAS-MAX-Y"rect-y should return y coordinate CANVAS-MIN-Y"))
;=================================================================================================================

;; rect-vx : Rectangle -> Int
;; GIVEN: a rectangle
;; RETURNS: the velocity of the rectangle in direction x
;; EXAMPLES:
;; (rect-vx RECT1) = -12
;; (rect-vx RECT1-AT-BOUNDRY-MIN-X) = 10
;; (rect-vx RECT1-AT-BOUNDRY-MAX-X) = 10

;; STRATEGY: use template of Rectangle on rect
(define (rect-vx rect)
  (cond
    [(or (<= (Rectangle-x rect) CANVAS-MIN-X) (>= (Rectangle-x rect) CANVAS-MAX-X)) (- 0 (Rectangle-vx rect))]
    [else (Rectangle-vx rect)]))

;; TESTS:
(begin-for-test
  ;; test when rectangle inside canvas
  (check-equal? (rect-vx rect1) -12 "rect-vx should return the velocity as same")
  ;; test when rectangle at the left edge
  (check-equal? (rect-vx rect1-at-boundry-min-x) 10 "rect-vx should reverse the velocity at left edge")
  ;; test when rectangle at the right
  (check-equal? (rect-vx rect1-at-boundry-max-x) 10 "rect-vx should reverse the velocity at right edge"))
;=================================================================================================================

;; rect-vy : Rectangle -> Int
;; GIVEN: a rectangle
;; RETURNS: the velocity of the rectangle in direction y
;; EXAMPLES:
;; (rect-vy RECT1) = 20
;; (rect-vy RECT1-AT-BOUNDRY-MIN-Y) = -10
;; (rect-vy RECT1-AT-BOUNDRY-MAX-Y) = -10

;; STRATEGY: use template of Rectangle on rect
(define (rect-vy rect)
  (cond
    [(or (<= (Rectangle-y rect) 25) (>= (Rectangle-y rect) 275)) (- 0 (Rectangle-vy rect))]
    [else (Rectangle-vy rect)]))

;; TESTS:
(begin-for-test
  ;; test when rectangle inside canvas
  (check-equal? (rect-vy rect1) 20 "rect-vy should return the velocity as same")
  ;; test when rectangle at top edge
  (check-equal? (rect-vy rect1-at-boundry-min-y) -10 "rect-vy should reverse the velocity at top edge")
  ;; test when rectangle at bottom edge
  (check-equal? (rect-vy rect1-at-boundry-max-y) -10 "rect-vy should reverse the velocity at bottom edge"))
;=================================================================================================================