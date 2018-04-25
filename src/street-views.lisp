;;;; src/street-views.lisp

(in-package #:skippy)

(print "src/street-views.lisp eval'd")

(defparameter streetview-base-url "https://maps.googleapis.com/maps/api/streetview")
(defparameter streetview-size "300x300")
(defparameter streetview-heading "165")

(defun image-url (streetview-latlong streetview-heading)
  (format nil "~a?size=~a&location=~a&heading=~a&key=~a"
          streetview-base-url
          streetview-size
          streetview-latlong
          streetview-heading
          skippy::streetview-key))

(defun download-image (image-url save-path)
  (trivial-download:download image-url save-path))

(defun make-gif (input-files output-file)
  "`#'uiop:run-program' executes shell commands, see:
   https://gitlab.common-lisp.net/asdf/asdf/blob/master/uiop/run-program.lisp#L539"
  (uiop:run-program (image-magick-shell-cmd input-files output-file)))

(defun image-magick-shell-cmd (input-files output-file)
  (format nil "convert -loop 0 -delay 50 ~a ~a" input-files output-file))
