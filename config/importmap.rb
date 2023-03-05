# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "utility", preload: true
pin "query-string-parser", to: "https://ga.jspm.io/npm:query-string-parser@0.2.3/query_string_parser.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/foodstuffs", under: "foodstuffs"
pin_all_from "app/javascript/partials", under: "partials"
