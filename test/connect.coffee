MeshbluFirehoseSocketIO = require 'meshblu-firehose-socket.io'
async                   = require 'async'
Server                  = require '../src/server'

class Connect
  constructor: ->

  connect: (callback) =>
    async.series [
      @startServer
      @createConnection
    ], (error) =>
      return callback error if error?
      @connection.once 'disconnect', => @connectionIsDisconnected = true
      @connection.once 'connect_error', (error) =>
        @connectionIsDisconnected = true
        callback error
      @connection.once 'connect', =>
        callback null,
          sut: @sut
          connection: @connection
          device: {uuid: 'masseuse', token: 'assassin'}

      @connection.connect()

  shutItDown: (callback) =>
    @closeConnection =>
      @sut.stop callback

  closeConnection: (callback) =>
    return callback() if @connectionIsDisconnected
    @connection.close callback

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
