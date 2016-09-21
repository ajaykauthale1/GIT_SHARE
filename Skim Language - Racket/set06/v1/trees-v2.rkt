;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname trees-v2) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Program for trees simulation

;(check-location "05" "screensaver-5.rkt")

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

(provide initial-world run world-after-mouse-event world-after-key-event world-to-trees
           tree-to-root tree-to-sons node-to-center node-to-selected?)

;=========================================================================================
;                                      CONSTANTS
;=========================================================================================
;; constant for displaying canvas
(define MT-SCENE (empty-scene 500 400))
;; constant for deleting the trees
(define CANVAS-X 250)
;; constant for node circle radius
(define NODE-RADIUS 30)
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
(define-struct node (posn mouse-posn parent-posn selected?))
;; A Node is a (make-node Posn Posn Posn Boolean)
;; INTERPRETATION:
;; posn - is Posn (x, y) of the node, where x and y are center coordinates of node
;; mouse-posn - is Posn (x, y), where x and y coordinates of the mouse event
;; parent-posn - is Posn (x, y), where x and y are center coordinates of the parent
;;               of the node
;; selected? - represents whether the node is selected or not

;; TEMPLATE:
;; node-fn : Node -> ??
#|(define (node-fn n)
  ....
  (node-posn n)
  (node-mouse-posn n)
  (node-parent-posn n)
  (node-selected? n)
  ....)|#

;; Nodes for testing
(define node-selected
  (make-node
   (make-posn 150 150) (make-posn 0 0) (make-posn 0 0) true))
(define node-1-selected
  (make-node
   (make-posn 250 10) (make-posn 0 0) (make-posn 0 0) true))
(define node-1-after-drag
  (make-node
   (make-posn 250 40) (make-posn 0 0) (make-posn 0 0) true))
(define node-2-selected
  (make-node
   (make-posn 280 40) (make-posn 0 0) (make-posn 250 10) true))
(define node-3-selected
  (make-node
   (make-posn 310 40) (make-posn 0 0) (make-posn 250 10) true))
(define node-1-unselected
  (make-node
   (make-posn 250 10) (make-posn 0 0) (make-posn 0 0) false))
(define node-2-unselected
  (make-node
   (make-posn 280 40) (make-posn 0 0) (make-posn 250 10) false))
(define node-3-unselected
  (make-node
   (make-posn 310 40) (make-posn 0 0) (make-posn 250 10) false))

;; A List of Node (ListOfNode) is one of:
;; -- empty
;; -- (cons n ListOfNode)
;; INTERPRETATION:
;; empty represents the empty list
;; (cons n ListOfNode) represents the list of Node with newly added node n

;; TEMPLATE:
;; listOfNode-fn : ListOfNode -> ??
#|(define (listOfNode-fn nodes)
  (cond
    [(empty? nodes) ... ]
    [else (... (first nodes)
               (listOfNode-fn (rest nodes)))]))|#

(define-struct tree (root sons))
;; A Tree is a (make-tree Node ListOfTree)
;; INTERPRETATION:
;; root is a root node of the tree
;; sons is a ListOfTree for reprenting the children of the root, where each son might
;; be another tree with some sons or empty sons

;; TEMPLATE:
;; tree-fn : Tree -> ??
#|(define (tree-fn t)
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

;; TEMPLATE:
;; listOfTree-fn : ListOfTree -> ??
#|(define (listOfTree-fn trees)
  (cond
    [(empty? trees) ... ]
    [else (... (first trees)
               (listOfTree-fn (rest trees)))]))|#


;; constants for testing
(define tree-1-selected
  (make-tree node-1-selected
             (list (make-tree node-2-selected empty) (make-tree node-3-selected empty))))
(define tree-1-unselected
  (make-tree node-1-unselected
             (list
              (make-tree node-2-unselected empty) (make-tree node-3-unselected empty))))
(define tree-1-first-son-selected
  (make-tree node-1-unselected
             (list
              (make-tree node-2-selected empty) (make-tree node-3-unselected empty))))
(define tree-2-selected
  (make-tree node-1-selected
             (list (make-tree node-2-selected empty) (make-tree node-3-selected empty))))
(define tree-1-root-selected
  (make-tree node-1-selected
             (list (make-tree node-2-unselected empty) (make-tree node-3-unselected empty))))

(define-struct world (trees))
;; A World is a (make-world ListOfTree)
;; INTERPRETATION:
;; trees is the list of Trees present in the world

;; TEMPLATE:
;; world-fn : World -> ??
#|(define (world-fn ws)
    ....
    (world-trees ws)
    ....)|#

;; constants for testing
(define initial-worldstate (make-world empty))
(define world-with-tree-at-center
  (make-world
   (list (make-tree
          (make-node (make-posn 250 10) (make-posn 0 0) (make-posn 0 0) false)
          empty))))
(define world-with-tree-root-selected
  (make-world (list tree-1-root-selected)))
(define world-with-no-root-selected (make-world (list tree-1-unselected)))

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
;; RETURNS: the image depicting the current World
;; EXAMPLES:
#| (world->scene world-with-tree-at-center) =
(place-image NODE-CIRCLE 250 10 MT-SCENE)

(world->scene world-with-tree-root-selected) =
 (display-all-branches (world-trees world-with-tree-root-selected)
 (display-all-trees (world-trees world-with-tree-root-selected)))|#

;; STRATEGY: using template of world on ws
(define (world->scene ws)
  (display-all-trees (world-trees ws)
                     MT-SCENE))

;; display-all-trees : ListOfTrees Image -> Image
;; GIVEN: a ListOfTree, and Image
;; RETURNS: the image of all trees drawn on the canvas
;; EXAMPLES:
#| (display-all-trees (list (make-tree
       (make-node
         (make-posn 250 10) (make-posn 0 0) (make-posn 0 0) true) empty))
= (place-image NODE-CIRCLE 250 10 MT-SCENE)|#

;; STRATEGY: using template of ListOfTree on trees
(define (display-all-trees trees scn)
  (cond
    [(empty? trees) scn]
    [else
     (display-all-trees (rest trees)
      (place-tree (first trees) scn))]))

;; descendants : tree -> ListOfNode
;; GIVEN: a Tree
;; RETURNS: a list of all nodes in the tree (including root)
;; EXAMPLES:
;; (descendants tree-1-selected) = (list node-1-selected node-2-selected node-3-selected)

;; STRATEGY: using template of Tree on t
(define (descendants t)
  (append
   (list (tree-root t))
   (all-descendants (tree-sons t))))

;; all-descendants : ListOfTree -> ListOfNode
;; GIVEN: a ListOfTree
;; RETURNS: a list of all root nodes of all trees
;; EXAMPLES:
;; (all-descendants (tree-sons tree-1-selected)) = (list node-2-selected node-3-selected)

;; STRATEGY: using HOF foldr, followed by HOF map on sons
(define (all-descendants sons)
  (foldr
   append empty
   (map
    ;; Tree -> ListOfNode
    ;; GIVEN: a Tree
    ;; RETURNS: a list of all sons
    (lambda (son) (descendants son))
    sons)))


;; get-list-of-node-images : ListOfNode -> ListOfImage
;; GIVEN: a ListOfNode
;; RETURNS: the list of images based on the selection, if selected then solid image,
;; otherwise outlined image
;; EXAMPLES:
#| (get-list-of-node-images (list node-1-selected node-2-unselected)) =
                                      (list SELECTED-NODE-CIRCLE NODE-CIRCLE)|#

;; STRATEGY: using HOF foldr, followed by HOF map on nodes
(define (get-list-of-node-images nodes scn)
  (foldr
   append empty
   (map
    ;; Node -> ListOfImage
    ;; GIVEN: a Node
    ;; RETURNS: a list of image for the node
    (lambda (node) (list (scene+line (place-image (get-node-image node)
                                                  (posn-x (node-posn node))
                                                  (posn-y (node-posn node)) scn)
                                     (posn-x (node-posn node)) (posn-y (node-posn node))
                                     (posn-x (node-parent-posn node))
                                     (posn-y (node-parent-posn node)) "blue")))
    nodes)))

;; get-node-image : Node -> Image
;; GIVEN: a Node
;; RETURNS: image of the node on basis of selected flag
;; EXAMPLES:
;; (get-node-image node-1-selected) = SELECTED-NODE-CIRCLE

;; STRATEGY: using template of Node on node
(define (get-node-image node)
  (if (node-selected? node)
      SELECTED-NODE-CIRCLE
      NODE-CIRCLE))

;; get-list-of-posn : ListOfNode -> ListOfPosn
;; GIVEN: a ListOfNode
;; RETURNS: a list of node positions
;; EXAMPLES:
#| (get-list-of-posn (list node-1-selected node-2-selected)) =
(list (make-posn 250 10) (make-posn 280 40))|#

;; STRATEGY: using HOF foldr, followed by HOF map on nodes
(define (get-list-of-posn nodes)
  (foldr
   append empty
   (map
    ;; Node -> ListOfPosn
    ;; GIVEN: a Node
    ;; RETURNS: a list of pons for the node
    (lambda (node) (list (node-posn node)))
    nodes)))

;; display-all-branches: ListOfTree Image -> Image
;; GIVEN: a ListOfTree and Image
;; RETURNS: Image containing trees with branches
;; EXAMPLES:
#| (display-all-branches (list tree-1-unselected tree-2-selected) MT-SCENE) =
(scene+line
 (scene+line
  (scene+line
   (scene+line MT-SCENE 280 40 250 10 "blue") 310 40 250 10 "blue")
  280 40 250 10 "blue")
 310 40 250 10 "blue")|#

;; STRATEGY: using template of ListOfTree on trees, then using template of tree
;; on (first trees)
(define (display-all-branches trees scn)
  (cond
    [(empty? trees) scn]
    [else
     (display-all-branches
      (rest trees)
      (place-all-nodes-branches
       (all-descendants (tree-sons (first trees))) scn))]))

;; place-all-branches : ListOfNode Image -> Image
;; GIVEN: a ListOfNode and Image
;; RETURNS: Image with lines drawn from child node center to parent node center
;; EXAMPLES:
#| (place-all-branches (list node-2-unselected node-3-unselected) MT-SCENE) =
   (scene+line
      (scene+line MT-SCENE 280 40 250 10 "blue") 310 40 250 10 "blue")|#

;; STRATEGY: using template of ListOfNode on nodes, further using template of
;; node on (first nodes)
(define (place-all-nodes-branches nodes scn)
  (cond
    [(empty? nodes) scn]
    [else
     (place-all-nodes-branches
      (rest nodes)
      (scene+line scn
                  (posn-x (node-posn (first nodes)))
                  (posn-y (node-posn (first nodes)))
                  (posn-x (node-parent-posn (first nodes)))
                  (posn-y (node-parent-posn (first nodes)))
                  "blue"))]))

;/////////////////////////////////////////////////////////////////

;; place-tree : Tree Image -> Image
(define (place-tree tree scn)
  (place-sons (tree-sons tree) (place-root (tree-root tree) scn)))

;; place-sons : ListOfTree Image -> Image
(define (place-sons sons scn)
  (cond
    [(empty? sons) scn]
    [else
     (place-sons (rest sons) (place-tree (first sons) scn))]))

;; place-line : Node Image -> Image
(define (place-root root scn)
  (if (node-selected? root)
      (place-image SELECTED-NODE-CIRCLE
                   (posn-x (node-posn root)) (posn-y (node-posn root))
                   (place-line root scn))
      (place-image NODE-CIRCLE
                   (posn-x (node-posn root)) (posn-y (node-posn root))
                   (place-line root scn))))

;; place-line : Node Image -> Image
(define (place-line node scn)
  (scene+line scn
                  (posn-x (node-posn node))
                  (posn-y (node-posn node))
                  (posn-x (node-parent-posn node))
                  (posn-y (node-parent-posn node))
                  "blue"))
;/////////////////////////////////////////////////////////////////

;; TESTS:
#;(begin-for-test
  (check set-equal? (descendants tree-1-selected)
         (list node-1-selected node-2-selected node-3-selected))
  (check set-equal? (all-descendants (tree-sons tree-1-selected))
         (list node-2-selected node-3-selected))
  (check-equal? (get-list-of-node-images (list node-1-selected node-2-unselected)) 
                (list SELECTED-NODE-CIRCLE NODE-CIRCLE))
  (check-equal? (get-list-of-posn (list node-1-selected node-2-selected))
                (list (make-posn 250 10) (make-posn 280 40)))
  (check-equal? (world->scene world-with-tree-at-center) 
                (place-image NODE-CIRCLE 250 10 MT-SCENE))
  (check-equal? (place-all-nodes-branches
                 (list node-2-unselected node-3-unselected) MT-SCENE)
                (scene+line
                 (scene+line MT-SCENE 280 40 250 10 "blue")
                 310 40 250 10 "blue"))
  (check-equal? (display-all-branches (list tree-1-unselected tree-2-selected) MT-SCENE)
                (scene+line
                 (scene+line
                  (scene+line
                   (scene+line MT-SCENE 280 40 250 10 "blue") 310 40 250 10 "blue")
                  280 40 250 10 "blue")
                 310 40 250 10 "blue")))

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
     (add-new-tree-at-center-top ws)]
    [(or (key=? ke BUTTON-N) (key=? ke BUTTON-D) (key=? ke BUTTON-L))
     (make-world-with-changed-nodes ws ke)]
    [else ws]))

;;;; Helper functions for world-after-key-event ;;;;

;; add-new-tree-at-center-top : World -> World
;; GIVEN: a World
;; RETURNS: the world with newly added tree at the centre of it, tree will be created
;; with root node and empty sons
;; EXAMPLES:
;; (add-new-tree-at-center-top initial-worldstate) = world-with-tree-at-center

;; STRATEGY: using template of world on ws
(define (add-new-tree-at-center-top ws)
  (make-world
   (cons
    (make-tree
     (make-node
      (make-posn NEW-NODE-CENTER-X NEW-NODE-CENTER-Y)
      (make-posn 0 0) (make-posn 0 0) false) empty)
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

;; trees-after-key-event : ListOfTree KeyEvent -> ListOfTree
;; GIVEN: a ListOfTree and key event
;; WHERE: node is selected and key event in between "n", "d"
;; RETURNS: the new ListOfNode with changed nodes according to the key event
;; EXAMPLES:
;;

;; STRATEGY: use HOF foldr, followed by HOF map on trees
(define (trees-after-key-event trees ke)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: A Tree
          ;; RETURNS: Tree after key event ke
          (lambda (tree) (tree-after-key-event tree ke))
          trees)))

;; tree-after-key-event : Node KeyEvent -> Node
;; GIVEN: A Node and KeyEvent
;; WHERE: Node is selected and key event in between "n", "d"
;; RETURNS: the state of the node that should follow the given node after
;; the given key event
;; EXAMPLES:
;;                                                     

;; STRATEGY: using cases on KeyEvent ke 
(define (tree-after-key-event tree ke)
  (cond
    [(key=? BUTTON-N ke) (add-son-to-selected-root tree)]
    [(key=? BUTTON-D ke) (delete-node-with-all-children tree BUTTON-D)]
    [(key=? BUTTON-L ke) (delete-all-left-nodes tree BUTTON-L)]))

;; delete-node-with-all-children : Tree -> Tree
(define (delete-node-with-all-children tree be)
  (if (or (node-selected? (tree-root tree)) (string=? be BUTTON-L))
      (make-tree (make-node (make-posn 0 0)
                            (make-posn -10 -10)
                            (make-posn -10 -10)
                            false) empty)
      (make-tree
       (tree-root tree)
       (delete-node-from-sons (tree-sons tree) be))))

;; delete-node-from-sons : ListOfTree -> ListOfTree
(define (delete-node-from-sons sons be)
  (cond
    [(empty? sons) empty]
    [else
     (cons
      (delete-node-with-all-children (first sons) be)
      (delete-node-from-sons (rest sons) be))]))

;; add-son-to-selected-root : Tree -> Tree
;; GIVEN: A Node
;; WHERE: the node is selected for adding new child
;; RETURNS: the node with added child
;; EXAMPLES:

;; STRATEGY: using template of Node on node
(define (add-son-to-selected-root tree)
  (if (node-selected? (tree-root tree))
      (make-tree (tree-root tree)
                 (add-chidren-to-right (tree-sons tree) (node-posn (tree-root tree))))
      (make-tree (tree-root tree)
                 (add-son-to-selected-roots (tree-sons tree)))))

;; add-son-to-selected-roots : ListOfTree -> ListOfTree
(define (add-son-to-selected-roots sons)
  (cond
    [(empty? sons) empty]
    [else
     (cons
      (add-son-to-selected-root (first sons))
      (add-son-to-selected-roots (rest sons)))]))

;; add-chidren-to-right : ListOfTree Posn -> ListOfTree
(define (add-chidren-to-right sons posn)
  (if (empty? sons)
      (cons (make-tree
             (make-node (make-posn (posn-x posn) (+ NODE-DIST (posn-y posn)))
                        (make-posn -1 -1)
                        posn false) empty) sons)
      (cons (make-tree
             (make-node (make-posn
                         (+ NODE-DIST (posn-x (node-posn (tree-root (first sons)))))
                         (+ NODE-DIST (posn-y posn)))
                        (make-posn -1 -1)
                        posn false) empty) sons)))

;; delete-all-left-nodes : Tree -> Tree
(define (delete-all-left-nodes tree be)
  (if (<= (posn-x (node-posn (tree-root tree))) 250)
      (delete-node-with-all-children tree be)
      (delete-node-from-sons (tree-sons tree) be)))

;; TESTS:
(begin-for-test
  (check-equal? (add-new-tree-at-center-top initial-worldstate) world-with-tree-at-center))

;=========================================================================================
;; world-after-mouse-event : World Integer Integer MouseEvent -> World
;; GIVEN: a World, a location, and a MouseEvent
;; RETURNS: the state of the world as it should be following the given mouse event at
;; that location.
;; EXAMPLES:
#| (world-after-mouse-event world-with-no-root-selected 280 40 BUTTON-DOWN) = 
   (make-world (list tree-1-first-son-selected))

   (world-after-mouse-event world-with-tree-root-selected 280 40 BUTTON-UP) = 
   (make-world (list tree-1-unselected)) |#

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
;; EXAMPLES:
#| (tree-list-after-mouse-event (list tree-1-unselected) 280 40 BUTTON-DOWN) =
   (list tree-1-first-son-selected) |#

;; STRATEGY: use HOF foldr, followed by HOF map on trees
(define (tree-list-after-mouse-event trees mx my me)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: A Tree
          ;; RETURNS: Tree after mouse event me
          (lambda (tree) (tree-after-mouse-event tree mx my me))
          trees)))

;; tree-after-mouse-event : Tree NonNegInt NonNegInt MouseEvent -> Tree
;; GIVEN: a Tree, x and y coordinates of the mouse event and mouse event
;; RETURNS: the tree after the mouse event
;; EXAMPLES:
#| (tree-after-mouse-event tree-1-unselected 280 40 BUTTON-DOWN) =
   tree-1-first-son-selected

  (tree-after-mouse-event tree-1-first-son-selected 280 40 BUTTON-UP) = tree-1-unselected
  (tree-after-mouse-event tree-1-unselected 280 40 ENTER) = tree-1-unselected |#

;; STRATEGY: using cases on mouse event me
(define (tree-after-mouse-event tree mx my me)
  (cond
    [(mouse=? me BUTTON-DOWN) (select-node-from-tree tree mx my)]
    [(mouse=? me BUTTON-UP) (unselect-all-nodes-from-tree tree mx my)]
    [(mouse=? me DRAG) (drag-node-from-tree tree mx my)]
    [else tree]))

;; select-node-from-tree : Tree NonNegInt NonNegInt -> Tree
;; GIVEN: a Tree, and x and y co-ordinates of the mouse event
;; WHERE: mouse event is button-down
;; RETURNS: the tree similar to previous one, but selected node will have
;; selected? flag true
;; EXAMPLES:
;; (select-node-from-tree tree-1-unselected 280 40) = tree-1-first-son-selected

;; STRATEGY: using template of Tree on tree
(define (select-node-from-tree tree mx my)
  (if (cursor-in-node? (node-posn (tree-root tree)) mx my)
      (make-tree
       (root-after-select (tree-root tree) mx my)
       (select-node-from-sons (tree-sons tree) mx my))
      (make-tree
       (tree-root tree)
       (select-node-from-sons (tree-sons tree) mx my))))

;; select-node-from-sons : ListOfTree NonNegInt NonNegInt -> ListOfTree
;; GIVEN: a ListOfTree, and x and y co-ordinates of the mouse event
;; RETURNS: the list of trees same as previous one, but if any of the son's root
;; is selected then selected? flag for same will be true
;; EXAMPLES:
#| (select-node-from-sons (tree-sons tree-1-unselected) 250 10) =
 (tree-sons tree-1-unselected)

 (select-node-from-sons (tree-sons tree-1-unselected) 280 40) =
 (list
 (make-tree (make-node (make-posn 280 40)
                       (make-posn -280 -40) (make-posn 250 10)) '())
 (make-tree (make-node (make-posn 310 40)
                       (make-posn 0 0) (make-posn 250 10)) '()))|#

;; STRATEGY: using HOF foldr, followed by HOF map on sons
(define (select-node-from-sons sons mx my)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: a Tree
          ;; RETURNS: tree same as previous one, but if root
          ;; is selected then selected? flag for same will be true
          (lambda (son) (select-node-from-tree son mx my))
          sons)))

;; cursor-in-node? : Posn NonNegInt NonNegInt -> Boolean
;; GIVEN: A Posn, x and y coordinates of a mouse event
;; RETURNS: true iff any node from the list is selected for dragging
;; EXAMPLES:
;; (cursor-in-node? (node-posn node-1-unselected) 250 10) = true

;; STRATEGY: combine using simpler functions
(define (cursor-in-node? posn mx my)
  (<= (sqrt (+ (sqr (- mx (posn-x posn))) (sqr (- my (posn-y posn))))) NODE-RADIUS))

;; root-after-select : Node NonNegInt NonNegInt -> Node
;; GIVEN: a Node, and x and y coordinates of the mouse event
;; RETURNS: the node same as previous, but with selected flag is true and mouse position
;; distance added into it
;; EXAMPLES:
#| (root-after-select node-1-unselected 50 50) =
                (make-node (node-posn node-1-unselected)
                           (make-posn
                            (- (posn-x (node-posn node-1-unselected)) 50)
                            (- (posn-y (node-posn node-1-unselected)) 50))
                           (node-parent-posn node-1-unselected)
                           true))
|#

;; STRATEGY: using template of Node on root
(define (root-after-select root mx my)
  (make-node (node-posn root)
             (make-posn mx my) (node-parent-posn root) true))

;; unselect-all-nodes-from-tree : Tree NonNegInt NonNegInt -> Tree
;; GIVEN: a Tree, and mouse position
;; RETURNS: same tree as previous one, but selected? flag of all the nodes will be false
;; EXAMPLES:
;; (unselect-all-nodes-from-tree tree-1-first-son-selected) = tree-1-unselected

;; STRATEGY: using template of Tree on tree
(define (unselect-all-nodes-from-tree tree mx my)
  (make-tree
   (root-after-unselect (tree-root tree) mx my)
   (unselect-node-from-sons (tree-sons tree) mx my)))

;; unselect-node-from-sons : ListOfTree NonNegInt NonNegInt -> ListOfTree
;; GIVEN: a ListOfTree, and mouse position
;; RETURNS: the list of tree with all nodes are un-selected
;; EXAMPLES:
;; (unselect-node-from-sons (list tree-1-first-son-selected)) = (list tree-1-unselected)

;; STRATEGY: using HOF foldr, followed by HOF map on sons
(define (unselect-node-from-sons sons mx my)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: a Tree
          ;; RETURNS: tree same as previous one, but if root
          ;; is selected then selected? flag for same will be false
          (lambda (son) (unselect-all-nodes-from-tree son mx my))
          sons)))

;; root-after-unselect : Node NonNegInt NonNegInt -> Node
;; GIVEN: a Node, and x and y coordinates of the mouse event
;; RETURNS: the node same as previous, but with selected flag is false and mouse position
;; distance become 0 for x and y axis
;; EXAMPLES:
;; (root-after-unselect node-1-selected) = node-1-unselected

;; STRATEGY: using template of Node on roor
(define (root-after-unselect root mx my)
  (make-node (node-posn root) (make-posn mx my) (node-parent-posn root) false))

;; drag-node-from-tree : Tree NonNegInt NonNegInt -> Tree
;; GIVEN: a Tree, and x and y coordinates of the mouse event
;; WHERE: mouse event is drag
;; RETURNS: the tree after the drag event
;; EXAMPLES:

;; STRATEGY: using template of Tree on tree
(define (drag-node-from-tree tree mx my)
  (if (cursor-in-node? (node-posn (tree-root tree)) mx my)
      (make-tree
       (root-after-drag (tree-root tree) mx my)
       (drag-all-sons (tree-sons tree)
                      (node-posn (root-after-drag (tree-root tree) mx my))))
      (make-tree
       (tree-root tree)
       (drag-node-from-sons (tree-sons tree) mx my))))

;; drag-node-from-sons : ListOfTree NonNegInt NonNegInt -> ListOfTree
;; GIVEN: a ListOfTree, and and x and y coordinates of the mouse event
;; RETURNS: a list of trees (sons) after the drag event
;; EXAMPLES:

;; STRATEGY: using HOF foldr, followed by HOF map on sons
(define (drag-node-from-sons sons mx my)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: a Tree
          ;; RETURNS: tree after the drag event
          (lambda (son) (drag-node-from-tree son mx my))
          sons)))

;; drag-son : Tree Posn -> Tree
;; GIVEN: a Tree, and new root position
;; RETURNS: a Tree with the child nodes (sons) are dragged
;; EXAMPLES:

;; STRATEGY: using template of Tree on son
(define (drag-son son root-posn)
  (make-tree
   (son-after-drag (tree-root son) root-posn)
   (drag-all-sons (tree-sons son) (node-posn (tree-root son)))))


;; drag-all-sons : ListOfTree Posn -> ListOfTree
;; GIVEN: a ListOfTree, and root new root position
;; RETURNS: list of tree with center coordinates of the roots are changed
;; EXAMPLES:
#|(drag-all-sons (tree-sons tree-1-root-selected) 0 0) =
                (tree-sons tree-1-root-selected) |#

;; STRATEGY: using HOF foldr, followed by HOF map on sons
(define (drag-all-sons sons root-posn)
  (foldr cons empty
         (map
          (lambda (son) (drag-son son root-posn))
          sons)))


;; son-after-drag : Node Posn -> Node
;; GIVEN: a Node, and root position
;; RETURNS: a node with changed coordinates after drag event
;; EXAMPLES:
;; (son-after-drag node-1-selected 0 0) = node-1-selected

;; STRATEGY: using template of Node on root
(define (son-after-drag son root-posn)
  (make-node (make-posn
              (+ (posn-x (node-posn son)) (- (posn-x root-posn) (posn-x (node-parent-posn son))))
              (+ (posn-y (node-posn son)) (- (posn-y root-posn) (posn-y (node-parent-posn son)))))
             (node-mouse-posn son)
             root-posn
             (node-selected? son)))

;; root-after-drag : Node NonNegInt NonNegInt -> Node
;; GIVEN: a Node
;; RETURNS: a node with changed coordinates after drag event
;; EXAMPLES:
;; (root-after-drag node-1-selected 250 40) = node-1-after-drag

;; STRATEGY: using template of Node on root
(define (root-after-drag root mx my)
  (if (node-selected? root)
      (make-node (make-posn
                  ( + (posn-x (node-posn root))
                      (- mx (posn-x (node-mouse-posn root))))
                  ( + (posn-y (node-posn root))
                      (- my (posn-y (node-mouse-posn root)))))
                 (make-posn mx my)
                 (node-parent-posn root)
                 (node-selected? root))
      root))

;; TESTS:
#;(begin-for-test
    (check-equal? (root-after-select node-1-unselected 50 50) 
                  (make-node (node-posn node-1-unselected)
                             (make-posn
                              (- (posn-x (node-posn node-1-unselected)) 50)
                              (- (posn-y (node-posn node-1-unselected)) 50))
                             (node-parent-posn node-1-unselected)
                             true))
    (check-equal? (cursor-in-node? (node-posn node-1-unselected) 250 10) true)
    (check-equal? (select-node-from-sons (tree-sons tree-1-unselected) 250 10)
                  (tree-sons tree-1-unselected))
    (check-equal? (select-node-from-sons (tree-sons tree-1-unselected) 280 40)
                  (list
                   (make-tree
                    (make-node (make-posn 280 40)
                               (make-posn 0 0) (make-posn 250 10) #true) '())
                   (make-tree
                    (make-node (make-posn 310 40)
                               (make-posn 0 0) (make-posn 250 10) #false) '())))
    (check-equal? (select-node-from-tree tree-1-unselected 280 40)
                  tree-1-first-son-selected)
    (check-equal?  (tree-after-mouse-event tree-1-unselected 280 40 BUTTON-DOWN)
                   tree-1-first-son-selected)
    (check-equal? (tree-after-mouse-event tree-1-unselected 280 40 ENTER)
                  tree-1-unselected)
    (check-equal?  (tree-list-after-mouse-event (list tree-1-unselected) 280 40 BUTTON-DOWN)
                   (list tree-1-first-son-selected))
    (check-equal? (world-after-mouse-event world-with-no-root-selected 280 40 BUTTON-DOWN) 
                  (make-world (list tree-1-first-son-selected)))
    (check-equal? (root-after-unselect node-1-selected) node-1-unselected)
    (check-equal? (unselect-node-from-sons (list tree-1-first-son-selected))
                  (list tree-1-unselected))
    (check-equal? (unselect-all-nodes-from-tree tree-1-first-son-selected)
                  tree-1-unselected)
    (check-equal? (tree-after-mouse-event tree-1-first-son-selected 280 40 BUTTON-UP)
                  tree-1-unselected)
    (check-equal? (world-after-mouse-event world-with-tree-root-selected 280 40 BUTTON-UP) 
                  (make-world (list tree-1-unselected)))
    (check-equal? (root-after-drag node-1-selected 250 40) node-1-after-drag)
    #;(check-equal? (drag-all-sons (tree-sons tree-1-root-selected) 0 0)
                    (tree-sons tree-1-root-selected)))

;=========================================================================================
;; initial-world : Any -> World
;; GIVEN: any value
;; RETURNS: an initial world.  The given value is ignored.
;; EXAMPLES:
;; Get world at initial state
;; (initial-world ZERO) = initial-worldstate
(define (initial-world input)
  (make-world empty))

;; TESTS:
(begin-for-test
  (check-equal? (initial-world ZERO) initial-worldstate))
;=========================================================================================
;; world-to-trees : World -> ListOfTree
;; GIVEN: a World
;; RETURNS: a list of all the trees in the given world.
;; EXAMPLES:
;; (world-to-trees initial-worldstate) = empty
(define (world-to-trees ws)
  (world-trees ws))

;; TESTS:
(begin-for-test
  (check-equal? (world-to-trees initial-worldstate) empty))

;=========================================================================================
;; tree-to-root : Tree -> Node
;; GIVEN: a tree
;; RETURNS: the node at the root of the tree
;; EXAMPLES:
;; (tree-to-root tree-1-selected) = node-1-selected
(define (tree-to-root t)
  (tree-root t))

;; TESTS:
(begin-for-test
  (check-equal? (tree-to-root tree-1-selected) node-1-selected))

;=========================================================================================
;; tree-to-sons : Tree -> ListOfTree
;; GIVEN: a tree
;; RETURNS: sons of the tree
;; EXAMPLES:
;; (tree-to-sons tree-1-selected) = (list node-2-selected node-3-selected)
(define (tree-to-sons t)
  (tree-sons t))

;; TESTS:
(begin-for-test
  (check set-equal? (tree-to-sons tree-1-selected)
         (list (make-tree node-2-selected empty) (make-tree node-3-selected empty))))
;=========================================================================================
;; node-to-center : Node -> Posn
;; GIVEN: A Node
;; RETURNS: the center of the given node as it is to be displayed on the
;; scene.
;; EXAMPLES:
;; (node-to-center node-1-selected) = (make-posn 250 10)
(define (node-to-center n)
  (node-posn n))

;; TESTS:
(begin-for-test
  (check-equal? (node-to-center node-1-selected) (make-posn 250 10)))

;=========================================================================================
;; node-to-selected? : Node -> Boolean
;; GIVEN: a Node
;; RETURNS: true iff the given node is selected.
;; EXAMPLES:
;; (node-to-selected? node-1-selected) = true
(define (node-to-selected? node)
  (node-selected? node))

;; TESTS:
(begin-for-test
  (check-equal? (node-to-selected? node-1-selected) true))

;=========================================================================================