;;;; src/server.lisp

(in-package #:skippy)

(print "src/server.lisp eval'd")

;; (defvar *clack-server*
;;   (clack:clackup
;;    (lambda (env)
;;      (funcall 'handler env))
;;    :server :woo
;;    :use-default-middlewares nil))

;; (defun handler (env)
;;   ((lambda ()
;;      (sleep 20)
;;      (print "hi")
;;      `(200 nil (,(prin1-to-string env))))))

;; (clack:stop *clack-server*)

(woo:run
 (lambda (env)
   (declare (ignore env))
   (print "hi")
   '(200 (:content-type "text/plain") ("Hello, World!"))))

(woo:stop)

;; (defun app (env)
;;   (declare (ignore env))
;;   '(200
;;     (:content-type "text/plain")
;;     ("Hello, Worlds!")))
;; (clack:clackup #'app)
;; (clack:clackd)
