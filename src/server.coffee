_                     = require 'lodash'
http                  = require 'http'
SocketIO              = require 'socket.io'
SocketIOHandler       = require './socket-io-handler'
redis                 = require 'ioredis'
RedisNS               = require '@octoblu/redis-ns'
HydrantManagerFactory = require 'meshblu-core-manager-hydrant/factory'
UuidAliasResolver     = require 'meshblu-uuid-alias-resolver'

class Server
  constructor: (options) ->
    {@port, @meshbluConfig, @aliasServerUri} = options
    {@redisUri, @namespace} = options

  address: =>
    @server.address()

  run: (callback) =>
    @server = http.createServer()

    uuidAliasClient = new RedisNS 'uuid-alias', redis.createClient(@redisUri)
    uuidAliasResolver = new UuidAliasResolver client: uuidAliasClient
    @hydrantManagerFactory = new HydrantManagerFactory {uuidAliasResolver, @namespace}

    @server.on 'request', @onRequest
    @io = SocketIO @server
    @io.on 'connection', @onConnection
    @server.listen @port, callback

  stop: (callback) =>
    @server.close callback

  onConnection: (socket) =>
    socketIOHandler = new SocketIOHandler {socket, @meshbluConfig, @hydrantManagerFactory}
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
