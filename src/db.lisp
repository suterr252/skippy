;;;; src/db.lisp

(in-package #:skippy)

(print "src/db.lisp eval'd")

(postmodern:connect-toplevel "testdb" "meep" "meep" "localhost")
(postmodern:disconnect-toplevel)

(defparameter *default-database* "testdb")
(defparameter *database-user* "meep")
(defparameter *database-password* "meep")
(defparameter *database* nil)

(defun start-db-connection (&optional (database *default-database*)
                              (database-user *database-user*)
                              (database-password *database-password*)
                              (host "localhost"))
  "Start the database connection. Reconnects if there is an unconnected
database in *database* which matches the database parameter in the function, it will
be reconnected. Returns boolean on whether the global *database* is now connected."
  (unless postmodern:*database*
    (setf postmodern:*database*
          (postmodern:connect database database-user database-password
                              host :pooled-p t))))

(postmodern:clear-connection-pool)

(with-connection `(,database-name ,user-name ,password ,host :pooled-p t)
  (query (:select 'id :from 'countries :where (:= 'name "US"))))


(postmodern:query (:create-table countries
                      ((id :type int4 :primary-key t)
                       (name :type varchar :default "")
                       (region-id :type int4 :default 0)
                       (latitude :type numeric :default 0)
                       (longitude :type numeric :default 0)
                       (iso :type bpchar :default "")
                       (currency :type varchar :default "")
                       (text :type text :default "")
                       (:foreign-key (region-id) (regions id)))))

(find-package :CL-USER)
(find-package :postmodern)
*package*
(find-symbol "query" :postmodern)
(find-symbol "query")
(intern "query" :postmodern)


(postmodern:query (:create-table regions
                      ((id :type int4 :primary-key t)
                       (name :type varchar :default ""))))


(postmodern:query (:create-table test
                      ((id :type int4 :primary-key t)
                       (date :type timestamptz)(number-test :type numeric :default 0)
                       (money :type money :default 0)
                       (text :type text :default ""))))


(print *package*)
