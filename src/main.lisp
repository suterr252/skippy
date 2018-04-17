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

(defparameter coordinates (decode encoded-polyline))


;; TODO: Dynamic headings


(defparameter coordinate-strings
  (loop for x in coordinates
        collect (format nil "~a,~a" (car x) (cadr x))))

(loop for latlong in coordinate-strings do
  (let ((image-url latlong))
    ))





;; (defun get-dirname (streetview-latlong)
;;   "example /40.42620,-86.91666,165/"
;;   (format nil "~a,~a" streetview-latlong streetview-heading))

;; (defun get-directory-path ()
;;   "creates directory `tmp/' if not already present"
;;   (format nil "./tmp/~a/filename.png" (get-dirname)))


(defun download-image (image-url save-path)
  (trivial-download:download image-url save-path))

(defparameter input-files "~/Desktop/lispshell/*.png")
(defparameter output-file "~/Desktop/lispshell/out.gif")

(defun make-gif (input-files output-file)
  "`#'uiop:run-program' executes shell commands, see:
   https://gitlab.common-lisp.net/asdf/asdf/blob/master/uiop/run-program.lisp#L539"
  (uiop:run-program (image-magick-shell-cmd input-files output-file)))

(defun image-magick-shell-cmd (input-files output-file)
  (format nil "convert -loop 0 -delay 25 ~a ~a" input-files output-file))

;; [ ] able to save gif to s3
;; [ ] add database storing s3 urls
