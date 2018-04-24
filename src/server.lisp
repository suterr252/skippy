(defvar *clack-server*
  (clack:clackup
   (lambda (env)
     (funcall 'handler env))))

(defun handler (env)
  `(200 nil (,(prin1-to-string env))))

(clack:stop *clack-server*)
