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
      @connection.on 'connect', =>
        callback null,
          sut: @sut
          connection: @connection
          device: {uuid: 'masseuse', token: 'assassin'}

      @connection.on 'connect_error', (error) =>
        callback error

      @connection.connect =>

  shutItDown: (callback) =>
    @connection.close =>
      @sut.stop callback

  startServer: (callback) =>
    @sut = new Server
      port: 0xcaff
      meshbluConfig:
        hostname: 'localhost'
        server: 'localhost'
        port:   0xbabb
        protocol: 'http'
      redisUri: 'redis://localhost'
      firehoseRedisUri: 'redis://localhost'
      namespace: 'ns'

    @sut.run callback

  createConnection: (callback) =>
    @connection = new MeshbluFirehoseSocketIO
      meshbluConfig:
        hostname: 'localhost'
        port: 0xcaff
        uuid: 'masseuse'
        token: 'assassin'
        protocol: 'http'

    callback()

module.exports = Connect
