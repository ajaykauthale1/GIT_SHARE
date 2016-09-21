;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname sc-4) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Author: Ajay Baban Kauthale
;; Date: 10/04/2015
;; Program for screensaver-3

;(check-location "04" "screensaver-3.rkt")

(require rackunit)
(require "extras.rkt")

(provide screensaver initial-world world-after-tick world-after-key-event new-rectangle rect-x rect-y rect-vx rect-vy
         world-paused? world-after-mouse-event rect-after-mouse-event rect-selected? world-rects rect-after-key-event
         rect-pen-down?)


;==========================================================================================================================
;                                      CONSTANTS
;==========================================================================================================================
;; constant for displaying canvas
(define MT-SCENE (empty-scene 400 300))
;; constants for screen center
(define CANVAS-CENTER-X 200)
(define CANVAS-CENTER-Y 150)
;; constants for rectangle width and height
(define RECT-WIDTH 60)
(define RECT-HEIGHT 50)
;; constants for half of width and height
(define RECT-HALF-WIDTH (/ RECT-WIDTH 2))
(define RECT-HALF-HEIGHT (/ RECT-HEIGHT 2))
;; constant for displaying rectangle
(define RECTANGLE (rectangle 60 50 "outline" "blue"))
;; constant for displaying circle
(define POINT-CIRCLE (circle 5 "outline" "red"))
(define RED-RECTANGLE (rectangle RECT-WIDTH RECT-HEIGHT "outline" "red"))
;; constant for displaying track of rectangle center
(define TRACK-POINT (circle 1 "solid" "black"))
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
;; constants for mouse evevents
(define BUTTON-DOWN "button-down")
(define BUTTON-UP "button-up")
(define DRAG "drag")
(define ENTER "enter")
;; constants for co-ordinate zero
(define ZERO 0)

;==========================================================================================================================
;                                      DATA DEFINITIONS
;==========================================================================================================================
(define-struct Point (x y))
;; A point is a (make-Point (Integer Integer))
;; INTERPRETATION:
;; x and y are the coordinates of the point on the canvas

;; TEMPLATE:
;; Point-fn : Point -> ??
#|(define (Point-fn pt)
  ....
  (Point-x pt)
  (Point-y pt)
  ....)|#

;; A List of Point (ListOfPoint) is one of:
;; -- empty
;; -- (cons Number ListOfPoint)

;; TEMPLATE:
;; ListOfPoint-fn -> ??
#|(define (ListOfPoint-fn pts)
  (cond
    [(empty? pts) ... ]
    [else (... (first pts)
               (ListOfPoint-fn (rest pts)))]))|#

(define-struct Rectangle (x y vx vy selected? dx dy pendown?))
;; A Rectangle is a (make-Rectangle NonNegInt NonNegInt Integer Integer Boolean NonNegInt NonNegInt Boolean)
;; INTERPRETATION:
;; x and y are the coordinates of the rectangle center
;; vx and vy are the velocities of the rectangle along with x and y axis respectively
;; selected? for showing whether the rectangle is selected or not
;; dx and dy are coordinates of the point where mouse drag event occured (inside rectangle)
;; pendown? is indicator for showing the track of rectangle center on the canvas

;; TEMPLATE:
;; Rectangle-fn : Rectangle -> ??
#|(define (Rectangle-fn rect)
    ....
    (Rectangle-x rect)
    (Rectangle-y rect)
    (Rectangle-vx rect)
    (Rectangle-vy rect)
    (Rectangle-selected? rect)
    (Rectangle-dx rect)
    (Rectangle-dy rect)
    (Rectangle-pendown? rect)
    .....)|#

;; Examples of Rectangle for testing purpose
;; rectangle one
(define rect1 (make-Rectangle RECT1-CENTER-X RECT1-CENTER-Y RECT1-VX RECT1-VY false ZERO ZERO false))
;; rectangle two
(define rect2 (make-Rectangle RECT2-CENTER-X RECT2-CENTER-Y RECT2-VX RECT2-VY false ZERO ZERO false))
;; rectangle one after tick
(define rect1-after-tick (make-Rectangle (+ RECT1-VX RECT1-CENTER-X ) (+ RECT1-VY RECT1-CENTER-Y)
                                         RECT1-VX RECT1-VY false ZERO ZERO false))
;; rectangle two after tick
(define rect2-after-tick (make-Rectangle (+ RECT2-VX RECT2-CENTER-X) (+ RECT2-VY RECT2-CENTER-Y)
                                         RECT2-VX RECT2-VY false ZERO ZERO false))
;; selected rectangles
(define rect1-selected (make-Rectangle RECT1-CENTER-X RECT1-CENTER-Y RECT1-VX RECT1-VY true ZERO ZERO false))
(define rect2-selected (make-Rectangle RECT2-CENTER-X RECT2-CENTER-Y RECT2-VX RECT2-VY true ZERO ZERO false))
;; rectangle with pen down
(define rect2-pendown (make-Rectangle RECT2-CENTER-X RECT2-CENTER-Y RECT2-VX RECT2-VY true ZERO ZERO true))
;; rectangle for testing
(define test-rect (make-Rectangle 200 200 -10 10 false ZERO ZERO false))
;; rectangle one after crossing the canvas
(define rect1-cross-min-x (make-Rectangle 40 200 -10 10 false ZERO ZERO false))
(define rect1-cross-max-x (make-Rectangle 370 200 -10 10 false ZERO ZERO false))
(define rect1-cross-min-y (make-Rectangle 200 25 -10 10 false ZERO ZERO false))
(define rect1-cross-max-y (make-Rectangle 40 285 -10 10 false ZERO ZERO false))
;; rectangle one at the boundry of canvas
(define rect1-at-boundry-min-x (make-Rectangle 30 200 -10 10 false ZERO ZERO false))
(define rect1-at-boundry-max-x (make-Rectangle 370 200 -10 10 false ZERO ZERO false))
(define rect1-at-boundry-min-y (make-Rectangle 200 25 -10 10 false ZERO ZERO false))
(define rect1-at-boundry-max-y (make-Rectangle 40 275 -10 10 false ZERO ZERO false))
;; rectangle at the center of the canvas
(define rect-at-canvas-center (make-Rectangle CANVAS-CENTER-X CANVAS-CENTER-Y ZERO ZERO false ZERO ZERO false))
(define rect-at-canvas-center-selected (make-Rectangle CANVAS-CENTER-X CANVAS-CENTER-Y ZERO ZERO true ZERO ZERO false))
;; rectangle after different key events
(define rect1-selected-speed-up (make-Rectangle CANVAS-CENTER-X CANVAS-CENTER-Y 0 -2 true ZERO ZERO false))
(define rect1-selected-speed-down (make-Rectangle CANVAS-CENTER-X CANVAS-CENTER-Y 0 2 true ZERO ZERO false))
(define rect1-selected-speed-left (make-Rectangle CANVAS-CENTER-X CANVAS-CENTER-Y -2 0 true ZERO ZERO false))
(define rect1-selected-speed-right (make-Rectangle CANVAS-CENTER-X CANVAS-CENTER-Y 2 0 true ZERO ZERO false))

;; A List of Rectangle (ListOfRectangle) is one of:
;; -- empty
;; -- (cons Number ListOfRectangle)

;; TEMPLATE:
;; ListOfRectangle-fn -> ??
#|(define (ListOfRectangle-fn rects)
  (cond
    [(empty? rects) ... ]
    [else (... (first rects)
               (ListOfRectangle-fn (rest rects)))]))|#

(define-struct WorldState (rects paused? pts))
;; A WorldState is a (make-WorldState ListOfRectangle Boolean ListOfPoint)
;; INTERPRETATION:
;; rects is the list of rectangles present on the screensaver
;; paused? is indicator for whether the screensaver is paused or not
;; pts is ListPoints for showing track of rectangles

;; TEMPLATE:
;; WorldState-fn : WorldState -> ??
#|(define (WorldState-fn ws)
    ....
    (WorldState-rects ws)
    (WorldState-paused? ws)
    (WorldState-pts ws)
    ....)|#

;; Examples of WorldState for testing purpose
;; initial world state
(define initial-worldstate (make-WorldState empty false empty))
;; world state with added rectangle
(define initial-worldstate-with-rect (make-WorldState (cons rect-at-canvas-center empty) false empty))
(define initial-worldstate-with-rect-selected (make-WorldState (cons rect-at-canvas-center-selected empty) false empty))
;; paused initial world state
(define paused-initial-worldstate (make-WorldState empty true empty))
;; world after tick
(define worldstate-after-tick (make-WorldState empty false empty))
;; world where rectangles are selected
(define worldstate-with-rect1 (make-WorldState (cons rect1-selected empty) false empty))
(define worldState-with-empy-rects (make-WorldState empty false empty))
;; world after various arrow key events
(define worldstate-after-key-up (make-WorldState (cons rect1-selected-speed-up empty) false empty))
(define worldstate-after-key-down (make-WorldState (cons rect1-selected-speed-down empty) false empty))
(define worldstate-after-key-right (make-WorldState (cons rect1-selected-speed-right empty) false empty))
(define worldstate-after-key-left (make-WorldState (cons rect1-selected-speed-left empty) false empty))

;===========================================================================================================================
;                                      FUNCTIONS
;===========================================================================================================================
;; screensaver : PosReal -> WorldState
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

;; world->scene : WorldState -> Image
;; GIVEN: a WorldState
;; RETURNS: the image depicting the current WorldState with red circle as a pointer if any of the rectangle is selected
;; EXAMPLES:
;; world at initial state:
;; (world->scene initial-worldstate) = (get-rects-for-display (WorldState-rects initial-worldstate))
#| (world->scene worldstate-with-rect1) = (place-image POINT-CIRCLE (cursor-x (WorldState-rects worldstate-with-rect1))
        (cursor-y (WorldState-rects worldstate-with-rect1)) (get-rects-for-display (WorldState-rects worldstate-with-rect1)))|#

;; STRATEGY: using template of WorldState on ws
(define (world->scene ws)
  (get-track-points (WorldState-pts ws) ws))

;;
(define (get-track-points pts ws)
  (cond
    [(empty? pts)
     (place-image TRACK-POINT -10 -10
                  (place-image POINT-CIRCLE
                               (cursor-x (WorldState-rects ws)) (cursor-y (WorldState-rects ws))
                               (get-rects-for-display (WorldState-rects ws)))) ]
    [else (place-image TRACK-POINT (Point-x (first pts)) (Point-y (first pts))
                       (get-track-points (rest pts) ws))]))

;; get-rects-for-display : ListOfRectangle -> Image
;; GIVEN: a ListOfRectangle
;; RETURNS: the image with all rectangles in the list are drawn on the scene
;; EXAMPPLES:
;; (get-rects-for-display empty) = MT-SCENE
;; (get-rects-for-display (cons rect1 empty)) = (place-image (get-rect-for-display rect1) RECT1-CENTER-X
;;                                              RECT1-CENTER-Y MT-SCENE)

;; STRATEGY: using template of ListOfRectangle on rects
(define (get-rects-for-display rects)
  (cond
    [(empty? rects) MT-SCENE]
    [else (place-image (get-rect-for-display (first rects)) (Rectangle-x (first rects)) (Rectangle-y (first rects))
                       (get-rects-for-display (rest rects)))]))

;; cursor-x : ListOfRectangle -> Integer
;; GIVEN: a ListOfRectangle
;; RETURNS: x coordinate of the cursor on the canvas
;; EXAMPLES:
;; (cursor-x (cons rect1 empty)) = -10

;; STRATEGY: using template of ListOfRectangle on rects
(define (cursor-x rects)
  (cond
    [(empty? rects) -10]
    [else (if (rect-selected? (first rects))
              (- (Rectangle-x (first rects)) (Rectangle-dx (first rects)))
              (cursor-x (rest rects)))]))

;; cursor-y : ListOfRectangle -> Integer
;; GIVEN: a ListOfRectangle
;; RETURNS: y coordinate of the cursor on the canvas
;; EXAMPLES:
;; (cursor-y (cons rect1 empty)) = -10

;; STRATEGY: using template of ListOfRectangle on rects
(define (cursor-y rects)
  (cond
    [(empty? rects) -10]
    [else (if (rect-selected? (first rects))
              (- (Rectangle-y (first rects)) (Rectangle-dy (first rects)))
              (cursor-y (rest rects)))]))

;; get-rect-for-display : Rectangle -> Image
;; GIVEN: a Rectangle
;; RETURNS: the rectangle with red outline if it is selected
;; EXAMPLES:
;; (get-rect-for-display rect1) = (overlay (get-velocity-string rect1) RECTANGLE)

;; STRATEGY: using template of Rectangle on rect
(define (get-rect-for-display rect)
  (if (rect-selected? rect)
      (overlay (get-velocity-string rect) RED-RECTANGLE) (overlay (get-velocity-string rect) RECTANGLE)))

;; get-velocity-string : Rectangle -> Image
;; GIVEN: a Rectangle
;; RETURNS: the text of velocities in the form of (vx, vy)
;; EXAMPLES:
;; (get-velocity-string rect1) = (text "(-12, 20)" 12 "blue")

;; STRATEGY: using template of Rectangle on rect
(define (get-velocity-string rect)
  (if (rect-selected? rect)
      (text (string-append "(" (number->string (Rectangle-vx rect)) ", " (number->string (Rectangle-vy rect)) ")")
            12 "red")
      (text (string-append "(" (number->string (Rectangle-vx rect)) ", " (number->string (Rectangle-vy rect)) ")")
            12 "blue")))

;; TESTS:
(begin-for-test
  ;; test for initial world
  (check-equal? (world->scene initial-worldstate) (get-rects-for-display (WorldState-rects initial-worldstate))
                "world->scene should display initial empty canvas with no rectangle in it")
  (check-equal? (world->scene worldstate-with-rect1) (place-image POINT-CIRCLE
                                                                  (cursor-x (WorldState-rects worldstate-with-rect1))
                                                                  (cursor-y (WorldState-rects worldstate-with-rect1))
                                                                  (get-rects-for-display
                                                                   (WorldState-rects worldstate-with-rect1)))
                "world->scene should display canvas with one rectangle in it") 
  ;; test for empty ListOfRectangle
  (check-equal? (get-rects-for-display empty) MT-SCENE "get-rects-for-display should display empty canvas for empty rects")
  ;; test for ListOfRectangle containing one rectangle in it
  (check-equal? (get-rects-for-display (cons rect1 empty)) (place-image (get-rect-for-display rect1)
                                                                        RECT1-CENTER-X RECT1-CENTER-Y MT-SCENE)
                "get-rects-for-display should display one rectangle on the canvas with specified coordinates")
  ;; tests for getting cursor coordinates
  (check-equal? (cursor-x (cons rect1 empty)) -10 "the cursor-x should return -10 since no rectangle is selected")
  (check-equal? (cursor-y (cons rect1 empty)) -10 "the cursor-y should return -10 since no rectangle is selected"))
;=================================================================================================================

;; initial-world : Any -> WorldState
;; GIVEN: any value (ignored)
;; RETURNS: the initial world specified in the problem set
;; EXAMPLES:
;; Get world at initial state
;; (initial-world ZERO) = initial-worldstate
(define (initial-world input)
  (make-WorldState empty false empty))

;; TESTS:
(begin-for-test
  ;; test if the  method returns the initial world
  (check-equal? (initial-world ZERO) initial-worldstate "initial-world should return the world in initial state"))
;=================================================================================================================

;; world-after-tick : WorldState -> WorldState
;; GIVEN: current worldState
;; RETURNS: the world state that should follow the given world state after a tick
;; EXAMPLES:
;; (world-after-tick initial-worldstate) = worldstate-after-tick
;; (world-after-tick paused-initial-worldstate) = paused-initial-worldstate

;; STRATEGY: using template of WorldState on ws
(define (world-after-tick ws)
  (cond
    [(WorldState-paused? ws) ws]
    [else (make-WorldState (world-rects ws) (WorldState-paused? ws)
                           (get-track-list (WorldState-rects ws) (WorldState-pts ws)))]))

;;;; Helper functions for ;;;;

;; get-track-list : ListOfRectangle ListOfPoint -> ListOfPoint
;; GIVEN: rects- ListOfRectangle and pts- ListOfPoints
;; WHERE: pts are the existing list all center points of the rectangles whose pen is down
;; RETURNS: the new ListOfPoint by adding new points after tick for each rectangle whose pen is down
;; EXAMPLES:
;;

;; STRATEGY: using template of ListOfRectangle on rects
(define (get-track-list rects pts)
  (cond
    [(empty? rects) pts]
    [else (cons (if (rect-pen-down? (first rects))
                    (make-Point (Rectangle-x (first rects)) (Rectangle-y (first rects)))
                    (make-Point -1 -1))
                (get-track-list (rest rects) pts))]))

;; TESTS:
(begin-for-test
  ;; test whether initial world is changed after tick
  (check-equal? (world-after-tick initial-worldstate) worldstate-after-tick
                "world-after-tick should return new worldstate after tick")
  ;; test whether paused world is remaining same
  (check-equal? (world-after-tick paused-initial-worldstate) paused-initial-worldstate
                "world-after-tick should return same worldstate after tick for paused world")
  ;; test whether new center points are added for selected rectangles into the point list
  (check-equal? (get-track-list (cons rect2-pendown empty) empty) (cons (make-Point RECT2-CENTER-X RECT2-CENTER-Y) empty)))
;=================================================================================================================

;; world-after-key-event : WorldState KeyEvent -> WorldState
;; GIVEN: current worldState
;; RETURNS: the WorldState that should follow the given worldstate after the given keyevent
;; EXAMPLES:
;; (world-after-key-event initial-worldstate " ") = paused-initial-worldstate
;; (world-after-key-event initial-worldstate "a") = worldstate-after-tick
;; (world-after-key-event initial-worldstate "n") = initial-worldstate-with-rect
;; (world-after-key-event worldstate-with-rect1 "up") = worldstate-after-key-up
;; (world-after-key-event worldstate-with-rect1 "down") = worldstate-after-key-down
;; (world-after-key-event worldstate-with-rect1 "right") = worldstate-after-key-right
;; (world-after-key-event worldstate-with-rect1 "left") = worldstate-after-key-left

;; STRATEGY: using cases on key event ke
(define (world-after-key-event ws ke)
  (cond
    [(key=? ke " ")
     (make-WorldState (WorldState-rects ws) (not (WorldState-paused? ws)) (WorldState-pts ws))]
    [(or (key=? ke "d") (key=? ke "u"))
     (make-WorldState (rect-add-velocity (WorldState-rects ws) ke) (WorldState-paused? ws) (WorldState-pts ws))]
    [(key=? ke "n")
     (make-WorldState (add-new-rectangle (WorldState-rects ws)) (WorldState-paused? ws) (WorldState-pts ws))]
    [(or (key=? ke "up") (key=? ke "down") (key=? ke "right") (key=? ke "left"))
     (make-WorldState (rect-add-velocity (WorldState-rects ws) ke) (WorldState-paused? ws) (WorldState-pts ws))]
    [else (world-after-tick ws)]))

;;; Helper Functions for world-after-key-event ;;;;

;; add-new-rectangle : ListOfRectangle -> ListOfRectangle
;; GIVEN: a ListOfRectangle
;; RETURNS: the ListOfRectangle with newly added rectangle as the first element
;; EXAMPLES:
;; (add-new-rectangle empty) = (cons RECT1 rects)
(define (add-new-rectangle rects)
  (cons (new-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y ZERO ZERO) rects))

;; rect-add-velocity : ListOfRectangle KeyEvent -> ListOfRectangle
;; GIVEN: a ListOfRectangle and key event
;; RETURNS: the new ListOfRectangle with changed velocities for the selected rectangles
;; EXAMPLES:
;; (rect-add-velocity (cons rect-at-canvas-center-selected empty) "right") = (cons rect1-selected-speed-right empty)
;; (rect-add-velocity (cons rect-at-canvas-center empty) "left") = (cons rect-at-canvas-center empty)

;; STRATEGY: using template of ListOfRectangle on rects
(define (rect-add-velocity lst ke)
  (cond
    [(empty? lst) empty]
    [else (cons (if (Rectangle-selected? (first lst))
                    (rect-after-key-event (first lst) ke) (first lst))
                (rect-add-velocity (rest lst) ke))]))

;; rect-after-key-event : Rectangle KeyEvent -> Rectangle
;; GIVEN: a Rectangle and KeyEvent
;; WHERE: rectangle is selected and key event in between up, down, right or left
;; RETURNS: the state of the rectangle that should follow the given rectangle after the given key event
;; EXAMPLES:
;; (rect-add-velocity rect-at-canvas-center-selected "right") = rect1-selected-speed-right

;; STRATEGY: using cases on KeyEvent ke 
(define (rect-after-key-event rect ke)
  (cond
    [(key=? ke "up")
     (make-Rectangle (Rectangle-x rect) (Rectangle-y rect) (rect-vx rect) (- (rect-vy rect) 2) true
                     (Rectangle-dx rect) (Rectangle-dy rect) (Rectangle-pendown? rect))]
    [(key=? ke "down")
     (make-Rectangle (Rectangle-x rect) (Rectangle-y rect) (rect-vx rect) (+ (rect-vy rect) 2) true
                     (Rectangle-dx rect) (Rectangle-dy rect) (Rectangle-pendown? rect))]
    [(key=? ke "right")
     (make-Rectangle (Rectangle-x rect) (Rectangle-y rect) (+ (rect-vx rect) 2) (rect-vy rect) true
                     (Rectangle-dx rect) (Rectangle-dy rect) (Rectangle-pendown? rect))]
    [(key=? ke "left")
     (make-Rectangle (Rectangle-x rect) (Rectangle-y rect) (- (rect-vx rect) 2) (rect-vy rect) true
                     (Rectangle-dx rect) (Rectangle-dy rect) (Rectangle-pendown? rect))]
    [(key=? ke "d")
     (make-Rectangle (Rectangle-x rect) (Rectangle-y rect) (rect-vx rect) (rect-vy rect) true
                     (Rectangle-dx rect) (Rectangle-dy rect) true)]
    [(key=? ke "u")
     (make-Rectangle (Rectangle-x rect) (Rectangle-y rect) (rect-vx rect) (rect-vy rect) true
                     (Rectangle-dx rect) (Rectangle-dy rect) false)]))

;; TESTS:
(begin-for-test
  ;; test if the world is paused by pressing bar or not
  (check-equal? (world-after-key-event initial-worldstate " ") paused-initial-worldstate
                "world-after-key-event should return paused world after space bar event")
  ;; test if the world is not paused for any other event than space bar
  (check-equal? (world-after-key-event initial-worldstate "a") worldstate-after-tick
                "world-after-key-event should not do anything for this event")
  ;; test if the new rectangle added to the world after pressing "n" or not
  (check-equal? (world-after-key-event initial-worldstate "n") initial-worldstate-with-rect
                "world-after-key-event should add rectangle to the world on click of 'n'")
  ;; tests for various arrow key events on selected rectangle
  (check-equal? (world-after-key-event initial-worldstate-with-rect-selected "up") worldstate-after-key-up
                "world-after-key-event should return worldstate with velocity of rectangle in y dir changed by -2")
  (check-equal? (world-after-key-event initial-worldstate-with-rect-selected "down") worldstate-after-key-down
                "world-after-key-event should return worldstate with velocity of rectangle in y dir changed by 2")
  (check-equal? (world-after-key-event initial-worldstate-with-rect-selected "right") worldstate-after-key-right
                "world-after-key-event should return worldstate with velocity of rectangle in x dir changed by 2")
  (check-equal? (world-after-key-event initial-worldstate-with-rect-selected "left") worldstate-after-key-left
                "world-after-key-event should return worldstate with velocity of rectangle in x dir changed by -2")
  ;; test for rect-add-velocity where no rectangle is selected
  (check-equal? (rect-add-velocity (cons rect-at-canvas-center empty) "left") (cons rect-at-canvas-center empty)
                "rect-add-velocity should return same list of rectangle without any change"))
;=================================================================================================================
;**************************************************** Check ***********************************************88
;; world-rects : WorldState -> ListOfRectangle
;; GIVEN: current worldState
;; RETURNS: the list of rectangles from the WorldState
;; EXAMPLES:
;; (world-rects initial-worldstate-with-rect) = (cons rect-at-canvas-center empty)
;; (world-rects initial-worldstate-with-rect-selected) = (cons rect-at-canvas-center-selected empty)

;; STRATEGY: using template of ListOfRectangle on (WorldState-rects ws)
(define (world-rects ws)
  (cond
    [(empty? (WorldState-rects ws)) empty]
    [else (cons (if (rect-selected? (first (WorldState-rects ws)))
                    (first (WorldState-rects ws))
                    (make-Rectangle (rect-x (first (WorldState-rects ws))) (rect-y (first (WorldState-rects ws)))
                                    (rect-vx (first (WorldState-rects ws))) (rect-vy (first (WorldState-rects ws)))
                                    false ZERO ZERO (rect-pen-down? (first (WorldState-rects ws)))))
                (world-rects
                 (make-WorldState (rest (WorldState-rects ws)) (WorldState-paused? ws) (WorldState-pts ws))))]))

;; TESTS:
(begin-for-test
  ;; test for worldstate with unselected rectangle in it
  (check-equal? (world-rects initial-worldstate-with-rect) (cons rect-at-canvas-center empty)
                "world-rects should return rects with one unselected rectangle")
  ;; test for worldstate with selected rectangle in it
  (check-equal? (world-rects initial-worldstate-with-rect-selected) (cons rect-at-canvas-center-selected empty)
                "world-rects should return rects with one selected rectangle"))
;=================================================================================================================

;; new-rectangle : NonNegInt NonNegInt Int Int -> Rectangle
;; GIVEN: 2 non-negative integers x and y, and 2 integers vx and vy
;; RETURNS: a rectangle centered at (x,y), which will travel with velocity (vx, vy)
;; EXAMPLES:
;; (new-rectangle 200 200 -10 10) = TEST-RECT
(define (new-rectangle x y vx vy)
  (make-Rectangle x y vx vy false ZERO ZERO false))

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
;; RETURNS: the y coordinate of the center of the rectangle by adding velocity vy
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
    [(or (<= (Rectangle-x rect) CANVAS-MIN-X) (>= (Rectangle-x rect) CANVAS-MAX-X)) (- ZERO (Rectangle-vx rect))]
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
    [(or (<= (Rectangle-y rect) 25) (>= (Rectangle-y rect) 275)) (- ZERO (Rectangle-vy rect))]
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

;; world-after-mouse-event : WorldState NonNegInt NonNegInt MouseEvent -> WorldState
;; GIVEN: A WorldState, the x- and y-coordinates of a mouse event, and the mouse event
;; RETURNS: the world that should follow the given world after the given mouse event
;; EXAMPLES:
;; (world-after-mouse-event worldstate-with-rect1 200 150 BUTTON-DOWN) =  worldstate-with-rect1
;; (world-after-mouse-event initial-worldstate 200 200 BUTTON-UP) =  initial-worldstate
;; (world-after-mouse-event worldstate-with-rect1 200 200 DRAG) =  worldstate-with-rect1
;; (world-after-mouse-event initial-worldstate 200 200 ENTER) =  initial-worldstate

;; STRATEGY: cases on MouseEvent me
(define (world-after-mouse-event ws mx my me)
  (cond
    [(mouse=? BUTTON-DOWN me)
     (make-WorldState
      (rect-list-after-mouse-event (WorldState-rects ws) mx my me) (WorldState-paused? ws) (WorldState-pts ws))]
    [(mouse=? BUTTON-UP me)
     (make-WorldState
      (rect-list-after-mouse-event (WorldState-rects ws) mx my me) (WorldState-paused? ws) (WorldState-pts ws))]
    [(mouse=? DRAG me)
     (make-WorldState
      (rect-list-after-mouse-event (WorldState-rects ws) mx my me) (WorldState-paused? ws) (WorldState-pts ws))]
    [else ws]))

;;; Helper Functions for world-after-mouse-event ;;;;

;; rect-list-after-mouse-event : ListOfRectangle NonNegInt NonNegInt MouseEvent -> ListOfRectangle
;; GIVEN: A ListOfRectangle, the x- and y-coordinates of a mouse event, and the mouse event
;; RETURNS: the ListOfRectangle after the given mouse event

;; STRATEGY: using template of ListOfRectangle on rects
(define (rect-list-after-mouse-event rects mx my me)
  (cond
    [(empty? rects) empty]
    [else (cons (rect-after-mouse-event (first rects) mx my me) (rect-list-after-mouse-event (rest rects) mx my me))]))

;; TESTS
(begin-for-test
  ;; test for button down event
  (check-equal? (world-after-mouse-event worldstate-with-rect1 200 100 BUTTON-DOWN) worldstate-with-rect1
                "world-after-mouse-event should return world with rectangle one is selected")
  (check-equal? (world-after-mouse-event initial-worldstate ZERO ZERO BUTTON-DOWN) initial-worldstate
                "world-after-mouse-event should return the same world after button down event")
  ;; test for button up event
  (check-equal? (world-after-mouse-event initial-worldstate 200 200 BUTTON-UP) initial-worldstate
                "world-after-mouse-event should return same world after button up event")
  ;; test for drag event
  (check-equal? (world-after-mouse-event worldstate-with-rect1 200 100 DRAG) worldstate-with-rect1
                "world-after-mouse-event should return world with rectangle one is selected after drag event")
  (check-equal? (world-after-mouse-event initial-worldstate ZERO ZERO DRAG) initial-worldstate
                "world-after-mouse-event should return same world after drag on origin of canvas")
  ;; test for no mouse event
  (check-equal? (world-after-mouse-event initial-worldstate 200 200 ENTER) initial-worldstate
                "world-after-mouse-event should return unchanged world after enter event"))
;=================================================================================================================

;; rect-after-mouse-event :  Rectangle NonNegInt NonNegInt MouseEvent -> Rectangle
;; GIVEN: A rectangle, the x- and y-coordinates of a mouse event, and the mouse event
;; RETURNS: the rectangle that should follow the given rectangle after the given mouse event
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

;; cursor-in-rect? : ListOfRectangle NonNegInt NonNegInt -> Boolean
;; GIVEN: a Rectangle, x and y coordinates of a mouse event
;; RETURNS: true iff any rectangle from the list is selected for dragging
;; EXAMPLES:
;; (cursor-in-rect? (cons rect1-selected empty) 200 100) = true
;; (cursor-in-rect? (cons rect-at-canvas-center empty) 200 210) = false
(define (cursor-in-rect? rect mx my)
  (and (<= mx (+ (Rectangle-x rect) RECT-HALF-WIDTH))
       (>= mx (- (Rectangle-x rect) RECT-HALF-WIDTH))
       (<= my (+ (Rectangle-y rect) RECT-HALF-HEIGHT))
       (>= my (- (Rectangle-y rect) RECT-HALF-HEIGHT))))

;; select-rect : Rectangle NonNegInt NonNegInt -> Rectangle
;; GIVEN: a Rectangle, x and y coordinates of a mouse event
;; WHERE: a Rectangle is unselected
;; RETURNS: the rectangle same as previous one but with selected flag true
;; EXAMPLES:
;; (select-rect rect1 200 100) = rect1-selected

;; STRATEGY: using template of Rectangle on rect
(define (select-rect rect mx my)
  (if (cursor-in-rect? rect mx my)
      (make-Rectangle (Rectangle-x rect) (Rectangle-y rect) (Rectangle-vx rect) (Rectangle-vy rect)
                      true (- (Rectangle-x rect) mx) (- (Rectangle-y rect) my) (Rectangle-pendown? rect))
      (unselect-rect rect)))

;; unselect-rect : Rectangle -> Rectangle
;; GIVEN: a Rectangle
;; WHERE: a Rectangle is selected
;; RETURNS: the rectangle same as previous one but with selected flag false
;; EXAMPLES:
;; (select-rect rect1-selected 200 100) = rect1

;; STRATEGY: using template of Rectangle on rect
(define (unselect-rect rect)
  (make-Rectangle (Rectangle-x rect) (Rectangle-y rect) (Rectangle-vx rect) (Rectangle-vy rect)
                  false ZERO ZERO (Rectangle-pendown? rect)))

;; drag-rect : Rectangle NonNegInt NonNegInt -> Rectangle
;; GIVEN: a Rectangle, x and y coordinate of mouse
;; WHERE: a Rectangle is selected
;; RETURNS: the rectangle same as previous one, but changed center coordinates
;; EXAMPLES:
;; (drag-rect rect1-selected 200 100) = rect1

;; STRATEGY: using template of Rectangle on rect
(define (drag-rect rect mx my)
  (if (cursor-in-rect? rect mx my)
      (make-Rectangle (+ mx (Rectangle-dx rect)) (+ my (Rectangle-dy rect)) (Rectangle-vx rect)
                      (Rectangle-vy rect) true (Rectangle-dx rect) (Rectangle-dy rect) (Rectangle-pendown? rect))
      (unselect-rect rect)))

;; TESTS:
(begin-for-test
  ;; test for mouse enter event on unselected rectangle
  (check-equal? (rect-after-mouse-event rect1 200 200 ENTER) rect1 "rect-after-mouse-event should return same rectangle")
  ;; test for mouse button up event on unselected rectangle
  (check-equal? (rect-after-mouse-event rect1 200 200 BUTTON-UP) rect1 "rect-after-mouse-event should return same rectangle")
  ;; test for select-rect for unselected rectangle
  (check-equal? (select-rect rect1 200 400) rect1 "select-rect should return unselected rectangle")
  ;; test for mouse drag event for unselected rectangle 
  (check-equal? (drag-rect rect1 200 400) rect1 "drag-rect should return unselected rectangle")
  ;; test if rectangle is seletected for dragging
  (check-equal? (cursor-in-rect? rect-at-canvas-center 200 210) false
                "cursor-in-rect? should return false if rectangle not selected"))
;=================================================================================================================

;; rect-selected? : Rectangle -> Boolean
;; GIVEN: a Rectangle
;; RETURNS: true iff the given rectangle is selected
;; EXAMPLES:
;; (rect-selected? rect1-selected) = true
(define (rect-selected? rect)
  (Rectangle-selected? rect))

;; TESTS:
(begin-for-test
  (check-equal? (rect-selected? rect1-selected) true "rect-selected? should return true for selected rectangle"))
;=================================================================================================================

;; world-paused? : WorldState -> Boolean
;; GIVEN: a rectangle
;; RETURNS: true iff the worldState is paused
;; EXAMPLES:
;; (world-paused? paused-initial-worldstate) = true

;; STRATEGY: using template of WorldState on ws
(define (world-paused? ws)
  (WorldState-paused? ws))

;; TESTS:
(begin-for-test
  ;; test if the given world is paused or not
  (check-equal? (world-paused? paused-initial-worldstate) true "world-paused? should return true for paused world"))
;=================================================================================================================

;; rect-pen-down? : Rectangle -> Boolean
;; GIVEN: a Rectangle
;; RETURNS: true iff the Rectangle is selected for tracking
;; EXAMPLES:
;; (rect-pen-down? rect1) = false

;; STRATEGY: using template of WorldState on ws
(define (rect-pen-down? rect)
  (Rectangle-pendown? rect))
;=================================================================================================================