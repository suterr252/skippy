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

(defun starts-with-p (str1 str2)
  "Determine whether `str1` starts with `str2`"
  (let ((p (search str2 str1)))
    (and p (= 0 p))))

(defun find-starts-with (word list)
  (let ((res ()))
    (loop for str in list do
      (if (starts-with-p str word)
          (setf res (append res str))))
    res))

(defun handler (env)
  (destructuring-bind (&key request-method path-info request-uri
                         query-string headers &allow-other-keys) env
    (let* ((queries (cl-utilities:split-sequence #\& query-string))
           (base-url "https://s3.amazonaws.com/skippy-cs252/")
           (from-full (find-starts-with "From=" queries))
           (body-full (find-starts-with "Body=" queries))
           (from-sep (cl-utilities:split-sequence #\= from-full))
           (body-sep (cl-utilities:split-sequence #\= body-full))
           (long-from (cadr from-sep))
           (from (subseq long-from 8 (- (length long-from) 1)))
           (body-combined (cadr body-sep))
           (output-filename-cleaned (remove #\, (remove #\+ body-combined)))
           (body-parts (ppcre:split "to" body-combined))
           (origin (replace-pluses-with-spaces (car body-parts)))
           (destination (replace-pluses-with-spaces (cadr body-parts)))
           (res (format nil "<Response><Message>~a~a.gif</Message></Response>"
                        base-url output-filename-cleaned)))
      (psy:enqueue
       'my-worker
       `(,origin ,destination))
      `(200
        (:content-type "text/xml")
        ,(list res)))))


(defparameter *clack-server*
  (clack:clackup (lambda (env) (funcall 'handler env))))

(clack:stop *clack-server*)


(defparameter
    queries '(
              "ToCountry=US&" "ToState=CA&"
              "SmsMessageSid=SMe206e4de856c9b01169d68799d52c962&" "NumMedia=0&"
              "ToCity=&" "FromZip=94121&"
              "SmsSid=SMe206e4de856c9b01169d68799d52c962&" "FromState=CA&"
              "SmsStatus=received&" "FromCity=SAN+FRANCISCO&"
              "Body=Mynameismooooo&" "FromCountry=US&"
              "To=%2B14159918156&" "ToZip=&NumSegments=1&"
              "MessageSid=SMe206e4de856c9b01169d68799d52c962&"
              "AccountSid=AC95279163d9047ec1b13079c31618b958&" "From=%2B14154257121&"
              "ApiVersion=2010-04-01"))
