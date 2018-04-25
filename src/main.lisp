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
