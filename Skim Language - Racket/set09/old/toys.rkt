#lang racket

(check-location "09" "toys.rkt")

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")
(require 2htdp/universe)   
(require 2htdp/image)

(provide make-world)
(provide run)
(provide make-square-toy)
(provide make-throbber)
(provide make-clock)
(provide make-football)
(provide PlaygroundState<%>)
(provide Toy<%>)

;=========================================================================================
;                                      CONSTANTS
;=========================================================================================
;; boundary of scene
(define EMPTY-CANVAS (empty-scene 500 600))
;; boundry of the canvas
(define CANVAS-MIN-X 20)
(define CANVAS-MAX-X 480)

;; constant for zero
(define ZERO 0)

;; constants for various key events
(define NEW-SQUARE-EVENT "s")
(define NEW-THROBBER-EVENT "t")
(define NEW-CLOCK-EVENT "w")
(define NEW-FOOTBALL-EVENT "f")

;; constans for various mouse events
(define MOUSE-BUTTON-UP "button-up")
(define MOUSE-BUTTON-DOWN "button-down")
(define MOUSE-DRAG "drag")

;; constants for square
(define SQUARE-INITIAL-X 250)
(define SQUARE-INITIAL-Y 300)
(define SQUARE-INITIAL-V 0)

;; constants for target
(define INITIAL-TARGET-X 250)
(define INITIAL-TARGET-Y 300)

;; constants for football
(define FOOTBALL-IMG (bitmap "football.png"))
(define FOOTBALL-WD-HALF (/ (image-width FOOTBALL-IMG) 2))
(define FOOTBALL-HT-HALF (/ (image-height FOOTBALL-IMG) 2))
;; constant of image for displaying the square toy
(define SQUARE-IMG (square 40 "outline" "blue"))
 ;; image constant for displaying the target
(define TARGET-IMG (circle 10 "outline" "blue"))
;; constant for throbber minimum radius
(define THROBBER-MIN-RADIUS 5)
;; constant for throbber maximum radius
(define THROBBER-MAX-RADIUS 20)

;=========================================================================================
;                                      DATA DEFINITIONS
;=========================================================================================
;; Time represents the time between two successive ticks

;; Scene is the image displaying the playground

;=========================================================================================
;                                      INTERFACES
;=========================================================================================
;; A WorldState represents a world
(define WorldState<%>
  (interface () 
    
    ;; after-tick : -> WorldState
    ;; RETURNS: the WorldState after tick
    after-tick
    
    ;; after-mouse-event : MouseEvent -> WorldState
    ;; GIVEN: a MosueEvent
    ;; RETURNS: the WorldState after mouse event
    after-mouse-event
    
    ;; after-key-event : KeyEvent -> WorldState
    ;; GIVEN: a KeyEvent
    ;; RETURNS: the WorldState after key event
    after-key-event
    
    ;; to-scene : -> Scene
    ;; RETURNS: the scene displaying the WorldState on canvas
    to-scene
    ))

;; Every object that lives in the playground must implement the Widget<%>
;; interface.
(define Widget<%>
  (interface () 
    
    ;; after-tick : -> Widget
    ;; RETURNS: the Widget after tick
    after-tick
    
    ;; after-button-down : -> Widget
    ;; RETURNS: the Widget after mouse event
    ;; WHERE: mouse event is button down
    after-button-down
    
    ;; after-button-up : -> Widget
    ;; RETURNS: the Widget after mouse event
    ;; WHERE: mouse event is button up
    after-button-up
    
    ;; after-drag : -> Widget
    ;; RETURNS: the Widget after mouse event
    ;; WHERE: mouse event is drag
    after-drag
    
    ;; after-key-event : KeyEvent -> Widget
    ;; GIVEN: a KeyEvent
    ;; RETURNS: the Widget after key event
    after-key-event
    
    ;; add-to-scene : -> Scene
    ;; RETURNS: the scene showing widget on canvas
    add-to-scene
    ))

;; A PlayGroundState represents the playground which contains a fix target and of various
;; key events new toy's are created in the playground at the center of the target
(define PlaygroundState<%>
  ;; Include all methods of WorldState<%>
  (interface (WorldState<%>)
    
    ;; target-x : -> Integer
    ;; RETURN: the x coordinates of the target
    target-x
    
    ;; target-y : -> Integer
    ;; RETURN: the y coordinates of the target
    target-y
    
    ;; target-selected? : -> Boolean
    ;; RETURNS: true iff the target is selected
    target-selected?
    
    ;; get-toys : -> ListOfToy<%>
    ;; RETURNS: list of toys present in the PlaygroundState<%>
    get-toys
    ))

;; A Toy represents the toy present in the playground
;; It can square, throbber, clock or footaball
(define Toy<%>
  ;; Include all methods of Widget<%>
  (interface (Widget<%>) 
    
    ;; toy-x : -> Integer
    ;; RETURNS: the x position of the center of the toy
    toy-x
    
    ;; toy-y : -> Integer
    ;; RETURNS: the y position of the center of the toy
    toy-y
    
    ;; toy-data : -> Int
    ;; RETURNS: some data related to the toy.  The interpretation of
    ;; this data depends on the class of the toy.
    ;; WHERE:
    ;; 1. for a square, it is the velocity of the square (rightward is
    ;;    positive)
    ;; 2. for a throbber, it is the current radius of the throbber
    ;; 3. for the clock, it is the current value of the clock
    ;; 4. for a football, it is the current size of the football (in
    ;;    arbitrary units; bigger is more)
    toy-data
    ))

;=========================================================================================
;                                      CLASSES
;=========================================================================================
;; A PlaygroundState is a
;; (new PlaygroundState% [objs ListOfToys][tx NonNegInt][ty NonNegInt][t PosNum][v PosInt]
;;                       [selected? Boolean][saved-mx Integer][saved-my Integer])
;; A PlayGroundState represents the play ground for toy's
;; The playground has target present when it is created and it can have 0 to N number of
;; toy's
(define PlaygroundState%
  (class* object% (PlaygroundState<%>)

    ;; ListOfWidget
    (init-field objs)
    ;; Time
    (init-field t)
     ;; speed of square
    (init-field v)
    ;; co-ordinates of the target
    (init-field tx ty)
    ;; selected? indicates whether the target is selected or not
    (init-field selected?)
     ;; if the target is selected, the position of the last button-down event inside the
     ;; target, relative to the target's center. Else any value.
    (init-field saved-mx saved-my)

    ;; Local constant for radius of the target
    (field [R 10])                        

    ;; calling super class
    (super-new)
    
    ;; target-x : -> Integer
    ;; RETURN: the x coordinates of the target
    (define/public (target-x)
      tx)
    
    ;; target-y : -> Integer
    ;; RETURN: the y coordinates of the target
    (define/public (target-y)
      ty)
    
    ;; target-selected? : -> Boolean
    ;; RETURNS: true iff the target is selected
    (define/public (target-selected?)
      selected?)
    
    ;; get-toys : -> ListOfToy<%>
    ;; RETURNS: list of toys present in the PlaygroundState<%>
    (define/public (get-toys)
      objs)
    
    ;; after-tick : -> PlaygroundState<%>
    ;; RETURNS: a play ground state after the tick
    ;; STRATEGY: Use HOF map on the Widget's in this World
    (define/public (after-tick)
      (make-playground
       (map
        ;; Toy<%> -> Toy<%>
        (lambda (obj) (send obj after-tick))
        objs)
       (+ 1 t)
       v tx ty selected? saved-mx saved-my))
    
    ;; to-scene : -> Scene
    ;; RETURNS: a play ground state as a scene
    ;; STRATEGY: Use HOF foldr on the Widget's in this World
    (define/public (to-scene)
      (foldr
       ;; Toy<%> -> Scene
       (lambda (obj scene)
         (send obj add-to-scene scene))
       (place-target)
       objs))
    
    ;; after-key-event : KeyEvent -> PlaygroundState<%>
    ;; GIVEN: a key event
    ;; RETURNS: a play ground state after the key event
    ;; STRATEGY: Cases on kev
    ;; WHERE:
    ;; 1. "s" will create a new square on the play ground
    ;; 2. "t" will create a new throbber circle on the play ground
    ;; 3. "w" will create a new clock on the play ground
    ;; 4. "f" will create a new football on the play ground
    ;; other keystrokes are passed on to the objects in the play ground.
    (define/public (after-key-event kev)
      (cond
        [(key=? kev NEW-SQUARE-EVENT)
         (make-playground
          (cons
           (new-square tx ty v #f 0 0) objs)
          t v tx ty selected? saved-mx saved-my)]
        [(key=? kev NEW-THROBBER-EVENT)
         (make-playground
          (cons
           (new-throbber tx ty v 5 #f 0 0) objs) 
          t v tx ty selected? saved-mx saved-my)]
        [(key=? kev NEW-CLOCK-EVENT)
         (make-playground
          (cons
           (new-clock tx ty 0 #f 0 0) objs)
          t v tx ty selected? saved-mx saved-my)]
        [(key=? kev NEW-FOOTBALL-EVENT)
         (make-playground
          (cons
           (new-football tx ty v FOOTBALL-WD-HALF FOOTBALL-HT-HALF #f 0 0) objs)
          t v tx ty selected? saved-mx saved-my)]
        [else
         this]))
    
    ;; world-after-mouse-event : Nat Nat MouseEvent -> PlaygroundState<%>
    ;; GIVEN: x and y coordinates of mouse event and mouse event
    ;; STRATGY: Cases on mev
    (define/public (after-mouse-event mx my mev)
      (cond
        [(mouse=? mev MOUSE-BUTTON-DOWN)
         (world-after-button-down mx my)]
        [(mouse=? mev MOUSE-DRAG)
         (world-after-drag mx my)]
        [(mouse=? mev MOUSE-BUTTON-UP)
         (world-after-button-up mx my)]
        [else this]))
    
    ;; Local functions
    
    ;; world-after-button-down : Nat Nat -> PlaygroundState<%>
    ;; GIVEN: x and y coordinates of mouse event
    ;; WHERE: mouse event is button down
    ;; RETURNS: the play ground state after button down event
    ;; STRATEGY: using HOF map on Widget's in this World
    (define (world-after-button-down mx my)
      (if (in-target? mx my)
          (make-playground
           (button-down-fn mx my) t v tx ty #t (- mx tx) (- my ty))
          (make-playground
           (button-down-fn mx my) t v tx ty #f 0 0)))
    
    ;; world-after-button-up : Nat Nat -> PlaygroundState<%>
    ;; GIVEN: x and y coordinates of mouse event
    ;; WHERE: mouse event is button up
    ;; RETURNS: the play ground state after button up event
    ;; STRATEGY: using HOF map on Widget's in this World
    (define (world-after-button-up mx my)
      (make-playground
       (map
        ;; Toy<%> -> Toy<%>
        ;; GIVEN: a Toy<%>
        ;; RETURNS: toy after button up event
        (lambda (obj) (send obj after-button-up mx my))
        objs)
       t v tx ty #f 0 0)) 
    
    ;; world-after-drag : Nat Nat -> PlaygroundState<%>
    ;; GIVEN: x and y coordinates of mouse event
    ;; WHERE: mouse event is drag
    ;; RETURNS: the play ground state after drag event
    ;; STRATEGY: using HOF map to send after-tick to each of the toy in playgound
    (define (world-after-drag mx my)
      (if selected?
          (make-playground
           (drag-fn mx my) t v (- mx saved-mx) (- my saved-my) #t saved-mx saved-my)
          (make-playground
           (drag-fn mx my) t v tx ty #f 0 0)))
    
    ;; button-down-fn : PosNum PosNum -> LOWidget 
    ;; GIVEN:the position (mx, my) of the mouse 
    ;; RETURN: the list of widgets after mouse event
    ;; WHERES: the mouse event is mouse button down 
    ;; STRATEGY: using HOF map to send after-button-down to each of the toy in playgound
    (define (button-down-fn mx my)
      (map
       ;; Toy<%> -> Toy<%>
       ;; GIVEN: a Toy<%>
       ;; RETURNS: toy after button down event
       (lambda (obj) (send obj after-button-down mx my))
       objs))
    
    ;; drag-fn : PosNum PosNum -> LOWidget
    ;; GIVEN: the position (mx, my) of the mouse
    ;; RETURN: the list of widgets after mouse event
    ;; WHERE : the mouse event is drag
    ;; STRATEGY: using HOF map to send after-drag to each of the toy in playgound
    (define (drag-fn mx my)
      (map
       ;; Toy<%> -> Toy<%>
       ;; GIVEN: a Toy<%>
       ;; RETURNS: toy after drag
       (lambda (obj) (send obj after-drag mx my))
       objs))
    
    ;; place-target : -> Scene
    ;; RETURNS: the scene with the target placed on it
    ;; STRATEGY: combine using simpler function
    (define (place-target)
      (place-image TARGET-IMG tx ty EMPTY-CANVAS))
    
    ;; in-target? : PosNum PosNum -> Boolean
    ;; GIVEN: the posiiton of the center of mouse
    ;; RETURN: true iff the mouse inside of the target
    ;; STRATEGY: combine using simpler function
    (define (in-target? mx my)
      (<= (+ (sqr (- tx mx)) (sqr (- ty my)))
          (sqr R)))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Square is a
;; (new Square% [x NonNegInt][y NonNegInt][v PosInt][selected? Boolean]
;;              [saved-mx Integer][saved-my Integer])
;; A Square represents the square shaped toy in the playground which is moving at the
;; given speed horizontally
(define Square%
  (class* object% (Toy<%>)
    
    ;; the x and y position is the center of the square and v is the velocity of the
    ;; square toy
    (init-field x y v)
    ;; selected? for indicating whether the square is selected or not
    (init-field selected?)
    ;; saved mouse coordinates after button down event inside the square toy
    (init-field saved-mx saved-my)
   
    ;; Local constant for representing square toy's half width
    (field [SQUARE-HALF 20])
    
    ;; toy-x : -> Integer
    ;; RETURNS: the x position of the center of the square
    (define/public (toy-x) x)
    
    ;; toy-y : -> Integer
    ;; RETURNS: the y position of the center of the square
    (define/public (toy-y) y)
    
    ;; toy-data : -> Int
    ;; RETURNS:the velocity of the square (rightward is positive).
    (define/public (toy-data) v)
    
    (super-new)
    
    ;; after-tick : -> Square%
    ;; RETURNS: the square after tick
    ;; DETAILS: the square toy will move horizontally at the velocity v until perfect
    ;; bounce, on perfect bounce velocity will get reversed and toy will travel opposite
    ;; direction
    (define/public (after-tick)
      (new Square%
           [x (get-x x v)][y y][v (get-v v x)]
           [selected? selected?][saved-mx saved-mx][saved-my saved-my]))
    
    ;; after-button-down : PosNum PosNum -> Square%
    ;; GIVEN: the position of the mouse 
    ;; RETURNS: the same square after mouse event 
    ;; WHERE: mouse event is button down
    ;; STRATEGY: using cases on whether the mouse cursor is inside the square
    (define/public (after-button-down mx my)
      (if (in-square? x y mx my)
          (new Square%
               [x x][y y][v v]
               [selected? #t][saved-mx (- mx x)][saved-my (- my y)])
          this))
    
    ;; after-button-up : PosNum PosNum -> Square%
    ;; GIVEN: the position of the mouse 
    ;; RETURNS: the square after mouse event
    ;; WHERE: mouse event is button up
    (define/public (after-button-up mx my)
      (new Square%
           [x x][y y][v v]
           [selected? #f][saved-mx 0][saved-my 0]))
    
    ;; after-drag :PosNum PosNum -> Square%
    ;; GIVEN: the position of the mouse 
    ;; RETURNS: the square after mouse event
    ;; WHERE: mouse event is drag
    ;; STRATEGY: using cases on whether the square is selected
    ;; WHERE: if selected then return selected square otherwise return this
    ;; square as it is
    (define/public (after-drag mx my)
      (if selected?
          (new Square%
               [x (- mx saved-mx)][y (- my saved-my)][v v]
               [selected? #t][saved-mx saved-mx][saved-my saved-my])
          this))
    
    ;; after-key-event : -> Square%
    ;; RETURNS: this square as it is
    (define/public (after-key-event)
      this)
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: the scene 
    ;; RETURNS: a new scene adding new square on canvas
    ;; STARTEGY: combine using simpler function
    (define/public (add-to-scene scene)
      (place-image SQUARE-IMG x y scene))

    ;;;;;;;;;;; For Testing ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; -> Boolean
    (define/public (for-test:selected?) selected?)
    
    ;; Local Functions
    
    ;; get-x : Integer Integer-> Integer
    ;; GIVEN: the x position of the square and the velocity v of the square
    ;; RETURNS: the new x coordinate of the square after adding velocity
    ;; STRATEGY: using cases on (+ x v)
    (define (get-x x v)
      (cond
        [(<= (+ x v) CANVAS-MIN-X) CANVAS-MIN-X]
        [(>= (+ x v) CANVAS-MAX-X) CANVAS-MAX-X]
        [else (+ x v)]))
    
    ;; get-v : Integer Integer -> Integer
    ;; GIVEN: the velocity of the square and the x position of the s
    ;; RETURNS: the new velocity
    ;; WHERE: velocity will be reversed at perfect bounce
    ;; STRATEGY: using cases on x
    (define (get-v v x)
      (cond
        [(or (<= (+ v x) CANVAS-MIN-X) (>= (+ v x) CANVAS-MAX-X)) (- ZERO v)]
        [else v]))
    
    ;; in-square? : PosNum PosNum PosNum PosNum -> Boolean
    ;; GIVEN: the position of the center of square and the position of the mouse
    ;; RETURN: true iff when the mouse inside of the square
    ;; STRATEGY: Combine using simpler functions
    (define (in-square? x y mx my)
      (and (<= mx (+ x SQUARE-HALF)) (>= mx (- x SQUARE-HALF))
           (<= my (+ y SQUARE-HALF)) (>= my (- y SQUARE-HALF))))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Throbber is a
;; (new Throbber% [x NonNegInt][y NonNegInt][v PosInt][r PosInt]
;;                [selected? Boolean][saved-mx Integer][saved-my Integer])
;; A Throbber represents the throbber shaped toy in the playground which is growing and
;; shrinking at the given speed
(define Throbber%
  (class* object% (Toy<%>)
    
    ;; the x and y position of the center of the Throbber, v is the velocity
    ;; of the Throbber and r is the radius of the throbber
    (init-field x y v r)
    ;; selected? indicates whether the throbber is selected or not
    (init-field selected?)
    ;; for saving mouse co-ordinates on mouse button down event
    (init-field saved-mx saved-my)
    
    ;; toy-x : -> Integer
    ;; RETURNS: the x position of the center of the throbber
    (define/public (toy-x) x)
    
    ;; toy-y : -> Integer
    ;; RETURNS: the y position of the center of the throbber
    (define/public (toy-y) y)
    
    ;; toy-data : -> Int
    ;; RETURNS: the radius of the throbber
    (define/public (toy-data) r)
    
    (super-new)
    
    ;; after-tick : -> Throbber%
    ;; RETURNS: the Throbber after tick
    ;; DETAILS: the throbber will grow at the given speed v at each tick until it reaches
    ;; to the maximum radius after that it will again shrink to minimum radius. This
    ;; continues until the end of the playgroud.
    (define/public (after-tick)
      (new Throbber%
           [x x][y y][v (get-v v r)]
           [r (get-r r v)][selected? selected?]
           [saved-mx saved-mx][saved-my saved-my]))
    
    ;; after-button-down : NonNegNum NonNegNum -> Throbber%
    ;; GIVEN: the position of mouse in x and y direction  
    ;; WHERE : mouse event is button down
    ;; RETURNS: the same Throbber after button down
    ;; STRATEGY: using cases on whether the mouse cursor is inside the throbber
    (define/public (after-button-down mx my)
      (if (in-throbber? (get-r r v) x y mx my)
          (new Throbber%
               [x x][y y][v (get-v v r)]
               [r (get-r r v)][selected? #t]
               [saved-mx (- mx x)][saved-my (- my y)])
          this))
    
    ;; after-button-up : NonNegNum NonNegNum -> Throbber%
    ;; GIVEN: the position of mouse in x and y direction
    ;; RETURNS: the Throbber after button up 
    ;; WHERE: mouse event is button up 
    ;; STRATEGY: combine using simpler function
    (define/public (after-button-up mx my)
      (new Throbber%
           [x x][y y][v (get-v v r)]
           [r (get-r r v)][selected? #f]
           [saved-mx 0][saved-my 0]))
    
    ;; after-drag : NonNegNum NonNegNum -> Throbber%
    ;; GIVEN: the position of mouse in x and y direction
    ;; WHERE: mouse event is drag
    ;; RETURNS: the Throbber after dragging 
    ;; WHERE: if throbber is selected then return selected throbber otherwise
    ;; returns throbber as it is
    ;; STRATEGY: using cases on whether the throbber is selected
    (define/public (after-drag mx my)
      (if selected?
          (new Throbber%
               [x (- mx saved-mx)][y (- my saved-my)][v v]
               [r r][selected? #t]
               [saved-mx saved-mx][saved-my saved-my])
          this))
    
    ;; after-key-event : -> Throbber%
    ;; RETURNS: the throbber as it is
    (define/public (after-key-event)
      this)
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: a scene 
    ;; RETURNS: a new scene adding new Throbber on canvas
    ;; STRATEGY: combine using simpler functions
    (define/public (add-to-scene scene)
      (place-image (circle r "solid" "green") x y scene))

    ;;;;;;;;;;; For Testing ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; -> Boolean
    (define/public (for-test:selected?) selected?)
    
    ;; Local Functions
    
    ;; get-r : PosInt PosInt -> PosInt
    ;; GIVEN: the radius r and the velocity v of the throbber
    ;; RETURNS: new radius which is the sum of radius and velocity 
    ;; WHERE : the new radius less and eual than 20 and greater and equal than 5
    ;; STRATEGY: case on r and v 
    (define (get-r r v)
      (cond
        [(<= (+ r v) THROBBER-MIN-RADIUS) THROBBER-MIN-RADIUS]
        [(>= (+ r v) THROBBER-MAX-RADIUS) THROBBER-MAX-RADIUS]
        [else (+ r v)]))
    
    ;; get-v : PosInt PosInt -> Integer
    ;; GIVEN: the velocity v and the redius r of the throbber 
    ;; RETURNS: the new velocity
    ;; WHERE : the velocity is reversed when minimum (5) or maximum (20) radius is reached
    ;; STRATEGY: using cases on r
    (define (get-v v r)
      (cond
        [(or (<= (+ r v) THROBBER-MIN-RADIUS) (>= (+ r v) THROBBER-MAX-RADIUS))
         (- ZERO v)]
        [else v]))
    
    ;; in-throbber? : PosInt PosNum PosNum NonNegNum NonNegNum -> Boolean
    ;; GIVEN: the radius of the throbber, the position of the center of throbber
    ;;         (x, y) and the position of the mouse (mx, my)
    ;; RETURN:  true iff the mouse inside of the throbber 
    ;; STRATEGY: Combine using simpler function 
    (define (in-throbber? r x y mx my)
      (<= (+ (sqr (- x mx)) (sqr (- y my)))
          (sqr r)))
    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Clock is a
;; (new Clock% [x NonNegInt][y NonNegInt][t PosInt][selected? Boolean]
;;             [saved-mx Integer][saved-my Integer])
;; A Clock represents the clock shaped toy in the playground which is showing the number
;; of ticks
(define Clock%
  (class* object% (Toy<%>)
    
    ;; the x and y position of the center of the clock, t is the clock value
    (init-field x y t)
    ;; selected? represents whether the clock is selected for dragging or not
    (init-field selected?)
    ;; for saving coordinates of the mouse after 
    (init-field saved-mx saved-my)

    ;; Local constant for clock half width
    (field [CLOCK-HALF-W 30])
    ;; Local constant for clock half height
    (field [CLOCK-HALF-H 20])
    
    ;; toy-x : -> Integer
    ;; RETURNS: the x position of the center of the clock
    (define/public (toy-x) x)
    
    ;; toy-y : -> Integer
    ;; RETURNS: the y position of the center of the clock
    (define/public (toy-y) y)
    
    ;; toy-data : -> Int
    ;; RETURNS: the clock value
    (define/public (toy-data) t)
    
    (super-new)
    
    ;; after-tick : -> Clock%
    ;; RETURNS: the clock after tick
    ;; DETAILS: after each tick the clock value gets incremented by one
    (define/public (after-tick)
      (new Clock%
           [x x][y y][t (+ t 1)][selected? selected?]
           [saved-mx saved-mx][saved-my saved-my]))
    
    ;; after-button-down : NonNegNum NonNegNum -> Clock%
    ;; GIVEN: x and y coordinates of the mouse
    ;; WHERE: mouse event is button down
    ;; RETURNS: the clock after button down event
    ;; WHERE: if mouse cursor is inside the clock, returns selected clock
    ;; otherwise the same clock
    ;; STARTEGY: cases in whether the mouse cursor is inside the clock
    (define/public (after-button-down mx my)
      (if (in-clock? x y mx my)
          (new Clock%
               [x x][y y][t (+ t 1)][selected? #t]
               [saved-mx (- mx x)][saved-my (- my y)])
          this))
    
    ;; after-button-up : NonNegNum NonNegNum -> Clock%
    ;; GIVEN: x and y coordinates of the mouse
    ;; WHERE: mouse event is button up
    ;; GIVEN: x and y coordinates of the mouse
    ;; RETURNS: the unselected clock
    (define/public (after-button-up mx my)
      (new Clock% [x x][y y][t (+ t 1)][selected? #f][saved-mx 0][saved-my 0]))
    
    ;; after-drag : NonNegNum NonNegNum -> Clock%
    ;; GIVEN: x and y coordinates of the mouse
    ;; WHERE: mouse event is drag
    ;; RETURNS: the clock after mouse event
    ;; WHERE: if clock is selected then return selected clock otherwise returns same clock
    ;; STARTEGY: cases on whether the clock is selected
    (define/public (after-drag mx my)
      (if selected?
          (new Clock%
               [x (- mx saved-mx)][y (- my saved-my)][t t]
               [selected? #t][saved-mx saved-mx][saved-my saved-my])
          this))
    
    ;; after-key-event : -> Clock%
    ;; RETURNS: the same clock
    (define/public (after-key-event)
      this)
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: the scene 
    ;; RETURNS: a new scene adding new clock on canvas
    (define/public (add-to-scene scene)
      (place-image (text (number->string t) 20 "black") x y
                   (place-image (rectangle 60 40 "outline" "black") x y scene)))

    ;;;;;;;;;;; For Testing ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; -> Boolean
    (define/public (for-test:selected?) selected?)
    
    ;; Local Functions
    
    ;; in-clock? : PosNum PosNum NonNegNum NonNegNum -> Boolean
    ;; GIVEN: the position (x, y) of the center of clock
    ;;         the position (mx, my) of the mouse
    ;; RETURN: true iff the mouse inside of the clock
    (define (in-clock? x y mx my)
      (and (<= mx (+ x CLOCK-HALF-W)) (>= mx (- x CLOCK-HALF-W))
           (<= my (+ y CLOCK-HALF-H)) (>= my (- y CLOCK-HALF-H))))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Football is a
;; (new Football% [x NonNegInt][y NonNegInt][v PosInt][s PosReal][wd PosReal][ht PosReal]
;;                [selected? Boolean][saved-mx Integer][saved-my Integer])
;; A Football represents the footbal shaped toy in the playground which will shrink at the
;; rate of given speed for every tick until it disappears
(define Football%
  (class* object% (Toy<%>)
    
    ;; the x and y position of the center of the football
    ;; v is the rate of the football shrinking
    ;; s is the scale of the football
    ;; wd is the width of the football
    ;; ht is the hight of the football 
    (init-field x y v s wd ht)
    ;; selected? depicts whether the football is selected for dragging
    (init-field selected?)
    ;; for saving mouse coordinates after button down
    (init-field saved-mx saved-my)
    
    ;; toy-x : -> Integer
    ;; RETURNS: the x position of the center of the football
    (define/public (toy-x) x)
    
    ;; toy-y : -> Integer
    ;; RETURNS: the y position of the center of the football
    (define/public (toy-y) y)
    
    ;; toy-data : -> Int
    ;; RETURNS: 
    (define/public (toy-data) s)
    
    (super-new)
    
    ;; after-tick : -> Football%
    ;; RETURNS: the football after tick
    ;; DETAILS: the football will shrink at every tick
    (define/public (after-tick)
      (new Football%
           [x x][y y][v v][ht (get-new-ht)][wd (get-new-wd)][s (get-scale v)]
           [selected? selected?][saved-mx saved-mx][saved-my saved-my]))
    
    ;; after-button-down : PosNum PosNum -> Football%
    ;; GIVEN: the position of the mouse (mx, my)
    ;; WHERE : mouse event is button down
    ;; RETURNS: the selected football if mouse is inside the football otherwise return
    ;; same football
    ;; STRATEGY: cases on whether the mouse is inside the football or not
    (define/public (after-button-down mx my)
      (if (in-football? x y mx my)
          (new Football%
               [x x][y y][v v][ht (get-new-ht)][wd (get-new-wd)][s (get-scale v)]
               [selected? #t][saved-mx (- mx x)][saved-my (- my y)])
          this))
    
    ;; after-button-up : PosNum PosNum -> Football%
    ;; GIVEN: the position of the mouse (mx, my)
    ;; WHERE: mouse event is button up
    ;; RETURNS: the unselected football
    ;; STRATEGY: combine using simpler function
    (define/public (after-button-up mx my)
      (new Football%
           [x x][y y][v v][ht (get-new-ht)][wd (get-new-wd)][s (get-scale v)]
           [selected? #f][saved-mx 0][saved-my 0]))
    
    ;; after-drag : PosNum PosNum -> Football%
    ;; GIVEN: the position of the mouse (mx, my)
    ;; WHERE : mouse event is drag
    ;; RETURNS: the football after drag event 
    ;; STRATEGY: cases on whether the mouse is inside the football
    (define/public (after-drag mx my)
      (if selected?
          (new Football%
               [x (- mx saved-mx)][y (- my saved-my)][v v][wd wd][ht ht]
               [s s][selected? #t][saved-mx saved-mx][saved-my saved-my])
          this))
    
    ;; after-key-event : -> Football%
    ;; RETURNS: this football
    (define/public (after-key-event)
      this)
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a new scene adding new football on canvas
    (define/public (add-to-scene scene)
      (place-image (scale s FOOTBALL-IMG) x y scene))

    ;;;;;;;;;;; For Testing ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; -> Boolean
    (define/public (for-test:selected?) selected?)
    
    ;; Local Functions
    
    ;; get-new-ht : -> PosNum
    ;; RETURNS: the new height of the football after shrinking
    ;; STRATEGY: use simpler function 
    (define (get-new-ht)
      (image-height (scale s FOOTBALL-IMG)))
    
    ;; get-new-wd : -> PosNum
    ;; RETURNS: the new width of the football after shrinking
    ;; STRATEGY: use simpler function 
    (define (get-new-wd)
      (image-width (scale s FOOTBALL-IMG)))
    
    ;; get-scale : PosInt -> NonNegNumber 
    ;; GIVEN: the spped v of at which football image will scale down
    ;; RETURN: return the new scale
    ;; STRATEGY: combine using simpler function 
    (define (get-scale v)
      v)
    
    ;; in-football? : PosNum PosNum NonNegNum NonNegNum -> Boolean 
    ;; GIVEN: the position of the center of the football (x,y)
    ;;         the position of the mouse (mx, my)
    ;; RETURN: true iff the mouse inside the football image
    ;; STRATEGY: combine using simpler function 
    (define (in-football? x y mx my)
      (and (<= mx (+ x wd)) (>= mx (- x wd))
           (<= my (+ y ht)) (>= my (- y ht))))
    ))

;=========================================================================================
;                                      FUNCTIONS
;=========================================================================================

;; make-world : PosInt -> PlaygroundState<%>
;; GIVEN: a time
;; RETURNS: a world with a target, but no toys, and in which any square toys created
;;          in the future will travel at the given speed (in pixels/tick).
;; STRATEGY: call more general function
(define (make-world t)
  (new PlaygroundState%
       [objs empty] [t t][v 0][tx INITIAL-TARGET-X]
       [ty INITIAL-TARGET-Y][selected? #f][saved-mx 0][saved-my 0]))

;; new-throbber : PosNum PosNum PosInt PosInt Boolean PosNum PosNum -> throbber%
;; GIVEN: the position (x, y) of the center of the throbber 
;;         the speed v of the throbber shrinking and expansion
;;         the radius of the throbber 
;;         true or false indicates whether the throbber is selected
;;         the position (mx, my) of the mouse
;; STRATEGY: call more general function
(define (new-throbber x y v r selected? mx my)
  (new Throbber% [x x][y y][v v][r r][selected? selected?][saved-mx mx][saved-my my]))

;; new-clock : PosNum PosNum PosInt Boolean PosNum PosNum -> throbber%
;; GIVEN: the position (x, y) of the center of the clock 
;;         the time of the clock 
;;         true or false indicates whether the clock is selected
;;         the position (mx, my) of the mouse
;; RETURNS: a new clock in the play ground
;; STRATEGY: call more general function
(define (new-clock x y t selected? mx my)
  (new Clock% [x x][y y][t t][selected? selected?][saved-mx mx][saved-my my]))

;; new-throbber : PosNum PosNum PosInt PosNum PosNum Boolean PosNum PosNum -> throbber%
;; GIVEN: the position (x, y) of the center of the football
;;         the speed at which football shrinks
;;         the width wd and the hight ht of the football image 
;;         true of false indicates whether the football is selected
;;         the position (mx, my) of the mouse
;; RETURNS: a new football in the play ground
;; STRATEGY: call more general function
(define (new-football x y v wd ht selected? mx my)
  (new Football% [x x][y y][v v][wd wd][ht ht][s 1]
       [selected? selected?][saved-mx mx][saved-my my]))

;; make-square-toy : PosInt PosInt PosInt -> Toy<%>
;; GIVEN: an x and a y position, and a speed 
;; RETURNS: an object representing a square toy at the given position,
;; travelling right at the given speed
;; STRATEGY: call more general function
(define (make-square-toy x y v)
  (new Square% [x x] [y y] [v v][selected? #f][saved-mx 0][saved-my 0]))

;; make-throbber : PosInt PosInt -> Toy<%>
;; GIVEN: an x and a y position
;; RETURNS: an object representing a throbber at the given position.
(define (make-throbber x y)
  (new-throbber x y 0 10 #f 0 0))

;; TESTS:
(define throbber-unselected (make-throbber 250 250)) 
(define throbber-selected (new-throbber 250 250 1 10 #t 10 10))
(define throbber-max-radius (new-throbber 250 250 1 THROBBER-MAX-RADIUS #f 10 10))
(define throbber-min-radius (new-throbber 250 250 -1 THROBBER-MIN-RADIUS #f 10 10))

(begin-for-test
  (check-equal? (send throbber-unselected toy-x) 250)
  (check-equal? (send throbber-unselected toy-y) 250)
  (check-equal? (send throbber-unselected toy-data) 10)
  (check-equal? (send
                 (send throbber-unselected after-tick)
                 toy-x) 250)
  (check-equal? (send
                 (send throbber-unselected after-tick)
                 toy-y) 250)
  (check-equal? (send
                 (send (send throbber-unselected after-tick) after-tick)
                 toy-data) 10)
  (check-equal? (send
                 (send (send throbber-max-radius after-tick) after-tick)
                 toy-data) 19)
  (check-equal? (send
                 (send (send throbber-min-radius after-tick) after-tick)
                 toy-data) 6)
  (check-equal? (send
                 (send throbber-unselected after-key-event)
                 toy-data) 10)
  (check-true (send
                 (send throbber-unselected after-button-down 250 250)
                 for-test:selected?))
  (check-false (send
                 (send throbber-unselected after-button-down 10 10)
                 for-test:selected?))
  (check-false (send
                 (send throbber-unselected after-button-up 250 250)
                 for-test:selected?))
  (check-true (send
                 (send throbber-selected after-drag 250 250)
                 for-test:selected?))
  (check-equal? (send
                 (send throbber-selected after-drag 250 250)
                 toy-x) 240)
  (check-equal? (send
                 (send throbber-selected after-drag 250 250)
                 toy-y) 240)
  (check-equal? (send
                 (send throbber-selected after-drag 250 250)
                 toy-data) 10)
  (check-equal? (send
                 (send throbber-unselected after-drag 250 250)
                 toy-x) 250)
  (check-equal?
   (send throbber-unselected add-to-scene EMPTY-CANVAS)
   (place-image
    (circle 10 "solid" "green") 250 250 EMPTY-CANVAS)))

;; make-clock : PosInt PostInt -> Toy<%>
;; GIVEN: an x and a y position
;; RETURNS: an object representing a clock at the given position.
;; EXAMPLES: see tests below
(define (make-clock x y)
  (new-clock x y 0 #f 0 0))

;; TESTS:
(define clock-unselected (make-clock 250 250))
(define clock-selected
  (new-clock 250 250 0 #t 10 10))

(begin-for-test
  (check-equal? (send clock-unselected toy-x) 250)
  (check-equal? (send clock-unselected toy-y) 250)
  (check-equal? (send clock-unselected toy-data) 0)
  (check-equal? (send
                 (send clock-unselected after-tick)
                 toy-x) 250)
  (check-equal? (send
                 (send clock-unselected after-tick)
                 toy-y) 250)
  (check-equal? (send
                 (send (send clock-unselected after-tick) after-tick)
                 toy-data) 2)
  (check-equal? (send
                 (send clock-unselected after-key-event)
                 toy-data) 0)
  (check-true (send
                 (send clock-unselected after-button-down 250 250)
                 for-test:selected?))
  (check-false (send
                 (send clock-unselected after-button-down 10 10)
                 for-test:selected?))
  (check-false (send
                 (send clock-selected after-button-up 250 250)
                 for-test:selected?))
  (check-true (send
                 (send clock-selected after-drag 250 250)
                 for-test:selected?))
  (check-equal? (send
                 (send clock-selected after-drag 250 250)
                 toy-x) 240)
  (check-equal? (send
                 (send clock-selected after-drag 250 250)
                 toy-y) 240)
  (check-equal? (send
                 (send clock-selected after-drag 250 250)
                 toy-data) 0)
  (check-equal? (send
                 (send clock-unselected after-drag 250 250)
                 toy-x) 250)
  (check-equal?
   (send clock-unselected add-to-scene EMPTY-CANVAS) 
   (place-image (text (number->string 0) 20 "black") 250 250
                (place-image (rectangle 60 40 "outline" "black") 250 250 EMPTY-CANVAS))))

;; make-football : PosInt PostInt -> Toy<%>
;; GIVEN: an x and a y position
;; RETURNS: an object representing a football at the given position.
;; EXAMPLES: see tests below
(define (make-football x y)
  (new-football x y 1 FOOTBALL-WD-HALF FOOTBALL-HT-HALF #f 0 0))

;; TESTS:
(define football-unselected (make-football 250 250))
(define football-selected
  (new-football 250 250 1 FOOTBALL-WD-HALF FOOTBALL-HT-HALF #t 10 10))

(begin-for-test
  (check-equal? (send football-unselected toy-x) 250)
  (check-equal? (send football-unselected toy-y) 250)
  (check-equal? (send football-unselected toy-data) 1)
  (check-equal? (send
                 (send football-unselected after-tick)
                 toy-x) 250)
  (check-equal? (send
                 (send football-unselected after-tick)
                 toy-y) 250)
  #;(check-equal? (send
                 (send (send football-unselected after-tick) after-tick)
                 toy-data) (/ 1 2))
  (check-equal? (send
                 (send football-unselected after-key-event)
                 toy-data) 1)
  (check-true (send
                 (send football-unselected after-button-down 250 250)
                 for-test:selected?))
  (check-false (send
                 (send football-unselected after-button-down 10 10)
                 for-test:selected?))
  (check-false (send
                 (send football-selected after-button-up 250 250)
                 for-test:selected?))
  (check-true (send
                 (send football-selected after-drag 250 250)
                 for-test:selected?))
  (check-equal? (send
                 (send football-selected after-drag 250 250)
                 toy-x) 240)
  (check-equal? (send
                 (send football-selected after-drag 250 250)
                 toy-y) 240)
  (check-equal? (send
                 (send football-selected after-drag 250 250)
                 toy-data) 1)
  (check-equal? (send
                 (send football-unselected after-drag 250 250)
                 toy-x) 250)
  (check-equal?
   (send football-unselected add-to-scene EMPTY-CANVAS)
   (place-image (scale 1 FOOTBALL-IMG) 250 250 EMPTY-CANVAS)))

;; new-square : PosNum PosNum PosInt Boolean PosNum PosNum -> Square%
;; GIVEN: the position (x, y) of the center of the square 
;;         the velocity v of the square
;;         true or false indicates whether the square is selected
;;         the position (mx, my) of the mouse 
;; RETURNS: a new square in the play ground
;; EXAMPLES: see tests below
(define (new-square x y v selected? mx my)
  (new Square% [x x][y y][v v][selected? selected?][saved-mx mx][saved-my my]))

;; TESTS:
(define square-unselected (make-square-toy 250 250 1))
(define square-at-right-boundry (make-square-toy 480 250 1))
(define square-at-left-boundry (make-square-toy 20 250 -1))

(begin-for-test
  (check-equal? (send square-unselected toy-x) 250)
  (check-equal? (send square-unselected toy-y) 250)
  (check-equal? (send square-unselected toy-data) 1)
  (check-equal? (send
                 (send square-unselected after-tick)
                 toy-x) 251)
  (check-equal? (send
                 (send square-at-right-boundry after-tick)
                 toy-x) 480)
  (check-equal? (send
                 (send square-at-left-boundry after-tick)
                 toy-x) 20)
  (check-equal? (send
                 (send square-at-left-boundry after-key-event)
                 toy-x) 20))

;; A PlaygroundState is a (make-playground ListOfWidget Time)

;; make-playground : LisOfToy<%> Time -> World
;; GIVEN: a list of toy's and time
;; RETURNS: a world with the give list of toys
;; EXAMPLES: see tests below
(define (make-playground objs t v tx ty selected? mx my)
  (new PlaygroundState% [objs objs][t t][v v][tx tx][ty ty]
       [selected? selected?][saved-mx mx][saved-my my]))

;; TESTS:
(define objs (list (new-square 250 250 1 #f 0 0)))
(define after-tick-objs (list (new-square 251 250 1 #f 0 0)))
(define selected-objs (list (new-square 250 250 1 #t 250 250)))
(define playground-with-square
  (make-playground objs 1 1 250 250 #f 0 0))
(define playground-with-square-selected
  (make-playground selected-objs 1 1 250 250 #t 250 250))
(define playground-with-square-after-tick
  (make-playground after-tick-objs 1 1 250 250 #f 0 0))
(define empty-playground
  (make-playground '() 1 1 250 250 #f 0 0))
(define empty-playground-1
  (make-world 1))

(begin-for-test
  (check-equal?
   (send playground-with-square target-x) 250)
  (check-equal?
   (send playground-with-square target-y) 250)
  (check-false
   (send playground-with-square target-selected?))
  (check set-equal?
         (send playground-with-square get-toys) objs)
  (check-equal?
   (send
    (first
     (send (send playground-with-square after-tick) get-toys)) toy-x) 251)
  (check-equal?
   (send
    (first
     (send
      (send playground-with-square after-tick) get-toys)) toy-y) 250)
  (check-equal?
   (send
    (first
     (send
      (send playground-with-square after-tick) get-toys)) toy-data) 1)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "s") get-toys)) toy-x) 250)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "s") get-toys)) toy-y) 250)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "s") get-toys)) toy-data) 1)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "t") get-toys)) toy-x) 250)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "t") get-toys)) toy-y) 250)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "t") get-toys)) toy-data) 5)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "w") get-toys)) toy-x) 250)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "w") get-toys)) toy-y) 250)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground-1 after-key-event "w") get-toys)) toy-y) 300)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "w") get-toys)) toy-data) 0)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "f") get-toys)) toy-x) 250)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "f") get-toys)) toy-y) 250)
  (check-equal?
   (send
    (first
     (send
      (send empty-playground after-key-event "f") get-toys)) toy-data) 1)
  (check-equal?
   (send empty-playground after-key-event "n") empty-playground)
  (check-true
   (send
    (send playground-with-square after-mouse-event 250 250 MOUSE-BUTTON-DOWN)
    target-selected?))
  (check-true
   (send
    (first
     (send
      (send playground-with-square after-mouse-event 250 250 MOUSE-BUTTON-DOWN)
      get-toys)) for-test:selected?) #t)
  (check-false
   (send
    (first
     (send
      (send playground-with-square after-mouse-event 400 400 MOUSE-BUTTON-DOWN)
      get-toys)) for-test:selected?))
  (check-false
   (send
    (first
     (send
      (send playground-with-square after-mouse-event 250 250 MOUSE-BUTTON-UP)
      get-toys)) for-test:selected?))
  (check-false
   (send
    (first
     (send
      (send playground-with-square after-mouse-event 250 250 MOUSE-BUTTON-UP)
      get-toys)) for-test:selected?))
  (check-true
   (send
    (first
     (send
      (send playground-with-square-selected after-mouse-event 250 250 MOUSE-DRAG)
      get-toys)) for-test:selected?))
  (check-false
   (send
    (first
     (send
      (send playground-with-square after-mouse-event 250 250 MOUSE-DRAG)
      get-toys)) for-test:selected?))
  (check-equal?
   (send
    (first
     (send
      (send playground-with-square after-mouse-event 250 250 "enter")
      get-toys)) for-test:selected?) #f)
  (check-equal?
   (send playground-with-square to-scene)
   (place-image SQUARE-IMG 250 250
                (place-image TARGET-IMG 250 250 EMPTY-CANVAS))))

;; run : PosNum PosInt -> PlaygroundState<%> 
;; GIVEN: a frame rate (in seconds/tick) and a square-speed (in pixels/tick),
;;        creates and runs a world in which square toys travel at the given
;;        speed.  Returns the final state of the world.
;; RETURNS: the final state of the play ground

;; STRATEGY: combine using simpler functions
(define (run rate v)
  (big-bang
   (make-playground empty rate v INITIAL-TARGET-X INITIAL-TARGET-Y #f 0 0)
   (on-tick
    (lambda (w) (send w after-tick))
    rate)
   (on-draw
    (lambda (w) (send w to-scene)))
   (on-key
    (lambda (w kev)
      (send w after-key-event kev)))
   (on-mouse
    (lambda (w mx my mev)
      (send w after-mouse-event mx my mev)))))