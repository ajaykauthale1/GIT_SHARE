;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname test) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Person -> Persons
;; STRATEGY: Use template for Person on p
(define (person-descendants p)
  (append
   (person-children p)
   (persons-descendants (person-children p))))

;; Persons -> Persons
;; STRATEGY: Use template for Persons on ps
(define (persons-descendants ps)
  (cond
    [(empty? ps) empty]
    [else (append
           (person-descendants (first ps))
           (persons-descendants (rest ps)))]))

;; Person -> Persons
;; STRATEGY: Use template for Person on p
(define (tree-sons p)
  (append
   (person-children p)
   (persons-descendants (person-children p))))

;; Persons -> Persons
;; STRATEGY: Use template for Persons on ps
(define (persons-descendants ps)
  (cond
    [(empty? ps) empty]
    [else (append
           (person-descendants (first ps))
           (persons-descendants (rest ps)))]))

