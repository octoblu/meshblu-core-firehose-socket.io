_             = require 'lodash'
redis         = require 'redis'
Server        = require './src/server'
MeshbluConfig = require 'meshblu-config'

class Command
  constructor: ->
    port = process.env.PORT ? 80
    namespace = process.env.NAMESPACE ? 'meshblu'
    redisUri  = process.env.REDIS_URI
    aliasServerUri = process.env.ALIAS_SERVER_URI
    meshbluConfig = new MeshbluConfig().toJSON()

    @server = new Server {
      port
      namespace
      meshbluConfig
      redisUri
      aliasServerUri
    }

  run: =>
    @server.run (error) =>
      return @panic error if error?
      {address,port} = @server.address()
      console.log "listening on #{address}:#{port}"
    process.on 'SIGTERM', =>
      console.log 'SIGTERM received, shutting down...'
      @server.stop =>
        process.exit 0

  panic: (error) =>
    console.error error.stack
    process.exit 1

command = new Command
command.run()
