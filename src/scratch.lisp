;;;; src/scratch.lisp

(in-package #:skippy)

(print "src/scratch.lisp eval'd")

(print "about to enqueue first worker")
(psy:enqueue 'my-worker '("hong kong" "tokyo"))
(print "just enqueue'd first worker")

(print "about to enqueue second worker")
(psy:enqueue 'my-worker '("paris" "london"))
(print "just enqueue'd second worker")
