#lang racket

;(check-location "10" "cubelets.rkt")

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")
(require "WidgetWorks.rkt")
(require 2htdp/universe)   
(require 2htdp/image)

;;----------------------------------------------------------------------------------------
;;                                      CONSTANTS
;;----------------------------------------------------------------------------------------
;; constants for the canvas
(define CANVAS-WIDTH 500)
(define CANVAS-HEIGHT 600)

;; constants for default block position
(define INIT-BLOCK-X (/ CANVAS-WIDTH 2))
(define INIT-BLOCK-Y (/ CANVAS-HEIGHT 2))


;;----------------------------------------------------------------------------------------
;;                                      DATA DEFINITIONS
;;----------------------------------------------------------------------------------------
;; ListOfSWidget

;; Scene is the image displaying the world

;;----------------------------------------------------------------------------------------
;;                                      INTERFACES
;;----------------------------------------------------------------------------------------
;; Every Block% implement the Block<%> interface
(define Block<%>
  (interface (SWidget<%>)
    ;; get-team : -> ListOfBlock<%>
    ;; RETURNS: the teammates of this block
    get-team
    
    ;; add-teammate: Block<%> -> Void
    ;; EFFECT: adds the given block to this block's team
    add-teammate
    )
  )

;;----------------------------------------------------------------------------------------
;;                                      CLASSES
;;----------------------------------------------------------------------------------------
;; A PlaygroundState is a
;; (new PlaygroundState%
;;        [sobjs ListOfBlock<%>][last-mx NonNegNumber][last-my NonNegNumber])
;; INTERPRETATION:
;; A PlayGroundState represents the play ground for toy's (blocks)

(define PlayGroundState%
  ;; Implement all methods of SWidget<%>
  (class* object% (SWidget<%>)
    
    ;; A ListOfSWidget present inside the play ground
    (init-field [sobjs empty])
    ;; the co-ordinates of the last mouse event
    ;; WHERE: mouse event is either button-up or button-down
    (init-field [last-mx INIT-BLOCK-X] [last-my INIT-BLOCK-Y])
    
    (super-new)
    
    ;; add-stateful-widget : SWidget -> Void
    ;; GIVEN:  A stateful widget
    ;; EFFECT: add the given widget to the play ground
    (define/public (add-stateful-widget w)
      (set! sobjs (cons w sobjs)))
    
    ;; process-widgets : (SWidget -> Void) -> Void
    ;; GIVEN:    a function to be applied on SWidgets present in play ground
    ;; EFFECT:   the list of SWidgets after applying the given function
    ;; STRATEGY: using HOF for-each on sobjs
    (define/public (process-widgets fn)
      (begin
        (for-each fn sobjs)))
    
    ;; after-tick : -> Void
    ;; EFFECT:   returns the widget after tick
    ;; STRATEGY: using HOF for-each on the stateful widgets
    (define/public (after-tick)
      (process-widgets
       ;; SWidget -> Void
       (lambda (obj) (send obj after-tick))))
    
    ;; add-to-scene : -> Scene
    ;; GIVEN:    a scene
    ;; RETURNS:  Scene after adding all SWidgets present in the play ground
    ;; STRATEGY: Use HOFC foldr on the SWidgets in this play ground
    (define/public (add-to-scene scn)
      (foldr
       ;; SWidget -> Scene
       (lambda (obj scene)
         (send obj add-to-scene scene))
       scn
       sobjs))
    
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN:    a key event
    ;; EFFECT:   add new block into the play ground if the key event is "b", otherwise
    ;;           do nothing
    ;; STRATEGY: cases on key event
    (define/public (after-key-event kev)
      (cond
        [(key=? kev "b")
         (add-stateful-widget
          (make-block last-mx last-my))]))
    
    
    ;; after-button-down : NonNegNum NonNegNum -> Void
    ;; GIVEN:    co-ordinates of the mouse event
    ;; EFFECT:   the play ground after applying button down event to all blocks present in
    ;;           the play ground. Also stores the mouse co-ordinates into last-mx and
    ;;           last-my for future use.
    ;; STRATEGY: use more general function
    (define/public (after-button-down mx my)
      (begin
        (set! last-mx mx)
        (set! last-my my)
        (process-widgets
         ;; SWidget -> Void
         (lambda (obj) (send obj after-button-down mx my)))))
    
    ;; after-button-up : NonNegNum NonNegNum -> Void
    ;; GIVEN:    co-ordinates of the mouse event
    ;; EFFECT:   the play ground after applying button up event to all blocks present in
    ;;           the play ground. Also stores the mouse co-ordinates into last-mx and
    ;;           last-my for future use.
    ;; STRATEGY: use more general function
    (define/public (after-button-up mx my)
      (begin
        (set! last-mx mx)
        (set! last-my my)
        (process-widgets
         ;; SWidget -> Void
         (lambda (obj) (send obj after-button-up mx my)))))
    
    ;; after-drag : NonNegNum NonNegNum -> Void
    ;; GIVEN:    co-ordinates of the mouse event
    ;; EFFECT:   the play ground after applying drag event to all blocks present in
    ;;           the play ground.
    ;; STRATEGY: use more general function
    (define/public (after-drag mx my)
      (process-widgets
       ;; SWidget -> Void
       (lambda (obj) (send obj after-drag mx my sobjs))))
    ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Block is a
;; (new Block%
;;        [team ListOfBlock<%>][sobjs ListOfBlock<%>][x NonNegNum][y NonNegNum]
;;        [selected? Boolean][saved-mx NonNegNum][saved-my NonNegNum])
;; INTERPRETATION:
;; A Block is a square shaped toy present in the play ground.
;; When the block is selected, it is shown in red outline. When block touches another
;; block in the play ground, then both of them will form the team and move along with
;; each other in future. Adding the block into team is symmetric and transitive.

(define Block%
  ;; Implement all methods of Block<%>
  (class* object% (Block<%>)
    
    ;; A ListOfSWidget which represents the team members of the block
    (init-field [team empty])
    ;; initial values of x, y (center of block)
    (init-field (x INIT-BLOCK-X))
    (init-field (y INIT-BLOCK-Y))
    ; is this selected? Default is false.
    (init-field [selected? false])  
    ;; if this is selected, the position of
    ;; the last button-down event inside this, relative to the
    ;; block's center.  Else any value.
    (init-field [saved-mx 0] [saved-my 0])

    ;; constant for block width
    (field [LENGTH 20])
    ;; constant for block's half width
    (field [SQUARE-HALF (/ LENGTH 2)])
    
    (super-new)
    
    ;; block-x : -> Integer
    ;; RETURNS: a x coordinate of the this
    (define/public (block-x)
      x)
    
    ;; block-y : -> Integer
    ;; RETURNS: a y coordinate of the this
    (define/public (block-y)
      y)
    
    ;; get-team : -> ListOfSWidget<%>
    ;; RETURNS: a list of all block's present in the this block's team
    (define/public (get-team)
      team)
    
    ;; check-block-equal? : SWidget<%> SWidget<%> -> Boolean
    ;; GIVEN:   two blocks
    ;; RETURNS: true iff both the blocks are same
    ;; STRATEGY: combine using simpler functions
    (define (check-block-equal? b1 b2)
      (local
        ((define b1-x-pos (send b1 block-x))
         (define b1-y-pos (send b1 block-y))
         (define b2-x-pos (send b2 block-x))
         (define b2-y-pos (send b2 block-y))
         (define b1-team (send b1 get-team))
         (define b2-team (send b2 get-team)))
        (and (equal? b1-x-pos b2-x-pos)
             (equal? b1-y-pos b2-y-pos)
             (set-equal? b1-team b2-team))))
    
    ;; already-present? : LisOfSWidget<%> SWidget<%> -> Boolean
    ;; GIVEN:    the ListOfSWidget<%> and block
    ;; RETURNS:  true iff block is already present in the list of SWidegt
    ;; STRATEGY: using HOF ormap on team
    (define (already-present? team block)
      (ormap
       ;; SWidget<%> -> Boolean
       (lambda (b) (check-block-equal? b block))
       team))
    
    ;; register-teammate : SWidget<%> NonNegNum NonNegNum -> Void
    ;; GIVEN:    a block and mouse coordinates
    ;; EFFECT:   if this is overlaping on any of the block present in the play ground,
    ;;           then add the overlapped block into the this team
    ;; STRATEGY: using cases on whether the this overlaps on any of the block and it is
    ;;           already present in team.
    (define/public (register-teammate block mx my)
      (local
        ;; get block position and it's team into local variables
        ((define x-pos (send block block-x))
         (define y-pos (send block block-y))
         (define block-team (send block get-team))
         (define current-team team))
        ;; check if block is same or already present in this team
        (if (and (not (already-present? team block))
                 (not (check-block-equal? this block)))
            ;; check if block overlaps with this
            (if (overlap? x y x-pos y-pos)
                (begin
                  ;; add block into this team
                  (add-teammate block)
                  ;; add all team members of block into this team
                  (add-all-team block-team)
                  ;; add block and it's team into each member of this team
                  (for-each
                   ;; SWidget<%> -> Void
                   (lambda (b) (send b add-all-team
                                     (append block-team (list block))))
                   current-team)

                  ;; add this into the block's team
                  (send block add-teammate this)
                  ;; add all this team into the block's team
                  (send block add-all-team current-team)
                  ;; add this and this team into each member of block's team
                  (for-each
                   (lambda (b) (send b add-all-team
                                     (append current-team (list this))))
                   block-team)

                  ;; select all newly added block's into this team
                  (after-button-down mx my))
                12)
            12)))
    
    ;; add-all-team : ListOfSWidget<%> -> Void
    ;; GIVEN:  a list of blocks
    ;; EFFECT: list of blocks is added into this team
    (define/public (add-all-team block-team)
      (set! team (append block-team team)))
    
    ;; add-teammate : SWidget<%> -> Void
    ;; GIVEN:  a block
    ;; EFFECT: the block is added into this team
    (define/public (add-teammate block)
      (set! team (append (list block) team)))
    
    ;; select-teammate : NonNegNum NonNegNum -> Void
    ;; GIVEN:  a coordinates of the mouse event
    ;; EFFECT: the mouse coordinates are updated into this
    (define/public (select-teammate mx my)
      (begin
        (set! saved-mx (- mx x))
        (set! saved-my (- my y))))
    
    ;; unselect-teammate : -> Void
    ;; EFFECT: the mouse coordinates are updated to zero
    (define/public (unselect-teammate)
      (begin
        (set! saved-mx 0)
        (set! saved-my 0)))
    
    ;; drag-teammate : NonNegNum NonNegNum -> Void
    ;; GIVEN:  a coordinates of the mouse event
    ;; EFFECT: the mouse coordinates are updated into this
    (define/public (drag-teammate mx my)
      (begin
        (set! x (- mx saved-mx))
        (set! y (- my saved-my))))
    
    ;; after-tick : -> SWidget<%>
    ;; EFFECT: returns the same block
    (define/public (after-tick)
      this) 
    
    ;; after-button-down : NonNegNum NonNegNum -> Void
    ;; GIVEN:    the location of a button-down event
    ;; EFFECT:   the mouse co-ordinates are updated for this and all it's team members
    ;; STRATEGY: Cases on whether the event is in this, further using HOF for-each on
    ;;           this team
    (define/public (after-button-down mx my)
      (if (in-this? mx my)
          (begin
            (set! selected? true)
            (set! saved-mx (- mx x))
            (set! saved-my (- my y))
            (for-each
             ;; SWidget<%> -> Void
             (lambda (obj) (send obj select-teammate mx my))
             team))
          this))
    
    ;; after-button-up : NonNegNum NonNegNum -> Void
    ;; GIVEN:    the location of a button-up event
    ;; EFFECT:   the block will be unselected
    ;; STRATEGY: Cases on whether the event is in this, further using HOF for-each on
    ;;           this team.
    ;; WHERE:    If this is selected, then unselect it.
    (define/public (after-button-up mx my)
      (if (in-this? mx my)
          (begin
            (set! selected? false)
            (for-each
             ;; SWidget<%> -> Void
             (lambda (obj) (send obj unselect-teammate))
             team))
          this))
    
    ;; after-drag : NonNegNum NonNegNum -> Void
    ;; GIVEN: the location of a drag event
    ;; EFFECT: the mouse co-ordinates are updated for this and all it's team members
    ;; STRATEGY: Cases on whether the block is selected, further using HOF for-each on
    ;;           this team.
    ;; WHERE:    If this is selected, move it so that the vector from the center to
    ;;           the drag event is equal to (mx, my).
    (define/public (after-drag mx my sobjs)
      (if selected?
          (begin
            (set! x (- mx saved-mx))
            (set! y (- my saved-my))
            (for-each
              ;; SWidget<%> -> Void
             (lambda (block)
               (register-teammate block mx my))
             sobjs)
            (for-each
              ;; SWidget<%> -> Void
             (lambda (obj) (send obj drag-teammate mx my)) team))
          this))
    
    ;; after-key-event : KeyEvent -> SWidget<%>
    ;; EFFECT: returns the same block
    (define/public (after-key-event kev)
      this)
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN:    a scene
    ;; RETURNS:  the scene after adding this
    ;; STRATEGY: cases on whether this is selected or not
    (define/public (add-to-scene s)
      (if selected?
          (place-image (square LENGTH "outline" "red") x y s)
          (place-image (square LENGTH "outline" "green") x y s)))
    
    ;; in-this? : NonNegNum NonNegNum -> Boolean
    ;; GIVEN:   a location on the canvas
    ;; RETURNS: true iff the location is inside this
    (define (in-this? other-x other-y)
      (and (<= other-x (+ x SQUARE-HALF)) (>= other-x (- x SQUARE-HALF))
           (<= other-y (+ y SQUARE-HALF)) (>= other-y (- y SQUARE-HALF))))
    
    ;; overlap? : NonNegNum NonNegNum NonNegNum NonNegNum -> Boolean
    ;; GIVEN:    coordinates of the two blocks
    ;; RETURNS : true iff the two blocks overlap based on their co-ordinates
    ;; STRATEGY: combie using simpler functions
    (define/public (overlap? x1 y1 x2 y2)
      (not
       (or (< (+ x1 20) x2) (< (+ y1 20) y2)
           (> x1 (+ x2 20)) (> y1 (+ y2 20)))))
    
    ))

;;---------------------------------------------------------------------------------------
;; make-playground : -> PlaygroundState
;; GIVEN: no arguments
;; RETURNS: a PlaygroundState
(define (make-playgraund)
  (new PlayGroundState%
       [sobjs empty][last-mx INIT-BLOCK-X][last-my INIT-BLOCK-Y]))

;; make-block : NonNegInt NonNegInt -> Block<%>
;; GIVEN: an x and y position
;; WHERE: the list of blocks is the list of blocks already on the playground.
;; RETURNS: a new block, at the given position, with no teammates
(define (make-block x y)
  (new Block%
       [x x][y y][selected? #f][team empty][saved-mx 0] [saved-my 0]))

;; TESTS:
(define block2 (make-block 50 10))
(define block1 (make-block 10 10))
(define block3 (make-block 100 10))

(begin-for-test
  (local
    ((define block1 (make-block 10 10))
     (define block2 (make-block 50 10))
     (define block3 (make-block 100 10))
     (define block4 (make-block 200 10)))
    (check-equal? (send block1 block-x) 10)
    (check-equal? (send block2 block-x) 50)
    (send block2 after-button-down 50 10)
    (send block2 after-drag 30 10 (list block1 block2 block3))
    (check-equal? (send block1 block-x) 10)
    (check-equal? (send block1 block-y) 10)
    (check-equal? (send block2 block-x) 30)
    (check-equal? (send block2 block-y) 10)
    (check-equal? (length (send block2 get-team)) 1)
    (check-equal? (length (send block1 get-team)) 1)
    (send block2 after-drag 80 10 (list block1 block2 block3))
    (check-equal? (length (send block1 get-team)) 2)
    (check-equal? (length (send block2 get-team)) 2)
    (check-equal? (length (send block3 get-team)) 2)
    ))

;; initial-world : -> Void
;; EFFECT: run the world simulation
(define (initial-world)
  (local
    ((define the-block (make-block INIT-BLOCK-X INIT-BLOCK-Y))
     (define the-playground (make-playgraund))
     (define the-world (make-world CANVAS-WIDTH CANVAS-HEIGHT)))
    (begin
      ;; put the playground in the world
      (send the-world add-stateful-widget the-playground)
      ;; run the simulation
      (send the-world run 0.25))))