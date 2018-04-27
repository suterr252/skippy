;;;; src/server.lisp

(in-package #:skippy)

(print "src/server.lisp eval'd")

;; (defparameter qwerty-string "origin=10+Rockefeller+Plaza,+New+York,+NY+10020&destination=1073+6th+Ave,+New+York,+NY+10018")

;; (defun parse-query-string (full-query-string)
;;   (let* ((queries (cl-utilities:split-sequence #\& full-query-string))
;;          (full-origin (car queries))
;;          (full-destination (cadr queries))
;;          (split-orig (cl-utilities:split-sequence #\= full-origin))
;;          (split-dest (cl-utilities:split-sequence #\= full-destination))
;;          (origin (cadr split-orig))
;;          (destination (cadr split-dest)))
;;     (list origin destination)))
;; (dostuff qwerty-string)

;; (defun verify-query-string (qs)
;;   ;; TODO: Parse origin and destination
;;   (let* ((parsed (parse-query-string qs))
;;          (origin (car parsed))
;;          (destination (cadr parsed))
;;          (url (format nil "https://s3.amazonaws.com/meep-zs3-demo/~a+to+~a.gif"
;;                       origin destination))
;;          (res (format nil "Thank you, your gif will be generated shortly,
;; and saved <a href=\"~a\">here</a> " url)))
;;     `(200
;;       (:content-type "text/html")
;;       (,res))))

;; (defun handler (env)
;;   (destructuring-bind (&key request-method query-string &allow-other-keys)
;;       env
;;     (if (and (string= request-method "GET") query-string)
;;         (verify-query-string query-string)
;;         '(404 nil nil))))

(defun handler (env)
  (destructuring-bind (&key request-method path-info request-uri
                         query-string headers raw-body &allow-other-keys) env
    (let ((stream (flexi-streams:flexi-stream-stream raw-body)))
      '(200
        (:content-type "text/xml")
        ("<Response><Message>things</Message></Response>"))
      ))
  )

(defparameter *clack-server*
  (clack:clackup (lambda (env) (funcall 'handler env))))

(clack:stop *clack-server*)
