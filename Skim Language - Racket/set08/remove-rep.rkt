;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname remove-rep) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(define lst
  (list '("ne" 1) '("ne" 2) '("ne" 3)
        '("se" 1) '("se" 2) '("se" 3)
        '("ne" 1) '("se" 1) '("sw" 1)
        '("se" 4) '("nw" 1) '("nw" 2)))


(define (remove-rep lst)
  (remove-successive-rep (first lst) (rest lst)))

(define (remove-successive-rep pre lst)
  (cond
    [(empty? lst) empty]
    [(empty? (rest lst)) (list (first lst))]
    [else
     (if (equal? (move-dir pre) (move-dir (first lst)))
         (remove-successive-rep (first lst) (rest lst))
         (append (list pre) (remove-successive-rep (first lst) (rest lst))))]))




;; move-dir : Move -> Direction
;; GIVEN:   a Move
;; RETURNS: first element from the list which represents direction of the move
(define (move-dir mv)
  (first mv))

;; move-step : Move -> PosInt
;; GIVEN:   a Move
;; RETURNS: second element from the list which represents step for the move
(define (move-step mv)
  (second mv))
