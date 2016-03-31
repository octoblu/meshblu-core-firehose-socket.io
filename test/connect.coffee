_                       = require 'lodash'
MeshbluFirehoseSocketIO = require 'meshblu-firehose-socket.io'
async                   = require 'async'
redis                   = require 'ioredis'
RedisNS                 = require '@octoblu/redis-ns'
Server                  = require '../src/server'

class Connect
  constructor: ->

  connect: (callback) =>
    async.series [
      @startServer
      @createConnection
    ], (error) =>
      return callback error if error?
      @connection.on 'ready', =>
        callback null,
          sut: @sut
          connection: @connection
          device: {uuid: 'masseuse', token: 'assassin'}

  shutItDown: (callback) =>
    @connection.close()

    async.series [
      async.apply @sut.stop
    ], callback

  startServer: (callback) =>
    @sut = new Server
      port: 0xcafe
      meshbluConfig:
        server: 'localhost'
        port:   0xbabe
      redisUri: 'redis://localhost'
      namespace: 'ns'

    @sut.run callback

  createConnection: (callback) =>
    @connection = new MeshbluFirehoseSocketIO
      server: 'localhost'
      port: 0xcafe
      uuid: 'masseuse'
      token: 'assassin'
      options: transports: ['websocket']

    @connection.on 'notReady', (error) =>
      console.error error.stack
      throw error

    callback()

module.exports = Connect
