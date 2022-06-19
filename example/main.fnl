;; If there is a fennel syntax error, we need to 
;; handle the require throwing an error or we won't get a message
;; So we wrap the root app module
(fn main []
  (let [{: app} (require :app)]
    (app)))

(fn on-error [err]
  (ngx.say err))

(xpcall main on-error)
