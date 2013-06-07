url = require 'url'
request = require 'request'
wikichanges = require 'wikichanges'

changes = new wikichanges.WikiChanges(
  ircNickname: 'wikilinks',
  wikipedias: ['#en.wikipedia', "#de.wikipedia"]
)

newCites = (revisions) ->
  cites = []
  m = /{{(cite .+?)}}/g
  if revisions? and revisions.length == 2
    prevCites = revisions[1]['*'].match(m)
    currCites = revisions[0]['*'].match(m)
    if currCites and prevCites
      for cite in currCites
        if cite not in prevCites
          cites.push(parseCite(cite))
  return cites

parseCite = (citeText) ->
  parts = (p.replace(/^\s+|\s+$/g, '') for p in citeText.split('|'))
  cite = type: parts.shift().split(' ')[1]
  for p in parts
    m = p.match(/^(.+?)=(.+)$/)
    if m
      cite[m[1]] = m[2]
  return cite

changes.listen (change) ->
  if change.delta <= 0
    return
  changeUrl = url.parse(change.url, 'parse-query')
  revId = changeUrl.query['diff']
  prevRevId = changeUrl.query['oldid']
  wikipedia = change.wikipediaUrl + "/w/api.php"
  qs =
    action: 'query'
    prop: 'revisions'
    rvprop: 'content'
    titles: change.page
    rvstartid: revId
    rvlimit: 2
    format: 'json'
  process.stdout.write('.')
  console.log qs.rvstartid
  request.get wikipedia, qs: qs, json: true, (e, r, results) ->
    for pageId, page of results.query.pages
      for cite in newCites(page.revisions)
        cite.change = change
        console.log ""
        console.log JSON.stringify cite, null, 2
        console.log ""

