os = require('os')
url = require 'url'
request = require 'request'
wikichanges = require('wikichanges')

class WikiCites
  
  constructor: (opts = {}) ->
    @channels = opts.channels || (w for w of wikichanges.wikipedias)
    @ircNickname = opts.ircNickname || "wikicites-" + os.hostname()

  listen: (callback) ->
    changes = new wikichanges.WikiChanges(
      ircNickname: 'wikilinks'
      wikipedias: @channels
    )
    changes.listen (change) =>
      # only looking for citations added
      if change.delta <= 0
        return

      # get the revision and send any citations to the callback
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
      self = this
      request.get wikipedia, qs: qs, json: true, (e, r, results) ->
        for pageId, page of results.query.pages
          for cite in _newCites(page.revisions)
            cite.change = change
            callback(cite)

    _newCites = (revisions) ->
      cites = []
      m = /{{(cite .+?)}}/g
      if revisions? and revisions.length == 2
        prevCites = revisions[1]['*'].match(m)
        currCites = revisions[0]['*'].match(m)
        if currCites and prevCites
          for cite in currCites
            if cite not in prevCites
              cites.push(_parseCite(cite))
      return cites


    _parseCite = (citeText) ->
      parts = (p.replace(/^\s+|\s+$/g, '') for p in citeText.split('|'))
      cite = type: parts.shift().split(' ')[1]
      for p in parts
        m = p.match(/^(.+?)=(.+)$/)
        if m
          cite[m[1]] = m[2]
      return cite


exports.WikiCites = WikiCites
