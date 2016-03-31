async   = require 'async'
_       = require 'lodash'
Connect = require './connect'
redis   = require 'ioredis'
RedisNS = require '@octoblu/redis-ns'

describe 'receiving messages', ->
  beforeEach (done) ->
    client = new RedisNS 'ns', redis.createClient()

  beforeEach (done) ->
    @connect = new Connect
    @connect.connect (error, things) =>
      return done error if error?
      {@sut,@connection,@device,@jobManager} = things
      done()

  afterEach (done) ->
    @connect.shutItDown done

  describe 'when called', ->
    beforeEach (done) ->
      message =
        metadata:
          code: 204
      @connection.socket.emit 'message', message
      @sut.on 'message', (@message) =>
        done()

    it 'should send a message', ->
      console.log @message
