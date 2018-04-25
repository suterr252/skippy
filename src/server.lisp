;;;; src/server.lisp

(in-package #:skippy)

(print "src/server.lisp eval'd")

(defvar *clack-server*
  (clack:clackup
   (lambda (env)
     (funcall 'handler env))))

(defun handler (env)
  `(200 nil (,(prin1-to-string env))))

(clack:stop *clack-server*)
