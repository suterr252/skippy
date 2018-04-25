;;;; src/s3.lisp

(in-package #:skippy)

(print "src/s3.lisp eval'd")

(defun send-gif-to-s3 (input-file-path-str output-filename)
  (let ((bucket-name "meep-zs3-demo"))
    (if (zs3:bucket-exists-p bucket-name)
        (zs3:put-file (pathname input-file-path-str) bucket-name output-filename))))
