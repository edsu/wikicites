wikicites = require('../wikicites')
assert = require('assert')

describe 'WikiChanges', ->
  it 'should be constructable', ->
    cites = new wikicites.WikiCites()
    assert cites.channels.length > 0

  it 'should receive a citation', (done) ->
    # wait up to two minutes for a citation, this could fail of course
    this.timeout(120000) 
    cites = new wikicites.WikiCites(channels: ["#en.wikipedia"])
    assert.deepEqual cites.channels, ["#en.wikipedia"]
    cites.listen (change) ->
      assert change.type
      done()
