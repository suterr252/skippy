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

;; took 47 seconds at 600x600
;; took 24 seconds at 300x300





;; TODO: Occasionally getting EINTR interrupted syscalls
;; --> Make transactions atomic

;; TODO: Drakma http client sometimes timing out
;; --> Have it automatically retry on fail

;; [ ] Save heading info into saved filename
;; [ ] able to save gif to s3
;; [ ] add database storing s3 urls
;; [ ] add summary printout, how many legs, points, etc
;; [ ] add correct heading orientation
;; [ ] unit testing framework


;;| 0000 | 37.79179  | -122.44004  | 83.769 |
;;| 0001 | 37.791847 | -122.439514 | 83.390 |
;;| 0002 | 37.79186  | -122.439415 | 82.527 |
;;| 0003 | 37.79206  | -122.43787  | 82.666 |
;;| 0004 | 37.79226  | -122.43632  | 90.000 |
;;| 0005 | 37.79226  | -122.436226 | 82.383 |
;;| 0006 | 37.7924   | -122.435165 | 82.201 |
;;| 0007 | 37.79248  | -122.43458  | 0.000  |
;;| 0008 | 37.79248  | -122.43458  | 169.261 |
;;| 0009 | 37.7916   | -122.43441  | 167.352 |
;;| 0010 | 37.79133  | -122.43435  | 167.352 |

;; 37.79179,-122.44004,0
;; 37.791847,-122.439514,1
;; 37.79186,-122.439415,2
;; 37.79206,-122.43787,3
;; 37.79226,-122.43632,4
;; 37.79226,-122.436226,5
;; 37.7924,-122.435165,6
;; 37.79248,-122.43458,7
;; 37.79248,-122.43458,8
;; 37.7916,-122.43441,9
;; 37.79133,-122.43435,10
