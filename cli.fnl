(local fennel (require :lib.fennel))
(local {: fhp-compile-file : get-options} (require :fhp))

(fn help-text []
  (print "Fennel hypertext processor")
  (print "commands:")
  (print "\tcompile FILE ?options"))

;; if args are passed, run CLI
(match arg
  [:compile file ?flags]
  (let [options
        (get-options
         (when ?flags
           (fennel.eval ?flags {:env {}})))]
    (print (fhp-compile-file file options)))
  _ (help-text))
