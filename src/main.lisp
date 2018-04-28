;;;; src/main.lisp

(in-package #:skippy)

(print "src/main.lisp eval'd")

(time (main
       "Lawson Computer Science Building, 305 N University St, West Lafayette, IN 47907"
       "John W. Hicks Undergraduate Library, 504 W State St, West Lafayette, IN 47907"))


(time (main
       "2813 Bush Street San Francisco, CA 94115"
       "104 Walnut Street San Francisco, CA 94118"))

(time (main
       "2750 Jackson St, San Francisco, CA 94115"
       "2343 Fillmore St, San Francisco, CA 94115"))

(time (main
       "2 N Salisbury St, West Lafayette, IN 47906"
       "329 W State St, West Lafayette, IN 47906"))

(time (main "10 Rockefeller Plaza, New York, NY 10020"
            "1073 6th Ave, New York, NY 10018"))

(time (main
       "2400 Yeager Rd, West Lafayette, IN 47906"
       "900 John R Wooden Dr, West Lafayette, IN 47907"))

(time (main "3700 N Outlet Parkway, Lehi, UT 84043"
            "2502 Cabela's Blvd, Lehi, UT 84043"))

(psy:enqueue
 'my-worker
 '("Lawson Computer Science Building, 305 N University St, West Lafayette, IN 47907"
   "John W. Hicks Undergraduate Library, 504 W State St, West Lafayette, IN 47907"))

(psy:enqueue
 'my-worker
 '("2 N Salisbury St, West Lafayette, IN 47906"
   "329 W State St, West Lafayette, IN 47906"))

(psy:enqueue
 'my-worker
 '("3700 N Outlet Parkway, Lehi, UT 84043"
   "2502 Cabela's Blvd, Lehi, UT 84043"))
