;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname outlines) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Program for Outline

;(check-location "07" "outlines.rkt")

(require rackunit)
(require 2htdp/universe)
(require 2htdp/image)
(require "extras.rkt")
(require "sets.rkt")

(provide legal-flat-rep?)
(provide tree-rep-to-flat-rep)

;=========================================================================================
;                                      DATA DEFINITIONS
;=========================================================================================
(define-struct section (name subsections))
;; A Section is a (make-section String ListOfSection)
;; INTERPRETATION:
;; name is the name of the section
;; subsections is a list of sub-sections under the sections

;; TEMPLATE:
;; section-fn : Section -> ??
#|(define (section-fn s)
  ....
  (section-name s)
  (section-subsections s)
  ....)|#

;; A List of Section (ListOfSection) is one of:
;; -- empty
;; -- (cons s ListOfSection)
;; INTERPRETATION:
;; empty represents the empty list
;; (cons s ListOfSection) represents the list of Section with newly added section s

;; TEMPLATE:
;; listOfSection-fn : ListOfSection -> ??
#|(define (listOfSection-fn secs)
  (cond
    [(empty? secs) ... ]
    [else (... (first secs)
               (listOfSection-fn (rest secs)))]))|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct outline (sections))
;; A Outline is a (make-outline ListOfSection)
;; INTERPRETATION:
;; sections is a list of sections present in the outline

;; TEMPLATE:
;; outline-fn : Outline -> ??
#|(define (outline-fn o)
  ....
  (outline-sections o)
  ....)|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct sectionLine (lon name))
;; A SectionLine is a (make-sectionLine ListOfNumber String)
;; INTERPRETATION:
;; lon - is a list of numbers which represents the section number
;;       ex.- (list 1 2 1) represent the section 1.2.1
;; name - is a name of the particular section name

;; TEMPLATE:
;; line-fn : Line -> ??
#|(define (line-fn l)
  ....
  (line-lon l)
  (line-name l)
  ....)|#

;; A List of SectionLine (ListOfSectionLine) is one of:
;; -- empty
;; -- (cons l ListOfSectionLine)
;; INTERPRETATION:
;; empty represents the empty list
;; (cons l ListOfSectionLine) represents the list of SectionLine with newly added
;; SectionLine l

;; TEMPLATE:
;; listOfSectionLine-fn : ListOfSectionLine -> ??
#|(define (listOfSectionLine-fn lines)
  (cond
    [(empty? lines) ... ]
    [else (... (first lines)
               (listOfSectionLine-fn (rest lines)))]))|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct flatRep (lines))
;; A FlatRep is a (make-flatrep ListOfLine)
;; INTERPRETATION:
;; lines is a list of Line present in the FlatRep

;; TEMPLATE:
;; flatRep-fn : FlatRep -> ??
#|(define (flatRep-fn fr)
  ....
  (flatRep-lines fr)
  ....)|#

;=========================================================================================
;                                      FUNCTIONS
;=========================================================================================
;; legal-flat-rep? : ListOfLine -> Boolean
;; GIVEN: A ListOfSectionLine
;; RETURNS: true iff it is a legal flat representation of an outline
;; EXAMPLES: see the tests below

;; STRATEGY:
(define (legal-flat-rep? lines)
  (check-legal-flat-rep? (first lines) (rest lines)))

;; TESTS:
;; constants for testing
(define legal-flat-rep-1
   (list
    (make-sectionLine (list 1) "The first section")
    (make-sectionLine (list 1 1) "A subsection with no subsections")
    (make-sectionLine (list 1 2) "Another subsection")
    (make-sectionLine (list 1 2 1) "This is a subsection of 1.2")
    (make-sectionLine (list 1 2 2) "This is another subsection of 1.2")
    (make-sectionLine (list 1 3) "The last subsection of 1")
    (make-sectionLine (list 2) "Another section")
    (make-sectionLine (list 2 1) "More stuff")
    (make-sectionLine (list 2 2) "Still more stuff")))
(define illegal-flat-rep-1
   (list
    (make-sectionLine (list 1) "The first section")
    (make-sectionLine (list 1 1) "A subsection with no subsections")
    (make-sectionLine (list 1 2) "Another subsection")
    (make-sectionLine (list 1 2 1) "This is a subsection of 1.2")
    (make-sectionLine (list 1 2 2 1) "This is another subsection of 1.2")
    (make-sectionLine (list 1 3) "The last subsection of 1")
    (make-sectionLine (list 2) "Another section")
    (make-sectionLine (list 2 1) "More stuff")
    (make-sectionLine (list 2 2) "Still more stuff")))
(define legal-flat-rep-2
  (list
     (make-sectionLine (list 1) "The first section")
     (make-sectionLine (list 1 1) "A subsection with no subsections")
     (make-sectionLine (list 1 2) "Another subsection")
     (make-sectionLine (list 1 2 1) "This is a subsection of 1.2")
     (make-sectionLine (list 1 2 2) "This is another subsection of 1.2")
     (make-sectionLine (list 1 2 2 1) "1.2.2.1")
     (make-sectionLine (list 1 2 2 2) "1.2.2.2")
     (make-sectionLine (list 1 2 3) "1.2.3")
     (make-sectionLine (list 1 2 3 1) "1.2.2.1")
     (make-sectionLine (list 1 2 3 2) "1.2.2.1")
     (make-sectionLine (list 1 2 3 3) "1.2.2.1")
     (make-sectionLine (list 1 2 4) "The last subsection of 1")
     (make-sectionLine (list 1 3) "The last subsection of 1")
     (make-sectionLine (list 2) "Another section")
     (make-sectionLine (list 2 1) "More stuff")
     (make-sectionLine (list 2 2) "Still more stuff")
     (make-sectionLine (list 2 3) "Still more stuff")))

(begin-for-test
  (check-equal? (legal-flat-rep? legal-flat-rep-1) #t)
  (check-equal? (legal-flat-rep? illegal-flat-rep-1)  #f)
  (check-equal? (legal-flat-rep? legal-flat-rep-2) #t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Helper Functions for legal-flat-rep?;;;;;;;;;;;;;;;;;;;;;;;;

;; check-legal-flat-rep? : Line ListOfLine -> Boolean
;; GIVEN: a Line which is part of larger ListOfSectionLine lol0 and ListOfLine
;; WHERE: lines is the ListOfSectionLine that occurs after the Line line (i.e. rest lines
;; after the Line line) and lol0 is the big list of line which contains both Line line and
;; ListOfSectionLine lines
;; EXAMPLES: see the tests below

;; STRATEGY: 
(define (check-legal-flat-rep? line lines)
  (cond
    [(empty? lines) true]
    [else
     (and
      (line-correct? line (first lines))
      (check-legal-flat-rep? (first lines) (rest lines)))]))

;; TESTS:
;; constants for testing
(define sections-list-1
  (list
   (make-sectionLine (list 1 1) "A subsection with no subsections")
   (make-sectionLine (list 1 2) "Another subsection")
   (make-sectionLine (list 1 2 1) "This is a subsection of 1.2")))
(define sections-list-2
  (list
   (make-sectionLine (list 1 2 2 1) "This is another subsection of 1.2")))

(begin-for-test
  (check-equal? (check-legal-flat-rep?
                 (make-sectionLine (list 1) "The first section")
                 sections-list-1) #t)
  (check-equal? (check-legal-flat-rep?
                 (make-sectionLine (list 1) "The first section") empty) #t)
  (check-equal? (check-legal-flat-rep?
                 (make-sectionLine (list 1 2 1) "This is a subsection of 1.2")
                 sections-list-2) #f))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; line-correct? : SectionLine SectionLine -> Boolean
;; GIVEN: two SectionLine
;; WHERE: the given lines are consecutive SectionLine in the ListOfSectionLine lol0
;; RETURNS: true iff the two SectionLine conforms with the outline
;; EXAMPLES: see tests below

;; STRATEGY:
(define (line-correct? line1 line2)
  (cond
    [(= (length (sectionLine-lon line1)) (length (sectionLine-lon line2)))
     (next-line-correct-for-same-size?
      (sectionLine-lon line1) (sectionLine-lon line2))]
    [(< (length (sectionLine-lon line1)) (length (sectionLine-lon line2)))
     (next-line-correct-for-first-less-than-second?
      (sectionLine-lon line1) (sectionLine-lon line2))]
    [(> (length (sectionLine-lon line1)) (length (sectionLine-lon line2)))
     (next-line-correct-for-first-greater-than-second?
      (sectionLine-lon line1) (sectionLine-lon line2))]))

;; TESTS:
(begin-for-test
  (check-equal? (line-correct?
                 (make-sectionLine (list 1 2) "a")
                 (make-sectionLine (list 1 2) "a")) #f)
  (check-equal? (line-correct?
                 (make-sectionLine (list 1 2) "a")
                 (make-sectionLine (list 1 3) "a")) #t)
  (check-equal? (line-correct?
                 (make-sectionLine (list 1) "a")
                 (make-sectionLine (list 2) "a")) #t)
  (check-equal? (line-correct?
                 (make-sectionLine (list 1 2) "a")
                 (make-sectionLine (list 1 2 1) "a")) #t)
  (check-equal? (line-correct?
                 (make-sectionLine (list 1 2) "a")
                 (make-sectionLine (list 1 2 1 2) "a")) #f)
  (check-equal? (line-correct?
                 (make-sectionLine (list 1 2 1) "a")
                 (make-sectionLine (list 1 2 1 1) "a")) #t)
  (check-equal? (line-correct?
                 (make-sectionLine (list 1 2 1 1) "a")
                 (make-sectionLine (list 1 3) "a")) #t)
  (check-equal? (line-correct?
                 (make-sectionLine (list 1 2 1 1) "a")
                 (make-sectionLine (list 1 4) "a")) #f))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; next-line-correct-for-same-size? : SectionLine SectionLine -> Boolean 
(define (next-line-correct-for-same-size? line1 line2)
  (if (> (length line2) 1)
      (and (all-prev-numbers-same? (get-sub-list line1 (- (length line1) 1) 1)
                                   (get-sub-list line2 (- (length line2) 1) 1))
           (= (get-number-at-pos line2 (length line2) 1)
              (+ 1 (get-number-at-pos line1 (length line1) 1))))
      (= (get-number-at-pos line2 (length line2) 1)
         (+ 1 (get-number-at-pos line1 (length line1) 1)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; next-line-correct-for-first-greater-than-second? : SectionLine SectionLine -> Boolean 
(define (next-line-correct-for-first-greater-than-second? line1 line2)
  (= (+ 1 (get-number-at-pos line1 (length line2) 1))
     (get-number-at-pos line2 (length line2) 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; next-line-correct-for-first-greater-than-second? : SectionLine SectionLine -> Boolean
;; EXAMPLES:
;; (next-line-correct-for-first-less-than-second? (list 1 2 1) (list 1 2 2 1))

;; STRATEGY:
(define (next-line-correct-for-first-less-than-second? line1 line2)
  (and (all-prev-numbers-same? line1 (get-sub-list line2 (length line1) 1))
       (= (get-number-at-pos line2 (length line2) 1) 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; all-prev-numbers-same? : ListOfNumber ListOfNumber -> Boolean
;; GIVEN: two ListOfNumber
;; WHERE: both the ListOfNumber have same number of elements
;; RETURNSL true iff the 
(define (all-prev-numbers-same? lon1 lon2)
  (cond
    [(and (empty? lon1) (empty? lon2)) #t]
    [else
     (and
      (if (= (first lon1) (first lon2))
         #t
         #f)
      (all-prev-numbers-same? (rest lon1) (rest lon2)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get-number-at-pos : ListOfNumber NonNegNumber NonNegNumber -> Number
;; GIVEN: a ListOfNumber and number representing position
;; RETURNS: the number from the list at the given position
;; EXAMPLES:
;; (get-number-at-pos (list 1 2 3 4 5 6) 4 1) = 4
;; (get-number-at-pos empty 4 1) = -1

;; STRATEGY:
(define (get-number-at-pos lon pos n)
  (cond
    [(empty? lon) -1]
    [else
     (if (= n pos)
         (first lon)
         (get-number-at-pos (rest lon) pos (+ 1 n)))]))

;; TESTS:
(begin-for-test
  (check-equal? (get-number-at-pos (list 1 2 3 4 5 6) 4 1) 4)
  (check-equal? (get-number-at-pos empty 4 1) -1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get-sub-list : ListOfNumber NonNegInt NonNegInt -> ListOfNumber
;; GIVEN: a ListOfNumber, size and number
;; WHERE: the size indicates the size of the sub-list and number n idicate the current
;; element position in the list lon
;; RETURNS: the sub-list from the given list
;; WHERE: the sub-list will be from first element to the element at size position
;; EXAMPLES:
;; (get-sub-list (list 1 2 3 4) 2 1) = (list 1 2)
;; (get-sub-list empty 2 1) = empty

;; STRATEGY:
(define (get-sub-list lon size n)
  (cond
    [(empty? lon) empty]
    [else
     (if (not (equal? size n))
         (cons
          (first lon)
          (get-sub-list (rest lon) size (+ 1 n)))
         (cons
          (first lon)
          empty))]))

;; TESTS:
(begin-for-test
  (check-equal? (get-sub-list (list 1 2 3 4) 2 1) (list 1 2))
  (check-equal? (get-sub-list empty 2 1) empty))

;=========================================================================================

;; tree-rep-to-flat-rep : Outline -> FlatRep
;; GIVEN: the representation of an outline as a list of Sections
;; RETURNS: the flat representation of the outline
;; EXAMPLES: see the tests below

;; STRATEGY: using more general function, further using template of Outline on outline
(define (tree-rep-to-flat-rep outline)
  (get-flat-rep (outline-sections outline) empty 1))

;; TESTS:
(begin-for-test
  (check-equal? (tree-rep-to-flat-rep valid-outline-1)
                legal-flat-rep-1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get-line : Section ListOfNumber PosNumber -> LisOfSectionLine
;; GIVEN: a Section, lon- ListOfNumber and n- positive number
;; WHERE: lon contain the previous list of indexes of the section and n represents the
;; current section index. i.e lon can be (list 1 2) and n can be 1
;; RETURNS: the list of sectionLine from the given section
;; EXAMPLES: see the tests below

;; STRATEGY: using recursion template of Section/LoS on section, further using template of
;; section
(define (get-line section lon n)
  (append
   (list (make-sectionLine (append lon (list n)) (section-name section)))
   (get-flat-rep (section-subsections section) (append lon (list n)) 1)))

;; TESTS:
;; constants for testing
(define section-1
  (make-section "The first section"
                (list
                 (make-section "A subsection with no subsections" empty)
                 (make-section "Another subsection"
                               (list
                                (make-section "This is a subsection of 1.2" empty)
                                (make-section "This is another subsection of 1.2" empty)))
                 (make-section "The last subsection of 1" empty))))

(define legal-flat-rep-3
  (list
   (make-sectionLine (list 1) "The first section")
   (make-sectionLine (list 1 1) "A subsection with no subsections")
   (make-sectionLine (list 1 2) "Another subsection")
   (make-sectionLine (list 1 2 1) "This is a subsection of 1.2")
   (make-sectionLine (list 1 2 2) "This is another subsection of 1.2")
   (make-sectionLine (list 1 3) "The last subsection of 1")))

(begin-for-test
  (check-equal? (get-line section-1 empty 1) legal-flat-rep-3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get-flat-rep : ListOfSections ListOfNumber PosNumber -> ListOfSectionLine
;; GIVEN: a ListOfSections, lon- ListOfNumber and n- positive number
;; WHERE: lon contain the previous list of indexes of the section and n represents the
;; current section index. i.e lon can be (list 1 2) and n can be 1
;; EXAMPLES:
;;  (get-flat-rep (outline-sections valid-outline-1) empty 1) = legal-flat-rep-1

;; STRATEGY: using recursion template of Section/LoS on sections
(define (get-flat-rep sections lon n)
  (cond
    [(empty? sections) empty]
    [else
     (append
      (get-line (first sections) lon n)
      (get-flat-rep (rest sections) lon (+ n 1)))]))

;; TESTS:
;; constants for testing
(define valid-outline-1
  (make-outline
   (list 
    (make-section "The first section"
                  (list
                   (make-section "A subsection with no subsections" empty)
                   (make-section "Another subsection"
                                 (list
                                  (make-section "This is a subsection of 1.2" empty)
                                  (make-section "This is another subsection of 1.2" empty
                                                )))
                   (make-section "The last subsection of 1" empty)))
    (make-section "Another section"
                  (list
                   (make-section "More stuff" empty)
                   (make-section "Still more stuff" empty))))))

(begin-for-test
  (check-equal?
   (get-flat-rep (outline-sections valid-outline-1) empty 1) legal-flat-rep-1))