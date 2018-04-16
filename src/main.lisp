;;; main.lisp

(print "Main file eval'd")

(defparameter directions-base-url "https://maps.googleapis.com/maps/api/directions/json")
(defparameter test-destination "85+10th+Ave,+New+York,+NY+10011")
(defparameter test-origin "75+9th+Ave+New+York,+NY")

(defun directions-url ()
  (format nil "~a?origin=~a&destination=~a&key=~A"
          directions-base-url
          test-origin
          test-destination
          skippy::directions-key))

(defun directions-response ()
  (let ((stream (drakma:http-request (directions-url)
                                     :want-stream t)))
    (setf (flexi-streams:flexi-stream-external-format stream) :utf-8)
    (yason:parse stream :object-as :plist)))

(defun find-val-from (list key)
  ;; validate key is string?
  (if (eq list nil)
      (return-from find-val-from))
  (let ((name (car list))
        (obj (car (cdr list)))
        (rest (cdr (cdr list))))
    (if (string= name key)
        obj
        (find-val-from rest key))))

(defparameter res (directions-response))
(defparameter routes (find-val-from (directions-response) "routes"))

(car routes);; individual route obj
(defparameter route (car routes))

(car (find-val-from route "overview_polyline")) ;; "points"
(car (cdr (find-val-from route "overview_polyline")));; encoded string

(defparameter polyline "}ktwF|`ubMp@b@iBxF}BjHm@_@")
;; 0: {latitude: 40.74191, longitude: -74.00479}
;; 1: {latitude: 40.74166, longitude: -74.00497}
;; 2: {latitude: 40.74219, longitude: -74.00622}
;; 3: {latitude: 40.74282, longitude: -74.00772}
;; 4: {latitude: 40.74305, longitude: -74.00756}
