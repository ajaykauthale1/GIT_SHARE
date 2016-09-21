;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname trees) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Program for trees simulation

;(check-location "05" "screensaver-5.rkt")

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

#;(provide initial-world run world-after-mouse-event world-after-key-event world-to-trees
           tree-to-root tree-to-sons node-to-center node-to-selected?)

;=========================================================================================
;                                      CONSTANTS
;=========================================================================================
;; constant for displaying canvas
(define MT-SCENE (empty-scene 500 400))
;; constant for node circle radius
(define NODE-RADIUS 10)
;; constant for node circle radius
(define NODE-DIST (* NODE-RADIUS 3))
;; costant for showing node on the screen
(define NODE-CIRCLE (circle NODE-RADIUS "outline" "green"))
(define SELECTED-NODE-CIRCLE (circle NODE-RADIUS "solid" "green"))
;; constants for screen center
(define NEW-NODE-CENTER-X 250)
(define NEW-NODE-CENTER-Y 10)
;; constants for mouse evevents
(define BUTTON-DOWN "button-down")
(define BUTTON-UP "button-up")
(define DRAG "drag")
(define ENTER "enter")
;; constant for button events
(define BUTTON-T "t")
(define BUTTON-N "n")
(define BUTTON-D "d")
(define BUTTON-L "l")
;; constants for co-ordinate zero
(define ZERO 0)


;=========================================================================================
;                                      DATA DEFINITIONS
;=========================================================================================
(define-struct node (x y dx dy selected? children))
;; A Node is a (make-node Integer Integer Boolean ListOfNode)
;; INTERPRETATION:
;; x is a x-coordinate of the node on the canvas
;; y is a x-coordinate of the node on the canvas
;; dx is a distance between x and x-coordinate mouse drag event (inside node)
;; dy is a distance between y and y-coordinate mouse drag event (inside node)
;; selected? represents whether the node is selected or not
;; children represents the child nodes of the node

;; TEMPLATE:
;; Node-fn : Node -> ??
#|(define (Node-fn n)
  ....
  (node-x n)
  (node-y n)
  (node-dx n)
  (node-dy n)
  (node-selected? n)
  (node-children n)
  ....)|#

;; Nodes for testing
(define node-selected (make-node 150 150 0 0 true empty))
(define node-added-son (make-node 150 150 0 0 true
                                  (list (make-node 180 180 0 0 false empty))))
(define node-added-two-sons (make-node 150 150 0 0 true
                                  (list (make-node 180 180 0 0 false empty)
                                        (make-node 210 180 0 0 false empty))))

;; A List of Node (ListOfNode) is one of:
;; -- empty
;; -- (cons n ListOfNode)
;; Interpretation:
;; empty represents the empty listn
;; (cons n ListOfNode) represents the list of Node with newly added node c

;; TEMPLATE:
;; ListOfNode-fn -> ??
#|(define (ListOfNode-fn nodes)
  (cond
    [(empty? nodes) ... ]
    [else (... (first nodes)
               (ListOfNode-fn (rest nodes)))]))|#

(define-struct world (nodes))
;; A World is a (make-world ListOfNode)
;; INTERPRETATION:
;; nodes is the list of Nodes present in the world

;; TEMPLATE:
;; world-fn : World -> ??
#|(define (world-fn ws)
    ....
    (world-nodes ws)
    ....)|#

;=========================================================================================
;                                      FUNCTIONS
;=========================================================================================
;; run :  Any -> World
;; GIVEN: any value
;; EFFECT: runs a copy of an initial world
;; RETURNS: the final state of the world.  The given value is ignored.
(define (run v)
    (big-bang (initial-world v)
              (on-key world-after-key-event)
              (on-mouse world-after-mouse-event)
              (to-draw world->scene)))

;;;; Helper functions for run ;;;;

;; world->scene : World -> Image
;; GIVEN: a World
;; RETURNS: the image depicting the current World with red circle as a pointer if any
;; of the node is selected
;; EXAMPLES:

;; STRATEGY: using template of World on ws
(define (world->scene ws)
  (display-nodes (world-nodes ws)))

;; display-nodes : ListOfNode -> Image
;; GIVEN: a ListOfNode
;; RETURNS: the image with all the nodes present on canvas
;; EXAMPLES:

;; STRATEGY: using template of ListOfNode on nodes
#;(define (display-nodes nodes)
  (cond
    [(empty? nodes) MT-SCENE ]
    [else (place-image (get-node-image (first nodes))
                       (node-x (first nodes)) (node-y (first nodes))
                       (display-nodes (rest nodes)))]))

;;
(define (display-node node) 
  (cond
    [(node? node)
     (place-image (get-node-image node)
                  (node-x node) (node-y node)
                  (display-nodes (node-children node)))]
    [else (display-nodes (node-children display-nodes))]))

;;
(define (display-nodes nodes) 
  (cond
    [(empty? nodes) MT-SCENE]
    [else (place-image (display-node (first nodes))
                       (node-x (first nodes)) (node-y (first nodes))       
                       (display-nodes (rest nodes)))]))


;; get-node-image : Node -> Image
;; GIVEN: a Node
;; RETURNS: the image of node
;; EXAMPLES:

;; STRATEGY: using template of Node on node
(define (get-node-image node)
  (if (node-selected? node)
      SELECTED-NODE-CIRCLE NODE-CIRCLE))

;=========================================================================================
;; world-after-mouse-event : World Integer Integer MouseEvent -> World
;; GIVEN: a World, a location, and a MouseEvent
;; RETURNS: the state of the world as it should be following the given mouse event at
;; that location.
;; EXAMPLES:

;; STRATEGY: using template of World on ws
(define (world-after-mouse-event ws mx my me)
  (if (or (mouse=? BUTTON-DOWN me) (mouse=? BUTTON-UP me) (mouse=? DRAG me))
      (make-world (node-list-after-mouse-event (world-nodes ws) mx my me))
      ws))

;;;; Helper functions for world-after-mouse-event ;;;;

;; node-list-after-mouse-event :
;;                       ListOfNode NonNegInt NonNegInt MouseEvent -> ListOfNode
;; GIVEN: A ListOfNode, the x- and y-coordinates of a mouse event, and the mouse
;; event
;; RETURNS: the ListOfNode after the given mouse event

;; STRATEGY: use HOF foldr, followed by HOF map on nodes
(define (node-list-after-mouse-event nodes mx my me)
  (foldr cons empty
         (map
          ;; Node -> Node
          ;; GIVEN: A Node
          ;; RETURNS: Node after mouse event me
          (lambda (node) (node-after-mouse-event node mx my me))
          nodes)))

;; node-after-mouse-event : Node NonNegInt NonNegInt MouseEvent -> Node
;; GIVEN: A Node, the x- and y-coordinates of a mouse event, and the mouse event
;; RETURNS: the Node that should follow the given Node after the given mouse
;; event
;; EXAMPLES:

;; STRATEGY: cases on MouseEvent me
(define (node-after-mouse-event node mx my me)
  (cond
    [(mouse=? me BUTTON-DOWN) (select-node node mx my)]
    [(mouse=? me BUTTON-UP) (unselect-node node)]
    [(mouse=? me DRAG) (drag-node node mx my)]
    [else (unselect-node node)]))

;; cursor-in-node? : Node NonNegInt NonNegInt -> Boolean
;; GIVEN: A Node, x and y coordinates of a mouse event
;; RETURNS: true iff any node from the list is selected for dragging
;; EXAMPLES:

(define (cursor-in-node? node mx my)
  (<= (sqrt (+ (sqr (- mx (node-x node))) (sqr (- my (node-y node))))) NODE-RADIUS))

;; select-node : Node NonNegInt NonNegInt -> Node
;; GIVEN: A Node, x and y coordinates of a mouse event
;; WHERE: A Node is unselected
;; RETURNS: the node same as previous one but with selected flag true
;; EXAMPLES:
;;

;; STRATEGY: using template of Node on node
(define (select-node node mx my)
  (if (cursor-in-node? node mx my)
      (make-node
       (node-x node) (node-y node)
       (- (node-x node) mx) (- (node-y node) my)
       true (node-children node))
      (unselect-node node)))

;; unselect-node : Node -> Node
;; GIVEN: A Node
;; WHERE: A Node is selected
;; RETURNS: the node same as previous one but with selected flag false
;; EXAMPLES:
;; 

;; STRATEGY: using template of Node on node
(define (unselect-node node)
  (make-node (node-x node) (node-y node) ZERO ZERO false (node-children node)))

;; drag-node : Node NonNegInt NonNegInt -> Node
;; GIVEN: A Node, x and y coordinate of mouse
;; WHERE: A Node is selected
;; RETURNS: the Node same as previous one, but changed center coordinates
;; EXAMPLES:
;; 

;; STRATEGY: using template of Node on node
(define (drag-node node mx my)
  (if (cursor-in-node? node mx my)
      (make-node
       (+ mx (node-dx node)) (+ my (node-dy node))
       (node-dx node) (node-dy node)
       true (node-children node))
      (unselect-node node)))

;=========================================================================================
;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a World and a key event
;; WHERE: key event is occurred on the worldstate might be anything
;; RETURNS: the state of the world as it should be following the given key event
;; EXAMPLES:

;; STRATEGY: using cases on key event ke
(define (world-after-key-event ws ke)
  (cond
    [(key=? ke BUTTON-T)
     (add-new-node-at-center-top ws)]
    [(or (key=? ke BUTTON-N) (key=? ke BUTTON-D))
     (make-world-with-changed-nodes ws ke)]
   ;[(key=? ke BUTTON-L) (delete-all-left-nodes ws)]
    [else ws]))

;;;; Helper functions for world-after-key-event ;;;;

;; add-new-node-at-center : World -> World
;; GIVEN: a World
;; RETURNS: the new world with node added  at center top
;; EXAMPLES:
;; 

;; STRATEGY: combine using simpler functions
(define (add-new-node-at-center-top ws)
  (make-world
   (cons
    (make-node NEW-NODE-CENTER-X NEW-NODE-CENTER-Y ZERO ZERO false empty)
    (world-nodes ws))))

;; make-world-with-changed-nodes : World KeyEvent -> World
;; GIVEN: current world and KeyEvent
;; WHERE: key event is between "n", "d" and "l"
;; RETURNS: the World after specified key event
;; EXAMPLES:
;; 

;; STARTEGY: combine using simpler functions
(define (make-world-with-changed-nodes ws ke)
  (make-world
   (append (nodes-after-key-event
            (get-selected-nodes (world-nodes ws)) ke)
           (get-unselected-nodes (world-nodes ws)))))

;; nodes-after-key-event : ListOfNode KeyEvent -> ListOfNode
;; GIVEN: a ListOfNode and key event
;; WHERE: node is selected and key event in between "n", "d"
;; RETURNS: the new ListOfNode with changed nodes according to the key event
;; EXAMPLES:
;;

;; STRATEGY: use HOF foldr, followed by HOF map on nodes
(define (nodes-after-key-event nodes ke)
  (foldr cons empty
         (map
          ;; Node -> Node
          ;; GIVEN: A Node
          ;; RETURNS: node after key event ke
          (lambda (node) (node-after-key-event node ke))
          nodes)))

;; node-after-key-event : Node KeyEvent -> Node
;; GIVEN: A Node and KeyEvent
;; WHERE: Node is selected and key event in between "n", "d"
;; RETURNS: the state of the node that should follow the given node after
;; the given key event
;; EXAMPLES:
;;                                                     

;; STRATEGY: using cases on KeyEvent ke 
(define (node-after-key-event node ke)
  (cond
    [(key=? BUTTON-N ke) (add-son-to-node node)]
    #;[(key=? BUTTON-D) (delete-node-with-all-children node)]))

;; add-son-to-node : Node -> Node
;; GIVEN: A Node
;; WHERE: the node is selected for adding new child
;; RETURNS: the node with added child
;; EXAMPLES:

;; STRATEGY: using template of Node on node
(define (add-son-to-node node)
  (make-node
   (node-x node) (node-y node) (node-dx node) (node-dy node)
   (node-selected? node) (add-chidren-to-right (node-children node) node)))

;; add-chidren-to-right : ListOfNode Node -> Node
;; GIVEN: A ListOfNode and Node
;; WHERE: ListOfNode is the child list of node
;; RETURNS: the new ListOfNode by adding new node as the first element
;; EXAMPLES:

;; STRATEGY: using template of Node on node
(define (add-chidren-to-right children node)
  (if (empty? children)
      (cons
       (make-node
        (+ (node-x node) NODE-DIST) (+ (node-y node) NODE-DIST)
        ZERO ZERO false empty) empty)
      (cons
       (make-node
        (+ (node-x (first children)) NODE-DIST) (+ (node-y node) NODE-DIST)
        ZERO ZERO false empty) children)))

;; get-selected-nodes : ListOfNode -> ListOfNode
;; GIVEN: a ListOfNode
;; WHERE: ListOfNode contains all nodes selected as well as unselected
;; RETURNS: list of selected nodes
;; EXAMPLES:
;; 

;; STRATEGY: use HOF filter on nodes
(define (get-selected-nodes nodes)
  (filter
   ;; Node -> Boolean
   ;; GIVEN: A Node
   ;; RETURNS: true iff node is selected
   (lambda (node) (node-selected? node))
   nodes))

;; get-unselected-nodes : ListOfNode -> ListOfNode
;; GIVEN: a ListOfNode
;; WHERE: ListOfNode contains all nodes selected as well as unselected
;; RETURNS: list of un-selected nodes
;; EXAMPLES:
;; 

;; STRATEGY: use HOF filter on nodes
(define (get-unselected-nodes nodes)
  (filter
   ;; Node -> Boolean
   ;; GIVEN: A Node
   ;; RETURNS: true iff the node is not selected
   (lambda (node) (not (node-selected? node)))
   nodes))

;; TESTS:
(begin-for-test
  (check set-equal?
         (node-children (node-after-key-event node-selected "n"))
         (node-children node-added-son))
  (check set-equal?
         (node-children (node-after-key-event node-added-son "n"))
         (node-children node-added-two-sons)))

;=========================================================================================
;; initial-world : Any -> World
;; GIVEN: any value
;; RETURNS: an initial world.  The given value is ignored.
;; EXAMPLES:
;; Get world at initial state
;; (initial-world ZERO) = initial-worldstate
(define (initial-world input)
  (make-world empty))