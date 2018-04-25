;;;; skippy.asd

(asdf:defsystem #:skippy
  :description "Describe skippy here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:alexandria
               #:cl-fad
               #:cl-json
               #:cl-utilities
               #:clack
               #:drakma
               #:hunchentoot
               #:optima
               #:postmodern
               #:trivial-download
               #:yason
               #:zs3)
  :components ((:file "package")
               (:file "skippy")
               (:file "src/directions")
               (:file "src/glue")
               (:file "src/polyline-decoder")
               (:file "src/s3")
               (:file "src/street-views")))
