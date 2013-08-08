WikiCites = require('./wikicites').WikiCites

w = new WikiCites(channels: ["#en.wikipedia"])
w.listen (citation) ->
  console.log JSON.stringify citation, null, 2



