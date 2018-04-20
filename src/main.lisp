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


(defun build-filename (idx latlng heading)
  (format nil "~4,'0d,~a,~a" idx latlng heading))

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

(defun angle-from-coordinates (lat1 long1 lat2 long2)
  (let* ((dlon (- long2 long1))
         (y (* (sin dlon) (cos lat2)))
         (x (- (* (cos lat1) (sin lat2))
               (* (sin lat1) (cos lat2) (cos dlon))))
         (tmp1 (atan y x))
         (tmp2 (rad-to-deg tmp1))
         (bearing (mod (+ tmp2 360) 360)))
    bearing))

(defun deg-to-rad (degrees)
  (* pi (/ degrees 180.0)))

(defun rad-to-deg (rad)
  (* rad (/ 180.0 pi)))

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
              (setf results (append results (list (list (format nil "~v$" 3 (angle-from-coordinates lat1 long1 lat2 long2))))))
              (setf prev-angle (angle-from-coordinates lat1 long1 lat2 long2))))))
    results))

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
    (print decoded-polylines)

    (defparameter heading-list (generate-heading-list decoded-polylines))
    (print "##### heading-list #####")
    (print heading-list)

    (defparameter all-three (mapcar #'(lambda (a b) (append a b)) decoded-polylines heading-list))

    (print "##### all-three #####")
    (print all-three)

    ;; (loop for x in decoded-polylines do
    ;;       (print x))

    (defparameter urls-and-paths ())
    (let ((file-count 0))
      (loop for latlng-list in all-three do
        (let* ((lat (car latlng-list))
               (lng (cadr latlng-list))
               (latlong (format nil "~a,~a" lat lng))
               (heading (caddr latlng-list))
               (target-url (image-url latlong heading))
               (save-path (get-save-path
                           (build-filename file-count latlong heading))))
          (setf urls-and-paths (append urls-and-paths (list (list target-url save-path)))))
        (incf file-count)))

    ;; (print "###### urls-and-paths #######")
    ;; (print urls-and-paths)

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

(defparameter asd '((37.785698 -122.44389)
                   (37.78577 -122.44339)
                   (37.78577 -122.44339)
                    (37.79042 -122.44918)))


(generate-heading-list asd)



(angle-from-coordinate 37.785698 -122.44389 37.79042 -122.44918)

(defparameter dpl '((40.42774 -86.91666) (40.42725 -86.91665) (40.42622 -86.91666)
                   (40.4262 -86.91666) (40.42597 -86.91666) (40.425167 -86.916664)
                   (40.424908 -86.91666) (40.424168 -86.91665) (40.424168 -86.91665)
                   (40.4241 -86.91666) (40.42408 -86.915924) (40.42408 -86.91582)
                   (40.42408 -86.91578) (40.42411 -86.91572) (40.424088 -86.91503)
                   (40.42408 -86.914856) (40.42408 -86.91424) (40.42407 -86.91384)
                   (40.42407 -86.91376) (40.42405 -86.91323) (40.42403 -86.91266)))
(defparameter hds '(("180.820") ("179.612") ("180.000") ("180.000") ("179.501") ("181.541")
                   ("180.540") ("0.000") ("174.198") ("268.359") ("270.000") ("270.000")
                   ("298.692") ("267.904") ("267.267") ("269.994") ("268.193") ("270.000")
                    ("267.727") ("267.909") ("267.909")))
(print dpl)

(defparameter atw '((40.42774 -86.91666 "180.820") (40.42725 -86.91665 "179.612")
                   (40.42622 -86.91666 "180.000") (40.4262 -86.91666 "180.000")
                   (40.42597 -86.91666 "179.501") (40.425167 -86.916664 "181.541")
                   (40.424908 -86.91666 "180.540") (40.424168 -86.91665 "0.000")
                   (40.424168 -86.91665 "174.198") (40.4241 -86.91666 "268.359")
                   (40.42408 -86.915924 "270.000") (40.42408 -86.91582 "270.000")
                   (40.42408 -86.91578 "298.692") (40.42411 -86.91572 "267.904")
                   (40.424088 -86.91503 "267.267") (40.42408 -86.914856 "269.994")
                   (40.42408 -86.91424 "268.193") (40.42407 -86.91384 "270.000")
                   (40.42407 -86.91376 "267.727") (40.42405 -86.91323 "267.909")
                    (40.42403 -86.91266 "267.909")))

(loop for x in atw
      do (print (car x))
         (print (cadr x))
         (print (caddr x)))
