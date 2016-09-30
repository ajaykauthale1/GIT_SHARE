;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname trees-v1-2-3) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Program for trees simulation

;(check-location "06" "tree.rkt")

(require rackunit)
(require 2htdp/universe)
(require 2htdp/image)
(require "extras.rkt")
(require "sets.rkt")

(provide initial-world)
(provide run)
(provide world-after-mouse-event)
(provide world-after-key-event)
(provide world-to-trees)
(provide tree-to-root)
(provide tree-to-sons)
(provide node-to-center)
(provide node-to-selected?)
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
;; a Posn is (make-posn Integer Integer) (-- defined is BSL)

(define-struct node (posn mouse-posn selected? hasparent? deleted?))
;; A Node is a (make-node Posn Posn Boolean Boolean Boolean)
;; INTERPRETATION:
;; posn - is Posn (x, y) of the node, where x and y are integers and
;; center coordinates of node
;; mouse-posn - is Posn (x, y), where x and y are integers and
;; mouse co-ordinates after drag event (inside node)
;; selected? - represents whether the node is selected or not
;; hasparent? - represents whether the node has parent or not
;; deleted? - represents whether the node is deleted or not 

;; TEMPLATE:
;; node-fn : Node -> ??
#|(define (node-fn n)
  ....
  (node-posn n)
  (node-mouse-posn n)
  (node-selected? n)
  (node-hasparent? n)
  (node-deleted? n)
  ....)|#

;; Nodes for testing
(define node-0-unselected
  (make-node
   (make-posn 100 100) (make-posn 0 0) false false false))
(define node-0-selected
  (make-node
   (make-posn 100 100) (make-posn 0 0) true false false))
(define node-selected
  (make-node
   (make-posn 150 150) (make-posn 0 0) true false false))
(define node-1-selected
  (make-node
   (make-posn 250 10) (make-posn 0 0) true false false))
(define node-1-after-drag
  (make-node
   (make-posn 250 40) (make-posn 0 0) true false false))
(define node-2-selected
  (make-node
   (make-posn 280 40) (make-posn 0 0) true false false))
(define node-3-selected
  (make-node
   (make-posn 310 40) (make-posn 0 0) true false false))
(define node-1-unselected
  (make-node
   (make-posn 250 10) (make-posn 0 0) false false false))
(define node-2-unselected
  (make-node
   (make-posn 280 40) (make-posn 0 0) false true false))
(define node-3-unselected
  (make-node
   (make-posn 310 40) (make-posn 0 0) false false false))
(define node-1-deleted
  (make-node
   (make-posn 100 100) (make-posn 0 0)  false false true))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct tree (root sons))
;; A Tree is a (make-tree Node ListOfTree)
;; INTERPRETATION:
;; root is a root node of the tree
;; sons is a ListOfTree for reprenting the children of the root, where each son might
;; be another tree with some sons or empty sons. (Leaf of the tree is represented by
;; the tree with no sons)

;; TEMPLATE:
;; tree-fn : Tree -> ??
#|(define (tree-fn t)
  (....
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
(define tree-0-unselected
  (make-tree node-0-unselected empty))
(define tree-0-selected
  (make-tree node-0-selected empty))
(define tree-selected
  (make-tree node-selected empty))
(define tree-1-selected
  (make-tree node-1-selected
             (list (make-tree node-2-selected empty)
                   (make-tree node-3-selected empty))))
(define tree-1-unselected
  (make-tree node-1-unselected
             (list
              (make-tree node-2-unselected empty)
              (make-tree node-3-unselected empty))))
(define tree-1-first-son-selected
  (make-tree node-1-unselected
             (list
              (make-tree node-2-selected empty)
              (make-tree node-3-unselected empty))))
(define tree-2-selected
  (make-tree node-1-selected
             (list (make-tree node-2-selected empty)
                   (make-tree node-3-selected empty))))
(define tree-1-root-selected
  (make-tree node-1-selected
             (list (make-tree node-3-unselected empty)
                   (make-tree node-2-unselected empty))))
(define tree-and-his-son
  (make-tree node-1-selected
             (list (make-tree node-1-after-drag empty))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
          (make-node
           (make-posn 250 10) (make-posn 0 0) false false false)
          empty))))
(define world-with-tree-root-selected
  (make-world (list tree-1-root-selected)))
(define world-with-no-root-selected (make-world (list tree-1-unselected)))

;;;; TEMPLATE OF MUTUAL RECURSION:

;;;; tree-fn : Tree -> ??
;;(define (tree-fn t)
;;  (... (tree-node t) (lot-fn (tree-sons t))))
;;
;;;; lot-fn : ListOfTrees -> ??
;;(define (lot-fn lot)
;;  (cond
;;    [(empty? lot) ...]
;;    [else (... (tree-fn (first t))
;;               (lot-fn (rest t)))]))


;; node is referred to the root of the tree

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Helper functions for run ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world->scene : World -> Image
;; GIVEN: a World
;; RETURNS: the image depicting the current World
;; EXAMPLES:
#| (world->scene world-with-tree-at-center) =
     (place-image NODE-CIRCLE 250 10 MT-SCENE) |#

;; STRATEGY: using template of World on ws
(define (world->scene ws)
  (display-all-trees (world-trees ws) MT-SCENE))

;; TESTS:
(begin-for-test
  (check-equal? (world->scene world-with-tree-at-center)
                (place-image NODE-CIRCLE 250 10 MT-SCENE)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; display-all-trees : ListOfTrees Image -> Image
;; GIVEN: a ListOfTree, and Image
;; RETURNS: the image of all trees drawn on the canvas
;; EXAMPLES:
#| (display-all-trees (list (make-tree
       (make-node
         (make-posn 250 10) (make-posn 0 0)
         true false false) empty)) MT-SCENE)
= (place-image SELECTED-NODE-CIRCLE 250 10 MT-SCENE)|#

;; STRATEGY: using template of ListOfTree on trees
(define (display-all-trees trees scn)
  (cond
    [(empty? trees) scn]
    [else
     (place-tree
            (first trees) (posn-x (node-posn (tree-root (first trees))))
            (display-all-trees (rest trees) scn))]))
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; place-tree : Tree Posn Image -> Image
;; GIVEN: a Tree, root position and Image
;; RETURNS: the image with the tree placed on it
;; EXAMPLES:
#| (place-tree tree-1-root-selected (node-posn (tree-root tree-1-root-selected)) MT-SCENE)
 = (place-tree (first (list tree-1-root-selected))
            (tree-root tree-1-root-selected)
            (place-sons (node-posn (tree-root tree-1-root-selected))
                        (rest (list tree-1-root-selected)) MT-SCENE)) |#

;; STRATEGY: using template of Tree on tree
(define (place-tree tree parent-posn scn)
  (place-root parent-posn (tree-root tree)
              (place-sons (node-posn (tree-root tree)) (tree-sons tree) scn)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; place-sons : ListOfTree Posn Image -> Image
;; GIVEN: a ListOfTree, root position and Image
;; RETURNS: the image with all trees placed on it
;; EXAMPLES:
#| (place-sons (node-posn (tree-root tree-1-root-selected))
            (list tree-1-root-selected) MT-SCENE) =
   (place-tree (first (list tree-1-root-selected))
            (tree-root tree-1-root-selected)
            (place-sons (node-posn (tree-root tree-1-root-selected))
                        (rest (list tree-1-root-selected)) MT-SCENE))|#

;; STRATEGY: using template of ListOfTree on sons
;; (not used HOF since foldr needs function with 2 args only)
(define (place-sons parent-posn sons scn)
  (cond
    [(empty? sons) scn]
    [else
     (place-tree (first sons) parent-posn (place-sons parent-posn (rest sons) scn))]))

;; TESTS:
(begin-for-test
  (check-equal? (place-sons (node-posn (tree-root tree-1-root-selected))
                            (list tree-1-root-selected) MT-SCENE)
                (place-tree (first (list tree-1-root-selected))
                            (tree-root tree-1-root-selected)
                            (place-sons (node-posn (tree-root tree-1-root-selected))
                                        (rest (list tree-1-root-selected)) MT-SCENE))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; place-line : Node Posn Image -> Image
;; GIVEN: a Node, root position (parent posn) and Image
;; RETURNS: the image with node placed on it with the line drawn from it's parent
;; center to it's center
;; WHERE: the node is displayed solid when it is selected, otherwise outlined
;; EXAMPLES:
#| (place-root (make-posn 0 0) node-1-selected MT-SCENE) = MT-SCENE |#

;; STRATEGY: using template of Node on root, further calling more general function
(define (place-root parent-posn root scn)
  (cond
    [(node-deleted? root) scn]
    [(node-selected? root) (place-node root parent-posn SELECTED-NODE-CIRCLE scn)]
    [else (place-node root parent-posn NODE-CIRCLE scn)]))

;; TESTS:
(begin-for-test
  (check-equal? 
   (place-root (make-posn 0 0) node-1-deleted MT-SCENE) MT-SCENE
   "node-1-deleted just has only one node and it is
    deleted now thus return empty scene. "))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; place-node : Node Posn Image Image -> Image
;; GIVEN: a Node, root position, and images of node and canvas
;; RETURNS: the image with node placed on it with the line drawn from it's parent
;; center to it's center
;; EXAMPLES:
#| (place-node node-0-selected (make-posn 0 0) SELECTED-NODE-CIRCLE MT-SCENE) =
  (place-line
    node-0-selected
    (make-posn 0 0)
    (place-image SELECTED-NODE-CIRCLE
                (posn-x (node-posn node-0-selected)) (posn-y (node-posn node-0-selected))
                MT-SCENE))
|#

;; STRATEGY: using templae of Node on root
(define (place-node root parent-posn node-image scn)
  (place-line
   root
   parent-posn
   (place-image node-image
                (posn-x (node-posn root)) (posn-y (node-posn root))
                scn)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; place-line : Node Posn Image -> Image
;; GIVEN: a Node, root position and Image
;; RETURNS: the image with line drawn from node center to it's parent center
;; EXAMPLES:
#| (place-line node-2-unselected MT-SCENE) =
  (scene+line MT-SCENE
                  (posn-x (node-posn node-2-unselected))
                  (posn-y (node-posn node-2-unselected))
                  (posn-x (node-parent-posn node-2-unselected))
                  (posn-y (node-parent-posn node-2-unselected))
                  "blue") |#

;; STRATEGY: using template of Node on node
(define (place-line node parent-posn scn)
  (if (node-hasparent? node)
      (scene+line scn
                  (posn-x (node-posn node))
                  (posn-y (node-posn node))
                  (posn-x parent-posn)
                  (posn-y parent-posn)
                  "blue")
      scn))

;=========================================================================================
;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a World and a key event
;; WHERE: key event is occurred on the worldstate might be anything
;; RETURNS: the state of the world as it should be following the given key event
;; EXAMPLES: see the tests below

;; STRATEGY: using cases on key event ke
(define (world-after-key-event ws ke)
  (cond
    [(key=? ke BUTTON-T)
     (add-new-tree-at-center-top ws)]
    [(key=? ke BUTTON-N)
     (world-trees-after-key-event ws ke)]
    [(key=? ke BUTTON-D)
     (world-trees-after-key-event ws ke)]
    [(key=? ke BUTTON-L)
     (world-trees-after-key-event ws ke)]
    [else ws]))

;; TESTS: 
(begin-for-test
  (check-equal? (world-after-key-event (make-world (list )) "t")
                (make-world
                 (list
                  (make-tree
                   (make-node
                    (make-posn 250 10) (make-posn 0 0)
                    #false #false #false) '())))
                "It should return a new green outline circle
                 at (250 10) on the empty scene")
  (check-equal? (world-after-key-event (make-world (list tree-0-unselected)) "t")
                (make-world
                 (list
                  (make-tree
                   (make-node
                    (make-posn 250 10) (make-posn 0 0)
                     #false #false #false) '())
                  (make-tree
                   (make-node
                    (make-posn 100 100) (make-posn 0 0)
                    #false #false #false) '())))
                "A new circle should appear on scene at (250,10)
                 and the old one should stay. ")  
  (check-equal? (world-after-key-event (make-world (list tree-0-selected)) "n")
                (world-trees-after-key-event (make-world (list tree-0-selected)) "n")  
                "Old circle should have a son now which under it located on (100,130).")  
  (check-equal? (display-all-trees
                 (list (make-tree
                        (make-node
                         (make-posn 250 10) (make-posn 0 0)
                         true false false) empty)) MT-SCENE)
                (place-image SELECTED-NODE-CIRCLE 250 10 MT-SCENE)
                "both of them should return a selected rode at (250,10) in scene. ")  
  (check-equal?  (world-after-key-event (make-world (list tree-0-selected)) "d")
                 (make-world (list
                              (make-tree
                               (make-node (make-posn -100 -100) (make-posn 0 0)
                                          #false #false #true) '())))
                 "Because there is only one node at (250,10) thus it should return an
                  empty scene with a deleted node. ")
  (check-equal? (world-after-key-event (make-world (list tree-0-selected)) "l")
                (make-world  (list
                              (make-tree
                               (make-node (make-posn -100 -100) (make-posn 0 0)
                                          #false #false #true)
                               '())))
                "Because node is at (100,100) which on the left thus return an empty
                 scene and the node is deleted now. ") 
  (check-equal? (world-after-key-event (make-world (list tree-0-selected)) "a")
                (make-world(list
                            (make-tree
                             (make-node (make-posn 100 100) (make-posn 0 0)
                                        #true #false #false)
                             '())))
                "Because user click key event a which should change nothing. "))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; Helper functions for world-after-key-event ;;;; 

;; add-new-tree-at-center-top : World -> World
;; GIVEN: a World
;; RETURNS: the world with newly added tree at the centre of it, tree will be created
;; with root node and empty sons
;; EXAMPLES:
;; (add-new-tree-at-center-top initial-worldstate) = world-with-tree-at-center

;; STRATEGY: using template of World on ws
(define (add-new-tree-at-center-top ws)
  (make-world
   (cons
    (make-tree
     (make-node
      (make-posn NEW-NODE-CENTER-X NEW-NODE-CENTER-Y)
      (make-posn 0 0) false false false) empty)
    (world-trees ws))))

;; TESTS:
(begin-for-test
  (check-equal? (add-new-tree-at-center-top initial-worldstate)
                world-with-tree-at-center))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-trees-after-key-event : World KeyEvent -> World
;; GIVEN: current world and KeyEvent
;; WHERE: key event is between "n", "d" and "l"
;; RETURNS: the World after specified key event
;; EXAMPLES: see the tests below

;; STARTEGY: using templae of World on ws, further using the combine using simpler functon
(define (world-trees-after-key-event ws ke)
  (make-world
   (trees-after-key-event (world-trees ws) ke)))

;; TESTS:
(begin-for-test
  (check-equal?
   (world-trees-after-key-event world-with-tree-at-center "n") (make-world
   (trees-after-key-event (world-trees world-with-tree-at-center) "n"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; trees-after-key-event : ListOfTree KeyEvent -> ListOfTree
;; GIVEN: a ListOfTree and key event
;; WHERE: key event in between "n", "d"
;; RETURNS: the new ListOfTree with changed trees according to the key event
;; EXAMPLES: see the tests below

;; STRATEGY: use HOF foldr, followed by HOF map on trees
(define (trees-after-key-event trees ke)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: A Tree
          ;; RETURNS: Tree after key event ke
          (lambda (tree) (tree-after-key-event tree ke))
          trees)))

;; TESTS:
(begin-for-test
  (check-equal?
   (trees-after-key-event (world-trees (make-world (list tree-0-selected))) "n")
   (list
    (make-tree
     (make-node (make-posn 100 100) (make-posn 0 0) #true #false #false)
     (list
      (make-tree
       (make-node (make-posn 100 (+ (* 3 NODE-RADIUS) 100)) (make-posn -1 -1)
                   #false #true #false) '()))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; tree-after-key-event : Tree KeyEvent -> Node
;; GIVEN: A Tree and KeyEvent
;; WHERE: key event in between "n", "d"
;; RETURNS: the state of the tree that should follow the given tree after
;; the given key event
;; EXAMPLES: see test below

;; STRATEGY: using cases on KeyEvent ke 
(define (tree-after-key-event tree ke)
  (cond
    [(key=? BUTTON-N ke) (add-son-to-selected-root tree)]
    [(key=? BUTTON-D ke) (delete-node-with-all-children tree)]
    [(key=? BUTTON-L ke) (delete-all-left-nodes tree)]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; delete-node-with-all-children : Tree -> Tree
;; GIVEN: a tree 
;; RETURNS: the tree with all sons deleted if the root is selected, also root node
;; deleted? flag is become true
;; EXAMPLES: see test below

;; STRATEGY: Use template for Tree/LoT (mutual recursion template),
;; further using template of Tree on tree
(define (delete-node-with-all-children tree)
  (if (node-selected? (tree-root tree))
      (make-tree (make-node (make-posn -100 -100)
                            (make-posn 0 0)
                            false false true) empty)
      (make-tree
       (tree-root tree)
       (delete-node-from-sons (tree-sons tree)))))

;; TESTS: 
(begin-for-test
  (check-equal? (delete-node-with-all-children tree-0-selected)
                (make-tree
                 (make-node (make-posn -100 -100) (make-posn 0 0)
                            #false #false #true)'())
                "Because tree-0-selected is selected, thus it is deleted now. ")
  
  (check-equal? (delete-node-with-all-children tree-0-unselected)
                (make-tree
                 (make-node (make-posn 100 100) (make-posn 0 0)
                            #false #false #false) '())
                "Because tree-0-unselected is unselected, so nothing changed. "))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; delete-node-from-sons : ListOfTree -> ListOfTree
;; GIVEN: a ListOfTree
;; RETURNS: the new list of tree by deleting each subtree if the root node is selected
;; EXAMPLES: see tests below

;; STRATEGY: Use template for Tree/LoT (mutual recursion template),
;; further using HOF foldr, followed by HOF map on sons
(define (delete-node-from-sons sons)
  (foldr
   cons empty
   (map
    ;; Tree -> Tree
    ;; GIVEN: a Tree
    ;; RETURNS: a tree with all sons deleted, if root is selected
    (lambda (son) (delete-node-with-all-children son))
    sons)))

;; TESTS:
(begin-for-test
  (check-equal? (delete-node-from-sons (list tree-and-his-son))
                (list (make-tree
                       (make-node (make-posn -100 -100) (make-posn 0 0)
                                  #false #false #true)
                       '()))
                "The tree-and-his-son has one node and one son. It should return
                 everything deleted of this tree. "))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; add-son-to-selected-root : Tree -> Tree
;; GIVEN: A Tree
;; RETURNS: the tree with added new son (tree) to the right
;; EXAMPLES: see tests below 

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further using
;; template of Tree on tree
(define (add-son-to-selected-root tree)
  (if (node-selected? (tree-root tree))
      (make-tree (tree-root tree)
                 (add-chidren-to-right (add-son-to-selected-roots (tree-sons tree))
                                       (node-posn (tree-root tree))))
      (make-tree (tree-root tree)
                 (add-son-to-selected-roots (tree-sons tree)))))

;; TESTS:
(begin-for-test
  (check-equal? (add-son-to-selected-root  tree-0-selected)
                (make-tree (tree-root tree-0-selected)
                 (add-chidren-to-right (tree-sons tree-0-selected)
                                       (node-posn (tree-root tree-0-selected))))
                "Because tree-0-selected is selected so just add one children under it. ")
  (check-equal? (add-son-to-selected-root  tree-0-unselected)
                (make-tree
                 (make-node
                  (make-posn 100 100) (make-posn 0 0)
                  #false #false #false) '())
                "Because tree-0-unselected is unselected and the sons
                 is empty, so just remain. "))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; add-son-to-selected-roots : ListOfTree -> ListOfTree
;; GIVEN: the list of tree 
;; RETURNS: a list of tree similar to previous one, but for each selected root
;; new son will be added at right side
;; EXAMPLES: see tests below

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further using HOF
;; foldr, followed by HOF map on sons
(define (add-son-to-selected-roots sons)
  (foldr
   cons empty
   (map
    ;; Tree -> Tree
    ;; GIVEN: a Tree
    ;; RETURNS: a tree sam as previous one with new son added
    (lambda (son) (add-son-to-selected-root son))
    sons))) 

;; TESTS:
(begin-for-test
  (check-equal? (add-son-to-selected-roots (list tree-0-selected))
                (list
                 (make-tree
                  (make-node (make-posn 100 100) (make-posn 0 0)
                             #true #false #false)
                  (list
                   (make-tree
                    (make-node (make-posn 100 (+ 100 (* 3 NODE-RADIUS)))
                                              (make-posn -1 -1)
                                              #false #true #false) '()))))
                "Because (list tree-0-selected) is not empty, thus add son to this tree. 
                 The new son's position should under the root which is (100,130)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; add-chidren-to-right : ListOfTree Posn -> ListOfTree
;; GIVEN: a list of tree and the position of root 
;; RETURN: a new list of tree witha new son (tree) has been added.
;; EXAMPLES: see the tests below

;; STRATEGY: Using template for Node on sons 
(define (add-chidren-to-right sons posn)
  (if (empty? sons)
      (cons (make-tree
             (make-node (make-posn (posn-x posn) (+ NODE-DIST (posn-y posn)))
                        (make-posn -1 -1)
                        false true false) empty) sons)
      (cons (make-tree
             (make-node (make-posn
                         (+ NODE-DIST (posn-x (node-posn (tree-root (first sons)))))
                         (+ NODE-DIST (posn-y posn)))
                         posn false true false) empty) sons)))

;; TESTS: 
(begin-for-test
  (check-equal? (add-chidren-to-right (list tree-and-his-son) (make-posn 250 10))
                (list
                 (make-tree
                  (make-node
                   (make-posn (+ 250 NODE-DIST) (+ 10 NODE-DIST))
                   (make-posn 250 10) #false #true #false) '())
                 (make-tree
                  (make-node
                   (make-posn 250 10) (make-posn 0 0) #true #false #false)
                  (list
                   (make-tree
                    (make-node
                     (make-posn 250 40) (make-posn 0 0) #true #false #false) '()))))
                "Because tree-and-his-son is not empty, one son added under the node
                 (250,10) in the tree. "))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; delete-all-left-nodes : Tree -> Tree
;; GIVEN: a Tree
;; RETURNS: the tree with all sons (trees) from left of the canvas (x coordinate < 250)
;; will be deleted, if root itself is left of the canvas then it is placed outside of the
;; canvas (for not displaying it) and making it's deleted? flag true
;; EXAMPLES:
;; (delete-all-left-nodes tree-1-root-selected) = tree-1-root-selected

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using template of Tree on tree
(define (delete-all-left-nodes tree)
  (if (< (posn-x (node-posn (tree-root tree))) 250)
      (make-tree (make-node (make-posn -100 -100)
                            (make-posn 0 0)
                            false false true) empty)
      (make-tree
       (tree-root tree)
       (delete-left-node-from-sons (tree-sons tree)))))

;; TESTS:
(begin-for-test
  (check-equal? (delete-all-left-nodes tree-1-root-selected) tree-1-root-selected)
  "because all the nodes of tree-1-root-selected are in the right hand of scene,
  thus nothing changed. ")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; delete-left-node-from-sons : ListOfTree -> ListOfTree
;; GIVEN: a ListOfTree
;; RETURNS: the list of tree similar to the old tree, but all sons from left of the
;;  (x coordinate < 250) canvas for each tree will be deleted
;; EXAMPLES: see the test below

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), fruther
;; using HOF foldr, followed by HOF map on sons
(define (delete-left-node-from-sons sons)
  (foldr
   cons empty
   (map
    ;; Tree -> Tree
    ;; GIVEN: a Tree
    ;; RETURNS: a tree with all sons left of the canvas deleted
    (lambda (son) (delete-all-left-nodes son))
    sons)))

;; TESTS:
(begin-for-test
  (check-equal?
   (delete-left-node-from-sons
    (list
     (make-tree
      (make-node
       (make-posn 100 40) (make-posn 0 0) false false false) empty))) 
   (list
    (make-tree
     (make-node (make-posn -100 -100) (make-posn 0 0)
                #false #false #true) '()))))

;=========================================================================================
;; world-after-mouse-event : World Integer Integer MouseEvent -> World
;; GIVEN: a World, a location of mouse, and a MouseEvent
;; RETURNS: the state of the world as it should be following the given mouse event at
;; that location.
;; EXAMPLES: see the tests below

;; STRATEGY: using template of World on ws and cases on mouse event
(define (world-after-mouse-event ws mx my me)
  (cond
    [(mouse=? BUTTON-DOWN me)
     (make-world (tree-list-after-mouse-event (world-trees ws) mx my me))]
    [(mouse=? BUTTON-UP me)
     (make-world (tree-list-after-mouse-event (world-trees ws) mx my me))]
    [(mouse=? DRAG me)
     (make-world (tree-list-after-mouse-event (world-trees ws) mx my me))]
    [else ws]))

;; TESTS:
(begin-for-test
  (check-equal? (world-after-mouse-event
                 (make-world
                  (list tree-0-unselected)) 100 100  BUTTON-DOWN)
                (make-world (list (make-tree (make-node
                                              (make-posn 100 100)
                                              (make-posn 100 100)
                                              #true #false #false) '())))
                "tree-o-unselected becomes to be selected after click BUTON-DOWN. ")
  
  (check-equal? (world-after-mouse-event
                 (make-world (list tree-0-selected)) 100 100  BUTTON-UP)
                (make-world (list (make-tree (make-node
                                              (make-posn 100 100)
                                              (make-posn 100 100)
                                              #false #false #false) '())))
                "tree-o-selected becomes to be unselected after click BUTON-up. ")
  
  (check-equal? (world-after-mouse-event (make-world(list tree-0-selected)) 50 50  DRAG)
                (make-world
                 (list
                  (make-tree
                   (make-node (make-posn 150 150) (make-posn 50 50)
                              #true #false #false) '())))
                "tree-0-selected is at (100,100) and after drag (50,50),
                 it should stay at (150,150)")
  
  (check-equal? (world-after-mouse-event
                 (make-world (list tree-0-unselected)) 50 50 ENTER)
                (make-world
                 (list
                  (make-tree (make-node (make-posn 100 100) (make-posn 0 0)
                                        #false #false #false) '())))
                "After mouse event ENTER, nothing should happened. "))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; tree-after-mouse-event : Tree NonNegInt NonNegInt MouseEvent -> Tree
;; GIVEN: a Tree, x and y coordinates of the mouse event and mouse event
;; RETURNS: the tree after the mouse event
;; EXAMPLES: see the tests below

;; STRATEGY: using cases on mouse event on me
(define (tree-after-mouse-event tree mx my me)
  (cond
    [(mouse=? me BUTTON-DOWN) (select-node-from-tree tree mx my)]
    [(mouse=? me BUTTON-UP) (unselect-all-nodes-from-tree tree mx my)]
    [(mouse=? me DRAG) (drag-node-from-tree tree mx my)]
    [else tree]))

;; TESTS:
(begin-for-test
  (check-equal? (tree-after-mouse-event tree-0-unselected 100 100 ENTER)
                (make-tree
                 (make-node (make-posn 100 100) (make-posn 0 0)
                            #false #false #false) '())
                "Because user click ENTER thus nothing happened. "))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; select-node-from-tree : Tree NonNegInt NonNegInt -> Tree
;; GIVEN: a Tree, and x and y co-ordinates of the mouse event
;; WHERE: mouse event is button-down
;; RETURNS: the tree similar to previous one, but selected node will have
;; selected? flag true, also mouse positions of all sons will also change
;; if the parent node is selected
;; EXAMPLES: see the tests below

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using template of Tree on tree
(define (select-node-from-tree tree mx my)
  (if (cursor-in-node? (node-posn (tree-root tree)) mx my)
      (make-tree
       (root-after-select (tree-root tree) mx my)
       (change-mouse-posn-all-sons (tree-sons tree) mx my))
      (make-tree
       (tree-root tree)
       (select-node-from-sons (tree-sons tree) mx my))))


;;TESTS:
(begin-for-test
  (check-equal? (select-node-from-tree tree-0-unselected 100 100)
                (make-tree
                 (make-node
                  (make-posn 100 100) (make-posn 100 100)
                  #true #false #false) '())
                "Because curson inside of node, thus return a tree which is selected")
  (check-equal? (select-node-from-tree tree-0-unselected 300 300)
                (make-tree
                 (make-node
                  (make-posn 100 100) (make-posn 0 0)
                  #false #false #false) '())
                "Because curson outside of node, thus remain everything. "))
           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; select-node-from-sons : ListOfTree NonNegInt NonNegInt -> ListOfTree
;; GIVEN: a ListOfTree, and x and y co-ordinates of the mouse event
;; RETURNS: the list of trees same as previous one, but if any of the son's root
;; is selected then selected? flag for same will be true and all of it's sons
;; mouse positions will change
;; EXAMPLES: see the tests below

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using HOF foldr, followed by HOF map on sons
(define (select-node-from-sons sons mx my)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: a Tree
          ;; RETURNS: tree same as previous one, but if root
          ;; is selected then selected? flag for same will be true
          (lambda (son) (select-node-from-tree son mx my))
          sons)))

;; TESTS:
(begin-for-test
  (check-equal? (select-node-from-sons (list tree-0-unselected) 100 100)
                (list
                 (make-tree (make-node (make-posn 100 100) (make-posn 100 100)
                                       #true #false #false) '()))
                "tree-0-unselected should be selected after call function
                 selecte-node-from-sons"))
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; cursor-in-node? : Posn NonNegInt NonNegInt -> Boolean
;; GIVEN: A Posn, x and y coordinates of a mouse event
;; RETURNS: true iff any node from the list is selected for dragging
;; EXAMPLES:
;; (cursor-in-node? (node-posn node-1-unselected) 250 10) = true

;; STRATEGY: combine using simpler functions
(define (cursor-in-node? posn mx my)
  (<= (sqrt (+ (sqr (- mx (posn-x posn))) (sqr (- my (posn-y posn))))) NODE-RADIUS))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
                           true false false))
|#

;; STRATEGY: using template of Node on root
(define (root-after-select root mx my)
  (make-node (node-posn root)
             (make-posn mx my) true (node-hasparent? root) (node-deleted? root)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; drag-son : Tree Integer Integer -> Tree
;; GIVEN : a Tree, position of mouse event
;; RETURNS: a Tree with changing all sons mouse position (the selected flag will remain
;; false for sons)
;; EXAMPLES:
#|(change-mouse-posn-son (make-tree node-0-unselected empty) 1 1) =
(make-tree (make-node (make-posn 101 101) (make-posn 1 1) #false #false #false) empty)|#

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using template of Tree on son
(define (change-mouse-posn-son son mx my)
  (make-tree
   (son-after-changed-mouse-posn (tree-root son) mx my)
   (change-mouse-posn-all-sons (tree-sons son) mx my)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; change-mouse-posn-all-sons : ListOfTree NonNegInt NonNegInt -> ListOfTree
;; GIVEN : a ListOfTree, position of mouse event
;; RETURNS: a ListOfTree with all nodes mouse position has been changed
;; EXAMPLES: 
#|(change-mouse-posn-all-sons (list (make-tree node-0-unselected empty)) 1 1) =
(list (make-tree (make-node (make-posn 100 100) (make-posn 0 0)
#false #false #false) empty))|#

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using HOF foldr, followed by HOF map on sons
(define (change-mouse-posn-all-sons sons mx my)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: a Tree
          ;; RETURNS: a Tree after changing mouse position of it's root
          (lambda (son) (change-mouse-posn-son son mx my))
          sons)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; son-after-changed-mouse-posn : Node NonNegInt NonNegInt -> Node
;; GIVEN: a Node and mouse event position
;; RETURNS: a Node with changed mouse position
;; EXAMPLES:
#|(son-after-changed-mouse-posn node-0-unselected 1 1) =
(make-node (make-posn 100 100) (make-posn 1 1) #false #false #false)|#

;; STRATEGY: using template of Node on root
(define (son-after-changed-mouse-posn root mx my)
  (if (cursor-in-node? (node-posn root) mx my)
      (make-node (node-posn root)
             (make-posn mx my) true (node-hasparent? root) (node-deleted? root))
      (make-node (node-posn root)
             (make-posn mx my) false (node-hasparent? root) (node-deleted? root))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; unselect-all-nodes-from-tree : Tree NonNegInt NonNegInt -> Tree
;; GIVEN: a Tree, and mouse position
;; RETURNS: same tree as previous one, but selected? flag of all the nodes will be false
;; EXAMPLES:
;; (unselect-all-nodes-from-tree tree-1-first-son-selected) = tree-1-unselected

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using template of Tree on tree
(define (unselect-all-nodes-from-tree tree mx my)
  (make-tree
   (root-after-unselect (tree-root tree) mx my)
   (unselect-node-from-sons (tree-sons tree) mx my)))

;; TESTS:
(begin-for-test (unselect-all-nodes-from-tree tree-and-his-son 100 100)
                (make-tree
                 (make-node (make-posn 250 10) (make-posn 100 100)
                            #false #false #false)
                 (list
                  (make-tree
                   (make-node (make-posn 250 40) (make-posn 100 100)
                              #false #false #false)'())))
                "After call unselected-all-from-tree, all nodes in tree-and-his-son
                 become unselected. ")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; unselect-node-from-sons : ListOfTree NonNegInt NonNegInt -> ListOfTree
;; GIVEN: a ListOfTree, and mouse position
;; RETURNS: the list of tree with all nodes (roots) are un-selected
;; EXAMPLES:
;; (unselect-node-from-sons (list tree-1-first-son-selected)) = (list tree-1-unselected)

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using HOF foldr, followed by HOF map on sons
(define (unselect-node-from-sons sons mx my)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: a Tree
          ;; RETURNS: tree same as previous one, but if root
          ;; is selected then selected? flag for same will be false
          (lambda (son) (unselect-all-nodes-from-tree son mx my))
          sons)))

;; TESTS:
(begin-for-test
  (check-equal? (select-node-from-sons (list tree-0-selected) 100 100)
                (list
                 (make-tree (make-node (make-posn 100 100) (make-posn 100 100)
                                       #true #false #false) '()))
                "tree-0-selected should be unselected after call function
                 unselecte-node-from-sons")) 
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; root-after-unselect : Node NonNegInt NonNegInt -> Node
;; GIVEN: a Node, and x and y coordinates of the mouse event
;; RETURNS: the node same as previous, but with selected flag is false and mouse position
;; distance become 0 along x and y axis
;; EXAMPLES:
;; (root-after-unselect node-1-selected) = node-1-unselected

;; STRATEGY: using template of Node on root
(define (root-after-unselect root mx my)
  (make-node
   (node-posn root) (make-posn mx my)
   false (node-hasparent? root) (node-deleted? root)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; drag-node-from-tree : Tree NonNegInt NonNegInt -> Tree
;; GIVEN: a Tree, and x and y coordinates of the mouse event
;; RETURNS: the tree after the drag event
;; EXAMPLES: see tests below

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using template of Tree on tree
(define (drag-node-from-tree tree mx my)
  (if (node-selected? (tree-root tree))
      (make-tree
       (root-after-drag (tree-root tree) mx my)
       (drag-all-sons (tree-sons tree)
                      mx my))
      (make-tree
       (tree-root tree)
       (drag-node-from-sons (tree-sons tree) mx my)))) 


(begin-for-test
  (check-equal? (drag-node-from-tree tree-0-selected 20 20)
                (make-tree
                 (make-node (make-posn 120 120) (make-posn 20 20)
                            #true #false #false) '())
                "The new position of the node should be add (20,20) which is (120,120) ")
  (check-equal? (drag-node-from-tree tree-0-unselected 20 20)
                (make-tree
                 (make-node (make-posn 100 100) (make-posn 0 0)
                            #false #false #false) '())
                "Because the node is unselected, thus it should not
                 move but remain at (100,100)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; drag-node-from-sons : ListOfTree NonNegInt NonNegInt -> ListOfTree
;; GIVEN: a ListOfTree, and and x and y coordinates of the mouse event
;; RETURNS: a list of trees (sons) after the drag event
;; EXAMPLES: see tests below

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using HOF foldr, followed by HOF map on sons
(define (drag-node-from-sons sons mx my)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: a Tree
          ;; RETURNS: tree after the drag event
          (lambda (son) (drag-node-from-tree son mx my))
          sons)))

;; TESTS:
(begin-for-test
  (check-equal? (drag-node-from-sons (list tree-and-his-son) 1 1)
                (list
                 (make-tree
                  (make-node
                   (make-posn 251 11) (make-posn 1 1) #true #false #false)
                  (list
                   (make-tree
                    (make-node (make-posn 251 41) (make-posn 1 1)
                               #true #false #false) '()))))
                "After drag them (1,1), both root and its sons'position add (1,1)"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; drag-son : Tree NonNegInt NonNegInt -> Tree
;; GIVEN: a Tree, and mouse event position
;; RETURNS: a Tree with the child nodes (sons) are dragged
;; EXAMPLES: see tests below

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using template of Tree on son
(define (drag-son son mx my)
  (make-tree
   (son-after-drag (tree-root son) mx my)
   (drag-all-sons (tree-sons son) mx my)))


;; TESTS:
(begin-for-test
  (check-equal? (drag-son tree-and-his-son 0 0)
                (make-tree
                 (make-node
                  (make-posn 250 10) (make-posn 0 0) #true #false #false)
                 (list
                  (make-tree
                   (make-node
                    (make-posn 250 40) (make-posn 0 0) #true #false #false) '())))
                "When drag root node-1-selected, his son node-1-after-drag
                 should move together. The new position of root should be
                 (500, 20), and son should be (500, 50)"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; drag-all-sons : ListOfTree NonNegInt NonNegInt -> ListOfTree
;; GIVEN: a ListOfTree, and mouse event position
;; RETURNS: list of tree with center coordinates of the roots are changed
;; EXAMPLES:
#|(drag-all-sons (tree-sons tree-1-root-selected) 0 0) =
                (tree-sons tree-1-root-selected) |#

;; STRATEGY: Use template for Tree/LoT (mutual recursion template), further
;; using HOF foldr, followed by HOF map on sons
(define (drag-all-sons sons mx my)
  (foldr cons empty
         (map
          ;; Tree -> Tree
          ;; GIVEN: a Tree
          ;; RETURNS: a Tree after mouse drag event
          (lambda (son) (drag-son son mx my))
          sons)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; son-after-drag : Node NonNegInt NonNegInt -> Node
;; GIVEN: a Node, and mouse event position
;; RETURNS: a node with changed coordinates after drag event
;; EXAMPLES:
;; (son-after-drag node-1-selected 0 0) = node-1-selected

;; STRATEGY: using template of Node on root
(define (son-after-drag son mx my)
  (make-node (make-posn
              ( + (posn-x (node-posn son))
                  (- mx (posn-x (node-mouse-posn son))))
              ( + (posn-y (node-posn son))
                  (- my (posn-y (node-mouse-posn son)))))
             (make-posn mx my)
             (node-selected? son)
             (node-hasparent? son)
             (node-deleted? son))) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
                 (node-selected? root)
                 (node-hasparent? root)
                 (node-deleted? root))
      root))

;; TESTS:
(begin-for-test
  (check-equal? (root-after-drag node-0-unselected 100 100)
                (make-node (make-posn 100 100) (make-posn 0 0)
                           #false #false #false)
                "Because node-0-unselected is unselected, thus remain everything. "))
                 
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

;; STRATEGY: using template of World on ws
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

;; STRATEGY: using template Tree on t
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

;; STRATEGY: using template Tree on t
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

;; STRATEGY: using template Node on n
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

;; STRATEGY: using template Node on node
(define (node-to-selected? node)
  (node-selected? node))

;; TESTS:
(begin-for-test
  (check-equal? (node-to-selected? node-1-selected) true))

;=========================================================================================