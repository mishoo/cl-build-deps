;;;; cl-build-deps.asd

(asdf:defsystem #:cl-build-deps
  :serial t
  :depends-on (#:cl-fad)
  :components ((:file "package")
               (:file "cl-build-deps")))

