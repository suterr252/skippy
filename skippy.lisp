;;;; skippy.lisp

(in-package #:skippy)

(load "config.lisp")

(print "config loaded")

(setf zs3:*credentials* (zs3:file-credentials "./.aws"))

(print "aws s3 credentials loaded")
