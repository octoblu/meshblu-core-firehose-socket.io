_                     = require 'lodash'
http                  = require 'http'
SocketIO              = require 'socket.io'
SocketIOHandler       = require './socket-io-handler'
redis                 = require 'ioredis'
RedisNS               = require '@octoblu/redis-ns'
MultiHydrantFactory   = require 'meshblu-core-manager-hydrant/multi'
UuidAliasResolver     = require 'meshblu-uuid-alias-resolver'
MeshbluHttp           = require 'meshblu-http'
URL                   = require 'url'

class Server
  constructor: (options) ->
    {
      @port
      @meshbluConfig
      @aliasServerUri
      @redisUri
      @firehoseRedisUri
      @namespace
    } = options

  address: =>
    @server.address()

  run: (callback) =>
    @server = http.createServer()

    uuidAliasClient = new RedisNS 'uuid-alias', redis.createClient(@redisUri, dropBufferSupport: true)
    uuidAliasResolver = new UuidAliasResolver client: uuidAliasClient
    hydrantClient = new RedisNS @namespace, redis.createClient(@firehoseRedisUri, dropBufferSupport: true)
    @hydrant = new MultiHydrantFactory {client: hydrantClient, uuidAliasResolver}
    @hydrant.connect (error) =>
      return callback(error) if error?

    @server.on 'request', @onRequest
    @io = SocketIO @server, allowRequest: @verifyRequest
    @io.on 'connection', @onConnection
    @server.listen @port, callback

  stop: (callback) =>
    @server.close callback

  onConnection: (socket) =>
    socketIOHandler = new SocketIOHandler {socket, @meshbluConfig, @hydrant}
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
    meshbluHttp.authenticate (error) =>
      if error?
        return callback null, false if @_isUserError error
        return callback error
      callback null, true

  _isUserError: (error) =>
    return unless error.code?
    error.code < 500

  getAuth: (request) =>
    uuid = request.headers['x-meshblu-uuid']
    token = request.headers['x-meshblu-token']
    return {uuid, token} if uuid && token
    {query} = URL.parse request.url, true
    return uuid: query.uuid, token: query.token

module.exports = Server
