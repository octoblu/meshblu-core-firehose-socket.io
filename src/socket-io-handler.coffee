_           = require 'lodash'
async       = require 'async'

class SocketIOHandler
  constructor: ({@socket,@meshbluConfig,@hydrantManagerFactory}) ->

  initialize: =>
    uuid = @socket.client.request.headers['x-meshblu-uuid']
    @firehose = @hydrantManagerFactory.build()
    @firehose.on 'message', (message) =>
      @socket.emit 'message', message

    @firehose.connect {uuid}, (error) =>
      throw error if error?

  onDisconnect: =>
    @firehose?.close()

module.exports = SocketIOHandler
