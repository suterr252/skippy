;;;; skippy.asd

(asdf:defsystem #:skippy
  :description "Describe skippy here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:hunchentoot
               #:trivial-download
               #:drakma
               #:yason
               #:cl-json)
  :components ((:file "package")
               (:file "skippy")))
