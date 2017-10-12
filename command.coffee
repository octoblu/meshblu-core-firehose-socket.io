_             = require 'lodash'
Server        = require './src/server'
MeshbluConfig = require 'meshblu-config'

class Command
  constructor: ->
    @serverOptions =
      port:                         process.env.PORT ? 80
      aliasServerUri:               process.env.ALIAS_SERVER_URI ? ''
      redisUri:                     process.env.REDIS_URI
      firehoseRedisUri:             process.env.FIREHOSE_REDIS_URI ? process.env.REDIS_URI
      namespace:                    process.env.NAMESPACE ? 'messages'
      meshbluConfig:                new MeshbluConfig().toJSON()

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    @panic new Error('Missing required environment variable: ALIAS_SERVER_URI') unless @serverOptions.aliasServerUri? # allowed to be empty
    @panic new Error('Missing required environment variable: REDIS_URI') if _.isEmpty @serverOptions.redisUri
    @panic new Error('Missing required environment variable: FIREHOSE_REDIS_URI') if _.isEmpty @serverOptions.firehoseRedisUri

    server = new Server @serverOptions
    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

    process.on 'SIGTERM', =>
      console.log 'SIGTERM caught, exiting'
      server.stop =>
        process.exit 0

command = new Command()
command.run()
