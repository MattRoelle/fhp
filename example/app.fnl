(local {: fhp-dofile} (require :lib.fhp))

(fn app []
   (match ngx.var.uri
     :/ (fhp-dofile :./home.fhp {:foo "Hello World"})
     _ (fhp-dofile "./404.fhp")))

{: app}
