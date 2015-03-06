<%= symbol %> = require("../../src/<%= symbol %>")

describe '<%= symbol %>Tests =>', ->

  describe 'constructor =>', ->

    it 'should instantiate without error', ->
      expect(-> new <%= symbol %>()).to.not.throw(Error)