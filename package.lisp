;;;; package.lisp

(defpackage #:cl-build-deps
  (:use #:cl #:cl-fad)
  (:export #:list-dependencies
           #:copy-dependencies
           #:with-interesting-files
           #:*log-func*))

