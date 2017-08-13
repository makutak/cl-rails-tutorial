(in-package :cl-user)
(defpackage caveman2-tutorial.web
  (:use :cl
        :caveman2
        :caveman2-tutorial.config
        :caveman2-tutorial.view
        :caveman2-tutorial.db
        :caveman2-tutorial.util
        :caveman2-tutorial.model.user
        :mito
        :sxql)
  (:import-from :lack.component
                :call)
  (:export :*web*))
(in-package :caveman2-tutorial.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(defmethod lack.component:call :around ((app <web>) env)
  (with-connection (db)
    (call-next-method)))
(clear-routing-rules *web*)

;;
;; Routing rules

(defun render-with-current (template-path &optional args)
  (render template-path (append args (list :current (current-user)))))

(defroute "/" ()
  (redirect "/home"))

(defroute "/home" ()
  (render-with-current #P"static_pages/home.html"))

(defroute "/help" ()
  (render-with-current #P"static_pages/help.html"))

(defroute "/about" ()
  (render-with-current #P"static_pages/about.html"))

(defroute "/signup" ()
  (redirect "/users/new"))

(defroute "/users/new" ()
  (render-with-current #P"users/new.html"))

(defroute ("/users/create" :method :POST) (&key _parsed)
  (setf params (get-value-from-params "user" _parsed))
  (when (valid-user params)
    (if (gethash :user-id *session*)
        (reset-current-user))
    (log-in (create-user params))
    (redirect (format nil "/users/~A" (object-id (current-user)))))
  (redirect "/users/new"))

(defroute "/users/:id" (&key id)
  (setf u (find-dao 'user :id id))
  (if (null u)
      (render-with-current #P"_errors/404.html")
      (render-with-current #P"users/show.html" (user-info u))))

(defroute "/login" ()
  (render-with-current #P"sessions/new.html"))

(defroute ("/login" :method :POST) (&key _parsed)
  (setf params (get-value-from-params "session" _parsed))
  (setf login-user (find-dao 'user
                             :email
                             (get-value-from-params "email" params)))
  (when login-user
    (when (authenticate-user login-user
                             (get-value-from-params "password" params))
      (log-in login-user)
      (redirect (format nil  "/users/~A" (gethash :user-id *session*)))))
  (render-with-current #P"sessions/new.html"))

(defroute ("/logout" :method :POST) ()
  (reset-current-user)
  (redirect "/home"))

(defroute "/api/users" ()
  (setf users (retrieve-dao 'user))
  (render-json users))

(defroute "/api/user/:id" (&key id)
  (setf user (find-dao 'user :id id))
  (render-json user))

(defroute "/counter" ()
  (format nil "You came here ~A times."
          (incf (gethash :counter *session* 0))))

(defroute "/current-user" ()
  (format nil "~A" (user-name (current-user))))

(defroute "/check-logged-in" ()
  (format nil "~A" (logged-in-p)))

(defroute "/test" ()
  (format nil "~A" (user-name (current-user))))

;;
;; Helper functions
(defun current-user ()
  (find-dao 'user :id (gethash :user-id *session* 0)))

(defun reset-current-user ()
  (remhash :user-id *session*))

(defun log-in (user)
  (reset-current-user)
  (setf (gethash :user-id *session*) (object-id user)))

(defun logged-in-p ()
  (not (null (current-user))))


;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
