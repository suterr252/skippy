(in-package #:skippy)

(psy:connect-toplevel :host "localhost" :port 6379)

(defclass my-worker (psy:worker) ())

(defmethod psy:perform ((worker my-worker) &rest args)
  (print "##### hi from worker #####")
  (let ((origin (car args))
        (destination (cadr args)))
    (print "### origin ###")
    (print origin)
    (print "### destination ###")
    (print destination)
    ;; (time (main
    ;;        "2750 Jackson St, San Francisco, CA 94115"
    ;;        "2343 Fillmore St, San Francisco, CA 94115"))
    )
  (print "##### bye from worker #####"))
