;;;; src/scratch.lisp

(in-package #:skippy)

(print "src/scratch.lisp eval'd")

(psy:enqueue
 'my-worker
 '("Lawson Computer Science Building, 305 N University St, West Lafayette, IN 47907"
   "John W. Hicks Undergraduate Library, 504 W State St, West Lafayette, IN 47907"))

(psy:enqueue
 'my-worker
 '("2813 Bush Street San Francisco, CA 94115"
   "104 Walnut Street San Francisco, CA 94118"))

(psy:enqueue
 'my-worker
 '("2750 Jackson St, San Francisco, CA 94115"
   "2343 Fillmore St, San Francisco, CA 94115"))

(psy:enqueue
 'my-worker
 '("2 N Salisbury St, West Lafayette, IN 47906"
   "329 W State St, West Lafayette, IN 47906"))

(psy:enqueue
 'my-worker
 '("10 Rockefeller Plaza, New York, NY 10020"
   "1073 6th Ave, New York, NY 10018"))

;; TODO: Too big and always breaks, add limit to num images
(psy:enqueue
 'my-worker
 '("2400 Yeager Rd, West Lafayette, IN 47906"
   "900 John R Wooden Dr, West Lafayette, IN 47907"))

(time (main "2750 Jackson St, San Francisco, CA 94115" "2343 Fillmore St, San Francisco, CA 94115"))

(time (main
       "2813 Bush Street San Francisco, CA 94115"
       "104 Walnut Street San Francisco, CA 94118"))

;; [ ] main should return url
;; [ ]

(time (main "2 N Salisbury St, West Lafayette, IN 47906"
            "329 W State St, West Lafayette, IN 47906"))


(time (main
       "2376 Foliage Oak Terrace Oviedo, Fl 32766"
       "2358 Live Oak Reserve Blvd, Oviedo, FL 32766"))

(time (main
       "2901 Pacific Ave San Francisco, CA 94115"
       "2261 Fillmore St San Francisco, CA 94115"))



;; Readme worthy
(time (main
       "3065 Jackson St San Francisco, CA 94115"
       "2261 Fillmore St San Francisco, CA 94115"))

;; two polylines
("mateFrbjjVUqDi@gIk@mIg@kIASg@uHg@uH?Q[sEOuB"
 "_jteFb_hjVnDa@nDc@h@I")
