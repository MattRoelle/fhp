# FHP | Fennel Hypertext Processor

```html
<h1>Hello! You requested <?fnl (ngx.say ngx.var.uri) ?></h1>
```

## What?

FHP Is a tool for embedding the [Fennel](https://fennel-lang.org/) lisp language into HTML templates inside of an [Open Resty](https://openresty.org/en/) application.

It is inspired by PHP and other CGI frameworks of days gone by. It is meant as a fun tool to enjoy building simple web applications.

I made this in an afternoon for fun, I plan to rebuild my personal website among a few other things in it. I'm not sure if this is a stupid idea or not yet. Have fun and let me know what you think! 

## Getting started

The easiest way to get started is to clone this repo and use the example folder as a starting point. Consult the opnresty docs if you are not sure how to run the application. I have included start and stop shell scripts that may need to be modified based on your openresty installation.

## How?

The FHP compiler is extremely simple. It takes input in the form of HTML with <?fnl/?> tags inside of it and translates it into valid fennel code. Anything not inside of a <?fnl/?> tag is wrapped in a call to ngx.say, and everything inside of a <?fnl/?> tag is inserted into the output as is.

For example, the above code will compile to:

```fennel
(ngx.say "<h1>Hello! You requested ")
(ngx.say ngx.var.uri)
(ngx.say "</h1>")
```

## Examples

The FHP compiler is very forgiving in that it does not check your fennel code for syntax errors, this job is left up to the fennel compiler. This makes it possible to embed html inside of your s-expressions for doing things such as logic and iteration within your FHP templates.

### Conditional

```html
<?fnl (when foo ?>
<p>Foo is true!</p>
<?fnl ) ?>
```

### Iterating over a list

```html
<?fnl
(local data [{:foo :bar} {:foo :baz}])
(each [ix row (ipairs data)]
?>
<div>
  <p>Foo is <?fnl (ngx.say row.foo) ?></p>
</div>
<?fnl )?>
```

### Template functions

```html
<?fnl
(fn even-odd-display [n]
?>
<div class="even-odd">
  <p><?fnl (ngx.say n) ?> is <?fnl (ngx.say (if (= 0 (% n 2)) "even" "odd")) ?></p>
</div>
<?fnl ) ?>

<?fnl (for [i 1 10] (even-odd-display i)) ?>
```

## Builtins

The only builtin right now is the `dofile` function, which is similar to lua or fennel's `dofile` except it expects a path to a fhp file and an optional environment table. This is useful for creating layout files, such as a header/footer, and small reusable components that can accept parameters. 

For example:

```
<?fnl (dofile :header.fhp) ?>
<?fnl (dofile :page-template.fhp {:title "Home"}) ?>
<p>Lorum ipsum</p>
<?fnl (dofile :footer.fhp) ?>
```

## TODO

### Editor Support

I am in the process of modifying emacs mhtml-mode to enable a good editing experience. Any pointers from more experienced emacsers would be welcomed.

### More features - maybe?

#### Data binding shorthand

I like the idea of a shorthand syntax for <?fnl (ngx.say foo) ?> for data binding, since this is the primary use case for such a templating language anyways. Perhaps <?! foo ?>.

#### More macros to clean up the template code

I am not sure that I like the current syntax for nesting html inside of s-expressions. I think that this will create more headaches than it is worth. I think that long term, it might be best to introduce macros that allow you to stay in lisp land and still render your HTML inside of s-expressions.



