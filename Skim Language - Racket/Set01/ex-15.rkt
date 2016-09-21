; Program to extract first 1String
; Author: Ajay Kauthale
; Date: 09/12/2015

; Indicate that we are using racket language
#lang racket

; Functions
; string-first: Function to extract first 1String
; Parameters
;          input-string: Input string given by user
(define (string-first input-string)
  (if (and (string? input-string)
           (not (equal? null input-string))
           (> (string-length input-string) 0))
      (substring input-string 0 1)
      (error "Argument should be of type String and non-empty!")
  )
 )