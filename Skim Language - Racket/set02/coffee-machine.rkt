;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname coffee-machine) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Author: Ajay Baban Kauthale
;; Date: 09/22/2015
;; Program for simulating coffee machine
;; Note: user mouse click of this program

(require rackUnit)
(require "extras.rkt")

(provide
 initial-machine
 machine-next-state
 machine-output
 machine-remaining-coffee
 machine-remaining-chocolate
 machine-bank)

;==========================================================================================
;                                      DATA DEFINITIONS
;==========================================================================================
(define-struct MachineState (coffee chocolate bank output))
;; MachineState is a (make-MachineState (PosReal PosReal NonNegInt))
;; INTERPRETATION:
;; number of coffee cups
;; number of hot chocolate cups
;; the amount inserted by customer
;; output string which will be shown to customer
;; MachineState-fn : PosReal PosReal NonNegInt String -> ??
#;(define (MachineState-fn coffee hot-chocolate bank output)
    ...)

;; A CustomerInput is one of
;; -- a PosInt          interpretation: insert the specified amount of money, in cents
;; -- "coffee"          interpretation: request a coffee
;; -- "hot chocolate"   interpretation: request a hot chocolate
;; -- "change"          interpretation: return all the unspent money that the
;;                             customer has inserted
#;(define (CustomerInput-fn c)
    (cond
      [(and (number? c) (> c 0))
       ...]
      [(string=? c "coffee")
       ...]
      [(string=? c "hot chocolate")
       ...]
      [(string=? c "change")
       ...]))

;; A MachineOutput is one of
;; -- "coffee"         interpretation: machine dispenses a cup of coffee
;; -- "hot chocolate"  interpretation: machine dispenses a cup of hot chocolate
;; -- "Out of Item"    interpretation: machine displays "Out of Item"
;; -- a PosInt         interpretation: machine releases the specified amount of
;;                            money, in cents
;; -- "Nothing"        interpretation: the machine does nothing
#;(define (MachineOutput-fn m)
    ...)

;==========================================================================================
;                                      CONSTANTS
;==========================================================================================
;; constants for machine outputs
(define COFFEE "coffee")
(define CHOCOLATE "hot chocolate")
(define CHANGE "change")
(define OUT-OF-ITEM "Out of Item")
(define NOTHING "")
;; coffee machine with coffee and chocolate five cups each
(define COFFEE-MACHINE-5-CUPS (make-MachineState 5 5 0 ""))
;; coffee machine with coffee and chocolate five cups each and bank having 2 dollors
(define COFFEE-MACHINE-5-CUPS-2-BANKS (make-MachineState 5 5 2.0 "Added Value 2.0"))
;; coffee machine with coffee and chocolate no cups and empty bank
(define COFFEE-MACHINE-0-CUPS (make-MachineState 0 0 0 OUT-OF-ITEM))
;; coffee machine with coffee and chocolate four and five cups each and bank having 0.5 dollors
(define COFFEE-MACHINE-4-CUPS-0.5-BANKS (make-MachineState 4 5 0.5 COFFEE))
;; coffee machine with coffee and chocolate five and 4 cups each and bank having 1.4 dollors
(define COFFEE-MACHINE-4-CUPS-1.4-BANKS (make-MachineState 5 4 1.4 CHOCOLATE))
;; coffee machine with coffee and chocolate five and 4 cups each and bank having 0 dollors
(define COFFEE-MACHINE-4-CUPS-0-BANKS (make-MachineState 5 4 0 "1.4"))
;; coffe machine with 1 dollor in bank
(define COFFEE-MACHINE-5-CUPS-1-BANKS (make-MachineState 5 5 1.0 "Added Value 2.0"))
;; coffe machine with 2 dollor in bank -> after adding 1 dollor in existing bank
(define COFFEE-MACHINE-5-CUPS-1-BANKS-STEP2 (make-MachineState 5 5 2.0 "Added Value 1.0"))
;; coffee machine with coffee and chocolate five cups each and dispensing change
(define COFFEE-MACHINE-5-CUPS-0-BANKS (make-MachineState 5 5 0 "2.0"))
;; coffee machine with no coffee and chocolate cups and two dollar in bank
(define COFFEE-MACHINE-0-CUPS-2-BANKS (make-MachineState 0 0 2.0 NOTHING))
;; rate of coffee cup
(define COFFEE-RATE 1.5)
;; rate of chocolate cup
(define CHOCOLATE-RATE 0.6)
;; constants for creating scenes
(define SCENE-WIDTH 300)
(define MT-SCENE (empty-scene SCENE-WIDTH 250))
(define COFFEE-SCENE (rectangle SCENE-WIDTH 50 "solid" "red"))
(define CHOCOLATE-SCENE (rectangle SCENE-WIDTH 50 "solid" "green"))
(define CHANGE-SCENE (rectangle SCENE-WIDTH 50 "solid" "blue"))
(define DEN-SCENE (rectangle 60 25 "outline" "black"))
;; constants for showing various coin denominations
(define CENT-MIN-WIDTH 22)
(define CENT-MAX-WIDTH 50)
(define CENT (overlay (text "1¢" 15 "black") DEN-SCENE))
(define NICKEL (overlay (text "5¢" 15 "black") DEN-SCENE))
(define DIME (overlay (text "10¢" 15 "black") DEN-SCENE))
(define QUARTER (overlay (text "25¢" 15 "black") DEN-SCENE))
(define DOLLOR (overlay (text "$1" 15 "black") DEN-SCENE))
;; constants for creating the add value panel in terms of the coins
(define ADD-VALUE-PANEL (place-image (text "add value" 15 "black") 150 10 (rectangle SCENE-WIDTH 50 "solid" "white")))
(define DEN-BOX-HALF-LENGTH (/ (image-width CENT) 2))
(define DEN-BOX-HALF-HEIGHT 36)
(define ADD-CENT (place-image CENT DEN-BOX-HALF-LENGTH DEN-BOX-HALF-HEIGHT ADD-VALUE-PANEL))
(define ADD-NICKEL (place-image NICKEL (+ 60 DEN-BOX-HALF-LENGTH) DEN-BOX-HALF-HEIGHT ADD-CENT))
(define ADD-DIME (place-image DIME (+ 120 DEN-BOX-HALF-LENGTH) DEN-BOX-HALF-HEIGHT ADD-NICKEL))
(define ADD-QUARTER (place-image QUARTER (+ 180 DEN-BOX-HALF-LENGTH) DEN-BOX-HALF-HEIGHT ADD-DIME))
;; constants for creating actual user interface for coffee machine
(define ADD-VALUE (place-image DOLLOR (+ 240 DEN-BOX-HALF-LENGTH) DEN-BOX-HALF-HEIGHT ADD-QUARTER))
(define VALUE-BAR (place-image ADD-VALUE 150 (/ (image-height ADD-VALUE) 2) MT-SCENE))
(define COFFEE-LINE (overlay (text COFFEE 15 "black") COFFEE-SCENE))
(define ADD-COFFEE (place-image COFFEE-LINE 150 (+ 50 (/ (image-height COFFEE-LINE) 2)) VALUE-BAR ))
(define CHOCOLATE-LINE (overlay (text CHOCOLATE 15 "black") CHOCOLATE-SCENE))
(define ADD-CHOCOLATE (place-image CHOCOLATE-LINE 150 (+ 100 (/ (image-height CHOCOLATE-LINE) 2)) ADD-COFFEE))
(define CHANGE-LINE (overlay (text CHANGE 15 "black") CHANGE-SCENE))
;; constant for displaying user menu
(define MENU
  (place-image CHANGE-LINE 150 (+ 150 (/ (image-height CHANGE-LINE) 2))
               ADD-CHOCOLATE))

;==========================================================================================
;                                      FUNCTIONS
;==========================================================================================
;; initial-machine : NonNegInt NonNegInt -> MachineState
;; GIVEN: a number of cups of coffee and of hot chocolate
;; RETURNS: the state of a machine loaded with the given number of cups
;;         of coffee and of hot chocolate, with an empty bank.
;; EXAMPLES:
;; (initial-machine 5 5) = COFFEE-MACHINE-5-CUPS
(define (initial-machine coffee hot-chocolate)
  (make-MachineState coffee hot-chocolate 0 ""))

;; machine-next-state : MachineState CustomerInput -> MachineState
;; GIVEN: a machine state and a customer input
;; RETURNS: the state of the machine that should follow the customer's
;; input
;; EXAMPLES:
;; (machine-next-state COFFEE-MACHINE-5-CUPS 2) = COFFEE-MACHINE-5-CUPS-2-BANKS
;; (machine-next-state COFFEE-MACHINE-5-CUPS-2-BANKS COFFEE) = COFFEE-MACHINE-4-CUPS-0.5-BANKS
;; (machine-next-state COFFEE-MACHINE-5-CUPS-2-BANKS CHOCOLATE) = COFFEE-MACHINE-4-CUPS-1.4-BANKS
;; (machine-next-state COFFEE-MACHINE-4-CUPS-1.4-BANKS CHANGE) = 1.4
;; STRATEGY: combine simpler functions and structural decomposition of CustomerInput
(define (machine-next-state ms c)
  (cond
    [(and (number? c) (> c 0))
     (add-value-in-bank ms c)]
    [(string=? c COFFEE)
     (dispense-coffee ms)]
    [(string=? c CHOCOLATE)
     (dispense-chocolate  ms)]
    [(string=? c CHANGE)
     (return-change ms)]))

;; add-value-in-bank : MachineState CustomerInput -> MachineState
;; GIVEN: a machine state and a customer input (in PosInt)
;; RETURNS: the state of the machine with added value in the bank
;; EXAMPLES:
;; (add-value-in-bank COFFEE-MACHINE-5-CUPS 2) = COFFEE-MACHINE-5-CUPS-2-BANKS
(define (add-value-in-bank ms c)
  (make-MachineState 
   (MachineState-coffee ms)
   (MachineState-chocolate ms)
   (+ (MachineState-bank ms) c)
   (string-append "Added Value "
                  (number->string (exact->inexact c)))))

;; dispense-coffee : MachineState -> MachineState
;; GIVEN: a machine state
;; RETURNS: the state of the machine with remove cup of coffee
;; EXAMPLES:
;; (dispense-coffee COFFEE-MACHINE-5-CUPS-2-BANKS) = COFFEE-MACHINE-4-CUPS-0.5-BANKS
;; (dispense-coffee COFFEE-MACHINE-0-CUPS) = (make-MachineState 0 0 0 NOTHING)
;; (dispense-coffee COFFEE-MACHINE-0-CUPS-2-BANKS) = (make-MachineState 0 0 2.0 OUT-OF-ITEM)
;; STRATEGY: combine simpler functions
(define (dispense-coffee ms)
  (cond
    [(< (machine-bank ms) COFFEE-RATE) (copy-machine-state-with-output ms NOTHING)]
    [(and
      (> (machine-remaining-coffee ms) 0) (>= (machine-bank ms) COFFEE-RATE))
     (make-MachineState
      (sub1 (MachineState-coffee ms))
      (MachineState-chocolate ms)
      (- (machine-bank ms) COFFEE-RATE)
      COFFEE)]
    [else (copy-machine-state-with-output ms OUT-OF-ITEM)])
  )

;; copy-machine-state-with-output : MachineState String -> MachineState
;; GIVEN: the machine state and string
;; RETURN: the machine state with given string as machine output
;; EXAMPLES:
;; (copy-machine-state-with-output ms OUT-OF-ITEM) = ((make-MachineState
;;                                                      (MachineState-coffee ms)
;;                                                      (MachineState-chocolate ms)
;;                                                      (MachineState-bank ms)
;;                                                       OUT-OF-ITEM)
(define (copy-machine-state-with-output ms str)
  (make-MachineState
   (MachineState-coffee ms)
   (MachineState-chocolate ms)
   (MachineState-bank ms)
   str))

;; dispense-chocolate : MachineState CustomerInput -> MachineState
;; GIVEN: a machine state
;; RETURNS: the state of the machine with remove cup of chocolate
;; EXAMPLES:
;; (dispense-chocolate COFFEE-MACHINE-5-CUPS-2-BANKS) = COFFEE-MACHINE-4-CUPS-1.4-BANKS
;; (dispense-chocolate COFFEE-MACHINE-0-CUPS) = (make-MachineState 0 0 0 NOTHING)
;; (dispense-chocolate COFFEE-MACHINE-0-CUPS-2-BANKS) = (make-MachineState 0 0 2.0 OUT-OF-ITEM)
;; STRATEGY: combine simpler functions
(define (dispense-chocolate ms)
  (cond
    [(< (machine-bank ms) CHOCOLATE-RATE) (copy-machine-state-with-output ms NOTHING)]
    [(and
      (> (machine-remaining-chocolate ms) 0) (>= (machine-bank ms) CHOCOLATE-RATE))
     (make-MachineState
      (MachineState-coffee ms)
      (sub1 (MachineState-chocolate ms))
      (- (machine-bank ms) CHOCOLATE-RATE)
      CHOCOLATE)]
    [else (copy-machine-state-with-output ms OUT-OF-ITEM)])
)

;; machine-output : MachineState CustomerInput -> MachineOutput
;; GIVEN: a machine state and a customer input
;; RETURNS: a MachineOutput that describes the machine's response to the
;; customer input
;; EXAMPLES:
;; (machine-output COFFEE-MACHINE-5-CUPS 2) = COFFEE-MACHINE-5-CUPS-2-BANKS
;; (machine-output COFFEE-MACHINE-5-CUPS-2-BANKS COFFEE) = COFFEE-MACHINE-4-CUPS-0.5-BANKS
;; (machine-output COFFEE-MACHINE-5-CUPS-2-BANKS CHOCOLATE) = COFFEE-MACHINE-4-CUPS-1.4-BANKS
;; (machine-output COFFEE-MACHINE-4-CUPS-1.4-BANKS CHANGE) = 1.4
(define (machine-output ms c)
  (machine-next-state ms c))

;; machine-remaining-coffee : MachineState -> NonNegInt
;; GIVEN: a machine state
;; RETURNS: the number of cups of coffee left in the machine
;; EXAMPLES:
;; (machine-remaining-coffee COFFEE-MACHINE-5-CUPS-2-BANKS) = 5
(define (machine-remaining-coffee ms)
  (MachineState-coffee ms))

;; machine-remaining-chocolate : MachineState -> NonNegInt
;; GIVEN: a machine state
;; RETURNS: the number of cups of hot chocolate left in the machine
;; EXAMPLES:
;; (machine-remaining-chocolate COFFEE-MACHINE-5-CUPS-2-BANKS) = 5
(define (machine-remaining-chocolate ms)
  (MachineState-chocolate ms))

;; machine-bank : MachineState -> NonNegInt
;; GIVEN: a machine state
;; RETURNS: the amount of money in the machine's bank, in cents
;; EXAMPLES:
;; (machine-bank COFFEE-MACHINE-4-CUPS-1.4-BANKS) = 1.4
(define (machine-bank ms)
  (MachineState-bank ms))

;; return-change : MachineState -> MachineState
;; GIVEN: a machine state
;; RETURNS: the new machine state with all change revoved from the bank
;; EXAMPLES:
;; (return-change COFFEE-MACHINE-4-CUPS-1.4-BANKS) = COFFEE-MACHINE-4-CUPS-0-BANKS
(define (return-change ms)
  (make-MachineState
   (MachineState-coffee ms)
   (MachineState-chocolate ms)
   0
   (get-change (number->string
                (exact->inexact(machine-bank ms))))))

;; render : MachineState -> Image
;; GIVEN: a machine state
;; RETURNS: the user interface of coffee machine
;; EXAMPLES:
;; (reder COFFEE-MACHINE-5-CUPS) = (place-image (overlay (text (MachineState-output COFFEE-MACHINE-5-CUPS) 15 "black")
;;                                   (rectangle 100 50 "outline" "white"))
;;                                     150 225
;;                                     MENU))
(define (render st)
  (place-image (overlay (text (MachineState-output st) 15 "black") (rectangle 100 50 "outline" "white"))
               150 225
               MENU))

;; order : MachineState Integer Integer MouseEvent -> MachineState
;; GIVEN: a machine state, x and y coordinates of the mouse and mouse event
;; RETURNS: the new machine state based on user click
;; EXAMPLES:
;; (order COFFEE-MACHINE-5-CUPS-2-BANKS 150 70 "button-down") = COFFEE-MACHINE-4-CUPS-0.5-BANKS
;; (order COFFEE-MACHINE-5-CUPS-2-BANKS 150 70 "drag") = COFFEE-MACHINE-5-CUPS-2-BANKS
;; STRATEGY: combine simpler functions
(define (order st mx my mev)
  (cond
    [(mouse=? mev "button-down") (get-order st mx my)]
    [else st]))

;; get-order: MachineState Integer Integer -> MachineState
;; GIVEN: a machine state, x and y coordinates of the mouse
;; RETURNS: the new machine state based on user click
;; EXAMPLES:
;; (get-order COFFEE-MACHINE-5-CUPS-1-BANKS 280 40) = COFFEE-MACHINE-5-CUPS-1-BANKS-STEP2
;; (get-order COFFEE-MACHINE-5-CUPS-2-BANKS 150 70) = COFFEE-MACHINE-4-CUPS-0.5-BANKS
;; (get-order COFFEE-MACHINE-5-CUPS-2-BANKS 150 120) = COFFEE-MACHINE-4-CUPS-1.4-BANKS
;; (get-order COFFEE-MACHINE-5-CUPS-2-BANKS 150 170) = COFFEE-MACHINE-5-CUPS-2-BANKS
;; STRATEGY: combine simpler functions
(define (get-order st mx my)
  (cond
    [(and (<= mx SCENE-WIDTH) (<= my 50))
     (machine-output st (get-value mx my))]
    [(and (<= mx SCENE-WIDTH) (<= my 100))
     (machine-output st COFFEE)]
    [(and (<= mx SCENE-WIDTH) (<= my 150))
     (machine-output st CHOCOLATE)]
    [(and (<= mx SCENE-WIDTH) (<= my 200))
     (machine-output st CHANGE)]
    [else st]))

;; get-change : String -> String
;; GIVEN: the bank amount in string
;; RETURNS: new string with bank amount is upto two decimal points
;; EXAMPLES:
;; (get-change "0.01000000") = "0.01"
(define (get-change number)
  (if (> (string-length number) 6)
      (substring number 0 4) 
      number))

;; get-value : Integer Integer -> NonNegInteger
;; GIVEN: x and y coordinate of the mouse click
;; RETURNS: the currency denomination selected by mouse click
;; EXAMPLES:
;; (get-value 40 45) = 1/100
;; (get-value 100 45) = 5/100
;; (get-value 140 45) = 10/100
;; (get-value 200 45) = 25/100
;; (get-value 280 45) = 1
(define (get-value mx my)
  (cond
    [(and (<= mx 60) (and (> my CENT-MIN-WIDTH) (<= my CENT-MAX-WIDTH)) ) 1/100]
    [(and (<= mx 120) (and (> my CENT-MIN-WIDTH) (<= my CENT-MAX-WIDTH))) 5/100]
    [(and (<= mx 180) (and (> my CENT-MIN-WIDTH) (<= my CENT-MAX-WIDTH))) 10/100]
    [(and (<= mx 240) (and (> my CENT-MIN-WIDTH) (<= my CENT-MAX-WIDTH))) 25/100]
    [(and (<= mx SCENE-WIDTH) (and (> my CENT-MIN-WIDTH) (<= my CENT-MAX-WIDTH))) 1]))

;; main method for running program
;; STRATEGY: combine simpler functions
(define (main st)
  (big-bang st
            (to-draw render)
            (on-mouse order)))

;; function application
(main COFFEE-MACHINE-5-CUPS)

;==========================================================================================
;                                      TESTS
;==========================================================================================
(begin-for-test
  ; initial-state
  (check-equal?  (initial-machine 5 5) COFFEE-MACHINE-5-CUPS "The machine should be added with 5 cups each")
  ; machine-next-state
  (check-equal? (machine-next-state COFFEE-MACHINE-5-CUPS 2) COFFEE-MACHINE-5-CUPS-2-BANKS "Banks should be filled with 2 dollors")
  (check-equal? (machine-next-state COFFEE-MACHINE-5-CUPS-2-BANKS COFFEE)  COFFEE-MACHINE-4-CUPS-0.5-BANKS "the new machine should be with 4 cups of coffee and 0.5 in bank")
  (check-equal? (machine-next-state COFFEE-MACHINE-5-CUPS-2-BANKS CHOCOLATE)  COFFEE-MACHINE-4-CUPS-1.4-BANKS "the new machine should be with 4 cups of chocolate and 1.4 in bank")
  (check-equal? (machine-next-state COFFEE-MACHINE-4-CUPS-1.4-BANKS CHANGE) COFFEE-MACHINE-4-CUPS-0-BANKS "machine should give back 1.4 dollor change")
  ; add-value-in-bank
  (check-equal? (add-value-in-bank COFFEE-MACHINE-5-CUPS 2) COFFEE-MACHINE-5-CUPS-2-BANKS "machine bank should be filled with 2 dollors")
  ; dispense-coffee
  (check-equal? (dispense-coffee COFFEE-MACHINE-5-CUPS-2-BANKS) COFFEE-MACHINE-4-CUPS-0.5-BANKS "after dispensing coffee the new machine should have 4 cups of it and bank should reduce by 1.5")
  (check-equal? (dispense-coffee COFFEE-MACHINE-0-CUPS) (make-MachineState 0 0 0 NOTHING) "nothing should be displayed since coffee cups are zero")
  (check-equal? (dispense-coffee COFFEE-MACHINE-0-CUPS-2-BANKS) (make-MachineState 0 0 2.0 OUT-OF-ITEM) "machine output should be out of item")
  ; dispense-chocolate
  (check-equal? (dispense-chocolate COFFEE-MACHINE-5-CUPS-2-BANKS) COFFEE-MACHINE-4-CUPS-1.4-BANKS "after dispensing chocolate the new machine should have 4 cups of it and bank should reduce by 0.6")
  (check-equal? (dispense-chocolate COFFEE-MACHINE-0-CUPS) (make-MachineState 0 0 0 NOTHING)  "nothing should be displayed since chocolate cups are zero")
  (check-equal? (dispense-chocolate COFFEE-MACHINE-0-CUPS-2-BANKS) (make-MachineState 0 0 2.0 OUT-OF-ITEM) "machine output should be out of item")
  ; machine-output
  (check-equal? (machine-output COFFEE-MACHINE-5-CUPS 2) COFFEE-MACHINE-5-CUPS-2-BANKS "Banks should be filled with 2 dollors")
  (check-equal? (machine-output COFFEE-MACHINE-5-CUPS-2-BANKS COFFEE)  COFFEE-MACHINE-4-CUPS-0.5-BANKS "the new machine should be with 4 cups of coffee and 0.5 in bank")
  (check-equal? (machine-output COFFEE-MACHINE-5-CUPS-2-BANKS CHOCOLATE)  COFFEE-MACHINE-4-CUPS-1.4-BANKS "the new machine should be with 4 cups of chocolate and 1.4 in bank")
  (check-equal? (machine-output COFFEE-MACHINE-4-CUPS-1.4-BANKS CHANGE) COFFEE-MACHINE-4-CUPS-0-BANKS "machine should give back 1.4 dollor change")
  ; machine-remaining-coffee
  (check-equal? (machine-remaining-coffee COFFEE-MACHINE-5-CUPS-2-BANKS) 5 "should return 5 remaining cups of coffee")
  ; machine-remaining-chocolate
  (check-equal? (machine-remaining-chocolate COFFEE-MACHINE-5-CUPS-2-BANKS) 5 "should return 5 remaining cups of chocolate")
  ; machine-bank
  (check-equal? (machine-bank COFFEE-MACHINE-4-CUPS-1.4-BANKS) 1.4 "should return 1.4 as a remaining bank amount")
  ; return change
  (check-equal? (return-change COFFEE-MACHINE-4-CUPS-1.4-BANKS) COFFEE-MACHINE-4-CUPS-0-BANKS "after returning change the coffee machine bank should be 0")
  ;; render
  (check-equal? (render COFFEE-MACHINE-5-CUPS) (place-image (overlay (text (MachineState-output COFFEE-MACHINE-5-CUPS) 15 "black") (rectangle 100 50 "outline" "white"))
                                                            150 225
                                                            MENU) "the redered image should show exact state of the coffee machine")
  ;; order
  (check-equal? (order COFFEE-MACHINE-5-CUPS-2-BANKS 150 70 "button-down") COFFEE-MACHINE-4-CUPS-0.5-BANKS "the bank shoul be reduced to 0.5 after dispensing coffee")
  (check-equal? (order COFFEE-MACHINE-5-CUPS-2-BANKS 150 70 "drag") COFFEE-MACHINE-5-CUPS-2-BANKS "for mouse event other than click machine should remain same")
  ;; get-order
  (check-equal? (get-order COFFEE-MACHINE-5-CUPS-1-BANKS 280 40) COFFEE-MACHINE-5-CUPS-1-BANKS-STEP2 "the bank amount should be 1")
  (check-equal? (get-order COFFEE-MACHINE-5-CUPS-2-BANKS 150 70) COFFEE-MACHINE-4-CUPS-0.5-BANKS "machine bank amount should be 0.5 and output should be coffee")
  (check-equal? (get-order COFFEE-MACHINE-5-CUPS-2-BANKS 150 120) COFFEE-MACHINE-4-CUPS-1.4-BANKS "machine bank amount should be 1.4 and output should be hot chocolate")
  (check-equal? (get-order COFFEE-MACHINE-5-CUPS-2-BANKS 150 170) COFFEE-MACHINE-5-CUPS-0-BANKS "machine bank amount should be 0 and output should be 2.0")
  ;; get-change
  (check-equal? (get-change "0.01000000") "0.01" "the string should be at most length of four")
  ;; get-value
  (check-equal? (get-value 40 45) 1/100 "should return 1/100")
  (check-equal? (get-value 100 45) 5/100 "should return 5/100")
  (check-equal? (get-value 140 45) 10/100 "should return 10/100")
  (check-equal? (get-value 200 45) 25/100 "should return 25/100")
  (check-equal? (get-value 280 45) 1 "should return 1")
  )