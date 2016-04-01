_           = require 'lodash'
async       = require 'async'
MeshbluHttp = require 'meshblu-http'

class SocketIOHandler
  constructor: ({@socket,@meshbluConfig,@hydrantManagerFactory}) ->

  initialize: =>
    uuid = @socket.client.request.headers['x-meshblu-uuid']
    token = @socket.client.request.headers['x-meshblu-token']
    config = _.extend {uuid, token}, @meshbluConfig
    console.log config
    meshbluHttp = new MeshbluHttp config
    meshbluHttp.whoami (error, data) =>
      console.log error, data

      @firehose = @hydrantManagerFactory.build uuid
      @firehose.on 'message', (message) =>
        @socket.emit 'message', message

      @firehose.connect (error) =>
        throw error if error?

  onDisconnect: =>
    @firehose?.close()

module.exports = SocketIOHandler
