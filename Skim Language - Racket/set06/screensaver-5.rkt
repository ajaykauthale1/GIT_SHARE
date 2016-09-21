;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname screensaver-5) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Author: Ajay Baban Kauthale
;; Date: 10/12/2015
;; Program for screensaver-5 using HOF

;(check-location "05" "screensaver-5.rkt")

(require rackunit)
(require "extras.rkt")

(provide screensaver initial-world world-after-tick world-after-key-event new-rect
         rect-x rect-y rect-vx rect-vy world-paused? world-after-mouse-event
         rect-after-mouse-event rect-selected? world-rects rect-after-key-event
         rect-pen-down?)


;=========================================================================================
;                                      CONSTANTS
;=========================================================================================
;; constant for displaying canvas
(define MT-SCENE (empty-scene 400 300))
;; constants for screen center
(define CANVAS-CENTER-X 200)
(define CANVAS-CENTER-Y 150)
;; constants for rect width and height
(define RECT-WIDTH 60)
(define RECT-HEIGHT 50)
;; constants for half of width and height
(define RECT-HALF-WIDTH (/ RECT-WIDTH 2))
(define RECT-HALF-HEIGHT (/ RECT-HEIGHT 2))
;; constant for displaying rect
(define RECTANGLE (rectangle 60 50 "outline" "blue"))
;; constant for displaying circle
(define POINT-CIRCLE (circle 5 "outline" "red"))
;; constant for displaying rect of red color
(define RED-RECTANGLE (rectangle RECT-WIDTH RECT-HEIGHT "outline" "red"))
;; constant for displaying track of rect center
(define TRACK-POINT (circle 1 "solid" "black"))
;; constants for rect centers
(define RECT1-CENTER-X 200)
(define RECT1-CENTER-Y 100)
(define RECT2-CENTER-X 200)
(define RECT2-CENTER-Y 200)
;; constants for rect velocities
(define RECT1-VX -12)
(define RECT1-VY 20)
(define RECT2-VX 23)
(define RECT2-VY -14)
;; constants for checking if rect is crossing the canvas boundries
(define CANVAS-MIN-X 30)
(define CANVAS-MAX-X 370)
(define CANVAS-MIN-Y 25)
(define CANVAS-MAX-Y 275)
;; constants for mouse evevents
(define BUTTON-DOWN "button-down")
(define BUTTON-UP "button-up")
(define DRAG "drag")
(define ENTER "enter")
;; constants for button events
(define UP "up")
(define DOWN "down")
(define LEFT "left")
(define RIGHT "right")
(define BUTTON-N "n")
(define BUTTON-D "d")
(define BUTTON-U "u")
;; constants for co-ordinate zero
(define ZERO 0)

;=========================================================================================
;                                      DATA DEFINITIONS
;=========================================================================================
(define-struct point (x y))
;; A Point is a (make-point (Integer Integer))
;; INTERPRETATION:
;; x and y are the coordinates of the point on the canvas

;; TEMPLATE:
;; Point-fn : Point -> ??
#|(define (Point-fn pt)
  ....
  (point-x pt)
  (point-y pt)
  ....)|#

;; A List of Point (ListOfPoint) is one of:
;; -- empty
;; -- (cons pt ListOfPoint)
;; Interpretation:
;; empty represents the empty list
;; (cons pt ListOfPoint) represents the list of points with newly added point pt

;; TEMPLATE:
;; ListOfPoint-fn -> ??
#|(define (ListOfPoint-fn pts)
  (cond
    [(empty? pts) ... ]
    [else (... (first pts)
               (ListOfPoint-fn (rest pts)))]))|#

(define-struct rect (x y vx vy selected? dx dy pendown?))
;; A Rect is a (make-rect NonNegInt NonNegInt Integer Integer Boolean NonNegInt
;;                   NonNegInt Boolean)
;; INTERPRETATION:
;; x and y are the coordinates of the rect center
;; vx and vy are the velocities of the rect along with x and y axis respectively
;; selected? for showing whether the rect is selected or not
;; dx and dy are coordinates of the point where mouse drag event occured
;; (inside rect)
;; pendown? is indicator for showing the track of rect center on the canvas

;; TEMPLATE:
;; Rect-fn : Rect -> ??
#|(define (Rect-fn rect)
    ....
    (rect-x rect)
    (rect-y rect)
    (rect-vx rect)
    (rect-vy rect)
    (rect-selected? rect)
    (rect-dx rect)
    (rect-dy rect)
    (rect-pendown? rect)
    .....)|#

;; Examples of Rect for testing purpose
;; rect one
(define rect1 (make-rect RECT1-CENTER-X RECT1-CENTER-Y RECT1-VX RECT1-VY false
                              ZERO ZERO false))
;; rect two
(define rect2 (make-rect RECT2-CENTER-X RECT2-CENTER-Y RECT2-VX RECT2-VY false
                              ZERO ZERO false))
;; rect one after tick
(define rect1-after-tick (make-rect (+ RECT1-VX RECT1-CENTER-X )
                                         (+ RECT1-VY RECT1-CENTER-Y)
                                         RECT1-VX RECT1-VY false ZERO ZERO false))
;; rect two after tick
(define rect2-after-tick (make-rect (+ RECT2-VX RECT2-CENTER-X)
                                         (+ RECT2-VY RECT2-CENTER-Y)
                                         RECT2-VX RECT2-VY false ZERO ZERO false))
;; selected rects
(define rect1-selected (make-rect RECT1-CENTER-X RECT1-CENTER-Y RECT1-VX RECT1-VY
                                       true ZERO ZERO false))
(define rect2-selected (make-rect RECT2-CENTER-X RECT2-CENTER-Y RECT2-VX RECT2-VY
                                       true ZERO ZERO false))
;; rect with pen down
(define rect2-pendown (make-rect RECT2-CENTER-X RECT2-CENTER-Y RECT2-VX RECT2-VY
                                      true ZERO ZERO true))
;; rect for testing
(define test-rect (make-rect 200 200 -10 10 false ZERO ZERO false))
;; rect one after crossing the canvas
(define rect1-cross-min-x (make-rect 40 200 -10 10 false ZERO ZERO false))
(define rect1-cross-max-x (make-rect 370 200 -10 10 false ZERO ZERO false))
(define rect1-cross-min-y (make-rect 200 25 -10 10 false ZERO ZERO false))
(define rect1-cross-max-y (make-rect 40 285 -10 10 false ZERO ZERO false))
;; rect one at the boundry of canvas
(define rect1-at-boundry-min-x (make-rect 30 200 -10 10 false ZERO ZERO false))
(define rect1-at-boundry-max-x (make-rect 370 200 -10 10 false ZERO ZERO false))
(define rect1-at-boundry-min-y (make-rect 200 25 -10 10 false ZERO ZERO false))
(define rect1-at-boundry-max-y (make-rect 40 275 -10 10 false ZERO ZERO false))
;; rect at the center of the canvas
(define rect-at-canvas-center (make-rect CANVAS-CENTER-X CANVAS-CENTER-Y ZERO ZERO
                                              false ZERO ZERO false))
(define rect-at-canvas-center-selected (make-rect CANVAS-CENTER-X CANVAS-CENTER-Y
                                                       ZERO ZERO true ZERO ZERO false))
;; rect after different key events
(define rect1-selected-speed-up (make-rect CANVAS-CENTER-X CANVAS-CENTER-Y 0 -2
                                                true ZERO ZERO false))
(define rect1-selected-speed-down (make-rect CANVAS-CENTER-X CANVAS-CENTER-Y 0 2
                                                  true ZERO ZERO false))
(define rect1-selected-speed-left (make-rect CANVAS-CENTER-X CANVAS-CENTER-Y -2 0
                                                  true ZERO ZERO false))
(define rect1-selected-speed-right (make-rect CANVAS-CENTER-X CANVAS-CENTER-Y 2 0
                                                   true ZERO ZERO false))

;; A List of Rect (ListOfRect) is one of:
;; -- empty
;; -- (cons rect ListOfRect)
;; Interpretation:
;; empty represents the empty list
;; (cons rect ListOfRect) represents the list of rect's with newly
;; added rect rect

;; TEMPLATE:
;; ListOfRect-fn -> ??
#|(define (ListOfRect-fn rects)
  (cond
    [(empty? rects) ... ]
    [else (... (first rects)
               (ListOfRect-fn (rest rects)))]))|#

(define-struct world (rects paused? pts))
;; A World is a (make-world ListOfRect Boolean ListOfPoint)
;; INTERPRETATION:
;; rects is the list of rects present on the screensaver
;; paused? is indicator for whether the screensaver is paused or not
;; pts is ListPoints for showing track of rects

;; TEMPLATE:
;; world-fn : World -> ??
#|(define (world-fn ws)
    ....
    (world-rects ws)
    (world-paused? ws)
    (world-pts ws)
    ....)|#

;; Examples of World for testing purpose
;; initial world state
(define initial-worldstate (make-world empty true empty))
;; world state with added rect
(define initial-worldstate-with-rect (make-world (list rect-at-canvas-center)
                                                      true empty))
(define initial-worldstate-with-rect-selected
  (make-world (list rect-at-canvas-center-selected) true empty))
;; unpaused initial world state
(define unpaused-initial-worldstate (make-world empty false empty))
;; world after tick
(define worldstate-after-tick (make-world empty true empty))
;; worlds where rects are selected
(define worldstate-with-rect1 (make-world (list rect1-selected) true empty))
(define worldState-with-empy-rects (make-world empty true empty))
;; worlds after various arrow key events
(define worldstate-after-key-up
  (make-world (list rect1-selected-speed-up) true empty))
(define worldstate-after-key-down
  (make-world (list rect1-selected-speed-down) true empty))
(define worldstate-after-key-right
  (make-world (list rect1-selected-speed-right) true empty))
(define worldstate-after-key-left
  (make-world (list rect1-selected-speed-left) true empty))
;; worlds after button events
(define worldstate-pen-up (make-world (list rect2-selected) true empty))
(define worldstate-pen-down (make-world (list rect2-pendown) true empty))

;; world corresponds to the state of the World
;; rect corresponds to the Rectangle in the world

;=========================================================================================
;                                      FUNCTIONS
;=========================================================================================
;; screensaver : PosReal -> World
;; GIVEN: the speed of the simulation, in seconds/tick
;; EFFECT: runs the simulation, starting with the initial state as
;; specified in the problem set.
;; RETURNS: the final state of the world

;; STRATEGY: combine using simpler functions
(define (screensaver v)
  (big-bang (initial-world v)
            (on-tick world-after-tick v)
            (on-key world-after-key-event)
            (on-mouse world-after-mouse-event)
            (to-draw world->scene)))

;;; Helper Functions for Screensaver ;;;;

;; world->scene : World -> Image
;; GIVEN: a World
;; RETURNS: the image depicting the current World with red circle as a pointer if any
;; of the rect is selected
;; EXAMPLES:
;; world at initial state:
#| (world->scene initial-worldstate) = (get-rects-for-display
                                      (world-rects initial-worldstate))
   (world->scene worldstate-with-rect1) = (place-image POINT-CIRCLE
                                          (cursor-x
                                              (world-rects worldstate-with-rect1))
                                          (cursor-y
                                              (world-rects worldstate-with-rect1))
                                          (get-rects-for-display
                                           (world-rects worldstate-with-rect1)))|#

;; STRATEGY: using template of World on ws
(define (world->scene ws)
  (get-track-points (world-pts ws) ws))

;; get-track-points : ListOfPoint World -> Image
;; GIVEN: the list of points and world state
;; RETURNS: the image of world showing the rects with their track points if pen is
;; down for them
;; EXAMPLES:
#|(get-track-points (list (make-point 40 40)) initial-worldstate) =
(place-image TRACK-POINT 40 40
             place-image POINT-CIRCLE
             (cursor-x (get-selected-rects (world-rects initial-worldstate)))
             (cursor-y (get-selected-rects (world-rects initial-worldstate)))
             (get-rects-for-display (world-rects initial-worldstate))))|#

;; STRATEGY: using template of ListOfPoint on pts
(define (get-track-points pts ws)
  (cond
    [(empty? pts)
     (place-image POINT-CIRCLE
                  (cursor-x (get-selected-rects (world-rects ws)))
                  (cursor-y (get-selected-rects (world-rects ws)))
                  (get-rects-for-display (world-rects ws)))]
    [else (place-image TRACK-POINT (point-x (first pts)) (point-y (first pts))
                       (get-track-points (rest pts) ws))]))

;; get-rects-for-display : ListOfRect -> Image
;; GIVEN: a ListOfRect
;; RETURNS: the image with all rects in the list are drawn on the scene
;; EXAMPPLES:
;; (get-rects-for-display empty) = MT-SCENE
;; (get-rects-for-display (list rect1)) = (place-image (get-rect-for-display rect1)
;;                                         RECT1-CENTER-X RECT1-CENTER-Y MT-SCENE)

;; STRATEGY: using template of ListOfRect on rects
(define (get-rects-for-display rects)
  (cond
    [(empty? rects) MT-SCENE]
    [else (place-image (get-rect-for-display (first rects))
                       (rect-x (first rects)) (rect-y (first rects))
                       (get-rects-for-display (rest rects)))]))

;; cursor-x : ListOfRect -> Integer
;; GIVEN: a ListOfRect
;; WHERE: a ListOfRect contains the rects which are selected
;; RETURNS: x coordinate of the cursor on the canvas if list has the selected rect
;; otherwise return -10 (out of canvas)
;; EXAMPLES:
;; (cursor-x (list rect1)) = -10

;; STRATEGY: using template of ListOfRect on rects
(define (cursor-x rects)
  (cond
    [(empty? rects) -10]
    [else
     (- (rect-x (first rects)) (rect-dx (first rects)))]))

;; cursor-y : ListOfRect -> Integer
;; GIVEN: a ListOfRect
;; WHERE: a ListOfRect contains the rects which are selected
;; RETURNS: y coordinate of the cursor on the canvas if list has the selected rect
;; otherwise return -10 (out of canvas)
;; EXAMPLES:
;; (cursor-y (list rect1)) = -10

;; STRATEGY: using template of ListOfRect on rects
(define (cursor-y rects)
  (cond
    [(empty? rects) -10]
    [else
     (- (rect-y (first rects)) (rect-dy (first rects)))]))

;; get-rect-for-display : Rect -> Image
;; GIVEN: A Rect
;; RETURNS: the rect with red outline if it is selected
;; EXAMPLES:
;; (get-rect-for-display rect1) = (overlay (get-velocity-string rect1) RECTANGLE)

;; STRATEGY: using template of Rect on rect
(define (get-rect-for-display rect)
  (if (rect-selected? rect)
      (overlay (get-velocity-string rect) RED-RECTANGLE)
      (overlay (get-velocity-string rect) RECTANGLE)))

;; get-velocity-string : Rect -> Image
;; GIVEN: A Rect
;; RETURNS: the text of velocities in the form of (vx, vy) in red if the rect is
;; selected
;; EXAMPLES:
;; (get-velocity-string rect1) = (text "(-12, 20)" 12 "blue")

;; STRATEGY: using template of Rect on rect
(define (get-velocity-string rect)
  (if (rect-selected? rect)
      (text (string-append "(" (number->string (rect-vx rect)) ", "
                           (number->string (rect-vy rect)) ")")
            12 "red")
      (text (string-append "(" (number->string (rect-vx rect)) ", "
                           (number->string (rect-vy rect)) ")")
            12 "blue")))

;; TESTS:
(begin-for-test
  ;; test for initial world
  (check-equal? (world->scene initial-worldstate) (get-rects-for-display
                                                   (world-rects initial-worldstate))
                "world->scene should display initial empty canvas with no rect
                in it")
  (check-equal? (world->scene worldstate-with-rect1)
                (place-image POINT-CIRCLE
                             (cursor-x (world-rects worldstate-with-rect1))
                             (cursor-y (world-rects worldstate-with-rect1))
                             (get-rects-for-display
                              (world-rects worldstate-with-rect1)))
                "world->scene should display canvas with one rect in it") 
  ;; test for empty ListOfRect
  (check-equal? (get-rects-for-display empty) MT-SCENE
                "get-rects-for-display should display empty canvas for empty rects")
  ;; test for ListOfRect containing one rect in it
  (check-equal? (get-rects-for-display (list rect1))
                (place-image (get-rect-for-display rect1)
                             RECT1-CENTER-X RECT1-CENTER-Y MT-SCENE)
                "get-rects-for-display should display one rect on the canvas with
                 specified coordinates")
  ;; tests for getting cursor coordinates
  (check-equal? (cursor-x (list rect1-selected)) 200
                "the cursor-x should return -10 since no rect is selected")
  (check-equal? (cursor-y (list rect1-selected))
                100 "the cursor-y should return -10 since no rect is selected")
  (check-equal? (get-track-points (list (make-point 40 40)) initial-worldstate) 
                (place-image TRACK-POINT 40 40
                             (place-image POINT-CIRCLE
                                          (cursor-x
                                           (get-selected-rects
                                            (world-rects initial-worldstate)))
                                          (cursor-y
                                           (get-selected-rects
                                            (world-rects initial-worldstate)))
                                          (get-rects-for-display
                                           (world-rects initial-worldstate))))))
;=========================================================================================

;; initial-world : Any -> World
;; GIVEN: any value (ignored)
;; RETURNS: the initial world specified in the problem set
;; EXAMPLES:
;; Get world at initial state
;; (initial-world ZERO) = initial-worldstate
(define (initial-world input)
  (make-world empty true empty))

;; TESTS:
(begin-for-test
  ;; test if the  method returns the initial world
  (check-equal? (initial-world ZERO) initial-worldstate
                "initial-world should return the world in initial state"))
;=========================================================================================

;; world-after-tick : World -> World
;; GIVEN: current worldState
;; RETURNS: the world state that should follow the given world state after a tick
;; EXAMPLES:
;; (world-after-tick initial-worldstate) = worldstate-after-tick
;; (world-after-tick unpaused-initial-worldstate) = unpaused-initial-worldstate

;; STRATEGY: using cases on (world-paused? ws), (world-paused? used for
;; showing whether world is paused or not)
(define (world-after-tick ws)
  (if (world-paused? ws)
      ws (make-world (get-world-rects ws) (world-paused? ws)
                          (get-track-list (get-rects-with-pendown (world-rects ws))
                                          (world-pts ws)))))

;;;; Helper functions for ;;;;

;; get-track-list : ListOfRect ListOfPoint -> ListOfPoint
;; GIVEN: rects- ListOfRect and pts- ListOfPoints
;; WHERE: pts are the existing list of all center points of the rects whose pen
;; is down
;; RETURNS: the new ListOfPoint by adding new points after tick for each rect
;; whose pen is down
;; EXAMPLES:
;; (get-track-list (list rect2-pendown)) = (list (make-point RECT2-CENTER-X RECT2-CENTER-Y))

;; STRATEGY: use HOF foldr, followed by HOF map on rects
(define (get-track-list rects pts)
  (foldr cons pts
         (map
          ;; Rect -> Point
          ;; GIVEN: A Rect
          ;; RETURNS: Point with x and y co-ordinate as the rect center
          ;; co-ordinates
          (lambda (rect) (make-point (rect-x rect) (rect-y rect)))
          rects)))

;; get-rects-with-pendown : ListOfRect -> ListOfRect
;; GIVEN: a ListOfRect
;; WHERE: ListOfRect contains rect with pen-up and pen-down
;; RETURNS: list of rects whose pen is down
;; EXAMPLES:
;; (get-rects-with-pendown (list rect1 rect2-pendown)) = (list rect2-pendown)

;; STRATEGY: usw HOF filter on rects
(define (get-rects-with-pendown rects)
  (filter
   ;; Rect -> Boolean
   ;; GIVEN: A Rect
   ;; RETURNS: true iff the pen is down for Rect
   (lambda (rect) (rect-pen-down? rect))
   rects))

;; TESTS:
(begin-for-test
  ;; test whether initial world is changed after tick
  (check-equal? (world-after-tick initial-worldstate) worldstate-after-tick
                "world-after-tick should return new worldstate after tick")
  ;; test whether paused world is remaining same
  (check-equal? (world-after-tick unpaused-initial-worldstate) unpaused-initial-worldstate
                "world-after-tick should return same worldstate after tick for paused
                 world")
  ;; test rects whose pen is down
  (check-equal? (get-track-list (list rect2-pendown) empty)
                (list (make-point RECT2-CENTER-X RECT2-CENTER-Y))
                "get-track-list should return the list of rect center for the
                 selected rect")
  ;; test rects whose pen is up
  (check-equal? (get-rects-with-pendown (list rect1)) empty
                "get-rects-with-pendown should return the empty list"))
;=========================================================================================

;; world-after-key-event : World KeyEvent -> World
;; GIVEN: current worldState and KeyEvent
;; WHERE: key event is occurred on the worldstate might be anything
;; RETURNS: the World that should follow the given worldstate after the given
;; keyevent
;; EXAMPLES:
;; (world-after-key-event initial-worldstate " ") = unpaused-initial-worldstate
;; (world-after-key-event initial-worldstate "a") = worldstate-after-tick
;; (world-after-key-event initial-worldstate BUTTON-N) = initial-worldstate-with-rect
;; (world-after-key-event worldstate-with-rect1 UP) = worldstate-after-key-up
;; (world-after-key-event worldstate-with-rect1 DOWN) = worldstate-after-key-down
;; (world-after-key-event worldstate-with-rect1 RIGHT) = worldstate-after-key-right
;; (world-after-key-event worldstate-with-rect1 LEFT) = worldstate-after-key-left

;; STRATEGY: using cases on key event ke
(define (world-after-key-event ws ke)
  (cond
    [(key=? ke " ")
     (make-world (world-rects ws) (not (world-paused? ws)) (world-pts ws))]
    [(key=? ke BUTTON-N)
     (make-world (add-new-rect (world-rects ws)) (world-paused? ws) (world-pts ws))]
    [(or (key=? ke UP) (key=? ke DOWN) (key=? ke RIGHT) (key=? ke LEFT)
         (key=? ke BUTTON-D) (key=? ke BUTTON-U))
     (make-world-with-changed-rects ws ke)]
    [else (world-after-tick ws)]))

;;; Helper Functions for world-after-key-event ;;;;

;; make-world-with-changed-rects : World KeyEvent -> World
;; GIVEN: current worldState and KeyEvent
;; WHERE: key event is between "u", "d", left, right, up or down
;; RETURNS: the World after adding/subtracting velocity or making pen up/down
;; for rects
;; EXAMPLES:
;; (make-world-with-changed-rects worldstate-with-rect1 DOWN) =
;; (list rect1-selected-speed-down)

;; STARTEGY: combine using simpler functions
(define (make-world-with-changed-rects ws ke)
  (make-world (append (rect-list-after-key-event
                            (get-selected-rects (world-rects ws))  ke)
                           (get-unselected-rects (world-rects ws)))
                   (world-paused? ws) (world-pts ws)))

;; get-selected-rects : ListOfRect -> ListOfRect
;; GIVEN: a ListOfRect
;; WHERE: ListOfRect contains all rects selected as well as unselected
;; RETURNS: list of selected rects
;; EXAMPLES:
;; (get-selected-rects (list rect1 rect1-selected)) = (list rect1-selected)

;; STRATEGY: use HOF filter on rects
(define (get-selected-rects rects)
  (filter
   ;; Rect -> Boolean
   ;; GIVEN: A Rect
   ;; RETURNS: true iff Rect is selected
   (lambda (rect) (rect-selected? rect))
   rects))

;; get-unselected-rects : ListOfRect -> ListOfRect
;; GIVEN: a ListOfRect
;; WHERE: ListOfRect contains all rects selected as well as unselected
;; RETURNS: list of un-selected rects
;; EXAMPLES:
;; (get-unselected-rects (list rect1 rect1-selected)) = (list rect1)

;; STRATEGY: use HOF filter on rects
(define (get-unselected-rects rects)
  (filter
   ;; Rect -> Boolean
   ;; GIVEN: A Rect
   ;; RETURNS: true iff the Rect is not selected
   (lambda (rect) (not (rect-selected? rect)))
   rects))

;; add-new-rect : ListOfRect -> ListOfRect
;; GIVEN: a ListOfRect
;; RETURNS: the ListOfRect with newly added rect as the first element
;; EXAMPLES:
;; (add-new-rect empty) = (cons RECT1 rects)

;; STRATEGY: combine using simpler functions
(define (add-new-rect rects)
  (cons (new-rect CANVAS-CENTER-X CANVAS-CENTER-Y ZERO ZERO) rects))

;; rect-list-after-key-event : ListOfRect KeyEvent -> ListOfRect
;; GIVEN: a ListOfRect and key event
;; WHERE: rect is selected and key event in between up, down, right, left,
;; BUTTON-D and BUTTON-U
;; RETURNS: the new ListOfRect with changed velocities or pendown? flag
;; EXAMPLES:
;; (rect-list-after-key-event (list rect-at-canvas-center-selected) RIGHT) =
;;                                                    (list rect1-selected-speed-right)
;; (rect-list-after-key-event (list rect-at-canvas-center) LEFT) = (list rect-at-canvas-center)

;; STRATEGY: use HOF foldr, followed by HOF map on rects
(define (rect-list-after-key-event rects ke)
  (foldr cons empty
         (map
          ;; Rect -> Rect
          ;; GIVEN: A Rect
          ;; RETURNS: Rect after key event ke
          (lambda (rect) (rect-after-key-event rect ke))
          rects)))

;; rect-after-key-event : Rect KeyEvent -> Rect
;; GIVEN: A Rect and KeyEvent
;; WHERE: rect is selected and key event in between up, down, right, left,
;; BUTTON-D and BUTTON-U
;; RETURNS: the state of the rect that should follow the given rect after
;; the given key event
;; EXAMPLES:
;; (rect-list-after-key-event rect-at-canvas-center-selected RIGHT) =
;;                                                      rect1-selected-speed-right

;; STRATEGY: using cases on KeyEvent ke 
(define (rect-after-key-event rect ke)
  (cond
    [(key=? ke UP)
     (make-rect (rect-x rect) (rect-y rect)
                     (get-rect-vx rect) (- (get-rect-vy rect) 2) true
                     (rect-dx rect) (rect-dy rect) (rect-pendown? rect))]
    [(key=? ke DOWN)
     (make-rect (rect-x rect) (rect-y rect)
                     (get-rect-vx rect) (+ (get-rect-vy rect) 2) true
                     (rect-dx rect) (rect-dy rect) (rect-pendown? rect))]
    [(key=? ke RIGHT)
     (make-rect (rect-x rect) (rect-y rect)
                     (+ (get-rect-vx rect) 2) (get-rect-vy rect) true
                     (rect-dx rect) (rect-dy rect) (rect-pendown? rect))]
    [(key=? ke LEFT)
     (make-rect (rect-x rect) (rect-y rect)
                     (- (get-rect-vx rect) 2) (get-rect-vy rect) true
                     (rect-dx rect) (rect-dy rect) (rect-pendown? rect))]
    [(key=? ke BUTTON-D)
     (make-rect (rect-x rect) (rect-y rect)
                     (get-rect-vx rect) (get-rect-vy rect) true
                     (rect-dx rect) (rect-dy rect) true)]
    [(key=? ke BUTTON-U)
     (make-rect (rect-x rect) (rect-y rect)
                     (get-rect-vx rect) (get-rect-vy rect) true
                     (rect-dx rect) (rect-dy rect) false)]))

;; TESTS:
(begin-for-test
  ;; test if the world is paused by pressing bar or not
  (check-equal? (world-after-key-event initial-worldstate " ") unpaused-initial-worldstate
                "world-after-key-event should return paused world after space bar event")
  ;; test if the world is not paused for any other event than space bar
  (check-equal? (world-after-key-event initial-worldstate "a") worldstate-after-tick
                "world-after-key-event should not do anything for this event")
  ;; test if the new rect added to the world after pressing "n" or not
  (check-equal? (world-after-key-event initial-worldstate BUTTON-N)
                initial-worldstate-with-rect
                "world-after-key-event should add rect to the world on click of 'n'")
  ;; tests for various arrow key events on selected rect
  (check-equal? (world-after-key-event initial-worldstate-with-rect-selected UP)
                worldstate-after-key-up
                "world-after-key-event should return worldstate with velocity of rect
                 in y dir changed by -2")
  (check-equal? (world-after-key-event initial-worldstate-with-rect-selected DOWN)
                worldstate-after-key-down
                "world-after-key-event should return worldstate with velocity of
                 rect in y dir changed by 2")
  (check-equal? (world-after-key-event initial-worldstate-with-rect-selected RIGHT)
                worldstate-after-key-right
                "world-after-key-event should return worldstate with velocity of rect
                in x dir changed by 2")
  (check-equal? (world-after-key-event initial-worldstate-with-rect-selected LEFT)
                worldstate-after-key-left
                "world-after-key-event should return worldstate with velocity of rect
                in x dir changed by -2")
  ;; test for rect-list-after-key-event where no rect is selected
  (check-equal? (rect-list-after-key-event (list rect1-selected) LEFT)
                (list (rect-after-key-event rect1-selected LEFT))
                "rect-list-after-key-event should return list of rect with changed
                 velocities")
  ;; test the world for pen down and pen up events
  (check-equal? (world-after-key-event worldstate-pen-up BUTTON-D) worldstate-pen-down
                "world-after-key-event should return the worldstate with selected
                 rects pen down")
  (check-equal? (world-after-key-event worldstate-pen-down BUTTON-U) worldstate-pen-up
                "world-after-key-event should return the worldstate with selected
                 rects pen up"))
;=========================================================================================

;; get-world-rects : World -> ListOfRect
;; GIVEN: current worldState
;; RETURNS: the list of rects from the World
;; EXAMPLES:
;; (get-world-rects initial-worldstate-with-rect) = (list rect-at-canvas-center)
;; (get-world-rects initial-worldstate-with-rect-selected) =
;;                                                (list rect-at-canvas-center-selected)

;; STRATEGY: using template of World on ws
(define (get-world-rects ws)
  (append
   (rects-after-tick
    (get-unselected-rects (world-rects ws)))
   (get-selected-rects (world-rects ws))))

;;;; Helper functions for get-world-rects ;;;;

;; rects-after-tick : ListOfRect -> ListOfRect
;; GIVEN: a ListOfRect
;; WHERE: some rects might be selected, in that case same rect should be
;; returned
;; otherwise rects x and y coordinates will be changed
;; RETURNS: the list of rects from the World after changing x and y co-ordinates
;; EXAMPLES:
;; (get-list-of-rects rect-at-canvas-center) = (list rect-at-canvas-center)

;; STRATEGY: use HOF foldr , followed by HOF map on rects
(define (rects-after-tick rects)
  (foldr cons empty
         (map
          ;; Rect -> Rect
          ;; GIVEN: A Rect
          ;; RETURNS: A Rect after changin x and y co-ordinates
          ;; and velocities vx and vy
          (lambda (rect)
            (make-rect (get-rect-x rect) (get-rect-y rect)
                            (get-rect-vx rect) (get-rect-vy rect)
                            false ZERO ZERO (rect-pen-down? rect)))
          rects)))

;; TESTS:
(begin-for-test
  ;; test for worldstate with unselected rect in it
  (check-equal? (get-world-rects initial-worldstate-with-rect)
                (list rect-at-canvas-center)
                "get-world-rects should return rects with one unselected rect")
  ;; test for worldstate with selected rect in it
  (check-equal? (get-world-rects initial-worldstate-with-rect-selected)
                (list rect-at-canvas-center-selected)
                "get-world-rects should return rects with one selected rect"))
;=========================================================================================

;; new-rect : NonNegInt NonNegInt Int Int -> Rect
;; GIVEN: 2 non-negative integers x and y, and 2 integers vx and vy
;; RETURNS: a rect centered at (x,y), which will travel with velocity (vx, vy)
;; EXAMPLES:
;; (new-rect 200 200 -10 10) = TEST-RECT
(define (new-rect x y vx vy)
  (make-rect x y vx vy false ZERO ZERO false))

;; TESTS:
(begin-for-test
  ;; T=test if rect is created with the given x and y coordinates and velocity
  (check-equal? (new-rect 200 200 -10 10) test-rect "new-rect should return new
                                                          rect with given specs"))
;=========================================================================================

;; get-rect-x : Rect -> NonNegInt
;; GIVEN: a rect
;; RETURNS: the x coordinate of the center of the rect by adding velocity vx
;; EXAMPLES:
;; (get-rect-x rect1) = 188
;; (get-rect-x rect1-cross-min-x) = CANVAS-MIN-X
;; (get-rect-x rect1-cross-max-x) = CANVAS-MAX-X

;; STRATEGY: use template of Rect on rect
(define (get-rect-x rect)
  (cond
    [(<= (+ (rect-x rect) (get-rect-vx rect)) CANVAS-MIN-X) CANVAS-MIN-X]
    [(>= (+ (rect-x rect) (get-rect-vx rect)) CANVAS-MAX-X) CANVAS-MAX-X]
    [else (+ (rect-x rect) (get-rect-vx rect))]))

;; TESTS:
(begin-for-test
  ;; test when x coordinate of rect is not at the edge of canvas
  (check-equal? (get-rect-x rect1) 188 "get-rect-x should return x coordinate after
                                        adding vx")
  ;; test when x coordinate of rect at the left edge of canvas
  (check-equal? (get-rect-x rect1-cross-min-x) CANVAS-MIN-X "get-rect-x should return
                                                           x coordinate CANVAS-MIN-X")
  ;; test when x coordinate of rect at the right edge of the canvas
  (check-equal? (get-rect-x rect1-cross-max-x) CANVAS-MAX-X "get-rect-x should return
                                                          x coordinate CANVAS-MAX-X"))
;=========================================================================================

;; get-rect-y : Rect -> NonNegInt
;; GIVEN: a rect
;; RETURNS: the y coordinate of the center of the rect by adding velocity vy
;; EXAMPLES:
;; (get-rect-y rect1) = 120
;; (get-rect-y rect1-cross-min-y) = CANVAS-MIN-Y
;; (get-rect-y rect1-cross-max-y) = CANVAS-MAX-Y

;; STRATEGY: use template of Rect on rect
(define (get-rect-y rect)
  (cond
    [(<= (+ (rect-y rect) (get-rect-vy rect)) CANVAS-MIN-Y) CANVAS-MIN-Y]
    [(>= (+ (rect-y rect) (get-rect-vy rect)) CANVAS-MAX-Y) CANVAS-MAX-Y]
    [else (+ (rect-y rect) (get-rect-vy rect))]))

;; TESTS:
(begin-for-test
  ;; test when y coordinate of rect is not at the edge of canvas
  (check-equal? (get-rect-y rect1) 120 "get-rect-y should return y coordinate after
                                        adding vy")
  ;; test when y coordinate of rect at the top edge of canvas
  (check-equal? (get-rect-y rect1-cross-min-y) CANVAS-MIN-Y"get-rect-y should return
                                                          y coordinate CANVAS-MIN-Y")
  ;; test when y coordinate of rect at the bottom edge of canvas
  (check-equal? (get-rect-y rect1-cross-max-y) CANVAS-MAX-Y"get-rect-y should return
                                                         y coordinate CANVAS-MIN-Y"))
;=========================================================================================

;; get-rect-vx : Rect -> Int
;; GIVEN: a rect
;; RETURNS: the velocity of the rect in direction x
;; EXAMPLES:
;; (get-rect-vx RECT1) = -12
;; (get-rect-vx RECT1-AT-BOUNDRY-MIN-X) = 10
;; (get-rect-vx RECT1-AT-BOUNDRY-MAX-X) = 10

;; STRATEGY: use template of Rect on rect
(define (get-rect-vx rect)
  (if (or (<= (rect-x rect) CANVAS-MIN-X) (>= (rect-x rect) CANVAS-MAX-X))
      (- ZERO (rect-vx rect)) (rect-vx rect)))

;; TESTS:
(begin-for-test
  ;; test when rect inside canvas
  (check-equal? (get-rect-vx rect1) -12 "get-rect-vx should return the velocity as same")
  ;; test when rect at the left edge
  (check-equal? (get-rect-vx rect1-at-boundry-min-x) 10 "get-rect-vx should reverse the
                                                         velocity at left edge")
  ;; test when rect at the right
  (check-equal? (get-rect-vx rect1-at-boundry-max-x) 10 "get-rect-vx should reverse the
                                                         velocity at right edge"))
;=========================================================================================

;; get-rect-vy : Rect -> Int
;; GIVEN: a rect
;; RETURNS: the velocity of the rect in direction y
;; EXAMPLES:
;; (get-rect-vy RECT1) = 20
;; (get-rect-vy RECT1-AT-BOUNDRY-MIN-Y) = -10
;; (get-rect-vy RECT1-AT-BOUNDRY-MAX-Y) = -10

;; STRATEGY: use template of Rect on rect
(define (get-rect-vy rect)
  (if (or (<= (rect-y rect) CANVAS-MIN-Y) (>= (rect-y rect) CANVAS-MAX-Y))
      (- ZERO (rect-vy rect)) (rect-vy rect)))

;; TESTS:
(begin-for-test
  ;; test when rect inside canvas
  (check-equal? (get-rect-vy rect1) 20 "get-rect-vy should return the velocity as same")
  ;; test when rect at top edge
  (check-equal? (get-rect-vy rect1-at-boundry-min-y) -10 "get-rect-vy should reverse the
                                                          velocity at top edge")
  ;; test when rect at bottom edge
  (check-equal? (get-rect-vy rect1-at-boundry-max-y) -10 "get-rect-vy should reverse the
                                                          velocity at bottom edge"))
;=========================================================================================

;; world-after-mouse-event : World NonNegInt NonNegInt MouseEvent -> World
;; GIVEN: A World, the x- and y-coordinates of a mouse event, and the mouse event
;; RETURNS: the world that should follow the given world after the given mouse event
;; EXAMPLES:
;; (world-after-mouse-event worldstate-with-rect1 200 150 BUTTON-DOWN) =
;;                                                                worldstate-with-rect1
;; (world-after-mouse-event initial-worldstate 200 200 BUTTON-UP) =  initial-worldstate
;; (world-after-mouse-event worldstate-with-rect1 200 200 DRAG) =  worldstate-with-rect1
;; (world-after-mouse-event initial-worldstate 200 200 ENTER) =  initial-worldstate

;; STRATEGY: cases on MouseEvent me
(define (world-after-mouse-event ws mx my me)
  (cond
    [(mouse=? BUTTON-DOWN me)
     (make-world
      (rect-list-after-mouse-event
       (world-rects ws) mx my me) (world-paused? ws) (world-pts ws))]
    [(mouse=? BUTTON-UP me)
     (make-world
      (rect-list-after-mouse-event
       (world-rects ws) mx my me) (world-paused? ws) (world-pts ws))]
    [(mouse=? DRAG me)
     (make-world
      (rect-list-after-mouse-event
       (world-rects ws) mx my me) (world-paused? ws) (world-pts ws))]
    [else ws]))

;;; Helper Functions for world-after-mouse-event ;;;;

;; rect-list-after-mouse-event :
;;                       ListOfRect NonNegInt NonNegInt MouseEvent -> ListOfRect
;; GIVEN: A ListOfRect, the x- and y-coordinates of a mouse event, and the mouse
;; event
;; RETURNS: the ListOfRect after the given mouse event

;; STRATEGY: use HOF foldr , followed by HOF map on rects
(define (rect-list-after-mouse-event rects mx my me)
  (foldr cons empty
         (map
          ;; Rect -> Rect
          ;; GIVEN: A Rect
          ;; RETURNS: Rect after mouse event me
          (lambda (rect) (rect-after-mouse-event rect mx my me))
          rects)))

;; TESTS
(begin-for-test
  ;; test for button down event
  (check-equal? (world-after-mouse-event worldstate-with-rect1 200 100 BUTTON-DOWN)
                worldstate-with-rect1
                "world-after-mouse-event should return world with rect one is
                 selected")
  (check-equal? (world-after-mouse-event initial-worldstate ZERO ZERO BUTTON-DOWN)
                initial-worldstate
                "world-after-mouse-event should return the same world after button
                 down event")
  ;; test for button up event
  (check-equal? (world-after-mouse-event initial-worldstate 200 200 BUTTON-UP)
                initial-worldstate
                "world-after-mouse-event should return same world after button up event")
  ;; test for drag event
  (check-equal? (world-after-mouse-event worldstate-with-rect1 200 100 DRAG)
                worldstate-with-rect1
                "world-after-mouse-event should return world with rect one is
                 selected after drag event")
  (check-equal? (world-after-mouse-event initial-worldstate ZERO ZERO DRAG)
                initial-worldstate
                "world-after-mouse-event should return same world after drag on origin
                of canvas")
  ;; test for no mouse event
  (check-equal? (world-after-mouse-event initial-worldstate 200 200 ENTER)
                initial-worldstate
                "world-after-mouse-event should return unchanged world after enter event")
  )
;=========================================================================================

;; rect-after-mouse-event :  Rect NonNegInt NonNegInt MouseEvent -> Rect
;; GIVEN: A rect, the x- and y-coordinates of a mouse event, and the mouse event
;; RETURNS: the rect that should follow the given rect after the given mouse
;; event
;; EXAMPLES:
;; (rect-after-mouse-event rect1 200 200 ENTER) =  rect1
;; (rect-after-mouse-event rect1 200 100 BUTTON-DOWN) =  rect1-selected
;; (rect-after-mouse-event rect1 200 200 BUTTON-UP) =  rect1
;; (rect-after-mouse-event rect1 200 200 DRAG) =  rect1-selected

;; STRATEGY: cases on MouseEvent me
(define (rect-after-mouse-event rect mx my me)
  (cond
    [(mouse=? me BUTTON-DOWN) (select-rect rect mx my)]
    [(mouse=? me BUTTON-UP) (unselect-rect rect)]
    [(mouse=? me DRAG) (drag-rect rect mx my)]
    [else (unselect-rect rect)]))

;;; Helper Functions for rect-after-mouse-event ;;;;

;; cursor-in-rect? : ListOfRect NonNegInt NonNegInt -> Boolean
;; GIVEN: A Rect, x and y coordinates of a mouse event
;; RETURNS: true iff any rect from the list is selected for dragging
;; EXAMPLES:
;; (cursor-in-rect? rect1-selected 200 100) = true
;; (cursor-in-rect? rect-at-canvas-center 200 210) = false
(define (cursor-in-rect? rect mx my)
  (and (<= mx (+ (rect-x rect) RECT-HALF-WIDTH))
       (>= mx (- (rect-x rect) RECT-HALF-WIDTH))
       (<= my (+ (rect-y rect) RECT-HALF-HEIGHT))
       (>= my (- (rect-y rect) RECT-HALF-HEIGHT))))

;; select-rect : Rect NonNegInt NonNegInt -> Rect
;; GIVEN: A Rect, x and y coordinates of a mouse event
;; WHERE: A Rect is unselected
;; RETURNS: the rect same as previous one but with selected flag true
;; EXAMPLES:
;; (select-rect rect1 200 100) = rect1-selected

;; STRATEGY: using template of Rect on rect
(define (select-rect rect mx my)
  (if (cursor-in-rect? rect mx my)
      (make-rect (rect-x rect) (rect-y rect)
                      (rect-vx rect) (rect-vy rect)
                      true
                      (- (rect-x rect) mx) (- (rect-y rect) my)
                      (rect-pendown? rect))
      (unselect-rect rect)))

;; unselect-rect : Rect -> Rect
;; GIVEN: A Rect
;; WHERE: A Rect is selected
;; RETURNS: the rect same as previous one but with selected flag false
;; EXAMPLES:
;; (select-rect rect1-selected 200 100) = rect1

;; STRATEGY: using template of Rect on rect
(define (unselect-rect rect)
  (make-rect (rect-x rect) (rect-y rect)
                  (rect-vx rect) (rect-vy rect)
                  false ZERO ZERO (rect-pendown? rect)))

;; drag-rect : Rect NonNegInt NonNegInt -> Rect
;; GIVEN: A Rect, x and y coordinate of mouse
;; WHERE: A Rect is selected
;; RETURNS: the rect same as previous one, but changed center coordinates
;; EXAMPLES:
;; (drag-rect rect1-selected 200 100) = rect1

;; STRATEGY: using template of Rect on rect
(define (drag-rect rect mx my)
  (if (cursor-in-rect? rect mx my)
      (make-rect
       (+ mx (rect-dx rect)) (+ my (rect-dy rect)) (rect-vx rect)
       (rect-vy rect) true (rect-dx rect)
       (rect-dy rect) (rect-pendown? rect))
      (unselect-rect rect)))

;; TESTS:
(begin-for-test
  ;; test for mouse enter event on unselected rect
  (check-equal? (rect-after-mouse-event rect1 200 200 ENTER) rect1
                "rect-after-mouse-event should return same rect")
  ;; test for mouse button up event on unselected rect
  (check-equal? (rect-after-mouse-event rect1 200 200 BUTTON-UP) rect1
                "rect-after-mouse-event should return same rect")
  ;; test for select-rect for unselected rect
  (check-equal? (select-rect rect1 200 400) rect1
                "select-rect should return unselected rect")
  ;; test for mouse drag event for unselected rect 
  (check-equal? (drag-rect rect1 200 400) rect1
                "drag-rect should return unselected rect")
  ;; test if rect is seletected for dragging
  (check-equal? (cursor-in-rect? rect-at-canvas-center 200 210) false
                "cursor-in-rect? should return false if rect not selected"))
;=========================================================================================

;; rect-pen-down? : Rect -> Boolean
;; GIVEN: A Rect
;; RETURNS: true iff the Rect is selected for tracking
;; EXAMPLES:
;; (rect-pen-down? rect1) = false

;; STRATEGY: using template of World on ws
(define (rect-pen-down? rect)
  (rect-pendown? rect))
;=========================================================================================