(in-package :cl-user)
(defpackage caveman2-tutorial.config
  (:use :cl)
  (:import-from :envy
                :config-env-var
                :defconfig)
  (:export :config
           :*application-root*
           :*static-directory*
           :*template-directory*
           :*database-directory*
           :appenv
           :developmentp
           :productionp))
(in-package :caveman2-tutorial.config)

(setf (config-env-var) "APP_ENV")

(defparameter *application-root*   (asdf:system-source-directory :caveman2-tutorial))
(defparameter *static-directory*   (merge-pathnames #P"static/" *application-root*))
(defparameter *template-directory* (merge-pathnames #P"templates/" *application-root*))
(defparameter *database-directory* (merge-pathnames #P"db/" *application-root*))

(defconfig :common
    `(:error-log #P"log/error.log"
      :debug T
      :databases ((:maindb :sqlite3 :database-name #P"db/common.sqlite3"))))

(defconfig |development|
    '())

(defconfig |production|
    '())

(defconfig |test|
    '())

(defun config (&optional key)
  (envy:config #.(package-name *package*) key))

(defun appenv ()
  (uiop:getenv (config-env-var #.(package-name *package*))))

(defun developmentp ()
  (string= (appenv) "development"))

(defun productionp ()
  (string= (appenv) "production"))
