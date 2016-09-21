;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname coffee-suporter) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
(require 2htdp/universe)

(define MT-SCENE (empty-scene 300 250))
(define COFFEE-SCENE (rectangle 300 50 "solid" "red"))
(define CHOCOLATE-SCENE (rectangle 300 50 "solid" "green"))
(define CHANGE-SCENE (rectangle 300 50 "solid" "blue"))

(define DEN-SCENE (rectangle 60 25 "outline" "black"))
(define CENT (overlay (text "1¢" 15 "black") DEN-SCENE))
(define NICKEL (overlay (text "5¢" 15 "black") DEN-SCENE))
(define DIME (overlay (text "10¢" 15 "black") DEN-SCENE))
(define QUARTER (overlay (text "25¢" 15 "black") DEN-SCENE))
(define DOLLOR (overlay (text "$1" 15 "black") DEN-SCENE))

(define ADD-VALUE-PANEL
  (place-image (text "add value" 15 "black") 150 10 (rectangle 300 50 "solid" "white")))
(define DEN-BOX-HALF-LENGTH (/ (image-width CENT) 2))
(define DEN-BOX-HALF-HEIGHT 36)

(define ADD-CENT (place-image CENT DEN-BOX-HALF-LENGTH DEN-BOX-HALF-HEIGHT ADD-VALUE-PANEL))
(define ADD-NICKEL (place-image NICKEL (+ 60 DEN-BOX-HALF-LENGTH) DEN-BOX-HALF-HEIGHT
                                ADD-CENT))
(define ADD-DIME (place-image DIME (+ 120 DEN-BOX-HALF-LENGTH) DEN-BOX-HALF-HEIGHT
                              ADD-NICKEL))
(define ADD-QUARTER (place-image QUARTER (+ 180 DEN-BOX-HALF-LENGTH) DEN-BOX-HALF-HEIGHT
                                 ADD-DIME))

(define ADD-VALUE
  (place-image DOLLOR (+ 240 DEN-BOX-HALF-LENGTH) DEN-BOX-HALF-HEIGHT
               ADD-QUARTER))

(define VALUE-BAR (place-image ADD-VALUE 150 (/ (image-height ADD-VALUE) 2) MT-SCENE))
(define COFFEE (overlay (text "coffee" 15 "black") COFFEE-SCENE))
(define ADD-COFFEE (place-image COFFEE 150 (+ 50 (/ (image-height COFFEE) 2))
                                VALUE-BAR ))


(define CHOCOLATE (overlay (text "hot chocolate" 15 "black") CHOCOLATE-SCENE))
(define ADD-CHOCOLATE (place-image CHOCOLATE 150 (+ 100 (/ (image-height CHOCOLATE) 2))
                            ADD-COFFEE))

(define CHANGE (overlay (text "change" 15 "black") CHANGE-SCENE))


(define MSG-WINDOW (overlay (text "" 15 "black") (rectangle 100 50 "outline" "white")))


(define MENU
  (place-image CHANGE 150 (+ 150 (/ (image-height CHANGE) 2))
               ADD-CHOCOLATE))

(define (render txt)
  ( if (> (string-length txt) 0)
   (place-image (overlay (text txt 15 "black") (rectangle 100 50 "outline" "white"))
               150 225
               MENU)
   (place-image (overlay (text txt 15 "black") (rectangle 100 50 "outline" "white"))
               150 225
               MENU)))

(define (order t mx my mev)
  (cond
    [(mouse=? mev "button-down") (get-order t mx my)]
    [else ""]))

(define (get-order txt mx my)
  (cond
    [(and (<= mx 300) (<= my 50)) "add value"]
    [(and (<= mx 300) (<= my 100)) "coffee"]
    [(and (<= mx 300) (<= my 150)) "chocolate"]
    [(and (<= mx 300) (<= my 200)) "change"]))

(define (main t)
  (big-bang t
            (to-draw render)
            (on-mouse order)))

(main "")

