local dump, explorer = require('FetchAPI')()
return {require('LexAPI')(dump),explorer}