;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname screansaver-5) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; screensaver-5.rkt
;; start with : (screensaver PosReal)
(require rackunit)
(require 2htdp/universe)
(require 2htdp/image)
(require "extras.rkt")
(provide screensaver)
(provide initial-world)
(provide world-after-tick)
(provide world-after-key-event)
(provide rect-after-key-event) 
(provide world-rects)
(provide world-paused?)
(provide new-rectangle)
(provide rect-x)
(provide rect-y)
(provide rect-vx)
(provide rect-vy)
(provide world-after-mouse-event)
(provide rect-after-mouse-event)
(provide rect-selected?)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Definition for Lists: 

;; A ListOfX is either
;; -- empty
;; -- (cons X ListOfX)
;; INTERP:
;; empty
;; (cons x xs)
;;

;; Template:
;; lox-fn : ListOfX -> ??
#|
(define (lox-fn 1ox)
  (cond
    [(empty? 1ox) ...]
    [else (... (first 1ox)
               (lox-fn (rest lox))]))
|#


;; A KeyEvent is one of:
;; "n"
;; " "
;; "down"
;; "up"
;; "left"
;; "right"
;; "d"
;; "u"
;; INTERPRETATION: self-evident

;; TEMPLATE
;; wake-fn: WorldState KeyEvent ->??
#|
(define (wake w kev)
  (cond
    [(key=? kev " ")...]
    [(key=? kev "n")...]
    [(key=?  kev "down")...]
    [(key=? kev "up")...]
    [(key=? kev "left")...]
    [(key=? kev "right")...]
    [(key=? kev "d")...]
    [(key=? kev "u")...]))
|#
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |Main| ok
;; MAIN FUNCTION.

;; main: PosReal -> World
;; GIVEN: the speed of the simulation, in seconds/tick
;; EFFECT: runs the simulation. 
;; RETURNS: the final state of the world
(define (main v)
  (big-bang (initial-world v)
            (on-tick world-after-tick v) 
            (on-key world-after-key-event)
            (on-draw world-to-scene)  
            (on-mouse world-after-mouse-event)                      
            ))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |Screensaver| 
;; screensaver: PosReal -> WorldState

;; GIVEN: the speed of the simulation, in seconds/tick
;; EFFECT: runs the simulation, starting with the initial world: empty canvas. 
;; Each time when User hitting "n", then adds a new rectangle at the center of
;; the canvas with (0,0) velocity, and user can drag it. When user select
;; one rectangle, he can use 'up' 'down' 'left' and 'right' key to adjust
;; it's velocity. When user use 'space' key, every rectangle will move toward
;; it's velocity. When user selecte certain rectangle, and hit 'd', then there is
;; a dot print in the center of rectangle and use 'u' to cancel it. 
;; RETURNS: the final state of the world after fill in like (screensaver 0.5) 
;; EXAMPLE:
;; (screensaver 0.5) = Game start in 0.5 second/tick
(define (screensaver v)
  (main v))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |Struct World| 
;; DATA DEFINITION
(define-struct world (rects paused? ))

;; A World is a (make-world ListOfRectangle Boolean)
;; Interpretation:
;; rects is the list of retangles which the user add in canvas totally
;; paused? describes whether or not the world is paused

;; Template:
;; world-fn: World ->?? 
;; (define (world-fn w)
;;   (...(world-rects w)(world-paused? w)
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |Struct Rect|
;; DATA DEFINITION

(define-struct rect (x y vx vy mx my selected? pen? dot))

;; A Rect is a
;; (make-rect NonNegInt NonNegInt Int Int NonNegInt NonNegInt Boolean Boolean ListOfDot)
;; Interpretation:
;; x, y give the position of the center of the rectangle
;; vx, vy give the speed of the rectangle in x and y direction
;; mx, my give the mouse's x and y position. When mouse inside of certain rectangle
;; and selecte it, mx and my save as the x and y position of the mouse. 
;; selected? describes whether or not the rectangle is selected
;; pen? describes whether or not the rectangle should draw dot
;; dot is  a list of dots which comes from certain rectangle's center and printed in the screen. 

;; Template:
;;rect-fn: Rect ->??
#|
(define (rect-fn r)
(...(rect-x r)
    (rect-y r) 
    (rect-vx r)
    (rect-vy r)
    (rect-mx r)
    (rect-my r)
    (rect-selected? r)
    (rect-pen? r)
    (rect-dot r)))
|#

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |Struct Dot|
;; DATA DEFINITION
(define-struct  dot (x y))

;; A Dot is a (make-dot PosInt PosInt)
;; Interpretation:
;; x, y given the x and y position of the dot drawing on the screen. 

;; Template:
;; dot-fn: Dot ->??
#|
(define (dot-fn d)
(...(dot-x d)
    (dot-y d)))
|#
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |CONSTANTS| 
;; CONSTANTS

;; use for original center of rectangle when it appear. 
(define CENTEROFRECTANGLE-X 200)
(define CENTEROFRECTANGLE-Y 150)

;; use for original speed of rectangle and mouse position. 
(define ZERO 0)

;; movement distance of a rectangle after each tick. 
(define EACH-TIME-MOVE 2)

;; dimensions of the canvas
(define CANVAS-WIDTH 400) 
(define CANVAS-HEIGHT 300)
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

;; dimensions of the rectangle
(define RECTANGLE (rectangle 60 50 "outline" "blue"))

;; dimension of the rectangle when certain rectangle is selected. 
(define RECTANGLE_RED (rectangle 60 50 "outline" "red"))
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |Initial World| 
;; initial-world: Any -> WorldState

;; PURPOSE: To design the initial world when start. 
;; GIVEN: any value (ignored)
;; RETURNS: The initial world specified in the problem set:
;;          An empty canvas without any rectangles. 
;;          Creat an empty list for puting rectangles in. 
;;          Even add rectangles, they are paused initially. 
;; EXAMPLES:
;; (initial-world 1) = (make-world '() #true)
;; STRATEGY: Use template for world on Any
(define (initial-world Any)
  (make-world
   (list ) true ))


;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |World-to-scene| 
;; world-to-scene: WorldState -> Scene

;; GIVENS: a world
;; RETURNS: a Scene that portrays the given world:
;; EXAMPLEs: see test below
;; STRATEGY: Use HOF foldr on w

(define (world-to-scene w)
  (foldr place-all EMPTY-CANVAS  (world-rects w)))


;; place-all: -> Scene

;; PURPOSE: a function combine place rectangle, text and dot in the scene. 
;; GIVENS: a rectangle 
;; RETURNS: a Scene that portrays the given world:
;; if certain rectangle is selected, it is red, otherwise it is blue.
;; if the mouse click inside of a certain rectangle, a small red circle appear.
;; velority will like (0,0) as text showing inside o the rectangle. 
;; EXAMPLEs: see test below
;; STRATEGY: Use template for World on w
(define (place-all a b )
  (place-rect a
   (place-text a
    (place-dot(rect-dot a) b))))
;;~~~~~~~~~~~~~~~~~~~~~~                
;; place-rect: Rectangle Scene -> Scene

;; PURPOSE: Help function for world-to-scene
;; GIVENS: a certain rectangle and the scene
;; RETURNS: a new scene that portrays the given world:
;;          when the rectangle is selected, it is red,
;;          and a red circle will locate at where user clicking.
;;          When it is unselected, it is blue without red circle.
;; EXAMPLEs: see test below
;; STRATEGY: combine simple functions

(define (place-rect r s)
  (if (rect-selected? r)
      (place-rect-select r s )
      (place-rect-unselect r s )))


;; place-rect-select: Rectangle Scene -> Scene

;; PURPOSE: Help function for place-rect
;; GIVENS: a rectangle and the scene
;; RETURNS: a new scene that when the rectangle is selected 
;; EXAMPLEs: see test below
;; STRATEGY: Use template for Rect on r
(define (place-rect-select r s )
  (place-image
   (circle 2 "outline" "red")
   (rect-mx r) (rect-my r)
   (place-image  RECTANGLE_RED  
                 (rect-x r) (rect-y r)
                 s)))


;; place-rect-unselect: Rectangle Scene -> Scene

;; PURPOSE: Help function for place-rect
;; GIVENS: a rectangle and the scene
;; RETURNS: a new scene that when the rectangle is unselected 
;; EXAMPLEs: see test below
;; STRATEGY: Use template for Rect on r
(define (place-rect-unselect r s )
  (place-image
   RECTANGLE
   (rect-x r) (rect-y r)
   s))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~
;; place-dot-single: ListOfDot Scene -> Scene

;; PURPOSE: Place single dot on the scene which is a small black circle
;;          following the center of the rectangle after click key 'd'. 
;; GIVEN: a single dot and a scene
;; RETURNS: a new scene with this single dot on it.
;; EXAMPLES: see tests below
;; STRATEGY: Use template for Dot on d

(define (place-dot-single dot s)
  (place-image
   (circle 1 "outline" "black")
   (dot-x dot)  (dot-y dot) s))


;; place-dot: ListOfDot Scene -> Scene

;; PURPOSE: Place all dots on the scene which are a small black circle
;;          following the center of the rectangle after click key 'd'.
;; GIVEN: a list of dots, and a scene
;; RETURNS: a new scene with new dots on it.
;; EXAMPLES: see tests below
;; STRATEGY: Use HOF foldr on d

(define (place-dot dots s)
  (foldr place-dot-single s dots))
 
 
;; Definition for testing. 
(define listofdot (list (make-dot 100 100) (make-dot 105 105) (make-dot 110 110)))

;;~~~~~~~~~~~~~~~~~~~~
;; place-text: Rectangle Scene -> Scene

;; PURPOSE: Help function for world-to-scene, to add text in the center of rectangle
;;          to showing its velocity. 
;; GIVENS: a certain rectangle and the scene
;; RETURNS: a new scene that portrays the given world:
;;          if certain rectangle is selected, the text inside it,red.
;;          Otherwise it is blue.
;; EXAMPLES: see test below
;; STRATEGY: Combine simpler functions 

(define (place-text r s)
  (if (rect-selected? r)
      (place-text-selected r s )
      (place-text-unselected r s )))

      
;; place-texted: Rectangle Scene -> Scene

;; PURPOSE: help function for place-text, when the rectangle is selected. 
;; GIVENS: a rectangle and a scene
;; RETURNS: a scene with red text inside of this selected rectangle
;; EXAMPLES: see test below
;; STRATEGY: Use template for Rect on r 

(define (place-text-selected r s )
  (place-image
   (rect-text-red (rect-vx r) (rect-vy r))
   (rect-x r)(rect-y r)
   s))

  
;; place-text-unselected: Rectangle Scene -> Scene

;; PURPOSE: help function for place-text, when the rectangle is unselected. 
;; GIVENS: a rectangle and a scene
;; RETURNS: a scene with blue text inside of this unselected rectangle
;; EXAMPLES: see test below
;; STRATEGY: Use template for Rect on r  
  (define (place-text-unselected r s )
    (place-image
     (rect-text (rect-vx r) (rect-vy r))
     (rect-x r)(rect-y r)
     s))


;; Definition for testing.
(define v (make-rect 100 100 4 4 0 0 false false (list )))
(define w (make-rect 100 100 4 4 100 100 true false (list )))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |Text| ok
;; rect-text: Int Int -> String

;; PURPOSE:Tell user what is the current velocity of the rectangle. 
;; negative input of test "vx" shows it move toward west, positive means east.
;; negative input of text "vy" shows it move toward north, positive means south. 
;; GIVEN: the rectangle's velocity at x and y direction
;; RETURN: a string which is conbind with (, rectangle's velocity at x direction, dot,
;; rectangle's velocity at y direction, and close ).They are all blue and size in 13.
;; WHERE: the rectangle is unselected
;; Examples:
;; (rect-text 20 30)= (20,30)
;; STRATEGY: Combine simpler functions

(define (rect-text vx vy)
  (text (string-append "(" (number->string vx) ", " (number->string vy) ")") 13 "blue"))

;;~~~~~~~~~~~~~~~~~~~~~

;; rect-text-red: Int Int -> String

;; PURPOSE:Tell user what is the current velocity of the rectangle. 
;; negative input of test "vx" shows it move toward west, positive means east.
;; negative input of text "vy" shows it move toward north, positive means south. 
;; GIVEN: the rectangle's velocity at x and y direction
;; RETURN: a string which is conbind with (, rectangle's velocity at x direction, dot,
;; rectangle's velocity at y direction, and close ).They are all red and size in 13.
;; WHERE: the rectangle is selected
;; Examples:
;; (rect-text-red -10 -15) =  (-10,-15)
;; STRATEGY: Combine simpler functions

(define (rect-text-red vx vy)
  (text (string-append "(" (number->string vx) ", " (number->string vy) ")") 13 "red"))

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |world-after-key-event| 

;; world-after-key-event: WorldState KeyEvent -> WorldState

;; GIVEN: a world w and a keyevent kev
;; RETURN: the world that should follow the given world after the given key event.
;; STRATEGY: case on KeyEvent kev
;; EXAMPLES: see below test

(define (world-after-key-event w kev)
  (cond
    [(key=? kev "down")(world-speed w kev)]
    [(key=? kev "up")(world-speed w kev)]
    [(key=? kev "left")(world-speed w kev)]
    [(key=? kev "right")(world-speed w kev)]
    [(key=? kev "d")(world-speed w kev)]
    [(key=? kev "u")(world-speed w kev)]
    [(key=? kev " ")(world-with-paused-toggled w)] 
    [(key=? kev "n")(world-add-one-rect w)]
    (else w))) 


;; Definition for testing. 
(define c (make-rect 50 50 0 0 0 0 true false (list )))  

;; TEST:

(begin-for-test
  (check-equal? (world-after-key-event (make-world (list c) true) "down")
                (make-world (cons (make-rect 50 50 0 2 0 0 #true #false '()) '()) #true)
                "the velocity of this rectangle d on y direction should add 2 pixels. ")
  (check-equal? (world-after-key-event (make-world (list c) true) "up")
                (make-world (cons (make-rect 50 50 0 -2 0 0 #true #false '()) '()) #true)
                "the velocity of this rectangle d on y direction should minus 2 pixels. ")
  (check-equal? (world-after-key-event (make-world (list c) true) "left")
                (make-world (cons (make-rect 50 50 -2 0 0 0 #true #false '()) '()) #true)
                "the velocity of this rectangle d on y direction should minus 2 pixels. ")
  (check-equal? (world-after-key-event (make-world (list c) true) "right")
                (make-world (cons (make-rect 50 50 2 0 0 0 #true #false '()) '()) #true)
                "the velocity of this rectangle d on y direction should add 2 pixels. ")
  (check-equal? (world-after-key-event (make-world (list c) true) " ")               
                (make-world (cons (make-rect 50 50 0 0 0 0 #true #false '()) '()) #false)
                "the world should from paused to unpaused. ")
  (check-equal? (world-after-key-event (make-world (list ) true) "n")
                (make-world (cons (make-rect 200 150 0 0 0 0 #false #false '()) '()) #true)
                "after click key 'n', a new rectangle appears at (200,150) with velocity (0,0) "))


;;~~~~~~~~~~~~~~~~
;; world-speed: WorldState KeyEvent -> WorldState

;; PURPOSES: help function of world-after-key-event, when key is down, up, left or right. 
;; GIVEN: a world w and a keyevent
;; RETURN: the world that should follow the given world after the given key event.
;; WHERE:
;; "down" means increase the rectangle's velocity of y direction by 2 pixels/tick
;; "up" means decrease the rectangle's velocity of y direction by 2 pixels/tick
;; "left" means decrease the rectangle's velocity of x direction by 2 pixels/tick
;; "right" means increase the rectangle's velocity of x direction by 2 pixels/tick
;; STRATEGY: Use template for World on w
;; EXAMPLES: see below test


(define (world-speed w kev)
  (cond
    [(equal?
       (select-rect  (world-rects w) kev)  
       (world-rects w))
      w]
    [else
      (make-world
       (select-rect (world-rects w) kev)  
       (world-paused? w))])) 



;; Definition for testing.
(define a (make-rect 30 30 0 0 0 0 false false (list )))
;; (define c (make-rect 50 50 0 0 0 0 true false (list )))


;; TESTS:
(begin-for-test
  (check-equal? (world-speed (make-world (list c) true) "up")
                (make-world (cons (make-rect 50 50 0 -2 0 0 #true #false '()) '()) #true)
                "because the rectangle c selected, then its should changed. No dot. ")
  (check-equal? (world-speed (make-world (list a) true) "up")
               (make-world (cons (make-rect 30 30 0 0 0 0 #false #false '()) '()) #true)
                "because the rectangle a unselected, thus return itself without any changes. No dot. "))

;;~~~~~~~~~~~~~~~~~~~
;; select-rect: List KeyEvent -> List

;; PURPOSES: help function of world-after-key-event, make sure every selected rectangle
;;           can call function rect-after-key-event. 
;; GIVEN: a list of rectangles and a keyevent. 
;; RETURN: a new list full of rectangles which have been selected. 
;; STRATEGY: Use template for ListOfRect on lst
;; EXAMPLES: see test below 
 
(define (select-rect lst kev ) 
  
  (cond 
    [(empty? lst) empty]
    [else (if (rect-selected? (first lst) )
              
              (cons
               (rect-after-key-event (first lst) kev)
               (select-rect (rest lst) kev)  )
              
              (cons
               (first lst)
               (select-rect (rest lst) kev)  ))]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Definition for testing.
;; (define a (make-rect 30 30 0 0 0 0 false false (list )))
;; (define c (make-rect 50 50 0 0 0 0 true false (list )))

;; TEST:
(begin-for-test  
  (check-equal? (select-rect (list a)  "up")
                (cons (make-rect 30 30 0 0 0 0 #false #false  (list )) '())
                "because the list1 is empty, thus return list2 which is list c in this case. ")
  (check-equal? (select-rect (list a  c)  "up")
                (cons
                 (make-rect 30 30 0 0 0 0 #false #false '())
                 (cons (make-rect 50 50 0 -2 0 0 #true #false '()) '()))
                "because only rectangle c being selected, thus only rectangle c changed in list2 "))

;;~~~~~~~~~~~~~~~~~~~~  
;; rect-after-key-event: Rectangle KeyEvent -> Rectangle

;; PURPOSES: To change the velocity of rectangle or draw dot or cancel dot. 
;; GIVEN: a world w and a keyevent
;; RETURNS: the world that should follow the given world after the given key event.
;;          if click right, left, down, up, then change velocity.
;;          if click d, then start draw dot. If click u, then cancel drawing dot. 
;; EXAMPLES: see test below. 
;; STRATEGY: case on KeyEvent kev 


(define (rect-after-key-event r kev)
  (cond
    [(key=? kev "right") (move-right-or-left r kev)]  
    [(key=? kev "left") (move-right-or-left r kev)]
    [(key=? kev "down") (move-down-or-up r kev)]
    [(key=? kev "up") (move-down-or-up r kev)]
    [(key=? kev "d") (click-d-or-u r kev)]
    [(key=? kev "u") (click-d-or-u r kev)]
    [else r]))

;; move-right-or-left: Rectangle KeyEvent -> Rectangle

;; PURPOSES: help function for rect-after-key-event, for change x direction speed. 
;; GIVEN: a world w and a keyevent
;; RETURNS: the speed of x direction of rectangle has been changed. 
;; EXAMPLES: see test below. 
;; STRATEGY: Use template for Rect on r. 

(define (move-right-or-left r kev)
  (make-rect  (rect-x r) (rect-y r)
              (cond
                [(key=? kev "right")
                 (+ (rect-vx r) EACH-TIME-MOVE)]
                [(key=? kev "left")
                 (- (rect-vx r) EACH-TIME-MOVE)]) 
              (rect-vy r) (rect-mx r) (rect-my r) true (rect-pen? r) (rect-dot r)))


;; move-down-or-up: Rectangle KeyEvent -> Rectangle

;; PURPOSES: help function for rect-after-key-event, for change y direction speed. 
;; GIVEN: a world w and a keyevent
;; RETURNS: the speed of y direction of rectangle has been changed. 
;; EXAMPLES: see test below. 
;; STRATEGY: Use template for Rect on r.

(define (move-down-or-up r kev)
  (make-rect  (rect-x r) (rect-y r) (rect-vx r)
              (cond
                [(key=? kev "down")
                 (+  (rect-vy r ) EACH-TIME-MOVE)]
                [(key=? kev "up")
                 (-  (rect-vy r) EACH-TIME-MOVE)])
              (rect-mx r) (rect-my r) true (rect-pen? r) (rect-dot r)))



;; move-down-or-up: Rectangle KeyEvent -> Rectangle

;; PURPOSES: help function for rect-after-key-event, for whether drawing dot.  
;; GIVEN: a world w and a keyevent
;; RETURNS: if click "d", then start drawing. if click "u", then cancel drawing. 
;; EXAMPLES: see test below. 
;; STRATEGY: Use template for Rect on r.

(define (click-d-or-u r kev)
  (make-rect  (rect-x r)(rect-y r)(rect-vx r)(rect-vy r)(rect-mx r)(rect-my r) true
              (cond
                [(key=? kev "d")
                 true]
                [(key=? kev "u")
                 false])
              (rect-dot r))) 
                

;; Definition for testing:
;; (define a (make-rect 30 30 0 0 0 0 false false (list )))
;; (define c (make-rect 50 50 0 0 0 0 true false (list )))
(define z (make-rect 30 30 0 0 0 0 false true (list )))

;; TESTS:
(begin-for-test
  (check-equal?  (rect-after-key-event a "right") (make-rect 30 30 2 0 0 0 #true #false '())
                 "rectangle a's new velocity should be (2,0)")
  (check-equal?  (rect-after-key-event a "left") (make-rect 30 30 -2 0 0 0 #true #false '())
                 "rectangle a's new velocity should be (-2,0)")
  (check-equal?  (rect-after-key-event a "up") (make-rect 30 30 0 -2 0 0 #true #false '())
                 "rectangle a's new velocity should be (0,-2)")
  (check-equal?  (rect-after-key-event a "down") (make-rect 30 30 0 2 0 0 #true #false '())
                 "rectangle a's new velocity should be (0,2)")
  (check-equal? (rect-after-key-event a "d") (make-rect 30 30 0 0 0 0 #true #true '())
                 "rectangle a should start dot")
  (check-equal? (rect-after-key-event z "u") (make-rect 30 30 0 0 0 0 #true #false '())
                "rectangle z should stop dot"))

;;~~~~~~~~~~~~~~~~~~~~~~~ 
;; world-add-one-rect: World -> World

;; PURPOSE: when user click key 'n', a new rectangle appear in the center of canvas.
;; GIVEN: a world
;; RETURN: the world added a new paused rectangle showing at (200,150). 
;; EXAMPLES: see test below 
;; STATEGY: Use template for World on w. 


(define (world-add-one-rect w)
  (make-world
   (append (world-rects w)  a-new-rectangle)
   true))    


;; a-new-rectangle: World -> World

;; PURPOSE: help function for world-add-one-rect, drawing a new rectangle. 那远code给我啊
;; GIVEN: a world
;; RETURN: an unselected and paused rectangle shows at (200,150) with (0,0) velocity.
;; EXAMPLES: see test below 
;; STATEGY: Use template for Rect on w. 

(define a-new-rectangle 
  (list (make-rect 
         CENTEROFRECTANGLE-X 
         CENTEROFRECTANGLE-Y
         ZERO ZERO ZERO ZERO false false (list )) ))



;; TESTS:
(begin-for-test
  (check-equal? (world-add-one-rect (make-world (list ) true))
                (make-world (cons (make-rect 200 150 0 0 0 0 #false #false '()) '()) #true)
                "world should appear a new rectangle at (200,150) with (0,0) velocity and unselected
                 The rectangle should paused and no pen at first."))


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |world-with-paused-toggled| ok
;; world-with-paused-toggled: World -> World

;; PURSPOSE:
;; if the world is paused, then unpause it.
;; if the world is unpaused, then pause it. 
;; GIVEN: a world w
;; RETURNS: a world just like the given one, but with paused? toggled
;; EXAMPLES: see test below 
;; STRATEGY: use template for World on w
(define (world-with-paused-toggled w) 
  (make-world
   (world-rects w)
   (not (world-paused? w))))


;;TESTS:
(begin-for-test
  (check-equal?  (world-with-paused-toggled (make-world (list ) false))
                 (make-world '() #true)
                 "World unpaused should paused after toggled.")
  (check-equal?  (world-with-paused-toggled (make-world (list ) true))
                 (make-world '() #false)
                 "World paused should unpaused after toggled."))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |world-after-mouse-event|
;; world-after-mouse-event: WorldState Integer Integer MouseEvent -> WorldState

;; GIVEN: a world and a description of a mouse event include the mouse's
;;        x and y position, and the keyevent. 
;; RETURNS: the world that should follow the given mouse event
;; EXAMPLES: see tests below
;; STRATEGY: use template for World on w

(define (world-after-mouse-event w mx my mev)
  (make-world
   (rects-after-mouse-event (world-rects w) mx my mev)  
   (world-paused? w))) 
 

;; TESTS:
(begin-for-test
  (check-equal? (world-after-mouse-event (make-world (list ) true) 100 100 "button-down")
                (make-world '() #true)
                "world paused after button down when mouse click at (100, 100) should
                 unchanged the list and continue paused. ")
  (check-equal? (world-after-mouse-event (make-world (list ) false) 100 100 "button-down")
                (make-world '() #false)
                "world unpaused after button down when mouse click at (100, 100) should
                 unchanged the list and continue unpaused. ")
  (check-equal? (world-after-mouse-event (make-world (list ) true) 100 100 "button-up")
                (make-world '() #true)
                "world paused after button-up when mouse at (100, 100) should
                 unchanged the list and continue paused. ")
  (check-equal? (world-after-mouse-event (make-world (list ) false) 100 100 "button-up")
                (make-world '() #false)
                "world unpaused after button-up when mouse at (100, 100) should
                 unchanged the list and continue unpaused. ")
  
  (check-equal? (world-after-mouse-event (make-world (list ) true) 100 100 "drag")
                (make-world '() #true)
                "world paused after drag when mouse at (100, 100) should
                 unchanged the list and continue paused. ")
  (check-equal? (world-after-mouse-event (make-world (list ) false) 100 100 "drag")
                (make-world '() #false)
                "world unpaused after drag when mouse at (100, 100) should
                 unchanged the list and continue unpaused. "))

;;~~~~~~~~~~~~~~~~~
;; rects-after-mouse-event: ListOfRectangle Integer Integer MouseEvent -> ListOfY

;; PURPOSE: Let every rectangles in world-rects list call function rect-after-mouse-event
;;          until when list empty. 
;; until the list1 is empty. Use recursion to accomplish. 
;; GIVEN: the list of rectangles, and a description of a mouse event include
;;        the mouse's x and y position, and the key.
;; RETURNS: list which every element has been call function rect-after-mouse-event. 
;; EXAMPLES: see tests below

;; STRATEGY: Use HOF map on lst


(define (rects-after-mouse-event lst mx my mev)
  (map (lambda (x) (rect-after-mouse-event x mx my mev)) lst))


;; Definition for testing:
;; (define a (make-rect 30 30 0 0 0 0 false false (list )))
 (define b (make-rect 50 50 0 0 0 0 false false (list )))


;;TESTS: 
(begin-for-test
  (check-equal? (rects-after-mouse-event (list a b)  40 40 "button-down")
                (cons
                 (make-rect 30 30 0 0 40 40 #true #false '())
                 (cons (make-rect 50 50 0 0 40 40 #true #false '()) '())) 
                "rectangle a and b are unselected, afteer rects-after-mouse-event, they should
                 both changed to be selected, recursion successful. "))


;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |rect-after-mouse-event|
;; rect-after-mouse-event:  Rectangle Integer Integer MouseEvent -> Rectangle

;; GIVEN: A rectangle, the x- and y-coordinates of a mouse event, and the mouse event
;; RETURNS: a rectangle that followed the given mouse event
;; EXAMPLES: see tests below 
;; STRATEGY: Cases on mouse event mev

(define (rect-after-mouse-event rec mx my mev)
  (cond
    [(mouse=? mev "button-down") (rect-after-button-down rec mx my)]
    [(mouse=? mev "drag") (rect-after-drag rec mx my)]
    [(mouse=? mev "button-up") (rect-after-button-up rec mx my)]
    [else rec])) 

;; Definition for testing.  
;; (define a (make-rect 30 30 0 0 0 0 false false (list )))
;; (define c (make-rect 50 50 0 0 0 0 true false (list )))

;; TESTS:
(begin-for-test
  (check-equal? (rect-after-mouse-event a 30 30 "button-down")
                (make-rect 30 30 0 0 30 30 #true #false '())
                "after button-down, rect 'a' should from unselected become selected. ")
  (check-equal? (rect-after-mouse-event c 30 30 "drag")


                (make-rect 80 80 0 0 30 30 #true #false '())
                "after drag, rect 'c' should from center (50,50) to (80,80). ")
  (check-equal? (rect-after-mouse-event c 30 30 "button-up")
                (make-rect 50 50 0 0 30 30 #false #false '())
                "after button-up, rect 'c' should from selected to unselected"))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |rec-after-button-down|
;; rect-after-button-down : Rectangle Integer Integer -> Rectangle

;; PURPOSE: To make the rectangle from unselected to selected with
;; unchanged center and velocity. 
;; GIVEN: a rectangle and the x and y position of the mouse when button down. 
;; RETURNS: the rectangle moving a button-down at the given location.
;; EXAMPLES: see tests below
;; STRATEGY: Use template for Rect on rec

(define (rect-after-button-down rec x y)
  (if (in-rect? rec x y)
      (make-rect
       (rect-x rec)
       (rect-y rec)
       (rect-vx rec)
       (rect-vy rec)
       x
       y
       true
       (rect-pen? rec)
       (rect-dot rec))
      rec))

;;TESTS:
(begin-for-test
  
  (check-equal? (rect-after-button-down (make-rect 100 100 2 4 100 100 false false (list )) 100 100)
                (make-rect 100 100 2 4 100 100 #true #false '())
                "rectangle center at (100,100), velocity is (2,4), unselected becomes selected")
  (check-equal? (rect-after-button-down (make-rect 50 50 -3 -10 100 100 false  false (list )) 100 100)
                (make-rect 50 50 -3 -10 100 100 #false #false '())
                "Because mouse button down outside the rectangle so it is still not selected"))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |rec-after-drag|
;; rect-after-drag : Rectangle Integer Integer -> Rectangle

;; PORPOSE: If the rectangle has been selected, then after dragging,
;; it will at new position where depended on the mouse moving distance on x and y direction.
;; If the rectangle are not selected, then return itself.
;; GIVEN: a rectangle before dragging, and the mouse x and y position after dragging. 
;; RETURNS: the rectangle moving a drag at the given location
;; EXAMPLES: see test below
;; STRATEGY: Use template for Rect on rec

(define (rect-after-drag rec x y)
  (if (rect-selected? rec)
      (make-rect
       ( + (rect-x rec) (- x (rect-mx rec) ))
       ( + (rect-y rec) (- y (rect-my rec))) 
       (rect-vx rec)
       (rect-vy rec)
       x
       y   
       true (rect-pen? rec) (rect-dot rec))
      rec))


;;TESTS:
(begin-for-test
  (check-equal? (rect-after-drag (make-rect 50 50 0 0 50 50 true false (list )) 20 30)
                (make-rect 20 30 0 0 20 30 #true #false '())
                "selected rectangle, center (50,50), velocity (0,0), mouse at the center of rectangle,
                 after dragging, mouse moves to (20, 30), rectangle changed to (20,30) too.")
  
  (check-equal? (rect-after-drag (make-rect 50 50 0 0 50 50 false false (list )) 20 30)
                (make-rect 50 50 0 0 50 50 #false #false '())
                "unselected rectangle, center (50,50), velocity (0,0), mouse at the center of rectangle,
                 after dragging, mouse moves to (20, 30), rectangle changed to (20,30) too.")
  
  (check-equal? (rect-after-drag (make-rect 30 30 0 0 20 40 true false (list )) 200 100)
                (make-rect 210 90 0 0 200 100 #true #false '()) 
                "selected rectangle, center (30,30), velocity (0,0), mouse at (20,40) inside of rectangle,
                 after dragging, mouse moves to (200, 100), rectangle changed to (210,90)")
  
  (check-equal? (rect-after-drag (make-rect 30 30 0 0 20 40 false false (list )) 200 100)
                (make-rect 30 30 0 0 20 40 #false #false '()) 
                "unselected rectangle, center (30,30), velocity (0,0), mouse at (20,40) inside of rectangle,
                 after dragging, mouse moves to (200, 100), rectangle changed to (210,90)"))


;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |rec-after-button-up|
;; rect-after-button-up : Rectangle Integer Integer -> Rectangle

;; PURPOSE: To make rectangle unselected. If it is selected, then unselected,
;; and if it is unselected, then unchanged.
;; GIVEN: one rectangle, and the mouse's x and y position 
;; RETURNS: the rectangle moving a button-up at the given location
;; EXAMPLES: see test below
;; STRATEGy: Use template for Rect on rec

(define (rect-after-button-up rect x y)
  (if (rect-selected? rect)
      (make-rect
       (rect-x rect)
       (rect-y rect)
       (rect-vx rect)
       (rect-vy rect)
       x
       y
       false
       (rect-pen? rect)
       (rect-dot rect))
      rect))

;;TESTS:
(begin-for-test
  (check-equal? (rect-after-button-up (make-rect 100 100 0 0 100 100 false false (list )) 100 100)
                (make-rect 100 100 0 0 100 100 #false #false '())
                "This rectangle is unselected, then unchanged. " )
  
  (check-equal? (rect-after-button-up (make-rect 100 100 0 0 100 100 true false (list )) 100 100)
                (make-rect 100 100 0 0 100 100 #false #false '())
                "This rectangle is selected, then after button up, it becomes unselected. " ))


;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |in-rec?|
;; in-rect? : Rectangle Integer Integer -> Rectangle

;; PURPOSE: test whether the mouse inside certain rectangle
;; GIVEN: certain rectangle and the mouse's x and y position
;; RETURNS true iff the given coordinate is inside the bounding box of
;; the given rectangle.
;; EXAMPLES: see tests below 

;; STRATEGY: Use template for Rect on rect

(define (in-rect? rect x y)
  (and
   (<= 
    (- (rect-x rect) 30)  
    x 
    (+  (rect-x rect) 30))
   (<=  
    (-  (rect-y rect) 25) 
    y
    (+  (rect-y rect) 25))))


;;TESTS:
(begin-for-test
  (check-equal? (in-rect? (make-rect 100 100 2 2 130 125 false false (list )) 130 125) #true
                "mouse inside rectangle standing at edge")
  (check-equal? (in-rect? (make-rect 100 100 2 2 100 100 false false (list )) 100 100) #true
                "mouse inside rectangle standing the center of rectangle ")
  (check-equal? (in-rect? (make-rect 100 100 2 2 140 120 false false (list )) 140 120) #false
                "mouse outside of rectangle on x direction which more than 30 pixels")
  (check-equal? (in-rect? (make-rect 100 100 2 2 100 126 false false (list )) 100 126) #false
                "mouse outside of rectangle on y direction which exceed only 1 pixels"))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |world-after-tick| ok
;; world-after-tick: WorldState -> WorldState

;; PURPOSE: desing what does the world should like after one tick 
;; GIVEN: a world w
;; RETURNS: the world that should follow w after a tick
;; EXAMPLES: see tests below

;; STRATEGY: Use template for World on w

(define (world-after-tick w)
  (if (world-paused? w)
      w
      (make-world
       (movecheck (world-rects w) )
       (world-paused? w))))


;; Definition for testing.
;; (define a (make-rect 30 30 0 0 0 0 false false (list )))
;; (define b (make-rect 50 50 0 0 0 0 false false (list ))) 
;; (define c (make-rect 50 50 0 0 0 0 true false (list )))
(define d (make-rect 50 50 -2 4 0 0 false false (list ))) 


;;TESTS:
(begin-for-test 
  (check-equal? (world-after-tick (make-world (list a b) true))
                (make-world (cons
                  (make-rect 30 30 0 0 0 0 #false #false '())
                  (cons (make-rect 50 50 0 0 0 0 #false #false '()) '())) #true)
                "If the world is paused, then world-after-tick, it is still paused, so unchanged. ")

  (check-equal? (world-after-tick (make-world (list d) false))
                (make-world (cons (make-rect 48 54 -2 4 0 0 #false #false '()) '()) #false)
                "when world is unpaused, after tick, the rectangle's new center should be (48, 54). ")
  (check-equal? (world-after-tick (make-world (list d) true))
                (make-world (cons (make-rect 50 50 -2 4 0 0 #false #false '()) '()) #true)
                "Because the whole world is paused, so nothing should be changed. "))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                
;; apply-to-each : (X->Y) ListOfX  -> ListOfY

;; PURPOSE: Help function for world-after-tick, for checking and make sure every rectangles
;;         in world-rects list has moved. 
;; GIVEN: a list lox and a function f
;; RETURNS: the list obtained by applying f to each element of lox
;; EXAMPLES:
;; (apply-to-each (list 10 20 30) add1) = (list 11 21 31)
;; (apply-to-each (list 1 2 3) sqr) = (list 1 4 9)

;; STRATEGY: Use template for ListOfX to lox

(define (apply-to-each fn lox)
  (cond
    [(empty? lox) empty]
    [else (cons (fn (first lox))
                (apply-to-each fn (rest lox)))]))



;; movecheck : List -> List

;; PURPOSE: Help function for world-after-tick, for checking and make sure every rectangles
;;          in world-rects list has moved after order. 
;; GIVEN: a list of rectangles 
;; RETURNS: the list obtained by applying f to each element of lst
;; STRATEGY: Use HOF apply-to-each to lst
(define (movecheck lst)
 (apply-to-each move-rect lst))


;; Definition for testing. 
;; (define a (make-rect 30 30 0 0 0 0 false false (list )))
;; (define b (make-rect 50 50 0 0 0 0 false false (list ))) 
;; (define c (make-rect 50 50 0 0 0 0 true false (list )))
;; (define d (make-rect 50 50 -2 4 0 0 false false (list ))) 

;;TESTS:

(begin-for-test
  (check-equal? (movecheck (list a b c d) )
                (cons (make-rect 30 30 0 0 0 0 #false #false '()) 
             
                 (cons
                  (make-rect 50 50 0 0 0 0 #false #false '())
                  (cons
                   (make-rect 50 50 0 0 0 0 #true #false '())
                    (cons
                 (make-rect 48 54 -2 4 0 0 #false #false '()) '())  )))
                "rectangle a, b, c and d should stay selected or unselected.
                 Because d's speed is not zero, thus after movecheck, it's center should
                 be (48,54). Every rectangle have been checked from list1 and given into
                 list2 and returned. Successful letting each rectangle in world-rects list
                 used world-after-tick function" ))


;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; move-rect: Rectangle -> Rectangle

;; PURPOSE: Help function for world-after-tick. Rectangle will move toward different directions,
;; thus this function is seperate different situation when moving and different moving situation
;; should use different boundary limit value. But if the rectangle is selected, it will not move. 
;; GIVEN: a rectangle
;; RETURNS: the rectangle at a new posiiton which after one tick move 
;; EXAMPLES: see tests below 
;; STRATEGY: Use template for Rect on rec  

(define  (move-rect rec)
  (if (rect-selected? rec) rec 
      (make-rect
       (cond
         [(positive? (rect-vx rec))  (bounce-check-pos-x rec) ]
         [(negative? (rect-vx rec))  (bounce-check-neg-x rec) ]
         [(zero? (rect-vx rec))  (rect-x rec) ]
         )
       (cond
         [(positive? (rect-vy rec))  (bounce-check-pos-y rec) ]
         [(negative? (rect-vy rec))  (bounce-check-neg-y rec) ]
         [(zero? (rect-vy rec))  (rect-y rec) ]
         
         )
       (cond
         [(positive? (rect-vx rec))  (bounce-check-pos-x-sp rec) ]
         [(negative? (rect-vx rec))  (bounce-check-neg-x-sp rec) ]
         [(zero? (rect-vx rec))  (rect-vx rec) ]
         
         )

       (cond
         [(positive? (rect-vy rec))  (bounce-check-pos-y-sp rec) ]
         [(negative? (rect-vy rec))  (bounce-check-neg-y-sp rec) ]
         [(zero? (rect-vy rec))  (rect-vy rec) ]
         
         )
       
       0 0  (rect-selected? rec) (rect-pen? rec)
       (if(rect-pen? rec)
          (append (list (make-dot (rect-x rec) (rect-y rec))) (rect-dot rec) )
          (rect-dot rec)))))


;; Definition for testing. 
;; (define a (make-rect 30 30 0 0 0 0 false false (list )))
;; (define b (make-rect 50 50 0 0 0 0 false false (list ))) 
;; (define c (make-rect 50 50 0 0 0 0 true false (list )))
;; (define d (make-rect 50 50 -2 4 0 0 false false (list )))


;; TESTS:
(begin-for-test
  (check-equal? (move-rect d) (make-rect 48 54 -2 4 0 0 #false #false '())
                "rectangle d should move from (50,50) to (48, 54) after this function and unselected.")
  (check-equal? (move-rect c) (make-rect 50 50 0 0 0 0 #true #false '())
                "rectangle c is selected, then return itself without any change. ")
  (check-equal? (move-rect a) (make-rect 30 30 0 0 0 0 #false #false '())
                "because rectangle a's velocity is (0, 0), so it's center stay at (30,30)"))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; bounce-check-pos-x: Rectangle -> PosInt

;; PURPOSE: Help function for move-check.  Prevent rectangle moves outside of east wall of canvas. 
;; GIVEN: a rectangle
;; RETURNS: x coordinate of the center of the rectangle
;; EXAMPLE: See test below. 
;; STRATEGY: Use template for Rect on rect  
(define (bounce-check-pos-x rect)
  (if (> (+ (rect-x rect) (rect-vx rect)) 370)
      370
      (+ (rect-x rect) (rect-vx rect)) ))

;; Definition for testing.
(define f (make-rect 300 100 60 10 0 0 false false (list )))
(define g (make-rect 300 100 80 10 0 0 false false (list )))

 
;;TEST:
(begin-for-test
  (check-equal? (bounce-check-pos-x f) 360 
                "rectangle still not go outside of canvas, and it's x-coordinate of the
                  center of the rectangle should be 360")
  (check-equal? (bounce-check-pos-x g) 370
                "rectanlge has gone outside of canvas, thus it's should touch the wall,
                 and it's x-coordinate of the center of the rectangle should be 370"))

;;~~~~~~~~~~~~~ 
;; bounce-check-neg-x: Rectangle -> PosInt

;; PURPOSE: Help function for move-check.  Prevent rectangle moves outside of west wall of canvas. 
;; GIVEN: a rectangle
;; RETURNS: x coordinate of the center of the rectangle
;; EXAMPLE: See test below. 
;; STRATEGY: Use template for Rect on rect  
(define (bounce-check-neg-x rect)
  (if (< (+ (rect-x rect) (rect-vx rect)) 30)
      30
      (+ (rect-x rect) (rect-vx rect)) ))

;; Definition for testing.
(define h (make-rect 40 100 -9 0 0 0 false false (list )))
(define i (make-rect 40 100 -11 0 0 0 false false (list )))


;;TEST:
(begin-for-test
  (check-equal? (bounce-check-neg-x h) 31 
                "rectangle still not go outside of canvas, and it's x-coordinate of the
                  center of the rectangle should be 31")
  (check-equal? (bounce-check-neg-x i) 30
                "rectanlge has gone outside of canvas, thus it's should touch the wall,
                 and it's x-coordinate of the center of the rectangle should be 30"))

;;~~~~~~~~~~~~~
;; bounce-check-pos-y: Rectangle -> PosInt

;; PURPOSE: Help function for move-check.  Prevent rectangle moves outside of south wall of canvas. 
;; GIVEN: a rectangle
;; RETURNS: y coordinate of the center of the rectangle
;; EXAMPLE: See test below. 
;; STRATEGY: Use template for Rect on rect 
(define (bounce-check-pos-y rect)
  (if (> (+ (rect-y rect) (rect-vy rect)) 275)
      275
      (+ (rect-y rect) (rect-vy rect)) ))


;; Definition for testing.  
(define j (make-rect 100 200 0 50 0 0 false false (list )))
(define k (make-rect 100 200 0 80 0 0 false false (list )))


;;TEST:
(begin-for-test
  (check-equal? (bounce-check-pos-y j) 250
                "rectangle still not go outside of canvas, and it's y-coordinate of the
                  center of the rectangle should be 250")
  (check-equal? (bounce-check-pos-y k) 275
                "rectanlge has gone outside of canvas, thus it's should touch the wall,
                 and it's y-coordinate of the center of the rectangle should be 275"))

;;~~~~~~~~~~~~~~~ 
;; bounce-check-neg-y: Rectangle -> PosInt

;; PURPOSE: Help function for move-check.  Prevent rectangle moves outside of north wall of canvas. 
;; GIVEN: a rectangle
;; RETURNS: y coordinate of the center of the rectangle
;; EXAMPLE: See test below. 
;; STRATEGY: Use template for Rect on rect 
(define (bounce-check-neg-y rect)
  (if (< (+ (rect-y rect) (rect-vy rect)) 25)
      25
      (+ (rect-y rect) (rect-vy rect)) ))

;; Definition for testing.
(define l (make-rect 100 40 0 -10 0 0 false false (list )))
(define m (make-rect 100 40 0 -30 0 0 false false (list )))


;;TEST:
(begin-for-test
  (check-equal? (bounce-check-neg-y l) 30
                "rectangle still not go outside of canvas, and it's y-coordinate of the
                  center of the rectangle should be 30")
  (check-equal? (bounce-check-neg-y m) 25
                "rectanlge has gone outside of canvas, thus it's should touch the wall,
                 and it's y-coordinate of the center of the rectangle should be 25"))

;;~~~~~~~~~~~~~~~~
;; bounce-check-pos-x-sp: Rectangle -> PosInt

;; PURPOSE: Help function for move-check.  If the rectangle touched east wall, then rebound.
;; GIVEN: a rectangle
;; RETURNS: velocity of rectangle at x direction. 
;; EXAMPLE: See test below. 
;; STRATEGY: Use template for Rect on rect 

(define (bounce-check-pos-x-sp rect)
  (if (> (+ (rect-x rect) (rect-vx rect)) 370)
      (- 0 (rect-vx rect))
      (rect-vx rect)  ))


;; Definition for testing. 
(define o (make-rect 370 100 10 0 0 0 false false (list )))


;;TEST:
(begin-for-test
  (check-equal? (bounce-check-pos-x-sp o) -10 
                "when the rectangle touchec the wall, it's x velocity's direction should change. "))

;;~~~~~~~~~~~~~~~~~~~~
;; bounce-check-neg-x-sp: Rectangle -> PosInt

;; PURPOSE: Help function for move-check.  If the rectangle touched west wall, then rebound.
;; GIVEN: a rectangle
;; RETURNS: velocity of rectangle at x direction. 
;; EXAMPLE: See test below. 
;; STRATEGY: Use template for Rect on rect 
(define (bounce-check-neg-x-sp rect)
  (if (< (+ (rect-x rect) (rect-vx rect)) 30)
      (-  0 (rect-vx rect))
      (rect-vx rect)    ))

;; Definition for testing.
(define p (make-rect 30 100 -10 0 0 0 false false (list )))


;;TEST:
(begin-for-test 
  (check-equal? (bounce-check-neg-x-sp p) 10 
                "when the rectangle touchec the wall, it's x velocity's direction should change. "))

;;~~~~~~~~~~~~~~~~~~~~
;; bounce-check-pos-y-sp: Rectangle -> PosInt

;; PURPOSE: Help function for move-check.  If the rectangle touched south wall, then rebound.
;; GIVEN: a rectangle
;; RETURNS: velocity of rectangle at y direction. 
;; EXAMPLE: See test below. 
;; STRATEGY: Use template for Rect on rect 
(define (bounce-check-pos-y-sp rect)
  (if (> (+ (rect-y rect) (rect-vy rect)) 275)
      (- 0 (rect-vy rect))
      (rect-vy rect)  ))

;; Definition for testing.
(define q (make-rect 100 200 0 80 0 0 false false (list ) ))

;;TEST:
(begin-for-test 
  (check-equal? (bounce-check-pos-y-sp q) -80
                "when the rectangle touchec the wall, it's y velocity's direction should change. "))

;;~~~~~~~~~~~~~~~~~~~~
;; bounce-check-neg-y-sp: Rectangle -> PosInt

;; PURPOSE: Help function for move-check.  If the rectangle touched north wall, then rebound.
;; GIVEN: a rectangle
;; RETURNS: velocity of rectangle at y direction. 
;; EXAMPLE: See test below. 
;; STRATEGY: Use template for Rect on rect 
(define (bounce-check-neg-y-sp rect)
  (if (< (+ (rect-y rect) (rect-vy rect)) 25) 
      (- 0 (rect-vy rect))
      (rect-vy rect) ))
                                        
;; Definition for testing.
(define r (make-rect 100 25 0 -40 0 0 false false (list ))) 


;;TEST:
(begin-for-test 
  (check-equal? (bounce-check-neg-y-sp r) 40
                "when the rectangle touchec the wall, it's y velocity's direction should change. "))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |new-rectangle| ok
;; new-rectangle : NonNegInt NonNegInt Int Int -> Rectangle

;; PURPOSE: For create a new rectangle which is unselected. 
;; GIVEN: Non-negative integers x and y, and 2 integers vx and vy
;; RETURNS: an unselected rectangle centered at (x,y), which will move with
;; velocity (vx, vy).
;; EXAMPLES:
;; (new-rectangle 100 100 2 -4) = (make-rect 100 100 2 -4 0 0 #false #false #false '())
;; (new-rectangle 200 200 10 -6) = (make-rect 200 200 10 -6 0 0 #false #false #false '())

;; STRATEGY: Structure rect auto has make-rect function

(define (new-rectangle x y vx vy) 
  (make-rect x y vx vy 0 0 false false (list )) )


;;TESTS:
(begin-for-test
  (check-equal? (new-rectangle 100 100 2 -4)(make-rect 100 100 2 -4 0 0 #false #false '())
                "unselected rectangle centered at (100,100), velocity is (2,-4), mouse does not appear")
  (check-equal? (new-rectangle 200 200 10 -6) (make-rect 200 200 10 -6 0 0 #false #false '())
                "unselected rectangle centered at 200,200), velocity is (10,-6), mouse does not appear"))


  