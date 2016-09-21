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
(define CANVAS-WIDTH 500)
(define CANVAS-HEIGHT 600)

(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))


(define INIT-BLOCK-X (/ CANVAS-HEIGHT 2))
(define INIT-BLOCK-Y (/ CANVAS-WIDTH 2))


;;----------------------------------------------------------------------------------------
;;                                      DATA DEFINITIONS
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;                                      INTERFACES
;;----------------------------------------------------------------------------------------

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
(define PlayGroundState%
  (class* object% (StatefulWorld<%>)
    
    (init-field canvas-width)
    (init-field canvas-height)
       
    (init-field [sobjs empty])  ; ListOfSWidget

    (init-field [last-mx INIT-BLOCK-X] [last-my INIT-BLOCK-Y])

    (super-new)

     ; run : PosReal -> World
    ; GIVEN: a frame rate, in secs/tick
    ; EFFECT: runs this world at the given frame rate
    ; RETURNS: the world in its final state of the world
    ; Note: the (begin (send w ...) w) idiom
    (define/public (run rate)
      (big-bang this
        (on-tick
          (lambda (w) (begin (after-tick) w))
          rate)
        (on-draw
          (lambda (w) (to-scene)))
        (on-key
          (lambda (w kev)
            (begin
              (after-key-event kev)
              w)))
        (on-mouse
          (lambda (w mx my mev)
            (begin
              (after-mouse-event mx my mev)
              w)))))

    (define/public (add-widget w)
      this)
    
    (define/public (add-stateful-widget w)
      (set! sobjs (cons w sobjs)))

    ;; (Widget or SWidget -> Void) -> Void
    (define (process-widgets fn)
      (begin
        (for-each fn sobjs)))

    ;; after-tick : -> Void
    ;; Use map on the Widgets in this World; use for-each on the
    ;; stateful widgets

    (define (after-tick)
      (process-widgets
        (lambda (obj) (send obj after-tick))))

    ;; to-scene : -> Scene
    ;; Use HOFC foldr on the Widgets and SWidgets in this World
    ;; Note: the append is inefficient, but clear..
      
    (define (to-scene)
      (foldr
        (lambda (obj scene)
          (send obj add-to-scene scene))
        EMPTY-CANVAS
        sobjs))

    ;; after-key-event : KeyEvent -> WorldState
    ;; STRATEGY: Pass the KeyEvents on to the objects in the world.

    (define (after-key-event kev)
      (cond
        [(key=? kev "b")
         (add-stateful-widget
               (make-block last-mx last-my sobjs))]))

    ;; world-after-mouse-event : Nat Nat MouseEvent -> WorldState
    ;; STRATGY: Cases on mev
    (define (after-mouse-event mx my mev)
      (cond
        [(mouse=? mev "button-down")
         (world-after-button-down mx my)]
        [(mouse=? mev "drag")
         (world-after-drag mx my)]
        [(mouse=? mev "button-up")
         (world-after-button-up mx my)]
        [else this]))

    ;; the next few functions are local functions, not in the interface.
    
    (define (world-after-button-down mx my)
      (begin
        (set! last-mx mx)
        (set! last-my my)
        (process-widgets
         (lambda (obj) (send obj after-button-down mx my)))))
    
    
    (define (world-after-button-up mx my)
      (begin
        (set! last-mx mx)
        (set! last-my my)
        (process-widgets
         (lambda (obj) (send obj after-button-up mx my)))))


    (define (world-after-drag mx my)
      (process-widgets
        (lambda (obj) (send obj after-drag mx my sobjs))))
    ))


(define Block%
  (class* object% (Block<%>)

    ;;
    (init-field [team empty])
    ;;
    (init-field [sobjs empty])
    
    ;; initial values of x, y (center of block)
    (init-field (x INIT-BLOCK-X))
    (init-field (y INIT-BLOCK-Y))
     ; is this selected? Default is false.
    (init-field [selected? false]) 

    ;; if this is selected, the position of
    ;; the last button-down event inside this, relative to the
    ;; block's center.  Else any value.
    (init-field [saved-mx 0] [saved-my 0])
    ;;
    (field [LENGTH 20])
    ;;
    (field [SQUARE-HALF (/ LENGTH 2)])

    (super-new)

    ;;
    (define/public (get-x-pos)
      x)

    ;;
    (define/public (get-y-pos)
      y)

    ;;
    (define/public (get-team)
      team)
     ;;
    (define/public (get-sobjs)
      sobjs)

    ;;
    (define (check-block-equal? b1 b2)
      (local
        ((define b1-x-pos (send b1 get-x-pos))
         (define b1-y-pos (send b1 get-y-pos))
         (define b2-x-pos (send b2 get-x-pos))
         (define b2-y-pos (send b2 get-y-pos)))
        (and (equal? b1-x-pos b2-x-pos)
             (equal? b1-y-pos b2-y-pos))))

    ;;
    (define (already-present? team block)
      (cond
        [(empty? team) #f]
        [else
         (or (check-block-equal? (first team) block)
             (already-present? (rest team) block))]))

    ;;
    (define/public (add-teammate block mx my)
      (local
        ((define x-pos (send block get-x-pos))
         (define y-pos (send block get-y-pos))
         (define block-team (send block get-team))
         (define current-team (get-team)))
        (if (and (not (already-present? team block))
                 (not (check-block-equal? this block)))
            (if (overlap? x y x-pos y-pos)
                (begin
                  (send block register-all-team (append (list this) team))
                  (send block select-teammate mx my)
                  (for-each
                   (lambda (obj)
                     (begin
                       (send obj select-teammate mx my)
                       ;(send obj add-teammate this mx my)
                       (send obj register-teammate this)
                       (send obj register-all-team (append (list this) team))
                       #;(send obj register-teammate this))) block-team)
                  ;(send block register-all-team (append (list this) team))
                  (set! team (append (list block) block-team team))
                  #;(for-each
                   (lambda (obj) (send obj register-teammate block) )))
                12)
            12)))
    
    ;;
    (define/public (register-all-team block-team)
      (set! team (append block-team team)))
    
    ;;
    (define/public (register-teammate block)
      (set! team (append (list block) team)))

    ;;
    (define/public (select-teammate mx my)
      (begin
        (set! saved-mx (- mx x))
        (set! saved-my (- my y))))

    ;;
    (define/public (unselect-teammate)
      (begin
        (set! saved-mx 0)
        (set! saved-my 0)))

    ;;
    (define/public (drag-teammate mx my)
      (begin
        (set! x (- mx saved-mx))
        (set! y (- my saved-my))))
    
    ;; after-tick : -> Void
    ;; state of this block after a tick
    (define/public (after-tick)
      this) 

    ;; after-button-down : Integer Integer -> Void
    ;; GIVEN: the location of a button-down event
    ;; STRATEGY: Cases on whether the event is in this
    (define/public (after-button-down mx my)
      (if (in-this? mx my)
        (begin
          (set! selected? true)
          (set! saved-mx (- mx x))
          (set! saved-my (- my y))
          (for-each (lambda (obj) (send obj select-teammate mx my)) team))
        this))

    ;; after-button-up : Integer Integer -> Void
    ;; GIVEN: the location of a button-up event
    ;; STRATEGY: Cases on whether the event is in this
    ;; If this is selected, then unselect it.
    (define/public (after-button-up mx my)
      (if (in-this? mx my)
          (begin
            (set! selected? false)
            (for-each (lambda (obj) (send obj unselect-teammate)) team))
          this))
    
    ; after-drag : Integer Integer -> Void
    ; GIVEN: the location of a drag event
    ; STRATEGY: Cases on whether the block is selected.
    ; If it is selected, move it so that the vector from the center to
    ; the drag event is equal to (mx, my)
    (define/public (after-drag mx my sobjs)
      (if selected?
        (begin
          (set! x (- mx saved-mx))
          (set! y (- my saved-my))
          (for-each
           (lambda (block)
             (add-teammate block mx my))
           sobjs)
          (for-each
           (lambda (obj) (send obj drag-teammate mx my)) team))
        this))
    
    ;; the block ignores key events
    (define/public (after-key-event kev) this)

    ;;
    (define/public (add-to-scene s)
      (if selected?
          (place-image (square LENGTH "outline" "red") x y s)
          (place-image (square LENGTH "outline" "green") x y s)))
    
    ;; in-this? : Integer Integer -> Boolean
    ;; GIVEN: a location on the canvas
    ;; RETURNS: true iff the location is inside this.
    (define (in-this? other-x other-y)
      (and (<= other-x (+ x SQUARE-HALF)) (>= other-x (- x SQUARE-HALF))
           (<= other-y (+ y SQUARE-HALF)) (>= other-y (- y SQUARE-HALF))))
    
    ;;
    (define/public (overlap? x1 y1 x2 y2)
      (not
       (or (< (+ x1 20) x2) (< (+ y1 20) y2)
           (> x1 (+ x2 20)) (> y1 (+ y2 20)))))
    
    ))

;;----------------------------------------------------------------------------------------

;;
(define (make-playgraund sobjs)
  (new PlayGroundState%
            [sobjs sobjs][canvas-width CANVAS-WIDTH]
            [canvas-height CANVAS-HEIGHT][last-mx INIT-BLOCK-X][last-my INIT-BLOCK-Y]))

#;(define block2 (new Block% [x 50][y 10][selected? #f][team empty]
       [sobjs empty][saved-mx 0] [saved-my 0]))

;; make-block : NonNegInt NonNegInt ListOfBlock<%> -> Block<%>
;; GIVEN: an x and y position, and a list of blocks
;; WHERE: the list of blocks is the list of blocks already on the playground.
;; RETURNS: a new block, at the given position, with no teammates
(define (make-block x y sobjs)
  (new Block% [x x][y y][selected? #f][team empty]
       [sobjs sobjs][saved-mx 0] [saved-my 0]))

;; TESTS:
(define block2 (make-block 50 10 empty))
(define block1 (make-block 10 10 empty))
(define block3 (make-block 100 10 empty))

(begin-for-test
  (local
    ((define block1 (make-block 10 10 empty))
     (define block2 (make-block 50 10 empty))
     (define block3 (make-block 100 10 empty))
     ;(define block4 (make-block 200 10 empty))
     #;(define block5 (make-block 200 50 empty)))
    (check-equal? (send block1 get-x-pos) 10)
    (check-equal? (send block2 get-x-pos) 50)
    (send block2 after-button-down 50 10)
    (send block2 after-drag 30 10 (list block1 block2 block3))
    (check-equal? (send block1 get-x-pos) 10)
    (check-equal? (send block1 get-y-pos) 10)
    (check-equal? (send block2 get-x-pos) 30)
    (check-equal? (send block2 get-y-pos) 10)
    (check-equal? (length (send block2 get-team)) 1)
    (check-equal? (length (send block1 get-team)) 1)
    (send block2 after-drag 80 10 (list block1 block2 block3))
    #;(check-equal? (length (send block1 get-team)) 2)
    (check-equal? (length (send block2 get-team)) 2)
    (check-equal? (length (send block3 get-team)) 2)
   #| (check-equal? (send (first (send block1 get-team)) get-x-pos) 30)
    (check-equal? (send (first (send block2 get-team)) get-x-pos) 10)
    (send block3 after-button-down 95 10)
    (send block3 after-drag 45 10 (list block1 block2 block3))
    (check-equal? (send (first (send block3 get-team)) get-x-pos) 30)
    (check-equal? (send (second (send block3 get-team)) get-x-pos) 10)
    (send block4 after-button-down 200 10)
    (send block4 after-drag 200 30 (list block1 block2 block3 block4 block5))
    (check-equal? (send (first (send block4 get-team)) get-x-pos) 200)
    (check-equal? (send (first (send block4 get-team)) get-y-pos) 50)
    (send block4 after-button-down 200 30)
    (send block4 after-drag 10 30 (list block1 block2 block3 block4 block5))
    #;(check-equal? (length (send block4 get-team)) 5)|#
    ))


(define (initial-world)
  (local
    ((define the-block (make-block INIT-BLOCK-X INIT-BLOCK-Y empty))
     (define the-world
       (new PlayGroundState%
            [sobjs (list the-block)][canvas-width CANVAS-WIDTH]
            [canvas-height CANVAS-HEIGHT][last-mx INIT-BLOCK-X][last-my INIT-BLOCK-Y])))
    (begin
      ;; put the factory in the world
      (send the-world run 0.25))))