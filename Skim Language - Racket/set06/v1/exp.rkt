;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname exp) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
(define-struct node (name))
(define-struct tree (root sons))

(define n1 (make-node "1"))
(define n2 (make-node "2"))
(define n3 (make-node "3"))
(define n4 (make-node "4"))
(define n5 (make-node "5"))
(define n6 (make-node "6"))
(define n7 (make-node "7"))
(define n8 (make-node "8"))
(define n9 (make-node "9"))

(define tree1 (make-tree n7 (list n2 n3)))
(define tree2 (make-tree n8 (list n4 n5)))
(define main-tree (make-tree n9 (list n1 tree1 tree2 n6)))

(define (print-son sons)
  (cond
    [(empty? sons) empty]
    [else
     (append
      (print-sons (first sons))
      (print-son (rest sons)))]))

(define (print-sons son)
  (cond
    [(node? son) (cons son empty)]
    [(tree? son) (print-son (tree-sons son))]))

(define (print-descendents sons)
  (cond
    [(empty? sons) empty]
    [else
     (append
      (print-all-descendents (first sons))
      (print-descendents (rest sons)))]))

(define (print-all-descendents son)
  (cond
    [(node? son) (cons son empty)]
    [(tree? son)
     (cons
      (tree-root son) (print-descendents (tree-sons son)))]))