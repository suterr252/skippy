;;;; src/street-views.lisp

(print "src/street-views.lisp eval'd")

(defparameter streetview-base-url "https://maps.googleapis.com/maps/api/streetview")
(defparameter streetview-size "600x600")
(defparameter streetview-heading "165")

(defun image-url (streetview-latlong)
  (format nil "~a?size=~a&location=~a&heading=~a&key=~a"
          streetview-base-url
          streetview-size
          streetview-latlong
          streetview-heading
          skippy::streetview-key))
