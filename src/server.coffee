_                     = require 'lodash'
http                  = require 'http'
SocketIO              = require 'socket.io'
SocketIOHandler       = require './socket-io-handler'
redis                 = require 'ioredis'
RedisNS               = require '@octoblu/redis-ns'
HydrantManagerFactory = require 'meshblu-core-manager-hydrant/factory'
UuidAliasResolver     = require 'meshblu-uuid-alias-resolver'
MeshbluHttp           = require 'meshblu-http'
URL                   = require 'url'

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
    @hydrantManagerFactory = new HydrantManagerFactory {uuidAliasResolver, @namespace, @redisUri}

    @server.on 'request', @onRequest
    @io = SocketIO @server, allowRequest: @verifyRequest
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

  verifyRequest: (request, callback) =>
    {uuid, token} = @getAuth request
    config = _.assign {uuid, token}, @meshbluConfig
    meshbluHttp = new MeshbluHttp config
    meshbluHttp.whoami (error, data) =>
      return callback error if error?
      callback null, data?.uuid == uuid

  getAuth: (request) =>
    uuid = request.headers['x-meshblu-uuid']
    token = request.headers['x-meshblu-token']
    return {uuid, token} if uuid && token
    {query} = URL.parse request.url, true
    return uuid: query.uuid, token: query.token

module.exports = Server
