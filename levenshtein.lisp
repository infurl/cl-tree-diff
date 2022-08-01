;===============================================================================================================================
;
;   project:    common-lisp
;   file:       levenshtein.lisp
;   author:     Andrew Smith
;   created:    2022-08-01
;   updated:    2022-08-01
;   language:   Common Lisp (SBCL)
;   licence:    AGPL-3.0-only or AGPL-3.0-or-later
;
;   Copyright 2022, Andrew Smith <http://asmith.id.au>
;
;   Tree comparison based on Levenshtein distance.
;
;===============================================================================================================================

(defpackage :levenshtein
  (:use :cl)
  (:export #:+delete+ #:+insert+ #:+static+ #:+update+
           #:diff_trees))

(in-package :levenshtein)

(defconstant +delete+ :-)
(defconstant +insert+ :+)
(defconstant +static+ :=)
(defconstant +update+ :/)


;-------------------------------------------------------------------------------------------------------------------------------

(defun diff_trees (list1 list2)
  "Report the differences between two trees using Levenshtein distance."
  (cond ((and (listp list1) (listp list2))
         (let* ((length1 (list-length list1))
                (length2 (list-length list2))
                (results (make-array (list (1+ length1) (1+ length2)) :initial-element nil)))
           (labels ((edit_minp (edit1 edit2 edit3)
                      "True if edit1 is not longer than edit2 or edit3."
                      (and (<= (first edit1) (first edit2))
                           (<= (first edit1) (first edit3))))
                    (diff_index (index1 index2)
                      "Find the best edit at offsets index1 and index2."
                      (or (aref results index1 index2)
                          (setf (aref results index1 index2)
                                (cond ((zerop index1)
                                       (cons index2 (loop :for index :from (- length2 index2) :below length2
                                                          :collect (list +insert+ (elt list2 index)))))
                                      ((zerop index2)
                                       (cons index1 (loop :for index :from (- length1 index1) :below length1
                                                          :collect (list +delete+ (elt list1 index)))))
                                      (t (let ((edit- (diff_index (1- index1) index2))
                                               (edit+ (diff_index index1 (1- index2)))
                                               (edit/ (diff_index (1- index1) (1- index2)))
                                               (item1 (elt list1 (- length1 index1)))
                                               (item2 (elt list2 (- length2 index2))))
                                           (cond ((edit_minp edit/ edit- edit+)
                                                  (cond ((equal item1 item2)
                                                         (list* (first edit/) (list +static+ item1) (rest edit/)))
                                                        ((and (listp item1) (listp item2))
                                                         (list* (1+ (first edit/)) (diff_trees item1 item2) (rest edit/)))
                                                        (t (list* (1+ (first edit/)) (list +update+ item1 item2) (rest edit/)))))
                                                 ((edit_minp edit- edit+ edit/)
                                                  (list* (1+ (first edit-)) (list +delete+ item1) (rest edit-)))
                                                 ((edit_minp edit+ edit/ edit-)
                                                  (list* (1+ (first edit+)) (list +insert+ item2) (rest edit+)))))))))))
             (diff_index length1 length2))))
        ((equal list1 list2) (list 0 (list +static+ list1)))
        (t (list 1 (list +update+ list1 list2)))))


;-------------------------------------------------------------------------------------------------------------------------------

(defun test_diff_trees (list1 list2 expected)
  "Test the diff_trees function."
  (let ((actual (diff_trees list1 list2)))
    (unless (equal expected actual)
      (format t "ERROR (diff_trees ~S ~S) => ~S~%" list1 list2 actual))))

(test_diff_trees '((cat)) '((cat)) `(0 (,+static+ (cat))))
(test_diff_trees '((cat)) '((dog)) `(0 (1 (,+update+ cat dog))))
(test_diff_trees '(cat (cat)) '(cat (cat dog rat)) `(0 (,+static+ cat) (2 (,+static+ cat) (,+insert+ dog) (,+insert+ rat))))
(test_diff_trees '(cat (cat)) '(cat (dog)) `(0 (,+static+ cat) (1 (,+update+ cat dog))))
(test_diff_trees '(cat (dog)) '(cat (cat dog rat)) `(0 (,+static+ cat) (2 (,+insert+ cat) (,+static+ dog) (,+insert+ rat))))
(test_diff_trees '(cat (dog)) '(cat (cat dog)) `(0 (,+static+ cat) (1 (,+insert+ cat) (,+static+ dog))))
(test_diff_trees '(cat (dog)) '(cat (cat pig rat)) `(0 (,+static+ cat) (3 (,+update+ dog cat) (,+insert+ pig) (,+insert+ rat))))
(test_diff_trees '(cat (dog)) '(cat (dog)) `(0 (,+static+ cat) (,+static+ (dog))))
(test_diff_trees '(cat (dog)) '(cat dog) `(1 (,+static+ cat) (,+update+ (dog) dog)))
(test_diff_trees '(cat dog rat) '(cat) `(2 (,+static+ cat) (,+delete+ dog) (,+delete+ rat)))
(test_diff_trees '(cat dog rat) '(dog) `(2 (,+delete+ cat) (,+static+ dog) (,+delete+ rat)))
(test_diff_trees '(cat dog) '(cat dog) `(0 (,+static+ cat) (,+static+ dog)))
(test_diff_trees '(cat dog) '(cat) `(1 (,+static+ cat) (,+delete+ dog)))
(test_diff_trees '(cat dog) '(dog cat) `(2 (,+update+ cat dog) (,+update+ dog cat)))
(test_diff_trees '(cat dog) '(dog) `(1 (,+delete+ cat) (,+static+ dog)))
(test_diff_trees '(cat pig rat) '(dog) `(3 (,+update+ cat dog) (,+delete+ pig) (,+delete+ rat)))
(test_diff_trees '(cat) '(cat dog rat) `(2 (,+static+ cat) (,+insert+ dog) (,+insert+ rat)))
(test_diff_trees '(cat) '(cat dog) `(1 (,+static+ cat) (,+insert+ dog)))
(test_diff_trees '(cat) '(cat) `(0 (,+static+ cat)))
(test_diff_trees '(cat) '(dog) `(1 (,+update+ cat dog)))
(test_diff_trees '(cat) 'cat `(1 (,+update+ (cat) cat)))
(test_diff_trees '(dog (cat)) '(cat (cat)) `(1 (,+update+ dog cat) (,+static+ (cat))))
(test_diff_trees '(dog (cat)) '(cat (dog)) `(1 (,+update+ dog cat) (1 (,+update+ cat dog))))
(test_diff_trees '(dog) '(cat dog rat) `(2 (,+insert+ cat) (,+static+ dog) (,+insert+ rat)))
(test_diff_trees '(dog) '(cat dog) `(1 (,+insert+ cat) (,+static+ dog)))
(test_diff_trees '(dog) '(cat pig rat) `(3 (,+update+ dog cat) (,+insert+ pig) (,+insert+ rat)))
(test_diff_trees 'cat 'cat `(0 (,+static+ cat)))
(test_diff_trees 'cat 'dog `(1 (,+update+ cat dog)))


;===============================================================================================================================
