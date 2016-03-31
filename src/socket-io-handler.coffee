_     = require 'lodash'
async = require 'async'

class SocketIOHandler
  constructor: ({@socket,@meshbluConfig,@messengerFactory}) ->

  initialize: =>
    @messenger = @messengerFactory.build()

    @messenger.on 'message', (channel, message) =>
      @socket.emit 'message', message

  onDisconnect: =>
    @messenger?.close()

module.exports = SocketIOHandler
