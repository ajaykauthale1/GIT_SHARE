;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname editor) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Program to simulate the editor
;; Author: Ajay Kauthale
;; Date: 09/24/2015

(require rackunit)
(require "extras.rkt")

(provide
 make-editor
 editor-pre
 editor-post
 edit
 )

;===========================================================================================================
;                                             Data Definitions
;===========================================================================================================
(define-struct editor (pre post))
;; A editor is a (make-editor String String)
;; INTERPRETATION:
;; the prefix string
;; the postfix string
;; editor-fn : Editor -> ??
#;(define (editor-fn ed)
    (... (editor-pre ed)
         (editor-post ed)))

;===========================================================================================================
;                                             Constants
;===========================================================================================================
;; Constant for cursor
(define CURSOR "|")
;; Constant for test editor created for testing
(define TEST-EDITOR (make-editor (string-append "Hello " CURSOR) "World"))

;===========================================================================================================
;                                             Functions
;===========================================================================================================
;; edit : Editor KeyEvent -> Editor
;; GIVEN: the editor and key event
;; RETURNS: the new editor based on key events
;; EXAMPLES:
;; (edit TEST-EDITOR "a") = (make-editor "Hello a|" "World")
;; (edit TEST-EDITOR "\b") = (make-editor "Hello|" "World")
;; STRATEGY: combine simpler functions
(define (edit ed ke)
  (cond
    [(key=? "\b" ke) (delete-char ed)]
    [else (insert-char ed ke)])
  )

;; insert-char : Editor KeyEvent -> Editor
;; GIVEN: the editor and key event
;; RETURNS: the new editor with added character
;; EXAMPLES:
;; (insert-char TEST-EDITOR "a") = (make-editor "Hello a|" "World")
;; (insert-char TEST-EDITOR " ") = (make-editor "Hello  |" "World")
;; (insert-char TEST-EDITOR "left") = (make-editor "Hello|" " World")
;; (insert-char TEST-EDITOR "right") = (make-editor "Hello W|" "orld")
;; (insert-char TEST-EDITOR "shift") = (make-editor "Hello |" "World")
;; STRATEGY: combine simpler functions
(define (insert-char ed ch)
  (cond
    [(string=? "left" ch) (move-left ed)]
    [(string=? "right" ch) (move-right ed)]
    [else (if (= (string-length ch) 1)
              (make-editor
               (insert-char-after-pre (editor-pre ed) ch)
               (editor-post ed))
              ed)])
  )

;; insert-char-after-pre : String String -> String
;; GIVEN: the String and character to insert
;; RETURNS: the new String with inserted character at the end
;; EXAMPLES:
;; (insert-char-after-pre "Hello|" "c") = "Helloc|"
(define (insert-char-after-pre pre ch)
  (string-append
   (string-append
    (substring pre 0
               (sub1 (string-length pre))) ch)
   CURSOR)
  )

;; delete-last-char-pre : String -> String
;; GIVEN: the String
;; RETURNS: the new String with deleted character at the end
;; EXAMPLES:
;; (delete-last-char-pre "Hello |") = "Hello|"
(define (delete-last-char-pre pre)
  (string-append
   (substring pre
              0 (- (string-length pre) 2)) CURSOR)
  )

;; delete-char : Editor -> Editor
;; GIVEN: the editor
;; RETURNS: the new editor with deleted character
;; EXAMPLES:
;; (delete-char TEST-EDITOR) = (make-editor "Hello" "World")
;; STRATEGY: combine simpler functions
(define (delete-char ed)
  (if (= (string-length (editor-pre ed)) 1)
      ed
      (make-editor
       (delete-last-char-pre (editor-pre ed))
       (editor-post ed)))
  )

;; move-right : Editor -> Editor
;; GIVEN: the editor
;; RETURNS: the new editor with cursor moved by one character righ
;; EXAMPLES:
;; (move-right TEST-EDITOR) = (make-editor "Hello W" "orld")
;; STRATEGY: combine simpler functions
(define (move-right ed)
  (if (= (string-length (editor-post ed)) 0)
      ed
      (make-editor
       (move-cursor-right (editor-pre ed) (editor-post ed))
       (substring (editor-post ed) 1))
      )
  )

;; move-cursor-right : String String -> String
;; GIVEN: the Strings of pre and post
;; RETURNS: the new String with appended first post char before cursor
;; EXAMPLES:
;; (move-cursor-right "Hello |" "World") = "Hello W|"
(define (move-cursor-right pre post)
  (string-append
   (string-append
    (substring pre
               0 (- (string-length pre) 1))
    (string-ith post 0)) CURSOR)
  )

;; move-left : Editor -> Editor
;; GIVEN: the editor
;; RETURNS: the new editor with cursor moved by one character left
;; EXAMPLES:
;; (move-left TEST-EDITOR) = (make-editor "Hello|" " World")
;; STRATEGY: combine simpler functions
(define (move-left ed)
  (if (= (string-length (editor-pre ed)) 1)
      ed
      (make-editor
       (delete-last-char-pre (editor-pre ed))
       (move-cursor-left (editor-pre ed) (editor-post ed))
       ))
  )

;; move-cursor-left : String String -> String
;; GIVEN: the Strings of pre and post
;; RETURNS: the new String with appended last pre character to the post
;; EXAMPLES:
;; (move-cursor-left "Hello |" "World") = " World"
(define (move-cursor-left pre post)
  (string-append
   (string-ith pre (- (string-length pre) 2))
   post)
  )

;; show-editor : Editor -> image
;; GIVEN: the editor
;; RETURNS: the image of editor panel
;; EXAMPLES:
;; (show-editor TEST-EDITOR) =  (overlay/align "left" "center"
;;                                              (text "Hello |World" 14 "black")
;;                                              (empty-scene 400 50))
;; 
(define (show-editor ed)
  (overlay/align "left" "center"
                 (text (string-append (editor-pre ed) (editor-post ed)) 14 "black")
                 (empty-scene 400 50))
  )

;; main function
(define (main txt)
  (big-bang txt
            [to-draw show-editor]
            [on-key edit])
  )

;; Program application
(main TEST-EDITOR)

;===========================================================================================================
;                                             TESTS
;===========================================================================================================
(begin-for-test
  ; edit
  (check-equal? (edit TEST-EDITOR "a") (make-editor "Hello a|" "World") "'a' should be inserted before cursor")
  (check-equal? (edit TEST-EDITOR "\b") (make-editor "Hello|" "World") "the cursor should move to one characted left")
  ; insert-char
  (check-equal? (insert-char TEST-EDITOR "a") (make-editor "Hello a|" "World") "'a' should be inserted before cursor")
  (check-equal? (insert-char TEST-EDITOR " ") (make-editor "Hello  |" "World") "space should be inserted before cursor")
  (check-equal? (insert-char TEST-EDITOR "left") (make-editor "Hello|" " World")  "cursor should be moved left")
  (check-equal? (insert-char TEST-EDITOR "right") (make-editor "Hello W|" "orld") "cursor should be moved right")
  (check-equal? (insert-char TEST-EDITOR "shift") (make-editor "Hello |" "World") "the editor should be unchanged")
  ; insert-char-after-pre
  (check-equal? (insert-char-after-pre "Hello|" "c") "Helloc|" "'c' should be inserted before cursor")
  ; delete-last-char-pre
  (check-equal? (delete-last-char-pre "Hello |") "Hello|" "characted before cursor should be deleted")
  ; delete-char
  (check-equal? (delete-char TEST-EDITOR) (make-editor "Hello|" "World") "The space before cursor should be deleted")
  ; move-right
  (check-equal? (move-right TEST-EDITOR) (make-editor "Hello W|" "orld") "cursor should be moved right")
  ; move-cursor-right
  (check-equal? (move-cursor-right "Hello |" "World") "Hello W|" "cursor should be moved right")
  ; move-left
  (check-equal? (move-left TEST-EDITOR)  (make-editor "Hello|" " World") "cursor should be moved left")
  ; move-cursor-left
  (check-equal? (move-cursor-left "Hello |" "World") " World" "cursor should be moved left")
  ; show-editor
  (check-equal? (show-editor TEST-EDITOR)  (overlay/align "left" "center"
                                                          (text "Hello |World" 14 "black")
                                                          (empty-scene 400 50)) "the editor should be displayed")
  )
