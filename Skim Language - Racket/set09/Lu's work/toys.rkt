#lang racket

;(check-location "10" "toys.rkt")

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")
(require 2htdp/universe)   
(require 2htdp/image)

(require "WidgetWorks.rkt")

;=========================================================================================
;                                      CONSTANTS
;=========================================================================================
;; boundry of scene
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

;; Image of displaying the toy square
(define SQUARE-IMG (square 40 "outline" "blue"))

;; Image of displaying the target
(define TARGET-IMG (circle 10 "outline" "blue"))

;; constant for throbber minimum radius
(define THROBBER-MIN-RADIUS 5)

;; constant for throbber maximum radius
(define THROBBER-MAX-RADIUS 20)

;=========================================================================================
;                                      INTERFACES
;=========================================================================================

(define PlaygroundState<%>
  ;; Include all methods of WorldState<%>
  (interface (SWidget<%>)
    
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
;; It can be square, throbber, clock or footaball
(define Toy<%>
  ;; Include all methods of Widget<%>
  (interface (SWidget<%>) 
    
    ;; toy-x : -> Integer
    ;; RETURNS: the x coordinates of the center of the toy
    toy-x
    
    ;; toy-y : -> Integer
    ;; RETURNS: the y coordinates of the center of the toy
    toy-y
    
    ;; toy-data : -> Integer
    ;; RETURNS: certain data related to the toy.  The interpretation of
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
;; (new PlaygroundState% [sobjs ListOfToys][t PosNum][v PosInt][tx NonNegNum]
;;                       [ty NonNegNum][selected? Boolean][saved-mx NonNegNumber]
;;                       [saved-my NonNegNumber])
;; A PlayGroundState represents the play ground for toy's
;; The playground has target present when it is created and it can have 0 to N number of
;; toy's
(define PlaygroundState%
  (class* object% (PlaygroundState<%>)
    
    
    ;(define/public (after-drag mx my) exit)
    ;(define/public (after-button-up mx my)  exit)
    ;(define/public (after-button-down mx my)  exit)
    ;(define/public (add-to-scene scene) exit)
    
    ;; ListOfToys
    (init-field sobjs)
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
    
    ;; target-x : -> NonNegNum
    ;; RETURN: the x coordinates of the target
    (define/public (target-x)
      tx)
    
    ;; target-y : -> NonNegNum
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
      sobjs)
    
    ;; after-tick : -> Void
    ;; RETURNS: a play ground state after the tick
    ;; STRATEGY: Use HOF map on the Toies in the World
    (define/public (after-tick)
      (begin
        (set! t (+ 1 t))
        (process-widgets
         (lambda (obj) (send obj after-tick)))))
    
    ;; add-to-scene : -> Scene
    ;; RETURNS: a play ground state as a scene
    ;; STRATEGY: Use HOF foldr on the Toies in this World
    (define/public (add-to-scene scene)
      (foldr
       ;; Toy<%> -> Scene
       (lambda (obj scene)
         (send obj add-to-scene scene))
       (place-target scene) 
       sobjs))
    
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN: a key event
    ;; EFFECT: a new play ground state after the key event
    ;; STRATEGY: Cases on kev
    ;; WHERE:
    ;; 1. "s" will create a new square at target 
    ;; 2. "t" will create a new throbber circle at target 
    ;; 3. "w" will create a new clock at target 
    ;; 4. "f" will create a new football at target 
    ;; other keystrokes are passed on to the objects in the play ground.
    (define/public (after-key-event kev)
      (cond
        [(key=? kev NEW-SQUARE-EVENT)
         (begin
           (set! sobjs (cons (make-square-toy tx ty v) sobjs)))]
        [(key=? kev NEW-THROBBER-EVENT)
         (begin
           (set! sobjs (cons (new-throbber tx ty v 5 #f 0 0) sobjs)))]
        [(key=? kev NEW-CLOCK-EVENT)
         (begin
           (set! sobjs (cons (new-clock tx ty 0 #f 0 0) sobjs)))]
        [(key=? kev NEW-FOOTBALL-EVENT)
         (begin
           (set! sobjs
                 (cons
                  (new-football tx ty v FOOTBALL-WD-HALF FOOTBALL-HT-HALF #f 0 0)
                  sobjs)))]))
    
    ;; process-widgets : (SWidget -> Void) -> Void
    ;; GIVEN:    a function to be applied on SWidgets present in play ground
    ;; EFFECT:   the list of SWidgets after applying the given function
    ;; STRATEGY: using HOF for-each on sobjs
    (define/public (process-widgets fn)
      (begin
        (for-each fn sobjs)))
    
    ;; after-button-down :  NonNegNum NonNegNum -> Void
    ;; GIVEN: x and y coordinates of the mouse
    ;; WHERE: mouse event is button down
    ;; EFFECT: the play ground state after button down event
    ;; STRATEGY: using HOF map on Widget's in this World
    (define/public (after-button-down mx my)
      (begin
        (if (in-target? mx my)
            (begin
              (set! selected? #t)
              (set! saved-mx (- mx tx))
              (set! saved-my (- my ty)))
            42)
        (process-widgets
         (lambda (obj) (send obj after-button-down mx my))))) 
      
      ;; after-button-up : NonNegNum NonNegNum -> PlaygroundState<%>
      ;; GIVEN: x and y coordinates of mouse
      ;; WHERE: mouse event is button up
      ;; RETURNS: the play ground state after button up event
      ;; STRATEGY: using HOF map on Widget's in this World
      (define/public (after-button-up mx my)
        (begin
          (set! selected? #f)
          (set! saved-mx 0)
          (set! saved-my 0)
          (process-widgets
           (lambda (obj) (send obj after-button-up mx my))))) 
      
      ;; after-drag : NonNegNum NonNegNum -> PlaygroundState<%>
      ;; GIVEN: x and y coordinates of mouse
      ;; WHERE: mouse event is drag
      ;; RETURNS: the play ground state after drag event
      ;; STRATEGY: using cases whether the target is selected or not 
      (define/public (after-drag mx my)
        (begin
          (if selected?
              (begin
                (set! selected? #t)
                (set! tx (- mx saved-mx))
                (set! ty (- my saved-my)))
              42)
          (process-widgets
           (lambda (obj) (send obj after-drag mx my)))))
    
    ;; place-target : Scene -> Scene
    ;; RETURNS: the scene with the target placed on it
    ;; STRATEGY: combine using simpler function
    (define (place-target scene)
      (place-image TARGET-IMG tx ty scene))
    
    ;; in-target? : NonNegNum NonNegNum -> Boolean
    ;; GIVEN: x and y coordinates of mouse
    ;; RETURN: true iff the mouse inside of the target
    ;; STRATEGY: combine using simpler functions
    (define (in-target? mx my)
      (<= (+ (sqr (- tx mx)) (sqr (- ty my)))
          (sqr R)))
    
    ;;
    (define/public (for-test:sobjs)
      sobjs)
    ))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Square is a
;; (new Square% [x NonNegNum][y NonNegNum][v PosInt][selected? Boolean]
;;              [saved-mx NonNegNum][saved-my NonNegNum])
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
    
    ;; toy-x : -> NonNegNum
    ;; RETURNS: the x coordinates of the center of the square
    (define/public (toy-x) x)
    
    ;; toy-y : -> NonNegNum
    ;; RETURNS: the y coordinates of the center of the square
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
      (local
        ((define new-speed (get-v v x))
         (define new-x (get-x x v)))
        (begin
          (set! x new-x)
          (set! v new-speed))))
    
    ;; after-button-down : NonNegNum NonNegNum -> Square%
    ;; GIVEN: the x and y coordinates of the mouse 
    ;; RETURNS: the same square after mouse event 
    ;; WHERE: mouse event is button down
    ;; STRATEGY: using cases on whether the mouse cursor is inside the square
    (define/public (after-button-down mx my)
      (if (in-square? mx my)
          (begin
            (set! selected? #t)
            (set! saved-mx (- mx x))
            (set! saved-my (- my y)))
          this))
    
    ;; after-button-up : NonNegNum NonNegNum -> Square%
    ;; GIVEN: the x and y coordinates of the mouse 
    ;; RETURNS: the square after mouse event
    ;; WHERE: mouse event is button up
    (define/public (after-button-up mx my)
      (begin
        (set! selected? #f)
        (set! saved-mx 0)
        (set! saved-my 0)))
    
    ;; after-drag NonNegNum NonNegNum -> Square%
    ;; GIVEN:  the x and y coordinates of the mouse 
    ;; RETURNS: the square after mouse event
    ;; WHERE: mouse event is drag
    ;; STRATEGY: using cases on whether the square is selected
    ;; WHERE: if selected then return selected square otherwise return this
    ;; square as it is
    (define/public (after-drag mx my)
      (if selected?
          (begin
            (set! x (- mx saved-mx))
            (set! y (- my saved-my)))
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
    
    ;; get-x : NonNegNum NonNegNum -> NonNegNum
    ;; GIVEN: the x coordinate and the velocity v of the square
    ;; RETURNS: the new x coordinate of the square after adding velocity v
    ;; STRATEGY: using cases on (+ x v)
    (define (get-x x v)
      (cond
        [(<= (+ x v) CANVAS-MIN-X) CANVAS-MIN-X]
        [(>= (+ x v) CANVAS-MAX-X) CANVAS-MAX-X]
        [else (+ x v)]))
    
    ;; get-v : NonNegNum NonNegNum -> NonNegNum
    ;; GIVEN: the velocity v and the x coordinate of the square 
    ;; RETURNS: the new velocity of the square 
    ;; WHERE: velocity will be reversed at perfect bounce
    ;; STRATEGY: using cases on (v + x)
    (define (get-v v x)
      (cond
        [(or (<= (+ v x) CANVAS-MIN-X) (>= (+ v x) CANVAS-MAX-X)) (- ZERO v)]
        [else v]))
    
    ;; in-square? : NonNegNum NonNegNum NonNegNum NonNegNum -> Boolean
    ;; GIVEN: the x and y coordinates of the center of the square (x, y)
    ;;        and x and y coordinates of the mouse (mx, my)
    ;; RETURN: true iff when the mouse inside of the square
    ;; STRATEGY: Combine using simpler functions
    (define (in-square? mx my)
      (and (<= mx (+ x SQUARE-HALF)) (>= mx (- x SQUARE-HALF))
           (<= my (+ y SQUARE-HALF)) (>= my (- y SQUARE-HALF))))
    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Throbber is a
;; (new Throbber% [x NonNegNum][y NonNegNum][v PosInt][r PosInt]
;;                [selected? Boolean][saved-mx NonNegNum][saved-my NonNegNum])
;; A Throbber represents the throbber shaped toy in the playground which is growing and
;; shrinking at the given speed
(define Throbber%
  (class* object% (Toy<%>)
    
    ;; the x and y coordinates of the center of the Throbber,
    ;; v is the velocity of the Throbber and r is the radius of the Throbber
    (init-field x y v r)
    ;; selected? indicates whether the throbber is selected or not
    (init-field selected?)
    ;; for saving mouse co-ordinates on mouse button down event
    (init-field saved-mx saved-my)
    
    ;; toy-x : -> NonNegNum
    ;; RETURNS: the x coordinate of the center of the throbber
    (define/public (toy-x) x)
    
    ;; toy-y : -> NonNegNum
    ;; RETURNS: the y coordinate of the center of the throbber
    (define/public (toy-y) y)
    
    ;; toy-data : -> Int
    ;; RETURNS: the radius of the throbber
    (define/public (toy-data) r)
    
    (super-new)
    
    ;; after-tick : -> Throbber%
    ;; RETURNS: the Throbber after tick
    ;; DETAILS: the throbber will grow at the given speed v at each tick until it reaches
    ;; to the maximum radius after that it will again shrink to minimum radius. This
    ;; continues until the end of the playground.
    (define/public (after-tick)
      ;;(new Throbber%
      ;;     [x x][y y][v (get-v v r)]
      ;;     [r (get-r r v)][selected? selected?]
      ;;     [saved-mx saved-mx][saved-my saved-my]))
      (begin
        (set! v (get-v v r))
        (set! r (get-r r v))
        this))
    
    ;; after-button-down : NonNegNum NonNegNum -> Throbber%
    ;; GIVEN: the x and y coordinates of mouse
    ;; WHERE : mouse event is button down
    ;; RETURNS: the same Throbber after button down
    ;; STRATEGY: using cases on whether the mouse cursor is inside the throbber
    (define/public (after-button-down mx my)
      (if (in-throbber? (get-r r v) x y mx my)
          (begin
            (set! v (get-v v r))
            (set! r (get-r r v))
            (set! selected? true)
            (set! saved-mx (- mx x))
            (set! saved-my (- my y)))
          42))
    
    ;; after-button-up : NonNegNum NonNegNum -> Throbber%
    ;; GIVEN: the x and y coordinates of mouse
    ;; WHERE: mouse event is button up 
    ;; RETURNS: the Throbber after button up    
    ;; STRATEGY: combine using simpler function
    (define/public (after-button-up mx my)
      (begin
        (set! v (get-v v r))
        (set! r (get-r r v))
        (set! selected? false)
        (set! saved-mx 0)
        (set! saved-my 0)
        this))
    
    
    ;; after-drag : NonNegNum NonNegNum -> Throbber%
    ;; GIVEN:the x and y coordinates of mouse
    ;; WHERE: mouse event is drag
    ;; RETURNS: the Throbber after dragging 
    ;; WHERE: if throbber is selected then return selected throbber otherwise
    ;; returns throbber as it is
    ;; STRATEGY: using cases on whether the throbber is selected
    (define/public (after-drag mx my)
      (if selected?
          (begin
            (set! x (- mx saved-mx))
            (set! y (- my saved-my)))
          42))
    
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
    ;; WHERE : the new radius less or eual than 20 but greater or equal than 5
    ;; STRATEGY: using case on r and v 
    (define (get-r r v)
      (cond
        [(<= (+ r v) THROBBER-MIN-RADIUS) THROBBER-MIN-RADIUS]
        [(>= (+ r v) THROBBER-MAX-RADIUS) THROBBER-MAX-RADIUS]
        [else (+ r v)]))
    
    ;; get-v : PosInt PosInt -> PosInt
    ;; GIVEN: the velocity v and the radius r of the throbber 
    ;; RETURNS: the new velocity
    ;; WHERE : the moving direction (velocity) is reversed when minimum (5)
    ;;         or maximum (20) radius is reached
    ;; STRATEGY: using cases on v and r
    (define (get-v v r)
      (cond
        [(or (<= (+ r v) THROBBER-MIN-RADIUS) (>= (+ r v) THROBBER-MAX-RADIUS))
         (- ZERO v)]
        [else v]))
    
    ;; in-throbber? : PosInt NonNegNum NonNegNum NonNegNum NonNegNum -> Boolean
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
;; (new Clock% [x NonNegNum][y NonNegNum][t PosInt][selected? Boolean]
;;             [saved-mx NonNegNum][saved-my NonNegNum])
;; A Clock represents the clock shaped toy in the playground which is showing the number
;; of ticks
(define Clock%
  (class* object% (Toy<%>)
    
    ;; the x and y coordinates of the center of the clock, t is the clock value
    (init-field x y t)
    ;; selected? represents whether the clock is selected or not 
    (init-field selected?)
    ;; for saving x and y coordinates of the clock after mouse button down 
    (init-field saved-mx saved-my)
    
    ;; Local constant for clock half width
    (field [CLOCK-HALF-W 30])
    ;; Local constant for clock half height
    (field [CLOCK-HALF-H 20])
    
    ;; toy-x : -> NonNegNum
    ;; RETURNS: the x coordinate of the center of the clock
    (define/public (toy-x) x)
    
    ;; toy-y : -> NonNegNum
    ;; RETURNS: the y coordinate of the center of the clock
    (define/public (toy-y) y)
    
    ;; toy-data : -> Int
    ;; RETURNS: the value in clock
    (define/public (toy-data) t)
    
    (super-new)
    
    ;; after-tick : -> Clock%
    ;; RETURNS: the clock after tick
    ;; DETAILS: after each tick the clock value gets incremented by one
    (define/public (after-tick)
      ;; (new Clock%
      ;;     [x x][y y][t (+ t 1)][selected? selected?]
      ;;     [saved-mx saved-mx][saved-my saved-my]))
      (begin
        (set! t (+ t 1))
        this))
    
    ;; after-button-down : NonNegNum NonNegNum -> Clock%
    ;; GIVEN: x and y coordinates of the mouse
    ;; WHERE: mouse event is button down
    ;; RETURNS: the clock after button down event
    ;; WHERE: if mouse cursor is inside the clock, returns selected clock
    ;; otherwise the same clock
    ;; STARTEGY: cases in whether the mouse cursor is inside the clock
    (define/public (after-button-down mx my)
      (if (in-clock? x y mx my)
          (begin
            (set! t (+ t 1))
            (set! selected? true)
            (set! saved-mx (- mx x))
            (set! saved-my (- my y)))
          42))
    
    ;; after-button-up : NonNegNum NonNegNum -> Clock%
    ;; GIVEN: x and y coordinates of the mouse
    ;; WHERE: mouse event is button up
    ;; RETURNS: the unselected clock
    (define/public (after-button-up mx my)
      (begin
        (set! t (+ t 1))
        (set! selected? false)
        (set! saved-mx 0)
        (set! saved-my 0)
        this))
    
    ;; after-drag : NonNegNum NonNegNum -> Clock%
    ;; GIVEN: x and y coordinates of the mouse
    ;; WHERE: mouse event is drag
    ;; RETURNS: the clock after dragging 
    ;; WHERE: if clock is selected then return selected clock otherwise returns same clock
    ;; STARTEGY: cases on whether the clock is selected
    (define/public (after-drag mx my)
      (if selected?
          (begin
            (set! x (- mx saved-mx))
            (set! y (- my saved-my)))
          42))
    
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
    
    ;; in-clock? : NonNegNum NonNegNum NonNegNum NonNegNum -> Boolean
    ;; GIVEN: the x and y coordinates of the center of clock (x, y)
    ;;        the x and y coordinates of the mouse (mx, my)
    ;; RETURN: true iff the mouse inside of the clock
    (define (in-clock? x y mx my)
      (and (<= mx (+ x CLOCK-HALF-W)) (>= mx (- x CLOCK-HALF-W))
           (<= my (+ y CLOCK-HALF-H)) (>= my (- y CLOCK-HALF-H))))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Football is a
;; (new Football% [x NonNegNum][y NonNegNum][v PosInt][s NonNegNum][wd NonNegNum]
;;                [ht NonNegNum][selected? Boolean][saved-mx NonNegNum]
;;                [saved-my NonNegNum])
;; A Football represents the footbal shaped toy in the playground which will shrink at
;; the rate of given speed for every tick until it disappears
(define Football%
  (class* object% (Toy<%>)
    
    ;; the x and y coordintates of the center of the football
    ;; v is the rate of the football shrinking
    ;; s is the scale of the football
    ;; wd is the width of the football
    ;; ht is the hight of the football 
    (init-field x y v s wd ht)
    ;; selected? depicts whether the football is selected or not 
    (init-field selected?)
    ;; for saving mouse coordinates after button down
    (init-field saved-mx saved-my)
    
    ;; toy-x : -> NonNegNum
    ;; RETURNS: the x coordinate of the center of the football
    (define/public (toy-x) x)
    
    ;; toy-y : -> NonNegNum
    ;; RETURNS: the y coordinate of the center of the football
    (define/public (toy-y) y)
    
    ;; toy-data : -> Int
    ;; RETURNS: 
    (define/public (toy-data) s)
    
    (super-new)
    
    ;; after-tick : -> Football%
    ;; RETURNS: the football after tick
    ;; DETAILS: the football will shrink at every tick
    (define/public (after-tick)
       (begin
        (set! v (+ v 1))
        (set! ht (get-new-ht))
        (set! wd (get-new-wd))
        (set! s (get-scale v))
        this))
    
    ;; after-button-down : NonNegNum NonNegNum -> Football%
    ;; GIVEN: the x and y coordinates of the mouse
    ;; WHERE : mouse event is button down
    ;; RETURNS: the selected football when mouse is inside the football otherwise return
    ;; same football
    ;; STRATEGY: cases on whether the mouse is inside the football or not
    (define/public (after-button-down mx my)
      (if (in-football? x y mx my)
          (begin
            (set! v (+ v 1))
            (set! ht (get-new-ht))
            (set! wd (get-new-wd))
            (set! s (get-scale v))
            (set! selected? true)
            (set! saved-mx (- mx x))
            (set! saved-my (- my y))) 
          this))
    
    
    ;; after-button-up : NonNegNum NonNegNum -> Football%
    ;; GIVEN: the x and y coordinates of the mouse 
    ;; WHERE: mouse event is button up
    ;; RETURNS: the unselected football
    ;; STRATEGY: combine using simpler function
    (define/public (after-button-up mx my)
       (begin
        (set! v (+ v 1))
        (set! ht (get-new-ht))
        (set! wd (get-new-wd))
        (set! s (get-scale v))
        (set! selected? false)
        (set! saved-mx 0)
        (set! saved-my 0)
        this))
    
    ;; after-drag : NonNegNum NonNegNum -> Football%
    ;; GIVEN: the x and y coordinates of the mouse 
    ;; WHERE : mouse event is drag
    ;; RETURNS: the football after drag event 
    ;; STRATEGY: cases on whether the mouse is inside the football
    (define/public (after-drag mx my)
      (if selected?
          (begin
            (set! x (- mx saved-mx))
            (set! y (- my saved-my)))
          this))
    
    ;; after-key-event : -> Football%
    ;; RETURNS: this football as it is
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
    
    ;; get-new-ht : -> NonNegNum
    ;; RETURNS: the new height of the football after shrinking
    ;; STRATEGY: use simpler function 
    (define (get-new-ht)
      (/ (image-height (scale s FOOTBALL-IMG)) 2))
    
    ;; get-new-wd : -> NonNegNum
    ;; RETURNS: the new width of the football after shrinking
    ;; STRATEGY: use simpler function 
    (define (get-new-wd)
      (/ (image-width (scale s FOOTBALL-IMG)) 2))
    
    ;; get-scale : PosInt -> NonNegNumber 
    ;; GIVEN: the speed v of at which football image will scale down
    ;; RETURN: return the new scale
    ;; STRATEGY: combine using simpler function 
    (define (get-scale v)
      (/ 1 v))
    
    ;; in-football? : NonNegNum NonNegNum NonNegNum NonNegNum -> Boolean 
    ;; GIVEN: the x and y coordinates of the center of the football (x,y)
    ;;         the x and y coordinates of the mouse (mx, my)
    ;; RETURN: true iff the mouse inside the football
    ;; STRATEGY: combine using simpler function 
    (define (in-football? x y mx my)
      (and (<= mx (+ x wd)) (>= mx (- x wd))
           (<= my (+ y ht)) (>= my (- y ht))))
    ))

(define (make-throbber x y)
  (new-throbber x y 1 10 #f 0 0))
(define (make-clock x y)
  (new-clock x y 0 #f 0 0))
(define (make-football x y)
  (new-football x y 1 FOOTBALL-WD-HALF FOOTBALL-HT-HALF #f 0 0))
(define (make-square-toy x y v)
  (new-square x y v #f 0 0))

#|
(define (make-world t)
  (new PlaygroundState%
       [objs empty] [t t][v 0][tx INITIAL-TARGET-X]
       [ty INITIAL-TARGET-Y][selected? #f][saved-mx 0][saved-my 0]))
|#
(define (make-playground speed)
  (new PlaygroundState%
       [sobjs empty][t 0][v speed][tx INITIAL-TARGET-X]
       [ty INITIAL-TARGET-Y][selected? #f][saved-mx 0][saved-my 0]))

#|
(define (make-playground objs t v tx ty selected? mx my)
  (new PlaygroundState% [objs objs][t t][v v][tx tx][ty ty]
       [selected? selected?][saved-mx mx][saved-my my]))
|#
(define (make-playgroundstate sobjs t v tx ty selected? mx my)
  (new PlaygroundState% [sobjs sobjs][t t][v v][tx tx][ty ty]
       [selected? selected?][saved-mx mx][saved-my my]))

(define (new-throbber x y v r selected? mx my)
  (new Throbber% [x x][y y][v v][r r][selected? selected?][saved-mx mx][saved-my my]))

(define (new-clock x y t selected? mx my)
  (new Clock% [x x][y y][t t][selected? selected?][saved-mx mx][saved-my my]))

(define (new-football x y v wd ht selected? mx my)
  (new Football% [x x][y y][v v][wd wd][ht ht][s 1]
       [selected? selected?][saved-mx mx][saved-my my]))

(define (new-square x y v selected? mx my)
  (new Square% [x x][y y][v v][selected? selected?][saved-mx mx][saved-my my]))

(begin-for-test
  (local
    ((define the-playground (make-playground 1))
     (define square1 (make-square-toy 200 200 1)))
    (send the-playground after-key-event "s")
    (check-equal? (length (send the-playground for-test:sobjs)) 1)
    (send the-playground after-button-down 270 300)
    (check-equal?
     (send
      (first (send the-playground for-test:sobjs)) for-test:selected?) #t)
    ;(send the-playground after-drag 270 300)
    (check-equal? (send square1 for-test:selected?) #f)
    (send square1 after-button-down 200 200)
    (check-equal? (send square1 for-test:selected?) #t)
    (send square1 after-drag 20 20)
    (check-equal? (send square1 toy-x) 20)
    (check-equal? (send square1 toy-y) 20)))

;; initial-world : -> Void
;; EFFECT: run the world simulation
(define (run rate speed)
  (local
    ((define the-playground (make-playground speed))
     (define the-world (make-world 500 600)))
    (begin
      ;; put the playground in the world
      (send the-world add-stateful-widget the-playground)
      ;; run the simulation
      (send the-world run rate))))