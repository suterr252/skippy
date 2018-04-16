;;;; src/directions.lisp

(print "src/directions.lisp eval'd")

(defun directions-url (base origin destination)
  (format nil "~a?origin=~a&destination=~a&key=~A"
          base
          origin
          destination
          skippy::directions-key))

(defun get-directions (base origin destination)
  (let ((stream (drakma:http-request (directions-url base origin destination)
                                     :want-stream t)))
    (setf (flexi-streams:flexi-stream-external-format stream) :utf-8)
    (yason:parse stream :object-as :plist)))

(defun find-val-from (list key)
  ;; TODO: validate key is string?
  (if (eq list nil)
      (return-from find-val-from))
  (let ((name (car list))
        (obj (car (cdr list)))
        (rest (cdr (cdr list))))
    (if (string= name key)
        obj
        (find-val-from rest key))))
