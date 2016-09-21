;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname trees-v1) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
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
(define-struct node (posn dx dy selected?))
;; A Node is a (make-node Posn Integer Integer Boolean)
;; INTERPRETATION:
;; posn is Posn (x, y) of the node
;; dx is a distance between x and x-coordinate mouse drag event (inside node)
;; dy is a distance between y and y-coordinate mouse drag event (inside node)
;; selected? represents whether the node is selected or not

;; TEMPLATE:
;; Node-fn : Node -> ??
#|(define (Node-fn n)
  ....
  (node-posn n)
  (node-dx n)
  (node-dy n)
  (node-selected? n)
  ....)|#

;; Nodes for testing
(define node-selected (make-node (make-posn 150 150) 0 0 true))
(define node-added-son (make-node (make-posn 150 150) 0 0 true))
(define node-added-two-sons (make-node (make-posn 150 150) 0 0 true))

(define node-1-selected (make-node (make-posn 250 10) 0 0 true))
(define node-2-selected (make-node (make-posn 280 40) 0 0 true))
(define node-3-selected (make-node (make-posn 310 40) 0 0 true))
(define node-1-unselected (make-node (make-posn 250 10) 0 0 false))
(define node-2-unselected (make-node (make-posn 280 40) 0 0 false))
(define node-3-unselected (make-node (make-posn 310 40) 0 0 false))
(define node-2-unselected-with-rel-dist (make-node (make-posn 280 40) 30 30 false))
(define node-3-unselected-with-rel-dist (make-node (make-posn 310 40) 60 30 false))

;; A List of Node (ListOfNode) is one of:
;; -- empty
;; -- (cons n ListOfNode)
;; INTERPRETATION:
;; empty represents the empty list
;; (cons n ListOfNode) represents the list of Node with newly added node c

;; TEMPLATE:
;; ListOfNode-fn -> ??
#|(define (ListOfNode-fn nodes)
  (cond
    [(empty? nodes) ... ]
    [else (... (first nodes)
               (ListOfNode-fn (rest nodes)))]))|#

(define-struct tree (root sons))
;; A Tree is a (make-tree Node ListOfNode)
;; INTERPRETATION:
;; root is a root node of the tree
;; sons is a ListOfTree for reprenting the children of the root

;; TEMPLATE:
;; Tree-fn : Tree -> ??
#|(define (Tree-fn t)
  ....
  (tree-root t)
  (tree-sons t)
  ....)|#

;; A List of Tree (ListOfTree) is one of:
;; -- empty
;; -- (cons t ListOfTree)
;; INTERPRETATION:
;; empty ListOfTree the empty list
;; (cons t ListOfTree) represents the list of Tree with newly added tree t

;; constants for testing
(define tree-1-selected (make-tree node-1-selected (list node-2-selected node-3-selected)))
(define tree-1-unselected (make-tree node-1-unselected (list node-2-unselected node-3-unselected)))
(define tree-1-root-selected (make-tree node-1-selected (list node-2-unselected-with-rel-dist
                                                              node-3-unselected-with-rel-dist)))
(define tree-2-selected (make-tree node-1-selected (list node-3-selected node-2-selected)))

(define-struct world (trees))
;; A World is a (make-world ListOfTrees)
;; INTERPRETATION:
;; trees is the list of Trees present in the world

;; TEMPLATE:
;; world-fn : World -> ??
#|(define (world-fn ws)
    ....
    (world-trees ws)
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
  (display-nodes (world-trees ws) MT-SCENE))

;; display-nodes : ListOfTree -> Image
;; GIVEN: a ListOfTree
;; RETURNS: the image with all the tree present on canvas
;; EXAMPLES:

;; STRATEGY: using template of ListOfTree on trees
#;(define (display-nodes trees)
  (cond
    [(empty? trees) MT-SCENE]
    [else (place-image (get-node-image (tree-root (first trees)))
                       (posn-x
                        (node-posn (tree-root (first trees))))
                       (posn-y
                        (node-posn (tree-root (first trees))))
                       (display-nodes (rest trees)))]))

;;
(define (display-node t scn)
  (cond
    [(node? t)
     (place-image
      (get-node-image t)
      (posn-x (node-posn t)) (posn-y (node-posn t))
      scn)]
    [else
     (place-image
      (get-node-image (tree-root t))
      (posn-x (node-posn (tree-root t))) (posn-y (node-posn (tree-root t)))
      (display-nodes (tree-sons t) scn))]))

;;
(define (display-nodes trees scn)
  (cond
    [(empty? trees) scn]
    [else (overlay
           (display-node (first trees) scn)
           (display-nodes (rest trees) scn))]))


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
      (make-world (tree-list-after-mouse-event (world-trees ws) mx my me))
      ws))

;;;; Helper functions for world-after-mouse-event ;;;;

;; tree-list-after-mouse-event :
;;                       ListOfTree NonNegInt NonNegInt MouseEvent -> ListOfTree
;; GIVEN: A ListOfTree, the x- and y-coordinates of a mouse event, and the mouse
;; event
;; RETURNS: the ListOfTree after the given mouse event

;; STRATEGY: use HOF foldr, followed by HOF map on trees
(define (tree-list-after-mouse-event trees mx my me)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: A Tree
          ;; RETURNS: Tree after mouse event me
          (lambda (tree) (tree-after-mouse-event tree mx my me))
          trees)))

;;
(define (tree-after-mouse-event tree mx my me)
  (cond
    [(mouse=? me BUTTON-DOWN) (select-node-from-tree tree mx my)]
    [(mouse=? me BUTTON-UP) (unselect-node-from-tree tree mx my)]
    [(mouse=? me DRAG) (drag-node-from-tree tree mx my)]
    [else tree]))

;;
(define (select-childs sons mx my)
  (cond
    [(empty? sons) empty]
    [(node? sons) (select-node-from-tree sons mx my)]
    [else
     (cons
      (select-node-from-tree (first sons) mx my)
      (select-childs (rest sons) mx my))]))

;;
(define (select-node-from-tree t mx my)
  (cond
    [(node? t)
     (if (cursor-in-node? (node-posn t) mx my)
         (select-node t mx my) t)]
    [(tree? t)
     (if (cursor-in-node? (node-posn (tree-root t)) mx my)
         (make-tree
          (select-node (tree-root t) mx my)
          (store-relative-dist-to-cursor (tree-sons t) mx my))
         (make-tree (tree-root t) (select-childs (tree-sons t) mx my)))]))

;;
#;(define (select-node-from-tree tree mx my)
  (cond
    [(node? tree)
     (if (cursor-in-node? (node-posn tree) mx my)
         (select-node tree mx my) tree)]
    [else
     (if (cursor-in-node? (node-posn (tree-root tree)) mx my)
         (make-tree
          (select-node (tree-root tree) mx my)
          (all-descendants (tree-sons tree) mx my))
         (make-tree (tree-root tree) (select-node-from-tree (tree-sons tree) mx my)))]))

;;
#|(define (select-sons-from-tree sons mx my)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: A Tree
          ;; RETURNS: Tree after mouse event button down
          (lambda (son) (select-node-from-tree son mx my))
          sons)))

;;
(define (all-descendants sons mx my)
  (cond
    [(empty? sons) empty]
    [(node? sons) (store-relative-dist-to-cursor sons mx my)]
    [else
     (append
           (store-relative-dist-to-cursor (first sons) mx my)
           (all-descendants (rest sons) mx my))]))

;;
(define (store-relative-dist-to-cursor t mx my)
  (cond
    [(node? t)
     (list
      (make-node
      (node-posn t)
      (- (posn-x (node-posn t)) mx)
      (- (posn-y (node-posn t)) my) false))]
    [else
     (append
      (make-node
       (node-posn (tree-root t))
       (- (posn-x (node-posn (tree-root t))) mx)
       (- (posn-y (node-posn (tree-root t))) my) false)
      (all-descendants (tree-sons t) mx my))]))
|#


(define (all-descendants sons mx my)
  (cond
    [(empty? sons) empty]
    [else
     (append
      (store-relative-dist-to-cursor (first sons) mx my)
      (all-descendants (rest sons) mx my))]))

(define (store-relative-dist-to-cursor son mx my)
  (cond
    [(empty? son) empty]
    [(node? son)
     (list
      (make-node
      (node-posn son)
      (- (posn-x (node-posn son)) mx)
      (- (posn-y (node-posn son)) my) false))]
    [(tree? son)
     (append
      (make-node
       (node-posn (tree-root son))
       (- (posn-x (node-posn (tree-root son))) mx)
       (- (posn-y (node-posn (tree-root son))) my) false)
      (all-descendants (tree-sons son) mx my))]))

;;
(define (unselect-node-from-tree tree mx my)
  (make-tree (unselect-node (tree-root tree))
             (unselect-sons-from-tree (tree-sons tree) mx my)))

;;
(define (unselect-sons-from-tree sons mx my)
  (foldr cons empty
         (map
          ;; Node -> Node
          ;; GIVEN: A Node
          ;; RETURNS: Node after mouse event button up
          (lambda (son) (unselect-node son))
          sons)))

(define (select-sons-from-tree sons mx my)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: A Tree
          ;; RETURNS: Tree after mouse event button down
          (lambda (son) (select-node-from-tree son mx my))
          sons)))

;;
(define (drag-node-from-tree tree mx my)
  (cond
    [(node? tree)
     (if (cursor-in-node? (node-posn tree) mx my)
         (drag-node tree mx my) tree)]
    [else
     (if (cursor-in-node? (node-posn (tree-root tree)) mx my)
         (make-tree
          (drag-node (tree-root tree) mx my)
          (all-descendants (tree-sons tree) mx my))
         (make-tree (tree-root tree) (select-sons-from-tree (tree-sons tree) mx my)))]))

;;
(define (drag-sons-from-tree sons mx my)
  (foldr cons empty
         (map
          ;; Node -> Node
          ;; GIVEN: A Node
          ;; RETURNS: Node after mouse event button up
          (lambda (son) (drag-node-from-tree son))
          sons)))

;; cursor-in-node? : Posn NonNegInt NonNegInt -> Boolean
;; GIVEN: A Posn, x and y coordinates of a mouse event
;; RETURNS: true iff any node from the list is selected for dragging
;; EXAMPLES:

(define (cursor-in-node? posn mx my)
  (<= (sqrt (+ (sqr (- mx (posn-x posn))) (sqr (- my (posn-y posn))))) NODE-RADIUS))

;; select-node : Node NonNegInt NonNegInt -> Node
;; GIVEN: A Node, x and y coordinates of a mouse event
;; WHERE: A Node is unselected
;; RETURNS: the node same as previous one but with selected flag true
;; EXAMPLES:
;;

;; STRATEGY: using template of Node on node
(define (select-node node mx my)
  (if (cursor-in-node? (node-posn node) mx my)
      (make-node
       (node-posn node)
       (- (posn-x (node-posn node)) mx) (- (posn-y (node-posn node)) my) true)
      (unselect-node node)))

;; unselect-node : Node -> Node
;; GIVEN: A Node
;; WHERE: A Node is selected
;; RETURNS: the node same as previous one but with selected flag false
;; EXAMPLES:
;; 

;; STRATEGY: using template of Node on node
(define (unselect-node node)
  (cond
    [(tree? node)
     (make-tree
      (make-node (node-posn (tree-root node)) ZERO ZERO false)
      (tree-sons node))]
    [else
     (make-node (node-posn node) ZERO ZERO false)]))

;; drag-node : Node NonNegInt NonNegInt -> Node
;; GIVEN: A Node, x and y coordinate of mouse
;; WHERE: A Node is selected
;; RETURNS: the Node same as previous one, but changed center coordinates
;; EXAMPLES:
;; 

;; STRATEGY: using template of Node on node
(define (drag-node node mx my)
  (if (cursor-in-node? (node-posn node) mx my)
      (make-node
       (make-posn
        (+ mx (node-dx node)) (+ my (node-dy node)))
       (node-dx node) (node-dy node)
       true)
      (unselect-node node)))

;; TESTS:
#;(begin-for-test
  (check-equal? (unselect-node-from-tree tree-1-selected 300 200) tree-1-unselected)
  (check-equal? (select-node-from-tree tree-1-unselected 250 10) tree-1-root-selected)
  (check-equal? (drag-node-from-tree tree-1-unselected 250 10) tree-1-root-selected))

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
    (make-tree
     (make-node (make-posn NEW-NODE-CENTER-X NEW-NODE-CENTER-Y) ZERO ZERO false) empty)
    (world-trees ws))))

;; make-world-with-changed-nodes : World KeyEvent -> World
;; GIVEN: current world and KeyEvent
;; WHERE: key event is between "n", "d" and "l"
;; RETURNS: the World after specified key event
;; EXAMPLES:
;; 

;; STARTEGY: combine using simpler functions
(define (make-world-with-changed-nodes ws ke)
  (make-world
   (trees-after-key-event (world-trees ws) ke)))

;; trees-after-key-event : ListOfNode KeyEvent -> ListOfNode
;; GIVEN: a ListOfNode and key event
;; WHERE: node is selected and key event in between "n", "d"
;; RETURNS: the new ListOfNode with changed nodes according to the key event
;; EXAMPLES:
;;

;; STRATEGY: use HOF foldr, followed by HOF map on nodes
(define (trees-after-key-event nodes ke)
  (foldr cons empty
         (map
          ;; Node -> Node
          ;; GIVEN: A Node
          ;; RETURNS: node after key event ke
          (lambda (node) (tree-after-key-event node ke))
          nodes)))

;; tree-after-key-event : Node KeyEvent -> Node
;; GIVEN: A Node and KeyEvent
;; WHERE: Node is selected and key event in between "n", "d"
;; RETURNS: the state of the node that should follow the given node after
;; the given key event
;; EXAMPLES:
;;                                                     

;; STRATEGY: using cases on KeyEvent ke 
(define (tree-after-key-event node ke)
  (cond
    [(key=? BUTTON-N ke) (add-son-to-selected-roots node)]
    #;[(key=? BUTTON-D) (delete-node-with-all-children node)]))

;; add-son-to-selected-roots : Node -> Node
;; GIVEN: A Node
;; WHERE: the node is selected for adding new child
;; RETURNS: the node with added child
;; EXAMPLES:

;; STRATEGY: using template of Node on node
(define (add-son-to-selected-roots tree)
  (cond
    [(node? tree)
     (cons (make-tree tree (add-chidren-to-right empty tree)) empty)]
    [else
     (if (node-selected? (tree-root tree))
      (make-tree
       (tree-root tree)
       (add-chidren-to-right (tree-sons tree) (tree-root tree)))
      (make-tree
       (tree-root tree)
       (add-son-if-children-selected (tree-sons tree))))]))

;;
(define (add-son-if-children-selected sons)
  (cond
    [(empty? sons) empty]
    [(tree? sons)
     (cons (add-son-to-selected-roots (tree-root sons)) empty)]
    [else
     (append
      (add-son-to-selected-roots (first sons))
      (add-son-if-children-selected (rest sons)))]))

;; add-son-to-root : Node -> Node
;; GIVEN: A Node
;; WHERE: the node is selected for adding new child
;; RETURNS: the node with added child
;; EXAMPLES:
(define (add-son-to-root node)
  (cond
    [(node? node)
     (make-tree node (add-chidren-to-right empty node))]
    [else
     (make-tree
      (make-node
       (node-posn (tree-root node)) (node-dx (tree-root node)) (node-dy (tree-root node))
       (node-selected? (tree-root node)))
      (add-chidren-to-right (tree-sons node) node))]))

;; add-chidren-to-right : ListOfNode Node -> Node
;; GIVEN: A ListOfNode and Node
;; WHERE: ListOfNode is the child list of node
;; RETURNS: the new ListOfNode by adding new node as the first element
;; EXAMPLES:

;; STRATEGY: using template of Node on node
(define (add-chidren-to-right sons node)
  (if (empty? sons)
      (cons
       (make-node
        (make-posn
         (+ (posn-x (node-posn node)) NODE-DIST) (+ (posn-y (node-posn node)) NODE-DIST))
        ZERO ZERO false) empty)
      (cons
       (make-node
        (make-posn
         (+ (posn-x (node-posn node)) NODE-DIST) (+ (posn-y (node-posn node)) NODE-DIST))
        ZERO ZERO false)
       sons)))

;; TESTS:
(begin-for-test
  #;(check-equal? (all-seleted-roots tree-1-root-selected) (list node-1-selected))
  #;(check-equal? (add-son-to-selected-roots tree-2-selected)))

;=========================================================================================
;; initial-world : Any -> World
;; GIVEN: any value
;; RETURNS: an initial world.  The given value is ignored.
;; EXAMPLES:
;; Get world at initial state
;; (initial-world ZERO) = initial-worldstate
(define (initial-world input)
  (make-world empty))

;=========================================================================================
;; world-to-trees : World -> ListOfTree
;; GIVEN: a World
;; RETURNS: a list of all the trees in the given world.
;; EXAMPLES:
;;
(define (world-to-trees ws)
  (world-trees ws))

;=========================================================================================
;; tree-to-root : Tree -> Node
;; GIVEN: a tree
;; RETURNS: the node at the root of the tree
;; EXAMPLES:
;;
(define (tree-to-root t)
  (tree-root t))

;=========================================================================================
;; tree-to-sons : Tree -> ListOfTree
;; GIVEN: a tree
;; RETURNS: sons of the tree
;; EXAMPLES:
;;
(define (tree-to-sons t)
  (tree-sons t))

;=========================================================================================
;; node-to-center : Node -> Posn
;; GIVEN: A Node
;; RETURNS: the center of the given node as it is to be displayed on the
;; scene.
;; EXAMPLES:
;;
(define (node-to-center n)
  (node-posn n))