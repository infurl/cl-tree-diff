# cl-tree-diff
Tree structure comparison using Levenshtein distance.

Analyze the differences between two symbolic tree structures. 

The raw result can be used to reconstruct either input or print a human readable summary of the differences.

Originally inspired by the example here https://rosettacode.org/wiki/Levenshtein_distance#Common_Lisp

```
(diff_trees '((cat)) '((cat)))                 ; (0 (:= (cat)))
(diff_trees '((cat)) '((dog)))                 ; (1 (1 (:/ cat dog)))
(diff_trees '(cat (cat)) '(cat (cat dog rat))) ; (1 (:= cat) (2 (:= cat) (:+ dog) (:+ rat)))
(diff_trees '(cat (cat)) '(cat (dog)))         ; (1 (:= cat) (1 (:/ cat dog)))
(diff_trees '(cat (dog)) '(cat (cat dog rat))) ; (1 (:= cat) (2 (:+ cat) (:= dog) (:+ rat)))
(diff_trees '(cat (dog)) '(cat (cat dog)))     ; (1 (:= cat) (1 (:+ cat) (:= dog)))
(diff_trees '(cat (dog)) '(cat (cat pig rat))) ; (1 (:= cat) (3 (:/ dog cat) (:+ pig) (:+ rat)))
(diff_trees '(cat (dog)) '(cat (dog)))         ; (0 (:= cat) (:= (dog)))
(diff_trees '(cat (dog)) '(cat dog))           ; (1 (:= cat) (:/ (dog) dog))
(diff_trees '(cat dog rat) '(cat))             ; (2 (:= cat) (:- dog) (:- rat))
(diff_trees '(cat dog rat) '(dog))             ; (2 (:- cat) (:= dog) (:- rat))
(diff_trees '(cat dog) '(cat dog))             ; (0 (:= cat) (:= dog))
(diff_trees '(cat dog) '(cat))                 ; (1 (:= cat) (:- dog))
(diff_trees '(cat dog) '(dog cat))             ; (2 (:/ cat dog) (:/ dog cat))
(diff_trees '(cat dog) '(dog))                 ; (1 (:- cat) (:= dog))
(diff_trees '(cat pig rat) '(dog))             ; (3 (:/ cat dog) (:- pig) (:- rat))
(diff_trees '(cat) '(cat dog rat))             ; (2 (:= cat) (:+ dog) (:+ rat))
(diff_trees '(cat) '(cat dog))                 ; (1 (:= cat) (:+ dog))
(diff_trees '(cat) '(cat))                     ; (0 (:= cat))
(diff_trees '(cat) '(dog))                     ; (1 (:/ cat dog))
(diff_trees '(cat) 'cat)                       ; (1 (:/ (cat) cat))
(diff_trees '(dog (cat)) '(cat (cat)))         ; (1 (:/ dog cat) (:= (cat)))
(diff_trees '(dog (cat)) '(cat (dog)))         ; (2 (:/ dog cat) (1 (:/ cat dog)))
(diff_trees '(dog) '(cat dog rat))             ; (2 (:+ cat) (:= dog) (:+ rat))
(diff_trees '(dog) '(cat dog))                 ; (1 (:+ cat) (:= dog))
(diff_trees '(dog) '(cat pig rat))             ; (3 (:/ dog cat) (:+ pig) (:+ rat))
(diff_trees 'cat 'cat)                         ; (0 (:= cat))
(diff_trees 'cat 'dog)                         ; (1 (:/ cat dog))
```
