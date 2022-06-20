(local fennel (require :lib.fennel))

(λ read-file-as-string [path]
  (let [file (io.open path :r)
        contents (file:read :*a)]
    (file:close)
    contents))

(λ fhp-default-sanitize [str options]
  (string.gsub str "\"" "\\\""))


(λ fhp-format-emit-string [s options]
    (.. "("
        (or (?. options :emit-symbol) :ngx.say)
        " \""
        (fhp-default-sanitize s options)
        "\")"))

(λ fhp-tokenizer-default-fnl-code [str options before begin end fnl-code]
  fnl-code)

(λ fhp-tokenizer-default-before [str options before begin end fnl-code]
  (when (> (length before) 1)
    (fhp-format-emit-string before options)))

(local fhp-base-options
       {:tokenizers
        [fhp-tokenizer-default-before
         fhp-tokenizer-default-fnl-code]})

(λ get-options [?options]
  (let [options (or ?options {})]
    (each [k v (pairs fhp-base-options)]
      (tset options k v))
    options))

(λ fhp-tokenize-iterator [str options]
  (var char-idx 1)
  (λ []
   (match (string.find str "<%?fnl(.-)%?>" char-idx)
     (nil _ _)
     ;; handle case with no <?fnl ?> tags
     (let [at-beginning (= 1 char-idx)
           at-end (<= char-idx (length str))
           tokens (if at-beginning
                      [(fhp-format-emit-string str options)]
                      (not at-end)
                      [(fhp-format-emit-string (string.sub char-idx (length str)) options)])]
       (set char-idx (+ 1 (length str)))
       tokens)
     (begin end fnl-code)
     (let [before (string.sub str char-idx (- begin 1))
           tokens []]
       (each [_ tokenize (ipairs options.tokenizers)]
         (table.insert tokens (tokenize str options before begin end fnl-code)))
       (set char-idx (+ end 1))
       tokens)))) 

(λ fhp-compile-string [str options]
  (accumulate [output "" tokens (fhp-tokenize-iterator str options)]
    (.. output " " (table.concat tokens " "))))


(λ fhp-compile-file [path options]
  (let [file-contents (read-file-as-string path)]
    (fhp-compile-string file-contents options)))

(λ get-env [builtins options ?env]
  (let [env {}]
    (each [k v (pairs (or options.sandbox _G))] (tset env k v))
    (each [k v (pairs builtins)] (tset env k v))
    (each [k v (pairs (or ?env {}))] (tset env k v))
    env))

(λ fhp-eval [fnl-code env]
  (when (> (length fnl-code) 0)
    (fennel.eval fnl-code {: env})))

(λ fhp-dofile [path ?options ?env]
  (let [options (get-options ?options)]
    (fhp-eval (fhp-compile-file path options)
              (get-env
               options
               {:dofile #(fhp-dofile $1 (or $2 ?env))
                :eval fhp-eval}
               ?env))))

{: fhp-eval
 : fhp-compile-file
 : fhp-dofile
 : fhp-base-options
 : get-options
 :fhpEval fhp-eval
 :fhpCompileFile fhp-compile-file
 :fhpDofile fhp-dofile}
