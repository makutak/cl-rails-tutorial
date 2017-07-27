(in-package :cl-user)
(defpackage caveman2-tutorial-asd
  (:use :cl :asdf))
(in-package :caveman2-tutorial-asd)

(defsystem caveman2-tutorial
  :version "0.1"
  :author "Kouno"
  :license "MIT"
  :depends-on (:clack
               :lack
               :caveman2
               :envy
               :cl-ppcre
               :uiop

               ;; for @route annotation
               :cl-syntax-annot

               ;; HTML Template
               :djula

               ;; for DB
               :sxql
               :mito)
  :components ((:module "src"
                :components
                ((:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "config")
                 (:module "model"
                  :depends-on ("db")
                  :components
                  ((:file  "user"))))))

  :description ""
  :in-order-to ((test-op (load-op caveman2-tutorial-test))))
