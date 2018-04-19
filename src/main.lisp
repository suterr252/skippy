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

(defun reformat-decoded-polyline (list)
  (loop for latlng in list
        collect (format nil "~a,~a" (car latlng) (cadr latlng))))

(defun combine-idx-and-loc (idx other)
  (format nil "~a,~a" idx other))

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

(defun reformat-decoded-polylines (polylines)
  (loop for polyline in polylines
        collect (reformat-decoded-polyline polyline)))

(defun main (origin destination)
  (format t "beginning route from ~a to ~a~%" origin destination)
  (let* ((from (replace-spaces-with-pluses origin))
         (to (replace-spaces-with-pluses destination))
         (directions-api-response (get-directions-api-response from to))
         (encoded-polylines (parse-response directions-api-response))
         (decoded-polylines (decode-polylines encoded-polylines))
         (formatted-latlng-lists (reformat-decoded-polylines decoded-polylines)))

    (cl-fad:delete-directory-and-files tmp-dir :if-does-not-exist :ignore)

    ;; TODO: Dynamic headings (camera angle)
    (defparameter urls-and-paths ())
    (let ((file-count 0))
      (loop for latlng-list in formatted-latlng-lists do
        (loop for latlong in latlng-list do
          (let ((target-url (image-url latlong "165"))
                (save-path (get-save-path
                            (combine-idx-and-loc
                             file-count latlong))))
            (setf urls-and-paths
                  (append urls-and-paths (list (list target-url save-path))))
            (setf file-count (+ 1 file-count))))))

    (let* ((partitioned-list (partition-in 4 urls-and-paths))
           (threads (threaded-get-requests partitioned-list)))
      (loop for thread in threads
            do (sb-thread:join-thread thread)))

    (print "##### Creating GIF now. ######")
    (make-gif (get-save-path "*") (get-save-path "out" "gif"))))


(time (main
  "Lawson Computer Science Building, 305 N University St, West Lafayette, IN 47907"
  "John W. Hicks Undergraduate Library, 504 W State St, West Lafayette, IN 47907"))

;; (Single Threaded )Evaluation took: 13.235 seconds of real time
;; (Pooled threads [5])Evaluation took: 12.348 seconds of real time
;; (Pooled threads [10])Evaluation took: 9.877 seconds of real time
;; (Pooled threads [50]) Evaluation took: 23.023 seconds of real tim
;; (basic use of 2 threads) Evaluation took:  4.014 seconds of real time
;; (basic use of 4 threads) Evaluation took:  4.595 seconds of real time

(time (main
       "2813 Bush Street San Francisco, CA 94115"
       "104 Walnut Street San Francisco, CA 94118"))

(time (main
  "2400 Yeager Rd, West Lafayette, IN 47906"
  "900 John R Wooden Dr, West Lafayette, IN 47907"))

;; (Single threaded) Evaluation took: 75.316 seconds of real time
;; (Pooled threads [5]) Evaluation took: 61.992 seconds of real time
;; (Pooled threads [10]) Evaluation took: 65.041 seconds of real time
;; (Pooled threads [50]) Evaluation took: 127.582 seconds of real time
;; (basic use of 2 threads) Evaluation took: 37.509 seconds of real time
;; (basic use of 4 threads) Evaluation took: 20.917 seconds of real time



;; [ ] able to save gif to s3
;; [ ] add database storing s3 urls
;; [ ] add summary printout, how many legs, points, etc
;; [ ] add correct heading orientation
