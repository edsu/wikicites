WikiCites = require('./wikicites').WikiCites

#w = new WikiCites(channels: ["#en.wikipedia"])
w = new WikiCites()
w.listen (citation) ->
  console.log JSON.stringify citation



