;; Load Fennel searcher so you can load .fnl files
(local fennel (require :lib.fennel))
(table.insert (or package.loaders package.searchers) fennel.searcher)

