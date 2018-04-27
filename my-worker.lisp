(in-package #:skippy)

(psy:connect-toplevel :host "localhost" :port 6379)

(defclass my-worker (psy:worker) ())

(defmethod psy:perform ((worker my-worker) &rest args)
  (let ((origin (car args))
        (destination (cadr args)))
    (time (main origin destination))))
