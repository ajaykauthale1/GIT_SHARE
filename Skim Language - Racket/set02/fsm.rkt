;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname fsm) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Author: Ajay Baban Kauthale
;; Date: 09/23/2015
;; Program finite state machine

(require rackunit)
(require "extras.rkt")

(provide
 initial-state
 next-state
 accepting-state?
 error-state?)

;==========================================================================================
;                                      DATA DEFINITIONS
;==========================================================================================
;; MachineInput is one of
;; -- "a", "b", "c", "d", "e" or "f"
;; INTERPRETATION: self evident
;; TEMPLATE:
#;(define (MachineInput-fn in)
    (cond
      [... (string=? in "c") ...]
      [... (or (string=? in "a") (string? in "b")
               ...)]
      [... (or (string=? in "e") (string? in "f")
               ...)]))

;; State is one of
;; -- 1 interpretation: Initial state of fsm
;; -- 2 interpretation: Intermediate state of fsm
;; -- 3 interpretation: Final state of fsm
;; TEMPLATE:
#;(define (State-fn st)
    (cond
      [(= st INITIAL-STATE) ...]
      [(= st INTERMEDIATE-STATE) ...]
      [(= st FINAL-STATE) ...]))

;==========================================================================================
;                                      CONSTANTS
;==========================================================================================
;; Constants for various states
(define INITIAL-STATE 1)
(define INTERMEDIATE-STATE 2)
(define FINAL-STATE 3)
(define FALSE-STATE -1)


;==========================================================================================
;                                      FUNCTIONS
;==========================================================================================
;; initial-state : Number -> State
;; GIVEN: a number
;; RETURNS: a representation of the initial state of your machine.  The given number is ignored.
;; EXAMPLES:
;; (initial-state 5) = INITIAL-STATE
(define (initial-state number)
  1) 

;; next-state : State MachineInput -> State
;; GIVEN: a state of the machine and a machine input
;; RETURNS: the state that should follow the given input.
;; EXAMPLES:
;; (next-state INITIAL-STATE "c") = INTERMEDIATE-STATE
;; (next-state INITIAL-STATE "a") = INITIAL-STATE
;; (next-state INITIAL-STATE "b") = INITIAL-STATE
;; (next-state INTERMEDIATE-STATE "a") = INTERMEDIATE-STATE
;; STRATEGY: Structural Decomposition on st and in 
(define (next-state st in)
  (cond
    [(and (= st INITIAL-STATE) (string=? in "c"))
     INTERMEDIATE-STATE]
    [(and (= st INITIAL-STATE)
          (or (string=? in "a") (string=? in "b")))
     INITIAL-STATE]
    [(and (= st INTERMEDIATE-STATE) (string=? in "d"))
     FINAL-STATE]
    [(and (= st INTERMEDIATE-STATE)
          (or (string=? in "a") (string=? in "b")))
     INTERMEDIATE-STATE]
    [(and (= st FINAL-STATE)
          (or (string=? in "e") (string=? in "f")))
     FINAL-STATE]
    [else FALSE-STATE]))

;; accepting-state? : State -> Boolean
;; GIVEN: a state of the machine
;; RETURNS: true iff the given state is a final (accepting) state
;; EXAMPLES:
;; (accepting-state? 3) = true
;; (accepting-state? 1) = false
;; STRATEGY: none
(define (accepting-state? st)
  (= st FINAL-STATE))

;; error-state? : State -> Boolean
;; GIVEN: a state of the machine
;; RETURNS: true iff there is no path (empty or non-empty) from the given state to an accepting state
;; EXAMPLES:
;; (error-state? -1) = true
;; (error-state? 2) = false
;; STRATEGY: none
(define (error-state? st)
  (not
   (or
    (= st INITIAL-STATE) (= st INTERMEDIATE-STATE) (= st FINAL-STATE))))

;; string-first : NonEmptyString -> 1String
;; GIVEN: the non empty string
;; RETURNS: the extracted first 1String of the given string
;; EXAMPLES:
;; (string-first "Hello I am Ajay") = "H"
;; (string-first "Good to see you") = "G"
;; STRATEGY: none
(define (string-first input-string)
  (substring input-string 0 1))

;; string-rest : NonEmptyString -> 1String
;; GIVEN: the non empty string
;; RETURNS: the extracted string by removing first character
;; EXAMPLES:
;; (string-rest "Hello") = "ello"
;; (string-rest "Good") = "ood"
;; STRATEGY: none
(define (string-rest input-string)
  (substring input-string 1))

;; check-fsm : State MachineInput -> String
;; GIVEN: state of the machine and input string
;; RETURNS:
;; "accepted" iff the string is accepted by the FSM
;; "not accepted" if string is not accepted by the FSM
;; EXAMPLES:
;; (check-fsm (initial-state 2) "cd") = "accepted"
;; (check-fsm (initial-state 2) "abcbdef") = "accepted"
;; (check-fsm (initial-state 2) "aacbadf") = "accepted"
;; (check-fsm (initial-state 2) "abc") = "not accepted"
;; (check-fsm (initial-state 2) "abdbcef") = "not accepted"
;; STARTEGY: combine simpler functions
(define (check-fsm st in)
  (cond
    [(accepting-state? st) "accepted"]
    [(or
      (= (string-length in) 0)
      (error-state? st)) "not accepted"]
    [else (check-fsm
           (next-state st (string-first in))
           (string-rest in))]))


;; function application for string "abcbdef"
(check-fsm (initial-state 2) "abcbdef")

;==========================================================================================
;                                      TESTS
;==========================================================================================
(begin-for-test
(check-= (initial-state 5) INITIAL-STATE 0.0 "the initial state should be returned")
(check-= (next-state INITIAL-STATE "c") INTERMEDIATE-STATE 0.0 "when input is 'c' and state is 1 then it should return state 2")
(check-= (next-state INITIAL-STATE "a") INITIAL-STATE 0.0 "when input is 'a' and state is 1 then it should return state 1")
(check-= (next-state INITIAL-STATE "b") INITIAL-STATE 0.0 "when input is 'b' and state is 1 then it should return state 1")
(check-= (next-state INTERMEDIATE-STATE "a") INTERMEDIATE-STATE 0.0 "when input is 'a' and state is 2 then it should return state 2")
(check-= (next-state INTERMEDIATE-STATE "b") INTERMEDIATE-STATE 0.0 "when input is 'b' and state is 2 then it should return state 2")
(check-= (next-state INTERMEDIATE-STATE "d") FINAL-STATE 0.0 "when input is 'd' and state is 2 then it should return state 3")
(check-= (next-state FINAL-STATE "e") FINAL-STATE 0.0 "when input is 'e' and state is 3 then it should return state 3")
(check-= (next-state FINAL-STATE "f") FINAL-STATE 0.0 "when input is 'f' and state is 3 then it should return state 3")
(check-= (next-state FINAL-STATE "d") FALSE-STATE 0.0 "when input is 'd' and state is 3 then it should return error state")
(check-equal? (accepting-state? 3) true "the state 3 should be acceptab;e")
(check-equal? (accepting-state? 1) false "the state 1 should not be acceptable")
(check-equal? (error-state? -1) true "the state -1 should be error state")
(check-equal? (error-state? 2) false "the state 2 should not be error state")
(check-equal? (string-first "Hello I am Ajay") "H" "the function should return first character")
(check-equal? (string-first "Good to see you") "G" "the function should return first character")
(check-equal? (string-rest "Hello") "ello" "the function should return string by removing first character")
(check-equal? (string-rest "Good") "ood" "the function should return string by removing first character")
(check-equal? (check-fsm (initial-state 2) "cd") "accepted" "the fsm should accept string 'cd'")
(check-equal? (check-fsm (initial-state 2) "abcbdef") "accepted" "ths fsm should accept string 'abcbdef'")
(check-equal? (check-fsm (initial-state 2) "aacbadf") "accepted" "ths fsm should accept string 'aacbadf'")
(check-equal? (check-fsm (initial-state 2) "abc") "not accepted" "ths fsm should not accept string 'abc'")
(check-equal? (check-fsm (initial-state 2) "abdbcef") "not accepted" "ths fsm should not accept string 'abdbcef'")
)


