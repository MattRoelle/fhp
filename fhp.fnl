(local fennel (require :lib.fennel))

(fn read-file-as-string [path]
  (let [file (io.open path :r)
        contents (file:read :*a)]
    (file:close)
    contents))

(fn fhp-parse-string [s]
  (var output [])
  (var done false)
  (var char-idx 1)
  (while (not done)
    (let [(begin end fnl-code) (string.find s "<%?fnl(.-)%?>" char-idx)]
      (if (not begin)
          (do
            (when (= 0 (length output))
              ;; Handle case where there are no <?fnl ?> tags
              (table.insert output
                            (.. "(ngx.say \""
                                (string.gsub s "\"" "\\\"")
                                "\")")))
            (set done true))
          (let [html (string.sub s char-idx (- begin 1))]
            (when (> (length html) 0)
              (table.insert output
                            (.. "(ngx.say \""
                                (string.gsub html "\"" "\\\"")
                                "\")")))
            (table.insert output fnl-code)
            (set char-idx (+ end 1)))))) 
  (table.concat output " "))

(fn fhp-parse-file [path]
  (let [file-contents (read-file-as-string path)]
    (fhp-parse-string file-contents)))

(fn get-env [builtins ?env]
  "Create the evaluation environment"
  (var env {})
  (each [k v (pairs _G)]
    (tset env k v))
  (each [k v (pairs builtins)]
    (tset env k v))
  (each [k v (pairs (or ?env {}))]
    (tset env k v))
  env)

(fn fhp-eval [fnl-code env]
  "Evaluate a string of fhp code"
  (when (> (length fnl-code) 0)
    (fennel.eval fnl-code {: env})))

(fn fhp-dofile [path ?env]
  "Parse and immediately evaluate a .fhp file"
  (fhp-eval (fhp-parse-file path)
            (get-env
             {:dofile #(fhp-dofile $1 (or $2 ?env))
              :eval fhp-eval}
             ?env)))

{: fhp-eval
 : fhp-parse-file
 : fhp-parse-string
 : fhp-dofile}


