async   = require 'async'
_       = require 'lodash'
Connect = require './connect'
redis   = require 'ioredis'
RedisNS = require '@octoblu/redis-ns'
shmock  = require 'shmock'

describe 'receiving messages', ->
  beforeEach ->
    @client = new RedisNS 'ns', redis.createClient('redis://localhost')

  beforeEach ->
    @meshbluHttp = shmock 0xbabe

  beforeEach (done) ->
    @connect = new Connect
    @connect.connect (error, things) =>
      return done error if error?
      {@sut,@connection,@device} = things
      done()

  afterEach (done) ->
    @connect.shutItDown done

  afterEach (done) ->
    @meshbluHttp.close done

  describe 'when called', ->
    beforeEach ->
      @meshbluHttp.get('/v2/whoami')
        .reply 200, '{}'

    beforeEach (done) ->
      message =
        metadata:
          code: 204

      @connection.on 'message', (@message) =>
        done()

      @client.publish 'masseuse', JSON.stringify(message), (error) =>
        return done error if error?

    it 'should send a message', ->
      expect(@message).to.deep.equal {"metadata":{"code":204}}
