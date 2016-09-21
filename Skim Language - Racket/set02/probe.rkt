;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname probe) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Program for simulating probe in trap
;; Author: Ajay Baban Kauthale
;; Date: 09/24/2015

(require rackUnit)
(require "extras.rkt")

(provide
 probe-at
 probe-turned-left
 probe-forward
 probe-north?
 probe-south?
 probe-east?
 probe-west?)

;==========================================================================================
;                                      DATA DEFINITIONS
;==========================================================================================
(define-struct probe (image x y facing))
;; A Probe is a (make-probe Image Integer Integer String)
;; INTERPRETATION:
;; the image of the probe
;; the x co-ordinate of the probe
;; the y co-ordinate of the probe
;; the direction on which the probe is facing
;; probe-fn : Probe -> ??
#;(define (probe-fn pb)
    ... (probe-image pb)
    (probe-x pb)
    (probe-y pb)
    (probe-facing pb) ....)

;==========================================================================================
;                                      CONSTANTS
;==========================================================================================
;; Constant for probe diameter
(define PROBE-DM 40)
;; Constant for probe image
(define PROBE-IMAGE (circle (/ PROBE-DM 2) "solid" "blue"))
;; Constant for prob step
(define PROBE-STEP 1)
;; Constant for the trap
(define TRAP (square 347 "solid" "black"))
;; Constant for maximum  x and y coordinates of trap
(define TRAP-MAX 347)
(define TRAP-MIN 0)
;; Constants for wall boundries
(define TRAP-WALL-WEST-X 21)
(define TRAP-WALL-EAST-X 326)
(define TRAP-WALL-NORTH-Y 21)
(define TRAP-WALL-SOUTH-Y 326)
;; Constants for trap center
(define TRAP-CENTER-X 173.5)
(define TRAP-CENTER-Y 173.5)
;; Constans for directions
(define NORTH "north")
(define SOUTH "south")
(define EAST "east")
(define WEST "west")
;; Constants for probe facing various directions
(define PROBE-NORTH (make-probe PROBE-IMAGE TRAP-CENTER-X TRAP-CENTER-Y NORTH))
(define PROBE-SOUTH (make-probe PROBE-IMAGE TRAP-CENTER-X TRAP-CENTER-Y SOUTH))
(define PROBE-EAST (make-probe PROBE-IMAGE TRAP-CENTER-X TRAP-CENTER-Y EAST))
(define PROBE-WEST (make-probe PROBE-IMAGE TRAP-CENTER-X TRAP-CENTER-Y WEST))
;; Constans for probe after moving to vaious directions
(define PROBE-FORWARD-NORTH (make-probe PROBE-IMAGE TRAP-CENTER-X (- TRAP-CENTER-Y 1) NORTH))
(define PROBE-FORWARD-SOUTH (make-probe PROBE-IMAGE TRAP-CENTER-X (+ TRAP-CENTER-Y 1) SOUTH))
(define PROBE-FORWARD-EAST (make-probe PROBE-IMAGE (+ TRAP-CENTER-X 1) TRAP-CENTER-Y EAST))
(define PROBE-FORWARD-WEST(make-probe PROBE-IMAGE (- TRAP-CENTER-X 1) TRAP-CENTER-Y WEST))
;; Constants for probe when it is at the edge of trap
(define PROBE-NORTH-EDGE (make-probe PROBE-IMAGE TRAP-CENTER-X (- TRAP-WALL-NORTH-Y 1) NORTH))
(define PROBE-SOUTH-EDGE (make-probe PROBE-IMAGE TRAP-CENTER-X (+ TRAP-WALL-SOUTH-Y 1) SOUTH))
(define PROBE-EAST-EDGE (make-probe PROBE-IMAGE (+ TRAP-WALL-EAST-X 1) TRAP-CENTER-Y EAST))
(define PROBE-WEST-EDGE (make-probe PROBE-IMAGE (- TRAP-WALL-WEST-X 1) TRAP-CENTER-Y WEST))
;; Constants for probe after it crossed the wall
(define PROBE-CROSSED-NORTH (make-probe PROBE-IMAGE TRAP-CENTER-X -20 NORTH))
(define PROBE-CROSSED-SOUTH (make-probe PROBE-IMAGE TRAP-CENTER-X 367 SOUTH))
(define PROBE-CROSSED-EAST (make-probe PROBE-IMAGE 367 TRAP-CENTER-Y EAST))
(define PROBE-CROSSED-WEST (make-probe PROBE-IMAGE -20 TRAP-CENTER-Y WEST))
;; Constants for probe after wall has been crossed
(define PROBE-NORTH-AFTER-WALL (make-probe PROBE-IMAGE TRAP-CENTER-X -1 NORTH))
(define PROBE-SOUTH-AFTER-WALL (make-probe PROBE-IMAGE TRAP-CENTER-X 350 SOUTH))
(define PROBE-EAST-AFTER-WALL (make-probe PROBE-IMAGE 350 TRAP-CENTER-Y EAST))
(define PROBE-WEST-AFTER-WALL (make-probe PROBE-IMAGE -1 TRAP-CENTER-Y WEST))

;==========================================================================================
;                                      FUNCTIONS
;==========================================================================================
;; probe-at : Integer Integer -> Probe
;; GIVEN: an x-coordinate and a y-coordinate
;; WHERE: these coordinates leave the robot entirely inside the trap
;; RETURNS: a probe with its center at those coordinates, facing north.
;; EXAMPLES:
;; (probe-at TRAP-CENTER-X TRAP-CENTER-Y) = PROBE-NORTH
(define (probe-at x y)
  (make-probe
   PROBE-IMAGE
   x
   y
   NORTH)
  )

;; probe-turned-left : Probe -> Probe
;; GIVEN: a probe
;; RETURNS: a probe like the original, but turned 90 degrees left
;; EXAMPLES:
;; (probe-turned-left PROBE-NORTH) = PROBE-WEST
;; (probe-turned-left PROBE-WEST) = PROBE-SOUTH
;; (probe-turned-left PROBE-EAST) = PROBE-NORTH
;; (probe-turned-left PROBE-SOUTH) = PROBE-EAST
;; STRATEGY: combine simpler functions
(define (probe-turned-left pb)
  (cond
    [(probe-north? pb)
     (probe-turned-west pb)]
    [(probe-south? pb)
     (probe-turned-east pb)]
    [(probe-east? pb)
     (probe-turned-north pb)]
    [(probe-west? pb)
     (probe-turned-south pb)])
  )

;; probe-turned-west : Probe -> Probe
;; GIVEN: a probe
;; RETURNS: a probe like the original, but turned to west
;; EXAMPLES:
;; (probe-turned-west PROBE-NORTH) = PROBE-WEST
;; STRATEGY: combine simpler functions
(define (probe-turned-west pb)
  (change-probe-facing
   pb
   WEST)
  )

;; probe-turned-east : Probe -> Probe
;; GIVEN: a probe
;; RETURNS: a probe like the original, but turned to east
;; EXAMPLES:
;; (probe-turned-east PROBE-SOUTH) = PROBE-EAST
;; STRATEGY: combine simpler functions
(define (probe-turned-east pb)
  (change-probe-facing
   pb
   EAST)
  )

;; probe-turned-north : Probe -> Probe
;; GIVEN: a probe
;; RETURNS: a probe like the original, but turned to north
;; EXAMPLES:
;; (probe-turned-north PROBE-EAST) = PROBE-NORTH
;; STRATEGY: combine simpler functions 
(define (probe-turned-north pb)
  (change-probe-facing
   pb
   NORTH)
  )

;; probe-turned-south : Probe -> Probe
;; GIVEN: a probe
;; RETURNS: a probe like the original, but turned to south
;; EXAMPLES:
;; (probe-turned-south PROBE-WEST) = PROBE-SOUTH
;; STRATEGY: combine simpler functions
(define (probe-turned-south pb)
  (change-probe-facing
   pb
   SOUTH)
  )

;; change-probe-facing : Probe String -> Probe
;; GIVEN: a probe and facing
;; RETURNS: a probe like the original, but turned to given facing
;; EXAMPLES:
;; (change-probe-facing PROBE-WEST SOUTH) = PROBE-SOUTH
(define (change-probe-facing pb fc)
  (make-probe
   (probe-image pb)
   (probe-x pb)
   (probe-y pb)
   fc)
  )

;; probe-turned-right : Probe -> Probe
;; GIVEN: a probe
;; RETURNS: a probe like the original, but turned 90 degree.
;; EXAMPLES:
;; (probe-turned-right PROBE-NORTH) = PROBE-EAST
;; (probe-turned-right PROBE-WEST) = PROBE-NORTH
;; (probe-turned-right PROBE-EAST) = PROBE-SOUTH
;; (probe-turned-right PROBE-SOUTH) = PROBE-WEST
;; STRATEGY: combine simpler functions
(define (probe-turned-right pb)
  (cond
    [(probe-north? pb)
     (probe-turned-east pb)]
    [(probe-south? pb)
     (probe-turned-west pb)]
    [(probe-east? pb)
     (probe-turned-south pb)]
    [(probe-west? pb)
     (probe-turned-north pb)])
  )

;; probe-forward : Probe PosInt -> Probe
;; GIVEN: a probe and a distance
;; RETURNS: a probe like the given one, but moved forward by the
;; specified distance.  If moving forward the specified distance would
;; cause the probe to hit any wall of the trap, then the probe should 
;; move as far as it can inside the trap, and then stop.
;; EXAMPLES:
;; (probe-forward PROBE-NORTH PROBE-STEP) = PROBE-FORWARD-NORTH
;; (probe-forward PROBE-SOUTH PROBE-STEP) = PROBE-FORWARD-SOUTH
;; (probe-forward PROBE-EAST PROBE-STEP) = PROBE-FORWARD-EAST
;; (probe-forward PROBE-WEST PROBE-STEP) = PROBE-FORWARD-WEST
;; STRATEGY: combine simpler functions
(define (probe-forward pb dist)
  (cond
    [(probe-north? pb)
     (forward-north pb dist)]
    [(probe-south? pb)
     (forward-south pb dist)]
    [(probe-east? pb)
     (forward-east pb dist)]
    [(probe-west? pb)
     (forward-west pb dist)])
  )

;; forward-north : Probe PosInt -> Probe
;; GIVEN: a probe and a distance
;; RETURNS: the probe similar to given one, but moved to north by given distance
;; EXAMPLES:
;; (forward-north PROBE-NORTH PROBE-STEP) = PROBE-FORWARD-NORTH
;; (forward-north PROBE-NORTH-EDGE PROBE-STEP) = PROBE-CROSSED-NORTH
;; STRATEGY: combine simpler functions
(define (forward-north pb dist)
  (if (>= (probe-y pb) TRAP-WALL-NORTH-Y)
      (get-probe-by-spec
       pb (probe-x pb) (- (probe-y pb) dist))
      (get-probe-by-spec
       pb (probe-x pb) (- (probe-y pb) PROBE-DM)))
  )

;; forward-south : Probe PosInt -> Probe
;; GIVEN: a probe and a distance
;; RETURNS: the probe similar to given one, but moved to south by given distance
;; EXAMPLES:
;; (forward-south PROBE-SOUTH PROBE-STEP) = PROBE-FORWARD-SOUTH
;; (forward-south PROBE-SOUTH-EDGE PROBE-STEP) = PROBE-CROSSED-SOUTH
;; STRATEGY: combine simpler functions
(define (forward-south pb dist)
  (if (<= (probe-y pb) TRAP-WALL-SOUTH-Y)
      (get-probe-by-spec
       pb (probe-x pb) (+ (probe-y pb) dist))
      (get-probe-by-spec
       pb (probe-x pb) (+ (probe-y pb) PROBE-DM)))
  )

;; forward-east : Probe PosInt -> Probe
;; GIVEN: a probe and a distance
;; RETURNS: the probe similar to given one, but moved to east by given distance
;; EXAMPLES:
;; (forward-east PROBE-EAST PROBE-STEP) = PROBE-FORWARD-EAST
;; (forward-east PROBE-EAST-EDGE PROBE-STEP) = PROBE-CROSSED-EAST
;; STRATEGY: combine simpler functions
(define (forward-east pb dist)
  (if (<= (probe-x pb) TRAP-WALL-EAST-X)
      (get-probe-by-spec
       pb (+ (probe-x pb) dist) (probe-y pb))
      (get-probe-by-spec
       pb (+ (probe-x pb) PROBE-DM) (probe-y pb)))
  )

;; forward-west : Probe PosInt -> Probe
;; GIVEN: a probe and a distance
;; RETURNS: the probe similar to given one, but moved to west by given distance
;; EXAMPLES:
;; (forward-west PROBE-WEST PROBE-STEP) = PROBE-FORWARD-WEST
;; (forward-west PROBE-WEST-EDGE PROBE-STEP) = PROBE-CROSSED-WEST
;; STRATEGY: combine simpler functions
(define (forward-west pb dist)
  (if (>= (probe-x pb) TRAP-WALL-WEST-X)
      (get-probe-by-spec
       pb (- (probe-x pb) dist) (probe-y pb))
      (get-probe-by-spec
       pb (- (probe-x pb) PROBE-DM) (probe-y pb)))
  )

;; get-probe-by-spec : Probe Integer Integer -> Probe
;; GIVEN: a probe and new x and y co-ordinates
;; RETURNS: the probe similar to given one, but changed x and y co-ordiantes
;; EXAMPLES:
;; (get-probe-by-spec PROBE-NORTH (probe-x PROBE-NORTH) (- (probe-y PROBE-NORTH) PROBE-STEP) = PROBE-FORWARD-NORTH
(define (get-probe-by-spec pb x y)
  (make-probe
   (probe-image pb)
   x
   y
   (probe-facing pb))
  )


;; probe-north? : Probe -> Boolean
;; GIVEN: a probe
;; RETURNS: returns true iff the probe facing to north location
;; EXAMPLES:
;; (probe-north? PROBE-NORTH) = true
;; (probe-north? PROBE-SOUTH) = false
;; STRATEGY: structural decomposition of probe
(define (probe-north? pb)
  (string=? (probe-facing pb) NORTH))

;; probe-south? : Probe -> Boolean
;; GIVEN: a probe
;; RETURNS: returns true iff the probe facing to south location
;; EXAMPLES:
;; (probe-south? PROBE-NORTH) = false
;; (probe-south? PROBE-SOUTH) = true
;; STRATEGY: structural decomposition of probe
(define (probe-south? pb)
  (string=? (probe-facing pb) SOUTH))

;; probe-east? : Probe -> Boolean
;; GIVEN: a probe
;; RETURNS: returns true iff the probe facing to east location
;; EXAMPLES:
;; (probe-east? PROBE-NORTH) = false
;; (probe-east? PROBE-EAST) = true
;; STRATEGY: structural decomposition of probe
(define (probe-east? pb)
  (string=? (probe-facing pb) EAST))

;; probe-west? : Probe -> Boolean
;; GIVEN: a probe
;; RETURNS: returns true iff the probe facing to east location
;; EXAMPLES:
;; (probe-west? PROBE-NORTH) = false
;; (probe-west? PROBE-WEST) = true
;; STRATEGY: structural decomposition of probe
(define (probe-west? pb)
  (string=? (probe-facing pb) WEST))

;; main method for running program
(define (main pb)
  (big-bang pb
            (to-draw render)
            (on-key move-probe)
            (stop-when wall-crossed?)))

;; wall-crossed? : Probe -> Boolean
;; Given: a Probe
;; RETURNS: true iff the wall has been crossed by the probe
;; EXAMPLES:
;; (wall-crossed? PROBE-NORTH-AFTER-WALL) = true
;; (wall-crossed? PROBE-SOUTH-AFTER-WALL) = true
;; (wall-crossed? PROBE-EAST-AFTER-WALL) = true
;; (wall-crossed? PROBE-WEST-AFTER-WALL) = true
;; STRATEGY: structural decomposition of probe
(define (wall-crossed? pb)
  (cond
    [(probe-north? pb)
     (< (probe-y pb) TRAP-MIN)]
    [(probe-south? pb)
     (> (probe-y pb) TRAP-MAX)]
    [(probe-east? pb)
     (> (probe-x pb) TRAP-MAX)]
    [(probe-west? pb)
     (< (probe-x pb) TRAP-MIN)])
  )

;; reder : Probe -> Image
;; Given: a Probe
;; RETURNS: a Probe in the Trap after arrow button clicks
;; EXAMPLES:
;; (render PROBE-NORTH) = (place-image (probe-image PROBE-NORTH)
;;               (probe-x PROBE-NORTH) (probe-y PROBE-NORTH)
;;               TRAP)
;; STRATEGY: structural decomposition of probe
(define (render pb)
   (place-image (probe-with-coordinates pb)
               (probe-x pb) (probe-y pb)
               TRAP)
  )

;;
(define (probe-with-coordinates pb)
  (overlay (text (string-append "(" (number->string (- (exact->inexact (probe-x pb)) TRAP-CENTER-X))
                                ", "
                                (number->string (- (exact->inexact (probe-y pb)) TRAP-CENTER-Y)) ")") 12 "white")
           (probe-image pb))
  )

;; move-probe : Probe -> Probe
;; Given: a Probe
;; RETURNS: a Probe after varous arrow button moves
;; EXAMPLES:
;; (move-probe PROBE-NORTH "left") = PROBE-WEST
;; (move-probe PROBE-NORTH "right") = PROBE-EAST
;; (move-probe PROBE-NORTH "up") = PROBE-FORWARD-NORTH
;; (move-probe PROBE-NORTH "down") = PROBE-NORTH
;; STRATEGY: structural decomposition of probe and combine simpler functions
(define (move-probe pb ke)
  (cond
    [(key=? ke "left") (probe-turned-left pb)]
    [(key=? ke "right") (probe-turned-right pb)]
    [(key=? ke "up") (probe-forward pb PROBE-STEP)]
    [else pb])
  )

;; program application
(main (probe-at TRAP-CENTER-X TRAP-CENTER-X))


;==========================================================================================
;                                      TESTS
;==========================================================================================
(begin-for-test
  ; probe-at
  (check-equal? (probe-at TRAP-CENTER-X TRAP-CENTER-Y) PROBE-NORTH "probes initial position should be at the center of trap")
  ; probe-turned-left
  (check-equal? (probe-turned-left PROBE-NORTH) PROBE-WEST "probe should be turned to 90 degrees left in west")
  (check-equal? (probe-turned-left PROBE-WEST) PROBE-SOUTH "probe should be turned to 90 degrees left in south")
  (check-equal? (probe-turned-left PROBE-EAST) PROBE-NORTH "probe should be turned to 90 degrees left in north")
  (check-equal? (probe-turned-left PROBE-SOUTH) PROBE-EAST "probe should be turned to 90 degrees left in east")
  ; probe-forward
  (check-equal? (probe-forward PROBE-NORTH PROBE-STEP) PROBE-FORWARD-NORTH "probe should be moved north by 1 step")
  (check-equal? (probe-forward PROBE-SOUTH PROBE-STEP) PROBE-FORWARD-SOUTH "probe should be moved south by 1 step")
  (check-equal? (probe-forward PROBE-EAST PROBE-STEP) PROBE-FORWARD-EAST "probe should be moved east by 1 step")
  (check-equal? (probe-forward PROBE-WEST PROBE-STEP) PROBE-FORWARD-WEST "probe should be moved west by 1 step")
  ; probe-turned-right
  (check-equal? (probe-turned-right PROBE-NORTH) PROBE-EAST "probe should be turned to 90 degrees right in east")
  (check-equal? (probe-turned-right PROBE-WEST) PROBE-NORTH "probe should be turned to 90 degrees right in north")
  (check-equal? (probe-turned-right PROBE-EAST) PROBE-SOUTH "probe should be turned to 90 degrees right in south")
  (check-equal? (probe-turned-right PROBE-SOUTH) PROBE-WEST "probe should be turned to 90 degrees right in west")
  ; probe-turned-west
  (check-equal? (probe-turned-west PROBE-NORTH) PROBE-WEST "probe should be turned to west")
  ; probe-turned-east
  (check-equal? (probe-turned-east PROBE-SOUTH) PROBE-EAST "probe should be turned of east")
  ; probe-turned-north
  (check-equal? (probe-turned-north PROBE-EAST) PROBE-NORTH "probe should be turned of north")
  ; probe-turned-south
  (check-equal? (probe-turned-south PROBE-WEST) PROBE-SOUTH "probe should be turned of south")
  ; forward-north
  (check-equal? (forward-north PROBE-NORTH PROBE-STEP) PROBE-FORWARD-NORTH "probe should be moved north by 1 step")
  (check-equal? (forward-north PROBE-NORTH-EDGE PROBE-STEP) PROBE-CROSSED-NORTH "probe should have crossed trap in north")
  ; forward-south
  (check-equal? (forward-south PROBE-SOUTH PROBE-STEP) PROBE-FORWARD-SOUTH "probe should be moved south by 1 step")
  (check-equal? (forward-south PROBE-SOUTH-EDGE PROBE-STEP) PROBE-CROSSED-SOUTH "probe should have crossed trap in south")
  ; forward-east
  (check-equal? (forward-east PROBE-EAST PROBE-STEP) PROBE-FORWARD-EAST "probe should be moved east by 1 step")
  (check-equal? (forward-east PROBE-EAST-EDGE PROBE-STEP) PROBE-CROSSED-EAST "probe should have crossed trap in east")
  ; forward-west
  (check-equal? (forward-west PROBE-WEST PROBE-STEP) PROBE-FORWARD-WEST "probe should be moved west by 1 step")
  (check-equal? (forward-west PROBE-WEST-EDGE PROBE-STEP) PROBE-CROSSED-WEST "probe should have crossed trap in west")
  ; probe-north?
  (check-equal? (probe-north? PROBE-NORTH) true "should be return true for probe facing north")
  (check-equal? (probe-north? PROBE-SOUTH) false "should be return false for probe not facing north")
  ; probe-south?
  (check-equal? (probe-south? PROBE-NORTH) false "should be return false for probe not facing south")
  (check-equal? (probe-south? PROBE-SOUTH) true "should be return true for probe facing south")
  ; probe-east?
  (check-equal? (probe-east? PROBE-NORTH) false "should be return false for probe not facing east")
  (check-equal? (probe-east? PROBE-EAST) true "should be return true for probe facing east")
  ; probe-west?
  (check-equal? (probe-west? PROBE-NORTH) false "should be return false for probe not facing west")
  (check-equal? (probe-west? PROBE-WEST) true "should be return true for probe facing west")
  ; wall-crossed?
  (check-equal? (wall-crossed? PROBE-NORTH-AFTER-WALL) true "should be return true for probe crossed wall by north")
  (check-equal? (wall-crossed? PROBE-SOUTH-AFTER-WALL) true "should be return true for probe crossed wall by south")
  (check-equal? (wall-crossed? PROBE-EAST-AFTER-WALL) true "should be return true for probe crossed wall by east")
  (check-equal? (wall-crossed? PROBE-WEST-AFTER-WALL) true "should be return true for probe crossed wall by west")
  ; render
  (check-equal? (render PROBE-NORTH) (place-image (overlay (text (string-append
                                                                  "(" (number->string (- (exact->inexact (probe-x PROBE-NORTH)) TRAP-CENTER-X))
                                                                  ", "
                                                                  (number->string (- (exact->inexact (probe-y PROBE-NORTH)) TRAP-CENTER-Y))
                                                                  ")") 12 "white")
                                                           (probe-image PROBE-NORTH))
                                                  (probe-x PROBE-NORTH) (probe-y PROBE-NORTH)
                                                  TRAP) "both images should be same")
  ; move-probe
  (check-equal? (move-probe PROBE-NORTH "left") PROBE-WEST "probe should be moved 90 degrees left")
  (check-equal? (move-probe PROBE-NORTH "right") PROBE-EAST "probe should be moved 90 degrees right")
  (check-equal? (move-probe PROBE-NORTH "up") PROBE-FORWARD-NORTH "probe should be moved 1 step forward")
  (check-equal? (move-probe PROBE-NORTH "down") PROBE-NORTH "probe should be remained same")			  
  )
