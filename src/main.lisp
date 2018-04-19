;;;; src/main.lisp

(print "src/main.lisp eval'd")

(defun get-split-left-side (list count)
  (subseq list 0 count))

(defun get-split-right-side (list count)
  (nthcdr count list))

(defun list-of-latlng-ints-to-strings (list)
  (loop for latlng in list
        collect (format nil "~a,~a" (car latlng) (cadr latlng))))

(defun combine-idx-and-loc (idx other)
  (format nil "~a,~a" idx other))

(defun threaded-image-download (arg1 arg2)
  (sb-thread:make-thread
   #'(lambda (standard-output arg1 arg2)
       (let ((*standard-output* standard-output))
         ;;(trivial-download:download url (filename num))
         (download-image arg1 arg2)
         (print "#### Finished a download!!!!  ####")
         ))
   :arguments (list *standard-output* arg1 arg2)))

(defun main (origin destination)
  (format t "beginning route from ~a to ~a~%" origin destination)
  (let* ((from (replace-spaces-with-pluses origin))
         (to (replace-spaces-with-pluses destination))
         (directions-api-response (get-directions-api-response from to)))
    (print "#### API Response ####")
    (print directions-api-response)
    (terpri)
    (cl-fad:delete-directory-and-files
     "~/quicklisp/local-projects/skippy/tmp/"
     :if-does-not-exist :ignore)
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
    ;; TODO: Should instead build a flat list of threads to make

    (defparameter urls-and-paths ())
    (let ((file-count 0))
      (defparameter list-of-threads
        (loop for list in lists-of-coordinate-strings do
          (loop for latlong in list do

            (let ((target-url (image-url latlong "165"))
                  (save-path (get-save-path
                              (combine-idx-and-loc
                               file-count latlong))))
              (setf urls-and-paths
                    (append urls-and-paths (list (list target-url save-path))))
              (setf file-count (+ 1 file-count)))))))
    ;; TODO: Verify list exists and is good! then can:
    ;; (threaded-image-download target-url save-path)
    (terpri)(terpri)(terpri)
    (print "### ARE WE HERE ###")
    (terpri)(terpri)(terpri)

    (defparameter divide-index (floor (/ (length urls-and-paths) 2)))
    (defparameter new-list ())
    (setf new-list (append new-list
                           (list (get-split-left-side
                                  urls-and-paths divide-index))))
    (setf new-list (append new-list
                           (list (get-split-right-side
                                  urls-and-paths divide-index))))

    ;; single threaded
    ;; (loop for data in urls-and-paths do
    ;;   (download-image (car data) (cadr data)))

    (defparameter thruds
      (loop for half in new-list
            collect
            (sb-thread:make-thread
             #'(lambda (standard-output half)
                 (let ((*standard-output* standard-output))
                   (loop for data in half do
                     (download-image (car data) (cadr data)))
                   ))
             :arguments (list *standard-output* half))))

    (loop for thr in thruds do
      (sb-thread:join-thread thr))
    (print "##### Finished now after waiting???? ######")

    ;; thread pool
    ;; (defparameter *threadpool* (cl-threadpool:make-threadpool 50))
    ;; (cl-threadpool:start *threadpool*)
    ;; (loop for data in urls-and-paths do
    ;;   (cl-threadpool:add-job
    ;;    *threadpool*
    ;;    (download-image (car data) (cadr data))))

    ;; TODO: #'sb-thread:join-thread to prevent early calling
    ;; (make-gif (get-save-path "*") (get-save-path "out" "gif"))
    ))

(time (main
  "Lawson Computer Science Building, 305 N University St, West Lafayette, IN 47907"
  "John W. Hicks Undergraduate Library, 504 W State St, West Lafayette, IN 47907"))

;; (Single Threaded )Evaluation took: 13.235 seconds of real time
;; (Pooled threads [5])Evaluation took: 12.348 seconds of real time
;; (Pooled threads [10])Evaluation took: 9.877 seconds of real time
;; (Pooled threads [50]) Evaluation took: 23.023 seconds of real tim
;; (basic use of 2 threads) Evaluation took:  4.014 seconds of real time


;; routes.len == 1
;; bounds.len == 1
;; steps.len == 2

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





(main
 "2813 Bush Street San Francisco, CA 94115"
 "104 Walnut Street San Francisco, CA 94118")


;; All the points seemed good!
;; s_seFjyijVMeB
;; a`seFdvijVyDd@_Ef@wDb@oDb@qD^mDd@
;; cbteF`}ijVh@fIb@vGh@pI
;; k~seFrzjjVf@G




(time (main
  "2400 Yeager Rd, West Lafayette, IN 47906"
  "900 John R Wooden Dr, West Lafayette, IN 47907"))

;; (Single threaded) Evaluation took: 75.316 seconds of real time
;; (Pooled threads [5]) Evaluation took: 61.992 seconds of real time
;; (Pooled threads [10]) Evaluation took: 65.041 seconds of real time
;; (Pooled threads [50]) Evaluation took: 127.582 seconds of real time
;; (basic use of 2 threads) Evaluation took: 37.509 seconds of real time




;; [ ] able to save gif to s3
;; [ ] add database storing s3 urls
;; [ ] add README
;; [ ] add summary printout, how many legs, points, etc
;; [ ] add correct heading orientation
;; [ ] try to get threading going for the individual image downloads


;; (defparameter *threadpool* (cl-threadpool:make-threadpool 5))
;; (cl-threadpool:start *threadpool*)
;; (time (loop for data in '(4 5 6) do
;;   (cl-threadpool:add-job
;;    *threadpool*
;;    (sleep data))))
;; 15.016 seconds...

(defun split (list count)
  (values (subseq list 0 count) (nthcdr count list)))

(multiple-value-bind (q r) (split '(a b c d e f g) 3)
  (print "### Q ###")
  (print q)
  (print "### R ###")
  (print r)
  )
