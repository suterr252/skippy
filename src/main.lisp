;;;; src/main.lisp

(print "src/main.lisp eval'd")

(defparameter directions-base-url "https://maps.googleapis.com/maps/api/directions/json")
(defparameter directions-test-destination "85+10th+Ave,+New+York,+NY+10011")
(defparameter directions-test-origin "75+9th+Ave+New+York,+NY")

(defparameter directions-api-response
  (get-directions directions-base-url
                  directions-test-origin
                  directions-test-destination))

(defparameter routes (find-val-from directions-api-response "routes"))

;; TODO: What scenario gives multiple routes?
(defparameter route (car routes))
(defparameter encoded-polyline
  (car (cdr (find-val-from route "overview_polyline"))))






(defparameter polyline "}ktwF|`ubMp@b@iBxF}BjHm@_@")
;; 0: {latitude: 40.74191, longitude: -74.00479}
;; 1: {latitude: 40.74166, longitude: -74.00497}
;; 2: {latitude: 40.74219, longitude: -74.00622}
;; 3: {latitude: 40.74282, longitude: -74.00772}
;; 4: {latitude: 40.74305, longitude: -74.00756}

(defparameter streetview-base-url "https://maps.googleapis.com/maps/api/streetview")
(defparameter streetview-latlong "40.42620,-86.91666")
(defparameter streetview-size "600x600")
(defparameter streetview-heading "165")

(defun image-url ()
  (format nil "~a?size=~a&location=~a&heading=~a&key=~a"
          streetview-base-url
          streetview-size
          streetview-latlong
          streetview-heading
          skippy::streetview-key))

;; 0010 2
;; 0110 6
(logand 2 6)
(logor 2 4)

;; [ ] convert polyline to lat long pairs
;; [ ] able to save street view images
;; [ ] able to combine to a gif
;; [ ] able to save gif to s3
;; [ ] add database storing s3 urls

(defun get-dirname ()
  "example /40.42620,-86.91666,165/"
  (format nil "~a,~a" streetview-latlong streetview-heading))

(defun get-directory-path ()
  "creates directory `tmp/' if not already present"
  (format nil "./tmp/~a/filename.png" (get-dirname)))

(defun download-image (image-url save-path)
  (trivial-download:download (image-url) save-path))

(defparameter input-files "~/Desktop/lispshell/*.png")
(defparameter output-file "~/Desktop/lispshell/out.gif")

(defun make-gif (input-files output-file)
  "`#'uiop:run-program' executes shell commands, see:
   https://gitlab.common-lisp.net/asdf/asdf/blob/master/uiop/run-program.lisp#L539"
  (uiop:run-program (image-magick-shell-cmd input-files output-file)))

(defun image-magick-shell-cmd (input-files output-file)
  (format nil "convert -loop 0 -delay 25 ~a ~a" input-files output-file))
