;;;; src/main.lisp

(print "src/main.lisp eval'd")

(defun list-of-latlng-ints-to-strings (list)
  (loop for latlng in list
        collect (format nil "~a,~a" (car latlng) (cadr latlng))))

(defun main (origin destination)
  (format t "beginning route from ~a to ~a~%" origin destination)
  (let* ((from (replace-spaces-with-pluses origin))
         (to (replace-spaces-with-pluses destination))
         (directions-api-response (get-directions-api-response from to)))
    (print "#### API Response ####")
    (print directions-api-response)
    (terpri)
    ;; TODO: Delete contents of tmp/ if exists
    (defparameter all-polylines ())
    (let ((routes (find-val-from directions-api-response "routes")))
      (loop for route in routes do
        (let ((legs (find-val-from route "legs")))
          (loop for leg in legs do
            (let ((steps (find-val-from leg "steps")))
              (loop for single-step in steps do
                (push (cadr (find-val-from single-step "polyline"))
                      all-polylines)))))))
    (setf all-polylines (reverse all-polylines))
    ;;(loop for polyline in all-polylines do (print polyline))
    (defparameter lists-of-latlngs
      (loop for polyline in all-polylines
            do (progn (print "#### polyline for step ####")
                      (print polyline)
                      (terpri))
            collect (decode polyline)))
    (defparameter lists-of-coordinate-strings
      (loop for list in lists-of-latlngs
            collect (list-of-latlng-ints-to-strings list)))
    ;; TODO: Dynamic headings (camera angle)
    (let ((file-count 0))
      (loop for list in lists-of-coordinate-strings do
        (loop for latlong in list do
          (download-image (image-url latlong)
                          (get-save-path (combine-idx-and-loc file-count latlong)))
          (terpri)
          (format t "Saved image #~a with latlng ~a" file-count latlong)
          (terpri)
          (setf file-count (+ 1 file-count)))))
    (make-gif (get-save-path "*") (get-save-path "out" "gif"))))

(defun combine-idx-and-loc (idx other)
  (format nil "~a,~a" idx other))

(main
 "Lawson Computer Science Building, 305 N University St, West Lafayette, IN 47907"
 "John W. Hicks Undergraduate Library, 504 W State St, West Lafayette, IN 47907")

;; Lawson --> N University St & State St
;; k`wuFb|nqO`BAlE@B?l@?~C@r@ArCA
;; 00:40.42774,-86.91666
;; 01:40.42725,-86.91665
;; 02:40.42622,-86.91666
;; 03:40.42620,-86.91666
;; 04:40.42597,-86.91666
;; 05:40.42517,-86.91667
;; 06:40.42491,-86.91666
;; 07:40.42417,-86.91665

;; N University St & State St --> Hicks
;; ajvuF`|nqOL@BqC?U?GEKBiC@a@?{B@oA?OBiBBqB
;; 08:40.42417,-86.91665
;; 09:40.42410,-86.91665
;; 10:40.42408,-86.91593
;; 11:40.42408,-86.91582
;; 12:40.42408,-86.91578
;; 13:40.42411,-86.91572
;; 14:40.42409,-86.91503
;; 15:40.42408,-86.91486
;; 16:40.42408,-86.91424
;; 17:40.42407,-86.91384
;; 18:40.42407,-86.91376
;; 19:40.42405,-86.91323
;; 20:40.42403,-86.91266


routes.len == 1
bounds.len == 1
steps.len == 2

;; [ ] able to save gif to s3
;; [ ] add database storing s3 urls
