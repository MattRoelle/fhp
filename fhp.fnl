(local fennel (require :lib.fennel))

(fn read-file-as-string [path]
  (let [file (io.open path :r)
        contents (file:read :*a)]
    (file:close)
    contents))

(fn fhp-default-sanitize [str options]
  (string.gsub str "\"" "\\\""))


(fn fhp-format-emit-string [s options]
    (.. "("
        (or options.emit-symbol :ngx.say)
        " \""
        (fhp-default-sanitize s)
        "\")"))

(fn fhp-tokenizer-default-fnl-code [str options before begin end fnl-code]
  fnl-code)

(fn fhp-tokenizer-default-before [str options before begin end fnl-code]
  (when (> (length before) 1)
    (fhp-format-emit-string before options)))

(local fhp-base-options
       {:tokenizers
        [fhp-tokenizer-default-before
         fhp-tokenizer-default-fnl-code]})

(fn get-options [?options]
  (let [options (or ?options {})]
    (each [k v (pairs fhp-base-options)]
      (tset options k v))
    options))

(fn fhp-tokenize-iterator [str options]
  (var char-idx 1)
  (fn []
    (let [(begin end fnl-code) (string.find
                                str "<%?fnl(.-)%?>"
                                char-idx)]
      (match (values begin end fnl-code)
        (nil _ _)
        ;; handle case with no <? fnl ?> tags
        (when (= 1 char-idx)
          (fhp-format-emit-string str options))
        (begin end fnl-code)
        (let [before (string.sub str char-idx (- begin 1))
              tokens []]
          (each [_ tokenize (ipairs options.tokenizers)]
            (table.insert tokens (tokenize str options before begin end fnl-code)))
          (set char-idx (+ end 1))
          tokens))))) 

(fn fhp-compile-string [str options]
  (accumulate [output "" tokens (fhp-tokenize-iterator str options)]
    (.. output " " (table.concat tokens " "))))

(fn fhp-compile-file [path options]
  (let [file-contents (read-file-as-string path)]
    (fhp-compile-string file-contents options)))

(fn get-env [builtins options ?env]
  (let [env {}]
    (each [k v (pairs (or options.sandbox _G))] (tset env k v))
    (each [k v (pairs builtins)] (tset env k v))
    (each [k v (pairs (or ?env {}))] (tset env k v))
    env))

(fn fhp-eval [fnl-code env]
  (when (> (length fnl-code) 0)
    (fennel.eval fnl-code {: env})))

(fn fhp-dofile [path ?options ?env]
  (let [options (get-options ?options)]
    (fhp-eval (fhp-compile-file path options)
              (get-env
               options
               {:dofile #(fhp-dofile $1 (or $2 ?env))
                :eval fhp-eval
                : log}
               ?env))))

;; if args are passed, run CLI
(match arg
  [:compile file ?flags]
  (let [options
        (get-options
         (when ?flags
           (fennel.eval ?flags {:env {}})))]
    (print (fhp-compile-file file options))))

{: fhp-eval
 : fhp-compile-file
 : fhp-dofile
 : fhp-base-options
 :fhpEval fhp-eval
 :fhpCompileFile fhp-compile-file
 :fhpDofile fhp-dofile}
