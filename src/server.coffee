_                     = require 'lodash'
http                  = require 'http'
SocketIO              = require 'socket.io'
SocketIOHandler       = require './socket-io-handler'
redis                 = require 'ioredis'
RedisNS               = require '@octoblu/redis-ns'
MessengerFactory      = require './messenger-factory'
UuidAliasResolver     = require 'meshblu-uuid-alias-resolver'

class Server
  constructor: (options) ->
    {@port, @meshbluConfig, @aliasServerUri} = options
    {@redisUri, @namespace} = options

  address: =>
    @server.address()

  run: (callback) =>
    @server = http.createServer()

    uuidAliasClient = _.bindAll new RedisNS 'uuid-alias', redis.createClient(@redisUri)

    @server.on 'request', @onRequest
    @io = SocketIO @server
    @io.on 'connection', @onConnection
    @server.listen @port, callback

  stop: (callback) =>
    @server.close callback

  onConnection: (socket) =>
    socketIOHandler = new SocketIOHandler {socket, @meshbluConfig, @messengerFactory}
    socketIOHandler.initialize()

  onRequest: (request, response) =>
    if request.url == '/healthcheck'
      response.writeHead 200
      response.write JSON.stringify online: true
      response.end()
      return

    response.writeHead 404
    response.end()

module.exports = Server
