;;;; src/s3.lisp

(in-package #:skippy)

(print "src/s3.lisp eval'd")

(defun send-gif-to-s3 (input-file-path-str output-filename bucket-name)
  (if (not (zs3:bucket-exists-p bucket-name))
      (zs3:create-bucket bucket-name :access-policy :PUBLIC-READ))
  (zs3:put-file (pathname input-file-path-str)
                bucket-name
                output-filename
                :content-type "image/gif"
                :access-policy :public-read))
