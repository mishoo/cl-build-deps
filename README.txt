A quick hack to help with building a Common Lisp project on multiple
machines.

I'm working on a rather big project with many dependencies.  The main
development machine is my laptop, but from time to time I need to update a
machine for folks that actually use my app.  Since I don't care about
replicating the exact setup of my laptop on that machine, I thought it would
be enough if I just copy the dependencies there, so that the build script
would be able to produce a binary.

This tool helps me copy the dependencies, so that there I only need a bare
SBCL and buildapp [1] to compile the thing.

Here's how I use it.  I load it from the REPL (no need to :depends-on it)
and run the following:

  (cl-build-deps:copy-dependencies
   :systems '(:my-sys-1 :my-sys-2 :swank)
   :source (list (merge-pathnames "lisp/source/"
                                  (user-homedir-pathname))
                 (merge-pathnames "quicklisp/dists/quicklisp/software/"
                                  (user-homedir-pathname)))
   :target "/tmp/libs/")

This puts into "/tmp/libs" all the libraries that (1) are needed for
building :my-sys-1, :my-sys-2 and :swank, and (2) appear under
~/lisp/source/ or ~/quicklisp/dists/quicklisp/software/.  Then I rsync
/tmp/libs/ to that machine and run a small wrapper around buildapp that
passes --asdf-tree /path/to/where/I/put/tmp/libs/.

[1] http://www.xach.com/lisp/buildapp/
