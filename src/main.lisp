;;;; src/main.lisp

(print "src/main.lisp eval'd")

(defparameter tmp-dir "~/quicklisp/local-projects/skippy/tmp/")
(defun range (max &key (min 0) (step 1))
  (loop for n from min below max by step
        collect n))

(defun partition-in (num data)
  (let ((jump (floor (/ (length data) num))))
    (loop for (beg end) on (range num)
          collect (subseq data (* jump beg)
                          (if end (* jump end) nil)))))

(defun flatten-once (list)
  (let ((flattened ()))
    (loop for sublist in list do
      (setf flattened (append flattened sublist)))
    flattened))


(defun build-filename (idx other)
  (format nil "~4,'0d,~a" idx other))

(defun threaded-get-requests (list)
  (loop for chunk in list
        collect
        (sb-thread:make-thread
         #'(lambda (standard-output chunk)
             (let ((*standard-output* standard-output))
               (loop for data in chunk do
                 (download-image (car data) (cadr data)))))
         :arguments (list *standard-output* chunk))))

;; TODO: Maybe try destructured binding on keys
(defun parse-response (directions-api-response)
  ;; TODO: Collect instead of mutating response
  (defparameter all-polylines ())
  (let ((routes (find-val-from directions-api-response "routes")))
    (loop for route in routes do
      (let ((legs (find-val-from route "legs")))
        (loop for leg in legs do
          (let ((steps (find-val-from leg "steps")))
            (loop for single-step in steps do
              (push (cadr (find-val-from single-step "polyline"))
                    all-polylines)))))))
  (reverse all-polylines))

(defun decode-polylines (polylines)
  (loop for polyline in polylines collect (decode polyline)))

(defun add-individual-heading (decoded-polyline)
  (append decoded-polyline "188"))

(defun add-headings (polylines)
  (loop for polyline in polylines
        collect (add-individual-heading polyline)))

(defun main (origin destination)
  (format t "beginning route from ~a to ~a~%" origin destination)
  (let* ((from (replace-spaces-with-pluses origin))
         (to (replace-spaces-with-pluses destination))
         (directions-api-response (get-directions-api-response from to))
         (encoded-polylines (parse-response directions-api-response))
         (decoded-polylines-lists (decode-polylines encoded-polylines))
         (decoded-polylines (flatten-once decoded-polylines-lists)))
    (cl-fad:delete-directory-and-files tmp-dir :if-does-not-exist :ignore)
    (print "##### decoded polylines ####")
    (print decoded-polylines);; nesty

    (defparameter urls-and-paths ())
    (let ((file-count 0))
      (loop for latlng-list in decoded-polylines do
        (let* ((lat (car latlng-list))
               (lng (cadr latlng-list))
               (latlong (format nil "~a,~a" lat lng))
               (heading "165")
               (target-url (image-url latlong heading))
               (save-path (get-save-path (build-filename file-count latlong))))
          (setf urls-and-paths
                (append urls-and-paths (list (list target-url save-path)))))
        (incf file-count)))

    (print "###### urls-and-paths #######")
    (print urls-and-paths)

    (let* ((partitioned-list (partition-in 4 urls-and-paths))
           (threads (threaded-get-requests partitioned-list)))
      (loop for thread in threads
            do (sb-thread:join-thread thread)))

    (print "##### Creating GIF now. ######")
    (make-gif (get-save-path "*") (get-save-path "out" "gif"))))


(time (main
  "Lawson Computer Science Building, 305 N University St, West Lafayette, IN 47907"
  "John W. Hicks Undergraduate Library, 504 W State St, West Lafayette, IN 47907"))


(time (main
       "2813 Bush Street San Francisco, CA 94115"
       "104 Walnut Street San Francisco, CA 94118"))

(time (main
  "2400 Yeager Rd, West Lafayette, IN 47906"
  "900 John R Wooden Dr, West Lafayette, IN 47907"))




;; [ ] able to save gif to s3
;; [ ] add database storing s3 urls
;; [ ] add summary printout, how many legs, points, etc
;; [ ] add correct heading orientation
