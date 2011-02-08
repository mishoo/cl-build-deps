(in-package #:cl-build-deps)

(defparameter *log-func* nil)

(defun list-dependencies (&rest systems)
  (let ((deps (make-hash-table :test #'equal))
        (seen (make-hash-table)))
    (labels ((getem (sys)
               (format t "~S~%" sys)
               (when (and (listp sys)
                          (eq (car sys) :version))
                 (setf sys (cadr sys)))
               (let* ((sys (asdf:find-system sys)))
                 (unless (gethash sys seen)
                   (setf (gethash sys seen) t
                         (gethash (slot-value sys 'asdf::absolute-pathname) deps) t)
                   (mapc #'getem (slot-value sys 'asdf::load-dependencies))))))
      (mapc #'getem systems)
      (loop :for i :being :the :hash-keys :in deps :collect i))))

(defun for-interesting-files (dir func)
  (flet ((dodir (dir)
           (walk-directory dir func :directories :breadth-first
                           :test (lambda (src)
                                   (if (directory-pathname-p src)
                                       (not (member (car (last (pathname-directory src)))
                                                    '(".git" ".hg" "_darcs" "CVS" ".svn")
                                                    :test #'string=))
                                       (not (member (pathname-name src)
                                                    '(".gitignore"
                                                      ".hgignore"
                                                      ".cvsignore")
                                                    :test #'string=)))))))
    (etypecase dir
      (list (mapc #'dodir dir))
      (pathname (dodir dir))
      (string (dodir dir)))))

(defmacro with-interesting-files ((file dir) &body body)
  `(for-interesting-files ,dir (lambda (,file) ,@body)))

(defun copy-dependencies (&key systems source target)
  (let ((files (make-hash-table :test #'equal))
        (source (mapcar #'pathname-as-directory (if (listp source) source (list source))))
        (target (pathname-as-directory target))
        (dirs (remove-if-not (lambda (dir)
                               (loop :for i :in source
                                  :unless (string= (enough-namestring dir i)
                                                   (format nil "~A" dir)) :do (return t)))
                             (apply #'list-dependencies systems))))
    (with-interesting-files (f dirs)
      (setf (gethash f files) t))
    (flet ((enough (f)
             (or (loop :for i :in source
                    :for ns = (enough-namestring f i)
                    :with str = (format nil "~A" f)
                    :unless (string= ns str) :do (return ns))
                 f)))
      (loop :for f :being :the :hash-keys :in files
         :for en = (enough f)
         :for dest = (merge-pathnames en target)
         :do (unless (directory-pathname-p f)
               (when (functionp *log-func*)
                 (funcall *log-func* f dest))
               (copy-file f (ensure-directories-exist dest) :overwrite t))))))
