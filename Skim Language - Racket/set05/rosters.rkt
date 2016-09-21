;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname rosters) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; Author: Ajay Baban Kauthale
;; Date: 10/14/2015
;; Program for screensaver-5 using HOF

;(check-location "05" "rosters.rkt")

(require rackunit)
(require "extras.rkt")

(provide make-enrollment enrollment-student enrollment-class make-roster
         roster-classname roster-students)

;=========================================================================================
;                                      DATA DEFINITIONS
;=========================================================================================
;; A SetOfX is a list of X's without duplication.  Two SetOfX's are
;; considered equal if they have the same members.
;; Example: (list (list 1 2) (list 2 1)) is NOT a SetOfSetOfNumber,
;; because (list 1 2) and (list 2 1) represent the same set of numbers.

;; Student is a String of alphabets representing the student name ex. "Feng", "Amy" etc.
;; Class and Class name are String of characters for representing class name ex. "PDP-1", "PDP-2", "IR" etc.

;; A SetOfStudent is a list of Student is one of:
;; -- empty
;; -- (cons e SetOfStudent)
;; INTERPRETATION:
;; empty represents the empty list
;; (cons e SetOfStudent) represents the list of Student with newly added
;; student s

;; TEMPLATE:
;; SetOfEnrollment-fn -> ??
#|(define (SetOfEnrollment-fn enrollments)
  (cond
    [(empty? enrollments) ... ]
    [else (... (first enrollments)
               (SetOfEnrollment-fn (rest enrollments)))]))|#

(define-struct enrollment (student class))
;; An Enrollment is a (make-enrollment Student Class)
;; INTERPRTATION:
;; student is a name of the student and it should only accepts alphabets
;; class is a name of the student's class

;; TEMPLATE: enrollment-fn -> ??
#|(define (enrollment-fn e)
  ....
  (enrollment-student e)
  (enrollment-class e)
  ....)|#

;; A SetOfEnrollment is a list of enrollment is one of:
;; -- empty
;; -- (cons e SetOfEnrollment)
;; INTERPRETATION:
;; empty represents the empty list
;; (cons e SetOfEnrollment) represents the list of enrollment with newly added
;; enrollment e

;; TEMPLATE:
;; SetOfEnrollment-fn -> ??
#|(define (SetOfEnrollment-fn enrollments)
  (cond
    [(empty? enrollments) ... ]
    [else (... (first enrollments)
               (SetOfEnrollment-fn (rest enrollments)))]))|#

;; Examples for testing:
(define enrollment-set (list (make-enrollment "John" "PDP")
                             (make-enrollment "Kathryn" "Networks")
                             (make-enrollment "Feng" "PDP")
                             (make-enrollment "Amy" "PDP")
                             (make-enrollment "Amy" "Networks")))
(define enrollment-set-PDP (list (make-enrollment "John" "PDP")
                                 (make-enrollment "Feng" "PDP")
                                 (make-enrollment "Amy" "PDP")))
(define enrollment-set-NW (list (make-enrollment "Kathryn" "Networks")
                                (make-enrollment "Amy" "Networks")))

(define-struct roster (classname students))
;; A Roster is a (make-roster Class SetOfStudent)
;; INTERPRETATION:
;; classname is a name of the class present in the roster, for each class there is
;; unique entry in roster
;; SetOfStudent is a list of students belonging to the class

;; TEMPLATE: roster-fn -> ??
#|(define (roster-fn r)
  ....
  (roster-classname)
  (roster-students)
  ....)|#

;; Examples for testing
(define pdp-roster-1 (make-roster "PDP" (list "John" "Feng" "Amy")))
(define pdp-roster-2 (make-roster "PDP" (list "John" "Feng" "Amy")))
(define pdp-roster-3 (make-roster "PDP" (list "John" "Feng" "Amy" "gef")))
(define ir-roster (make-roster "IR" (list "abc" "cde" "efg")))
(define fcn-roster (make-roster "FCN" (list "abc" "pqr" "que")))
(define networks-roster (make-roster "Networks" (list "Kathryn" "Amy")))

;; A SetOfRoster is a list of roster is one of:
;; -- empty
;; -- (cons r SetOfRoster)
;; INTERPRETATION:
;; empty represents the empty list
;; (cons r SetOfRoster) represents the list of roster with newly added roster r

;; TEMPLATE:
;; SetOfRoster-fn -> ??
#|(define (SetOfRoster-fn rosters)
  (cond
    [(empty? rosters) ... ]
    [else (... (first rosters)
               (SetOfRoster-fn (rest rosters)))]))|#

;; Examples for testing
(define roster-set (list pdp-roster-1 networks-roster))
(define roster-set-1 (list pdp-roster-3))
(define roster-set-2 (list pdp-roster-1 networks-roster ir-roster))
(define roster-set-3 (list networks-roster pdp-roster-1))

;; rosterset1 and rosterset2 are used for depicting rosters of different or similar
;; classes

;=========================================================================================
;                                      FUNCTIONS
;=========================================================================================
;; roster=? : Roster Roster -> Boolean
;; GIVEN: two Roster's
;; RETURNS: true iff the two arguments represent the same roster
;; EXAMPLES:
;; (roster=? pdp-roster-1 pdp-roster-2) = true
;; (roster=? pdp-roster-1 pdp-roster-3) = false
;; (roster=? pdp-roster-1 ir-roster) = false
;; (roster=? pdp-roster-1 fcn-roster) = false

;; STRATEGY: using template of Roster on roster1 and roster2
(define (roster=? roster1 roster2)
  (and
   (equal? (roster-classname roster1) (roster-classname roster2))
   (set=? (roster-students roster1) (roster-students roster2))
   (set=? (roster-students roster2) (roster-students roster1))))

;;;; Helper Functions for roster=? ;;;

;; set=? : SetOfX SetOfX -> Boolean
;; GIVEN: two Sets SetOfX
;; WHERE: X can be student or roster
;; RETURNS: true iff the two set contains the same elements
;; EXAMPLES:

;; STRATEGY: using HOF andmap on set1
(define (set=? set1 set2)
  (andmap
   ;; X -> Boolean
   ;; GIVEN: element from the set1
   ;; RETURNS: true iff the element of set1 is present in set2
   (lambda (set1-elt) (my-member? set1-elt set2))
   set1))

;; my-member? : X SetOfX-> Boolean
;; GIVEN: a X and SetOfX
;; WHERE: X can be of student or roster
;; RETURNS: true iff the given string is present in SetOfString
;; EXAMPLES:

;; STARTEGY: use HOF ormap on set
(define (my-member? elt set)
  (ormap
   ;; X -> Boolean
   ;; GIVEN: element from the set
   ;; RETURNS: true iff the element of set matches with the elt
   (lambda (set-elt) (equal? set-elt elt))
   set))

;; TESTS:
(begin-for-test
  ;; test for rosters with same class and same set of students
  (check-equal? (roster=? pdp-roster-1 pdp-roster-2) true
                "roster=? should return true since both rosters have same elements")
  ;; test for rosters with same class and different set of students
  (check-equal? (roster=? pdp-roster-1 pdp-roster-3) false
                "roster=? should return false since both rosters have same class  but
                different students")
  ;; test for roster with different class and same set of students
  (check-equal? (roster=? pdp-roster-1 ir-roster) false
                "roster=? should return false since both rosters have same students but
                different class")
  ;; test for roster with different class and different set of students
  (check-equal? (roster=? pdp-roster-1 fcn-roster) false
                "roster=? should return false since both rosters have different elements
                and different students"))

;=========================================================================================
;; rosterset=? : SetOfRoster SetOfRoster -> Boolean
;; GIVEN: two SetOfRoster rosterset1 and rosterset1
;; RETURNS: true iff the two arguments represent the same set of rosters
;; EXAMPLES:
;; (rosterset=? roster-set roster-set) = true
;; (rosterset=? roster-set roster-set-1) = false
;; (rosterset=? roster-set roster-set-2) = false

;; STRATEGY: combine using simpler functions
(define (rosterset=? rosterset1 rosterset2)
  (and
   (set=? rosterset1 rosterset2)
   (set=? rosterset2 rosterset1)))

;; TESTS:
(begin-for-test
  (check-equal? (rosterset=? roster-set roster-set-3) true
                "rosterset=? should return true since both the roster are same")
  (check-equal? (rosterset=? roster-set roster-set-1) false
                "rosterset=? should return false since both the roster are not same")
  (check-equal? (rosterset=? roster-set roster-set-2) false
                "rosterset=? should return false since both the roster are not same"))

;=========================================================================================
;; enrollments-to-rosters : SetOfEnrollment -> SetOfRoster
;; GIVEN: a set of enrollments
;; RETURNS: the set of class rosters for the given enrollments
;; EXAMPLES:
;; (enrollments-to-rosters enrollment-set) = roster-set

;; STRATEGY: use template of SetOfEnrollment on set
(define (enrollments-to-rosters set)
  (cond
    [(empty? set) empty]
    [else
     (cons
      (create-roster (first set) set)
      (enrollments-to-rosters
       (remove-duplicate (rest set) (first set))))]))


;;;; Helper Functions for enrollments-to-rosters ;;;;

;; create-roster : Enrollment SetOfEnrollment -> Roster
;; GIVEN: an Enrollment and SetOfEnrollment
;; RETURNS: Roster with class from enrollment and list of student present with same class
;; (in SetOfEnrollment)
;; EXAMPLES:
;; (create-roster (make-enrollment "John" "PDP") enrollment-set) =
;; (make-roster "PDP" (list "John" "Feng" "Amy"))

;; STRATEGY: using template of Enrollment on enroll
(define (create-roster enroll enrollmentset)
  (make-roster
   (enrollment-class enroll)
   (get-class-students (filter-by-class (enrollment-class enroll) enrollmentset))))

;; remove-duplicate : SetOfEnrollment Enrollment -> SetOfEnrollment
;; GIVEN: a SetOfEnrollment and Enrollment
;; RETURNS: the SetOfEnrollment after removing any enrollment's
;; present for class same as class of Enrollment
;; EXAMPLES:
;; (remove-duplicate enrollment-set (make-enrollment "John" "PDP")) = enrollment-set-NW

;; STRATEGY: using template of Enrollment on enroll
(define (remove-duplicate enrollmentset enroll)
  (remove-forward-duplicate enrollmentset (enrollment-class enroll)))

;; filter-by-class : String SetOfEnrollment -> SetOfEnrollment
;; GIVEN: class name and set of enrollment
;; WHERE: SetOfEnrollment contains all enrollment irrespective of the class
;; RETURNS: all enrollments for the particular class
;; EXAMPLES:
;; (filter-by-class "PDP" enrollment-set) = enrollment-set-PDP

;; STRATEGY: use HOF filter on enrollment-set
(define (filter-by-class class enrollment-set)
  (filter
   ;; Enrollment -> Boolean
   ;; GIVEN: an Enrollment
   ;; RETURNS: true iff Class of Enrollment is same as class
   (lambda (enroll) (class-equal? enroll class))
   enrollment-set))

;; class-equal? : Enrollment Class -> Boolean
;; GIVEN: an Enrollment and Class
;; RETURNS: true iff Class of the Enrollment same as Class
;; EXAMPLES:
;; (class-equal? (make-enrollment "John" "PDP") "PDP") = true

;; STRATEGY: using template of Enrollment on enroll
(define (class-equal? enroll class)
  (equal? (enrollment-class enroll) class))

;; get-class-students : SetOfEnrollment -> SetOfStudent
;; GIVEN: set of enrollment
;; WHERE: SetOfEnrollment represents enrollments for only one class
;; RETURNS: all students for the particular class
;; EXAMPLES:
;; (get-class-students enrollment-set) = (list "John" "Feng" "Amy")

;; STRATEGY: use HOF foldr on enrollment-set
(define (get-class-students enrollment-set)
  (foldr cons empty
         (map
          ;; Enrollment -> Student
          ;; GIVEN: an Enrollment
          ;; RETURNS: sudent from the enrollment
          (lambda (enroll) (get-student enroll))
          enrollment-set)))

;; get-student : Enrollment -> Student
;; GIVEN: an Enrollment
;; RETURN: student from the enrollment
;; EXAMPLES:
;; (get-student (make-enrollment "John" "PDP")) = "John"

;; STRATEGY: using template of Enrollment on enroll
(define (get-student enroll)
  (enrollment-student enroll))

;; remove-forward-duplicate : SetOfEnrollment String -> SetOfEnrollment
;; GIVEN: set of enrollment and class name
;; WHERE: class name represent the class for which the roster is already created
;; RETURNS: a SetOfEnrollment by removing enrollments for the class name
;; EXAMPLES:
;; (remove-forward-duplicate enrollment-set "PDP") = enrollment-set-NW

;; STRATEGY: use HOF filter on enrollment-set
(define (remove-forward-duplicate enrollment-set class)
  (filter
   ;; Enrollment -> Boolean
   ;; GIVEN: an Enrollment
   ;; RETURNS: true iff class of Enrollment is not same as class
   (lambda (enroll) (not (class-equal? enroll class)))
   enrollment-set))

;; TESTS:
(begin-for-test
  (check-equal? (enrollments-to-rosters enrollment-set) roster-set
                "enrollments-to-rosters should return the set of rosters with class name
                 and student list")
  (check-equal? (create-roster (make-enrollment "John" "PDP") enrollment-set)
                (make-roster "PDP" (list "John" "Feng" "Amy"))
                "create-roster should return the roster of class PDP"))
;=========================================================================================