;;;; src/glue.lisp

(in-package #:skippy)

(print "src/glue.lisp eval'd")

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


(defun build-filename (idx latlng heading)
  (format nil "~3,'0d,~a,~a" idx latlng heading))

(defun watermark-image (file total-file-count)
  (uiop:run-program
   ;; "~/quicklisp/local-projects/skippy/tmp/652431//0002,37.79186,-122.439415,82.527.png"
   (format nil "~a ~a ~a ~a ~a ~a ~a ~a ~a ~a ~a"
           "convert"
           file ;;"dragon.gif"
           "-background"
           "Khaki"
           "label:'"
           (format nil "~a/~3,'0d"
                   (subseq (car (last (cl-utilities:split-sequence #\/ file))) 0 4)
                   total-file-count)
           "'"
           "-gravity"
           "Center"
           "-append"
           file
           ;;"anno_label.jpg"
           )))

(defun trim-image (file)
  (uiop:run-program
   (format nil "~a ~a ~a ~a ~a ~a ~a"
           "convert"
           file ;;"frame_red.gif"
           "-gravity"
           "South"
           "-chop"
           "0x30"
           file ;; "chop_bottom.gif"
           )))

(defun threaded-get-requests (list total-file-count)
  (loop for chunk in list
        collect
        (sb-thread:make-thread
         #'(lambda (standard-output chunk)
             (let ((*standard-output* standard-output))
               (loop for data in chunk do
                 (let ((url (car data))
                       (output (cadr data)))
                   (download-image url output)
                   ;; TODO: Maybe update image after downloaded?
                   (trim-image output)
                   (watermark-image output total-file-count)
                   ))))
         :arguments (list *standard-output* chunk))))


;; TODO: Maybe try destructured binding on keys
(defun parse-response (directions-api-response)
  (let ((all-polylines ())
        (routes (find-val-from directions-api-response "routes")))
    (loop for route in routes do
      (let ((legs (find-val-from route "legs")))
        (loop for leg in legs do
          (let ((steps (find-val-from leg "steps")))
            (loop for single-step in steps do
              (push (cadr (find-val-from single-step "polyline"))
                    all-polylines))))))
    (reverse all-polylines)))

(defun decode-polylines (polylines)
  (loop for polyline in polylines collect (decode polyline)))

(defun deg-to-rad (degrees)
  (* pi (/ degrees 180.0)))

(defun rad-to-deg (rad)
  (* rad (/ 180.0 pi)))

(defun angle-from-coordinates (lat1 long1 lat2 long2)
  (let* ((dlon (- long2 long1))
         (y (* (sin dlon) (cos lat2)))
         (x (- (* (cos lat1) (sin lat2))
               (* (sin lat1) (cos lat2) (cos dlon))))
         (bearing (mod (+ (rad-to-deg (atan y x)) 360) 360)))
    bearing))

(defun generate-heading-list (duples)
  (let ((prev-angle nil)
        (results ()))
    (loop for (cur next) on duples do
      (let ((lat1 (car cur))
            (long1 (cadr cur)))
        (if (not next)
            (setf results
                  (append results (list (list (format nil "~v$" 3 prev-angle)))))
            (let ((lat2 (car next))
                  (long2 (cadr next)))
              (setf results
                    (append results
                            (list
                             (list
                              (format nil "~v$" 3
                                      (angle-from-coordinates
                                       lat1 long1 lat2 long2))))))
              (setf prev-angle (angle-from-coordinates lat1 long1 lat2 long2))))))
    results))

(defun merge-lists (first-list second-list)
  (mapcar #'(lambda (a b) (append a b)) first-list second-list))

(defun create-tmp-dir-name ()
  (format nil "~a/quicklisp/local-projects/skippy/tmp/~a/" "~"
          (+ 10101 (random (expt 2 20)))))

(defun get-save-path (full-dir-path filename &optional (extension "png"))
  (format nil "~a/~a.~a"
          full-dir-path
          filename
          extension))

(defparameter *num-files* 0)

(defun main (origin destination)
  (format t "beginning route from ~a to ~a~%" origin destination)
  (let* ((tmp-dir (create-tmp-dir-name))
         (from (replace-spaces-with-pluses origin))
         (to (replace-spaces-with-pluses destination))
         (directions-api-response (get-directions-api-response from to))
         (encoded-polylines (parse-response directions-api-response))
         (decoded-polylines-lists (decode-polylines encoded-polylines))
         (decoded-polylines (flatten-once decoded-polylines-lists))
         (heading-list (generate-heading-list decoded-polylines)))

    (let ((urls-and-paths ())
          (all-three (merge-lists decoded-polylines
                                  heading-list)))
      (print "##### all-three #####")
      (print all-three)

      (let ((file-count 0))
        (loop for latlng-list in all-three do
          (let* ((lat (car latlng-list))
                 (lng (cadr latlng-list))
                 (latlong (format nil "~a,~a" lat lng))
                 (heading (caddr latlng-list))
                 (target-url (image-url latlong heading))
                 (save-path (get-save-path tmp-dir
                             (build-filename file-count latlong heading))))
            (setf urls-and-paths (append urls-and-paths
                                         (list (list target-url save-path)))))
          (incf file-count))
        (setf *num-files* file-count)
        )
      (let* ((partitioned-list (partition-in 4 urls-and-paths))
             (threads (threaded-get-requests partitioned-list *num-files*)))
        (loop for thread in threads
              do (sb-thread:join-thread thread)))

      (print "##### Creating GIF now. ######")
      (let* ((local-gif-filename "out")
            (s3-filename "out")
            (input-file-path-str (format nil "~a~a.gif" tmp-dir local-gif-filename))
             (output-filename (format nil "~a+to+~a.gif" from to)))
        (make-gif (get-save-path tmp-dir "*")
                  (get-save-path tmp-dir local-gif-filename "gif"))
        (print "##### Sending GIF to S3 now. ######")
        (send-gif-to-s3 input-file-path-str output-filename)
        (print "##### Verify gif made it to S3 #####")
        (print "##### Deleting residual local files ######")
        ;;(cl-fad:delete-directory-and-files tmp-dir :if-does-not-exist :ignore)
        ))))
