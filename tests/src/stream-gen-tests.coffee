streamGen = require("../../src/")


describe 'stream-gen tests =>', ->

  describe 'constructor =>', ->

    it 'should instantiate without error', ->
      expect(streamGen).to.not.throw(Error)