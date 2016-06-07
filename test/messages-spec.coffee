async   = require 'async'
_       = require 'lodash'
Connect = require './connect'
redis   = require 'ioredis'
RedisNS = require '@octoblu/redis-ns'
shmock  = require 'shmock'
enableDestroy = require 'server-destroy'

describe 'receiving messages', ->
  beforeEach (done) ->
    @client = new RedisNS 'ns', redis.createClient('redis://localhost', dropBufferSupport: true)
    @client.on 'ready', done

  beforeEach ->
    @meshbluHttp = shmock 0xbabe
    enableDestroy @meshbluHttp

  afterEach (done) ->
    @meshbluHttp.destroy done

  context 'when successful', ->
    beforeEach ->
      @meshbluHttp.post('/authenticate')
        .reply 204

    beforeEach (done) ->
      @connect = new Connect
      @connect.connect (error, things) =>
        return done error if error?
        {@sut,@connection,@device} = things
        done()

    afterEach (done) ->
      @connect.shutItDown done

    describe 'when called', ->

      beforeEach (done) ->
        message =
          metadata:
            code: 204

        @connection.on 'message', (@message) =>
          done()

        @client.publish 'masseuse', JSON.stringify(message), (error) =>
          return done error if error?

      it 'should send a message', ->
        expect(@message).to.deep.equal {"metadata":{"code":204}, rawData: undefined}

  context 'when failed', ->
    beforeEach ->
      @meshbluHttp.post('/authenticate')
        .reply 403

    beforeEach (done) ->
      @connect = new Connect
      @connect.connect (@error, things) =>
        done()

    afterEach (done) ->
      @connect.shutItDown done

    describe 'when called', ->
      it 'should have an error', ->
        expect(@error).to.exist
